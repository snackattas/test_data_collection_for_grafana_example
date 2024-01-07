module Models
  # The record of running an rspec/parallel_rspec command.
  # If 2 rspec commands are kicked off in a CI/CD run (perhaps because the first command failed, and the second command
  # was run with --only-failures) It should create 2 separate TestExecutions (1 per rspec/parallel_rspec command)
  class TestExecutions < ActiveRecord::Base
    def commit_url
      "https://github.com/#{repo_owner}/#{repo}/commit/#{git_hash}"
    end
  end
end
