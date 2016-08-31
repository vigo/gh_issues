require 'gh_issues/version'
require 'terminal-table'
require 'octokit'

module GhIssues
  class GitHubAccessTokenError < StandardError; end
  class InvalidOwnerError < StandardError; end
  
  def self.ghi_token_defined?
    raise ::GhIssues::GitHubAccessTokenError, "Please define GH_ISSUES_TOKEN environment variable." unless ENV['GH_ISSUES_TOKEN']
    true
  end

  def self.list_owner_issues(requested_owner)
    if ::GhIssues.ghi_token_defined?
      all_issues = ::GhIssues.all_issues
      if all_issues[requested_owner]
        all_issues[requested_owner]
      else
        raise ::GhIssues::InvalidOwnerError, "Invalid owner requested"
      end
    end
  end
  
  def self.all_issues
    if ::GhIssues.ghi_token_defined?
      client = Octokit::Client.new(:access_token => ENV['GH_ISSUES_TOKEN'])
      client.auto_paginate = true
      open_issues = {}
      client.repos.each do |repo|
        if repo[:open_issues_count] > 0
          owner = repo[:owner][:login]
          open_issues[owner] = [] unless open_issues[owner]
          data = {
            full_name: repo[:full_name],
            open_issues_count: repo[:open_issues_count],
          }
          open_issues[owner] << data
        end
      end
      open_issues
    end
  end
end
