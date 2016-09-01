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
  spec.homepage      = "https://github.com:vigo/gh-issues.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1', '>= 1.1.11'
  spec.add_development_dependency 'pry', '~> 0.10.4'

  spec.add_runtime_dependency 'terminal-table', '~> 1.6'
  spec.add_runtime_dependency 'thor', '~> 0.19.1'
  spec.add_runtime_dependency 'octokit', '~> 4.3'
  spec.add_runtime_dependency 'time_difference', '~> 0.4.2'
  spec.add_runtime_dependency 'redcarpet', '~> 3.3', '>= 3.3.4'
end
