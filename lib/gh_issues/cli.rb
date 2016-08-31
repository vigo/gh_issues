require "bundler/setup"

require 'thor'
require 'gh_issues'

module GhIssues
  class CLI < Thor
    class_option :color, :type => :boolean
    class_option :sort_by, default: 'name', banner: "count"
    class_option :sort_order, default: 'asc', banner: "desc"

    desc "version", "Version information"
    def version
      puts GhIssues::VERSION
    end
    
    desc "all", "List all open issues, grouped by owner"
    def all
      ENV['GH_ISSUES_COLORIZE'] = '1' if options[:color]
      sort_by = ['name', 'count'].include?(options[:sort_by]) ? options[:sort_by] : 'name'
      sort_order = ['asc', 'desc'].include?(options[:sort_order]) ? options[:sort_order] : 'asc'
      all_issues = GhIssues.all_issues
      if all_issues.count > 0
        puts print_issue_list(all_issues, sort_by: sort_by, sort_order: sort_order)
      else
        puts "Hooray! You have no issue to display..."
      end
    end

    desc "list OWNER_NAME", "List issues belongs to owner"
    def list(owner)
      ENV['GH_ISSUES_COLORIZE'] = '1' if options[:color]
      sort_by = ['name', 'count'].include?(options[:sort_by]) ? options[:sort_by] : 'name'
      sort_order = ['asc', 'desc'].include?(options[:sort_order]) ? options[:sort_order] : 'asc'
      begin
          owner_issues = GhIssues.list_owner_issues(owner)
      rescue InvalidOwnerError => error_message
        puts error_message
        exit
      end
      if owner_issues.count > 0
        m = {}
        m[owner] = owner_issues
        puts print_issue_list(m, sort_by: sort_by, sort_order: sort_order)
      else
        puts "Hooray! You have no issue to display..."
      end
    end
    
    no_commands do
      def print_issue_list(data, **options)
        sort_by = options[:sort_by]
        sort_order = options[:sort_order]
        all_issues_sum = 0
        table = Terminal::Table.new do |t|
          data.each do |owner, items|
            items.sort_by!{|item| item[:open_issues_count]} if sort_by == 'count'
            items.reverse! if sort_order == 'desc'
            t.add_row [{value: "#{colorize(owner, :yellow)}", colspan: 2, alignment: :center}]
            t.add_separator
            items.map{|item| t.add_row([colorize(item[:full_name], :cyan), {value: colorize(item[:open_issues_count], :white), alignment: :right}])}
            issues_sum = items.map{|item| item[:open_issues_count]}.inject(0){|sum,x| sum + x }
            all_issues_sum = all_issues_sum + issues_sum
            t.add_separator
            t.add_row [{value: colorize(issues_sum, :green), colspan: 2, alignment: :right}]
            t.add_separator
          end
        end
        table.add_row [colorize('Total amount', :white), {value: colorize(all_issues_sum, :white), alignment: :right}]
        table
      end
      
      def colorize(text, color)
        if ENV['GH_ISSUES_COLORIZE']
           set_color(text, color)
        else
          text
        end
      end
      
      def pluralize(singular, plural, number)
        if number > 1
          plural
        else
          singular
        end
      end
    end

  end
end