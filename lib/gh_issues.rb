require 'gh_issues/version'
require 'octokit'

module GhIssues
  @@client = nil
  class GitHubAccessTokenError < StandardError; end
  class GitHubBadCredentialsError < StandardError; end
  class InvalidOwnerError < StandardError; end
  
  def self.check_ghi_token_defined
    raise ::GhIssues::GitHubAccessTokenError, "Please define GH_ISSUES_TOKEN environment variable." unless ENV['GH_ISSUES_TOKEN']
  end

  def self.check_ghi_github_credentials
    begin
      user = @@client.user
    rescue Octokit::Unauthorized => error_message
      raise ::GhIssues::GitHubBadCredentialsError, "Bad GitHub credentials."
    end
  end
  
  def self.ghi_access_available?
    begin
      ::GhIssues.check_ghi_token_defined
    rescue ::GhIssues::GitHubAccessTokenError => error_message
      puts error_message
      exit
    end

    @@client = Octokit::Client.new(:access_token => ENV['GH_ISSUES_TOKEN'])
    @@client.auto_paginate = true
    
    begin
      ::GhIssues.check_ghi_github_credentials
    rescue ::GhIssues::GitHubBadCredentialsError => error_message
      puts error_message
      exit
    end
    true
  end
  
  def self.list_owner_issues(requested_owner)
    if ::GhIssues.ghi_access_available?
      all_issues = ::GhIssues.all_issues
      if all_issues[requested_owner]
        all_issues[requested_owner]
      else
        raise ::GhIssues::InvalidOwnerError, "Invalid owner requested"
      end
    end
  end
  
  def self.show_repos_issues(repo)
    if ::GhIssues.ghi_access_available?
      issues = []
      @@client.issues(repo).each do |issue|
        issues << {
          number: issue[:number],
          title: issue[:title],
          html_url: issue[:html_url],
          body: issue[:body],
        }
      end
      issues
    end
  end
  
  def self.get_issue(repo, issue_number)
    if ::GhIssues.ghi_access_available?
      begin
        issue = @@client.issue(repo, issue_number)
        {
          number: issue[:number],
          title: issue[:title],
          user: issue[:user][:login],
          labels: issue[:labels].map{|i| i[:name]},
          assignees: issue[:assignees].map{|i| i[:login]},
          body: issue[:body],
          created_at: issue[:created_at],
          updated_at: issue[:updated_at],
        }
      rescue Octokit::NotFound => error_message
          puts "Incorrect issue number (#{issue_number})"
          exit
      end
      
    end
  end
  
  def self.all_issues
    if ::GhIssues.ghi_access_available?
      open_issues = {}
      @@client.repos.each do |repo|
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