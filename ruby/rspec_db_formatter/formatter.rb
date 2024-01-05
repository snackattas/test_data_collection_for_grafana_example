require 'rspec/core/formatters/base_formatter'
require "parallel_tests"
require_relative '../config/environment.rb'

class RSpecDBFormatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :start, :example_group_started, :example_started, :example_passed, :example_failed, 
                                     :example_pending, :stop, :close
    @@max_wait_for_test_execution_in_s = 60 * 2

    def initialize(argment)
        puts "-------------argment in initialize #{argment} class #{argment.class}"
        # puts argment.methods.join(" ")
        @examples = []
        @passed = 0
        @failed = 0
        @pending = 0
        # These variables will change depending on what CI/CD platform you use
        # https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
        @build_id = "#{ENV['GITHUB_RUN_ID']}-#{ENV['GITHUB_RUN_ATTEMPT']}"
        @branch = ENV["GITHUB_REF_NAME"]
        @git_hash = ENV["GITHUB_SHA"]
        @url = "#{ENV['GITHUB_SERVER_URL']}/#{ENV['GITHUB_REPOSITORY']}/actions/runs/#{ENV['GITHUB_RUN_ID']}"
        @commit_author = ENV["GITHUB_ACTOR"]
        @parallel_process = ENV["TEST_ENV_NUMBER"] || 1
        @test_execution = nil
    end

    def start(notification)
        puts "-------------start... class #{notification.class}"
       # Get this info from rspec notification object

        test_groups = []
        cd = false
        rerun = false
        # This will be true if we're not running in parallel tests mode, or, if we are, and it happens to be the first process
        if ParallelTests.first_process?
            puts 'in first process processor'
            parallel_processes = ENV["TEST_ENV_NUMBER"] ? ParallelTests.number_of_running_processes : 1
            @tests_execution = Models::TestExecutions.create(
                test_groups: test_groups,
                build_id: @build_id,
                branch: @branch,
                url: @url,
                commit_author: @commit_author,
                git_hash: @git_hash,
                parallel_processes: parallel_processes,
                cd: cd,
                rerun: rerun,
                status: "running"
            )
        else
            start_time = Time.now
            while Time.now - start_time < @@max_wait_for_test_execution_in_s
                search_args = {build_id: @build_id, rerun: rerun}
                test_execution = Models::TestExecutions.where(search_args).first()
                if test_execution
                    @test_execution = test_execution
                    puts 'in other process processor'
                    break
                else
                    sleep rand(0.1..0.5)
                end
            end
            if not @test_execution
                raise "Waited #{@@max_wait_for_test_execution_in_s}s for a TestExecution record with args: #{search_args}"
                        "but one was never found. Check if anything is up with the database."
            end
        end
    end

    def example_group_started(notification)
        # puts "-------------example_group_started...class #{notification.class}"
        # puts notification.methods.join(" ")

    end

    def example_started(notification)
        # puts "-------------example_started...class #{notification.class}"
        # puts notification.methods.join(" ")

    end
    
    def example_passed(notification)
        # puts "------------- ✔ #{notification} class #{notification.class}"
        # puts notification.methods.join(" ")

    end
    
    def example_failed(notification)
        # puts "-------------✖ #{notification} class #{notification.class}"
        # puts notification.methods.join(" ")

    end

    def example_pending(notification)
        # puts "-------------pending #{notification} class #{notification.class}"
        # puts notification.methods.join(" ")

    end
    
    def stop(notification)
        # puts "-------------Stop class #{notification.class}."
        # puts notification.methods.join(" ")

    end

    def close(notification)
        # puts "-------------close... class #{notification.class}"
        # puts notification.methods.join(" ")

    end
end