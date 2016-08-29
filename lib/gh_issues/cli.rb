require "bundler/setup"

require 'thor'
require 'gh_issues'

module GhIssues
  class CLI < Thor
    class_option :color, :type => :boolean

    desc "version", "Version information"
    def version
      puts GhIssues::VERSION
    end
    
    desc "all", "List all open issues"
    option :sort_by, default: 'name', banner: "count"
    option :sort_order, default: 'asc', banner: "desc"
    def all
      sort_by = ['name', 'count'].include?(options[:sort_by]) ? options[:sort_by] : 'name'
      sort_order = ['asc', 'desc'].include?(options[:sort_order]) ? options[:sort_order] : 'asc'
      all_issues = GhIssues.all_issues
      if all_issues.count > 0
        all_issues.sort_by!{|item| item[:open_issues_count]} if sort_by == 'count'
        all_issues.reverse! if sort_order == 'desc'
        puts Terminal::Table.new :headings => ['Repo', 'Issue Count'],
                            :rows => all_issues.map{|item| [item[:full_name], item[:open_issues_count]]},
                            :title => "All Open Issue(s)"
      else
        puts "You have no issue to display..."
      end
    end
  end
end