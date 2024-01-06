require 'rspec/core/formatters/base_formatter'
require "parallel_tests"
require_relative '../config/environment.rb'

class RSpecDBFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :start, :example_started, :example_passed, :example_failed, 
                                     :example_pending, :close
    @@max_wait_for_test_execution_in_s = 60 * 2

    def in_rerun?
        RSpec.configuration.filter_manager.inclusions.rules[:last_run_status] == "failed"
    end

    def extract_test_groups
        rules = RSpec.configuration.filter_manager.inclusions.rules
        rules.filter { |k,v| k != :last_run_status and v == true }.keys.map { |k| k.to_s }
    end

    def in_cd?
        (ENV["CD"] || "false").strip.downcase == "true"
    end

    def initialize(argment)
        # These variables will change depending on what CI/CD platform you use
        # https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
        @build_id = "#{ENV['GITHUB_RUN_ID']}-#{ENV['GITHUB_RUN_ATTEMPT']}"
        @branch = ENV["GITHUB_REF_NAME"]
        @git_hash = ENV["GITHUB_SHA"]
        @url = "#{ENV['GITHUB_SERVER_URL']}/#{ENV['GITHUB_REPOSITORY']}/actions/runs/#{ENV['GITHUB_RUN_ID']}"
        @commit_author = ENV["GITHUB_ACTOR"]
        @parallel_process = (ENV["TEST_ENV_NUMBER"] || 1).to_i
        @test_groups = extract_test_groups
        @cd = in_cd?
        @rerun = in_rerun?
        @test_execution_id = nil
        @current_test_case_id = nil
    end

    def start(notification)
        return if notification.count == 0  # return early if no tests were collected
        puts "in start"
        # This will be true if we're not running in parallel tests mode, or, if we are, and it happens to be the first process
        if ParallelTests.first_process?
            parallel_processes = (ENV["TEST_ENV_NUMBER"] ? ParallelTests.number_of_running_processes : 1).to_i
            @test_execution_id = Models::TestExecutions.create(
                test_groups: @test_groups,
                build_id: @build_id,
                branch: @branch,
                url: @url,
                commit_author: @commit_author,
                git_hash: @git_hash,
                parallel_processes: parallel_processes,
                cd: @cd,
                rerun: @rerun,
                status: "running"
            ).id
        else
            start_time = Time.now
            while Time.now - start_time < @@max_wait_for_test_execution_in_s
                puts 'in while loop'
                search_args = {build_id: @build_id, rerun: @rerun}
                test_execution = Models::TestExecutions.select(:id).where(search_args).first()
                if test_execution
                    @test_execution_id = test_execution.id
                    puts 'in other process processor'
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
        puts 'in example started'
        name = notification.example.full_description
        path = notification.example.metadata[:location][2..]
        @current_test_case_id = Models::TestCases.create(
            test_execution: @test_execution_id,
            status: "running",
            parallel_process: @parallel_process,
            name: name,
            path: path
        ).id
    end
    
    def example_passed(notification)
        finished_at = notification.example.execution_result.finished_at
        if @current_test_case_id
            Models::TestCases.find(@current_test_case_id).update(status: "passed", finished_at: finished_at)
        end
        @current_test_case_id = nil
    end
    
    def example_failed(notification)
        exception_class = notification.example.execution_result.exception.class
        exception_message = notification.example.execution_result.exception.message[...7000]
        exception_traceback = notification.example.execution_result.exception.backtrace.join("\n")[...7000]
        finished_at = notification.example.execution_result.finished_at

        if @current_test_case_id
            Models::TestCases.find(@current_test_case_id).update(
                status: "failed",
                exception_class: exception_class,
                exception_message: exception_message,
                exception_traceback: exception_traceback,
                finished_at: finished_at
            )
        end
        @current_test_case_id = nil
    end

    def example_pending(notification)
        pending_message = notification.example.execution_result.pending_message
        finished_at = notification.example.execution_result.finished_at
        if @current_test_case_id
            Models::TestCases.find(@current_test_case_id).update(
                status: "pending",
                pending_message: pending_message,
                finished_at: finished_at
            )
        end
        @current_test_case_id = nil
    end

    def close(notification)
        puts 'in close'
        if ENV["TEST_ENV_NUMBER"] and ParallelTests.first_process?
            ParallelTests.wait_for_other_processes_to_finish
        end
        finished_at = Time.now
        any_failed_tests = Models::TestCases.where(test_execution: @test_execution_id, status: "failed").any?
        status = any_failed_tests ? "failed" : "passed"
        Models::TestExecutions.find(@test_execution_id).update(finished_at: finished_at, status: status)
    end
end