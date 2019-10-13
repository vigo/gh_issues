require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

def get_package_name
  name = Dir['*.gemspec'].first.split('.').first
  line = File.read("lib/#{name}/version.rb")[/^\s*VERSION\s*=\s*.*/]
  version = line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
  "#{name}-#{version}.gem"
end

AVAILABLE_REVISIONS = ["major", "minor", "patch"]
desc "Bump version"
task :bump, [:revision] do |t, args|
  args.with_defaults(revision: "patch")
  abort "Please provide valid revision: #{AVAILABLE_REVISIONS.join(',')}" unless AVAILABLE_REVISIONS.include?(args.revision)
  system "bumpversion #{args.revision}"
end

desc "Push #{get_package_name} to GitHub registry"
task :push_to_github do
  package_path = "pkg/#{get_package_name}.gem"
  system "gem push --key github --host https://rubygems.pkg.github.com/vigo #{package_path}"
end
