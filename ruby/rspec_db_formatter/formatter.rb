require 'rspec/core/formatters/base_formatter'
require "parallel_tests"
require_relative '../config/environment'
require_relative 'ad_hoc_data'

class RSpecDBFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :start, :example_started, :example_passed, :example_failed, :example_pending, :close
    @@max_wait_for_test_execution_in_s = 60 * 2

    def in_rerun?
        RSpec.configuration.filter_manager.inclusions.rules[:last_run_status] == "failed"
    end

    def extract_test_groups
        rules = RSpec.configuration.filter_manager.inclusions.rules
        # Expect the options like :api, or :unit, will be like this
        # Ex: describe 'i am a test', :api do
        # When the filter is written like that, internally, its stored as a rule like {:api => true}, so we can tell, any rule whose 
        # value is true, is a test group for us to grab
        rules.filter { |k,v| k != :last_run_status and v == true }.keys.map { |k| k.to_s }
    end

    def in_cd?
        (ENV["CD"] || "false").strip.downcase == "true"
    end

    def get_parallel_process_number
        env_test_number = ENV["TEST_ENV_NUMBER"]
        if env_test_number == nil || env_test_number.to_i == 0
            return 1
        end
        return env_test_number.to_i
    end

    def initialize(argment)
        # These variables will change depending on what CI/CD platform you use
        # https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
        @build_id = "#{ENV['GITHUB_RUN_ID']}-#{ENV['GITHUB_RUN_ATTEMPT']}"
        @branch = ENV["GITHUB_HEAD_REF"]
        @repo = ENV["GITHUB_REPOSITORY"].split("/")[1..].join("/")
        @git_hash = ENV["GITHUB_SHA"]
        @repo_owner = ENV["GITHUB_REPOSITORY_OWNER"]
        @url = "#{ENV['GITHUB_SERVER_URL']}/#{ENV['GITHUB_REPOSITORY']}/actions/runs/#{ENV['GITHUB_RUN_ID']}"
        @commit_author = ENV["GITHUB_ACTOR"]
        @parallel_process = get_parallel_process_number
        @test_groups = extract_test_groups
        @parallel_processes = (ENV["TEST_ENV_NUMBER"] ? ParallelTests.number_of_running_processes : 1).to_i
        @cd = in_cd?
        @rerun = in_rerun?
        @test_execution_id = nil
        @current_test_case_id = nil
    end

    def start(notification)
        # This will be true if we're not running in parallel tests mode, or, if we are, and it happens to be the first process
        if ParallelTests.first_process?
            begin
                @test_execution_id = Models::TestExecutions.create(
                    test_groups: @test_groups,
                    build_id: @build_id,
                    branch: @branch,
                    repo: @repo,
                    repo_owner: @repo_owner,
                    url: @url,
                    commit_author: @commit_author,
                    git_hash: @git_hash,
                    parallel_processes: @parallel_processes,
                    cd: @cd,
                    rerun: @rerun,
                    status: "running"
                ).id
            rescue ActiveRecord::RecordNotUnique => error
                puts "Failed to creat TestExecution record at the beginning of test...has this build already been rerun? The reporter "
                     "only supports being called once with --only-failures, not multiple reruns"
                raise error
            end
        else
            start_time = Time.now
            while Time.now - start_time < @@max_wait_for_test_execution_in_s
                search_args = {build_id: @build_id, rerun: @rerun}
                test_execution = Models::TestExecutions.select(:id).where(search_args).first()
                if test_execution
                    @test_execution_id = test_execution.id
                    break
                else
                    sleep rand(0.1..0.5)
                end
            end
            if not @test_execution_id
                raise "Waited #{@@max_wait_for_test_execution_in_s}s for a TestExecution record with args: #{search_args}"
                        "but one was never found. Check if anything is up with the database."
            end
        end
    end

    def example_started(notification)
        name = notification.example.full_description
        path = notification.example.metadata[:location][2..]  # remove the ./ at the start of the path
        @current_test_case_id = Models::TestCases.create(
            test_execution: @test_execution_id,
            status: "running",
            parallel_process: @parallel_process,
            name: name,
            path: path
        ).id
    end
    
    def example_passed(notification)
        return if not @test_execution_id
        return if not @current_test_case_id

        finished_at = notification.example.execution_result.finished_at
        if @current_test_case_id
            Models::TestCases.find(@current_test_case_id).update(
                status: "passed",
                finished_at: finished_at,
                data: RSpecDBFormatterAdHocData.instance.get_data
            )

        end

        @current_test_case_id = nil
        RSpecDBFormatterAdHocData.instance.clear_data
    end
    
    def example_failed(notification)
        return if not @test_execution_id
        return if not @current_test_case_id

        exception_class = notification.example.execution_result&.exception&.class
        exception_message = notification.example.execution_result&.exception&.message
        exception_message = exception_message[0...7000] if exception_message
        exception_traceback = notification.example.execution_result&.exception&.backtrace
        exception_traceback = exception_traceback.join("\n")[0...7000] if exception_traceback
        finished_at = notification.example.execution_result.finished_at

        Models::TestCases.find(@current_test_case_id).update(
            status: "failed",
            exception_class: exception_class,
            exception_message: exception_message,
            exception_traceback: exception_traceback,
            finished_at: finished_at,
            data: RSpecDBFormatterAdHocData.instance.get_data
        )

        @current_test_case_id = nil
        RSpecDBFormatterAdHocData.instance.clear_data
    end

    def example_pending(notification)
        return if not @test_execution_id
        return if not @current_test_case_id

        pending_message = notification.example.execution_result.pending_message
        finished_at = notification.example.execution_result.finished_at

        Models::TestCases.find(@current_test_case_id).update(
            status: "pending",
            pending_message: pending_message,
            finished_at: finished_at,
            data: RSpecDBFormatterAdHocData.instance.get_data
        )
    
        @current_test_case_id = nil
        RSpecDBFormatterAdHocData.instance.clear_data
    end

    def close(notification)
        return if not @test_execution_id
    
        if ENV["TEST_ENV_NUMBER"] and ParallelTests.first_process?
            ParallelTests.wait_for_other_processes_to_finish
        end

        data = {finished_at:  Time.now}
        any_tests = Models::TestCases.where(test_execution: @test_execution_id)
        if any_tests.any?  # Check that there are test cases, if there are none, its possible that invalid commands were passed to rspec
            any_failed_tests = any_tests.where(status: "failed").any?
            status = any_failed_tests ? "failed" : "passed"
        else
            status = "errored"
            data[:error] = true
        end
        data[:status] = status
        Models::TestExecutions.find(@test_execution_id).update(data)
    end
end