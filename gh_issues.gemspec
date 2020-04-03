# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gh_issues/version'

Gem::Specification.new do |spec|
  spec.name          = "gh_issues"
  spec.version       = GhIssues::VERSION
  spec.authors       = ["Uğur Özyılmazel"]
  spec.email         = ["ugurozyilmazel@gmail.com"]

  spec.summary       = %q{Manage your GitHub issues from command-line.}
  spec.description   = %q{Manage your GitHub issues from command-line.}
  spec.homepage      = "https://github.com/vigo/gh-issues"
  spec.metadata      = {"github_repo" => "ssh://github.com/vigo/gh-issues"}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 2.1', '>= 2.1.4'
  spec.add_development_dependency 'rake', '~> 13.0', '>= 13.0.1'
  spec.add_development_dependency 'minitest', '~> 5.14'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4', '>= 1.4.2'
  spec.add_development_dependency 'pry', '~> 0.13.0'

  spec.add_runtime_dependency 'terminal-table', '~> 1.8'
  spec.add_runtime_dependency 'thor', '~> 1.0', '>= 1.0.1'
  spec.add_runtime_dependency 'octokit', '~> 4.18'
  spec.add_runtime_dependency 'time_difference', '~> 0.7.0'
  spec.add_runtime_dependency 'redcarpet', '~> 3.5'
end
