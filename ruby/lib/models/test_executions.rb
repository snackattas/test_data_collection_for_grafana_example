module Models
  class TestExecutions < ActiveRecord::Base

    def commit_url
      "https://github.com/#{self.repo_owner}/#{self.repo}/commit/#{self.git_hash}"
    end
  end
end
