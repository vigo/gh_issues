require 'test_helper'

class GhIssuesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GhIssues::VERSION
  end
  
  def test_user_must_define_github_token
    assert_raises(::GhIssues::GitHubAccessTokenError) { ::GhIssues.ghi_token_defined? }
  end
  
  def test_user_defined_github_token
    ENV['GH_ISSUES_TOKEN'] = "1"
    assert_equal true, ::GhIssues.ghi_token_defined?
    ENV.delete('GH_ISSUES_TOKEN')
  end
end
