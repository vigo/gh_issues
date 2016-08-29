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
      ENV['GH_ISSUES_COLORIZE'] = '1' if options[:color]
      sort_by = ['name', 'count'].include?(options[:sort_by]) ? options[:sort_by] : 'name'
      sort_order = ['asc', 'desc'].include?(options[:sort_order]) ? options[:sort_order] : 'asc'
      all_issues = GhIssues.all_issues
      if all_issues.count > 0
        all_issues.sort_by!{|item| item[:open_issues_count]} if sort_by == 'count'
        all_issues.reverse! if sort_order == 'desc'
        puts print_table(style: 'issues',
                         title: 'All Open Issue(s)',
                         headings: ['Repo', 'Issue Count'],
                         rows: all_issues.map{|item| [item[:full_name], item[:open_issues_count]]})
      else
        puts "You have no issue to display..."
      end
    end
    
    
    no_commands do
      def print_table(**options)
        table_style = options[:style]
        table_title = ENV['GH_ISSUES_COLORIZE'] ? set_color(options[:title], :yellow) : options[:title]
        table_headings = ENV['GH_ISSUES_COLORIZE'] ? options[:headings].map{|t| set_color(t, :white) } : options[:headings]
        table_rows = options[:rows]
        if ENV['GH_ISSUES_COLORIZE']
          case table_style
          when 'issues'
            table_rows.map!{|r| [set_color(r[0], :white), set_color(r[1], :green)]}
          end
        end
        Terminal::Table.new :headings => table_headings,
                            :rows => table_rows,
                            :title => table_title
      end
    end
  end
end