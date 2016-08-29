require 'gh_issues/version'
require 'terminal-table'
require 'octokit'

module GhIssues
  class GitHubAccessTokenError < StandardError; end
  
  def self.ghi_token_defined?
    raise ::GhIssues::GitHubAccessTokenError, "Please define GH_ISSUES_TOKEN environment variable." unless ENV['GH_ISSUES_TOKEN']
    true
  end
  
  def self.all_issues
    if ::GhIssues.ghi_token_defined?
      client = Octokit::Client.new(:access_token => ENV['GH_ISSUES_TOKEN'])
      client.auto_paginate = true
      open_issues = []
      client.repos.each do |repo|
        if repo[:open_issues_count] > 0
          data = {
            full_name: repo[:full_name],
            open_issues_count: repo[:open_issues_count],
          }
          open_issues << data
        end
      end
      open_issues
    end
  end
end
