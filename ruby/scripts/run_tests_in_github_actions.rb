#!/usr/bin/env ruby

## First round of tests
test_groups = %w[api contract end_to_end integration unit]
num_test_groups_to_use = rand(0...test_groups.length)
test_groups_to_use = test_groups.sample(num_test_groups_to_use)
branch = ENV["GITHUB_REF_NAME"]
CD = branch == "master" ? true : false

puts "Running tests from these test groups: #{test_groups_to_use}"
puts "Branch: #{branch} CD: #{CD}"


base_run_command = """
CD=#{CD} \
bundle exec parallel_rspec -- \
--format documentation \
--require ./rspec_db_formatter/formatter.rb --format RSpecDBFormatter \
"""

formatted_test_groups_to_use = test_groups_to_use.map { |g| "--tag #{g}"}.join(" ")

first_run_command = "#{base_run_command} #{formatted_test_groups_to_use} --"

puts "Run command #{first_run_command}"

results = system(first_run_command)

rerun_results = true
if not results
    puts "\n--------------------------------------------------------------------------------\n"
    puts "First run failed. Now rerunning with --only-failed"
    rerun_run_command = "#{base_run_command} --only-failures --"
    rerun_results = system(rerun_run_command)
end

exit(results || rerun_results)


