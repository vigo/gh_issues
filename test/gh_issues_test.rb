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
end
