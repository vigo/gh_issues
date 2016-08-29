require 'gh_issues/version'
require 'terminal-table'
require 'octokit'

module GhIssues
  class GitHubAccessTokenError < StandardError; end
  
  def self.ghi_token_defined?
    raise ::GhIssues::GitHubAccessTokenError, "Please define GH_ISSUES_TOKEN environment variable." unless ENV['GH_ISSUES_TOKEN']
    true
  end
end
