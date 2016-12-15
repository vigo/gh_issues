require 'test_helper'

class GhIssuesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GhIssues::VERSION
  end
  
  def test_user_must_define_github_token
    buffer_token = nil
    if ENV['GH_ISSUES_TOKEN']
      buffer_token = ENV['GH_ISSUES_TOKEN']
      ENV.delete('GH_ISSUES_TOKEN') 
    end
    assert_raises(::GhIssues::GitHubAccessTokenError) { ::GhIssues.check_ghi_token_defined }
    ENV['GH_ISSUES_TOKEN'] = buffer_token if buffer_token
  end

  def test_get_issues_of_test_repo
    issues = ::GhIssues.show_repos_issues('vigo/gh-issues-test')
    assert_instance_of Array, issues
    assert_in_delta 0, 4, issues.count
    issues.each do |issue|
      assert_equal true, issue.has_key?(:number)
      assert_equal true, issue.has_key?(:title)
      assert_equal true, issue.has_key?(:html_url)
    end
  end
  
  def test_all_issues_of_test_repo
    repo = 'vigo/gh-issues-test'
    ::GhIssues.show_repos_issues(repo).each do |issue_item|
      issue = ::GhIssues.get_issue(repo, issue_item[:number])
      assert_equal issue_item[:number], issue[:number]
      assert_equal issue_item[:number], issue[:number]
      assert_equal true, issue.has_key?(:number)
      assert_equal true, issue.has_key?(:title)
    end
  end
  
  def test_are_we_under_a_github_repo
    ssh_repo = "git@github.com:vigo/dotfiles-universal.git"
    https_repo = "https://github.com/cloudson/gitql"
    non_github_repo = "http://google.com"

    assert_equal true, ::GhIssues.in_github_repo?(ssh_repo)
    assert_equal true, ::GhIssues.in_github_repo?(https_repo)
    assert_equal false, ::GhIssues.in_github_repo?(non_github_repo)
  end
  
  def test_what_is_the_repo_name
    https_repo = "https://github.com/cloudson/gitql"
    ssh_repo = "git@github.com:vigo/dotfiles-universal.git"
    not_a_url = "foo/bar/baz"
    
    assert_equal 'cloudson/gitql', ::GhIssues.get_repo_name(https_repo)
    assert_equal 'vigo/dotfiles-universal', ::GhIssues.get_repo_name(ssh_repo)
    assert_nil ::GhIssues.get_repo_name(not_a_url)
  end
end
