require "bundler/setup"

require 'thor'
require 'terminal-table'
require 'date'
require 'time_difference'
require 'redcarpet'
require 'redcarpet/render_strip'
require 'gh_issues'

TERMINAL_WIDTH = `tput cols`.strip.to_i
WRAP_TEXT_AT = 78

module GhIssues
  class TextRenderer < Redcarpet::Render::StripDown
    def image(link, title, content)
      link = "link" if link.length > WRAP_TEXT_AT
      content &&= content + " "
      "[#{content}]-[#{link}]"
    end
  end
  
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
      rescue GhIssues::InvalidOwnerError => error_message
        puts error_message
        exit
      end
      if owner_issues.count > 0
        only_owners_data = {}
        only_owners_data[owner] = owner_issues
        puts print_issue_list(only_owners_data, sort_by: sort_by, sort_order: sort_order)
      else
        puts "Hooray! You have no issue to display..."
      end
    end
    
    desc "show REPO_NAME [ISSUE_NUMBER]", "Show issues of REPO_NAME or ISSUE"
    def show(repo, issue_number=0)
      ENV['GH_ISSUES_COLORIZE'] = '1' if options[:color]
      issue_number = issue_number.to_i
      
      if issue_number > 0
        issue = GhIssues.get_issue(repo, issue_number)
        table = Terminal::Table.new do |t|
          t.add_row [colorize("Repo/Issue", :yellow), colorize("#{repo}/#{issue_number}", :white)]
          t.add_separator
          t.add_row [colorize("Title", :yellow), issue[:title]]
          t.add_separator
          t.add_row [colorize("Opener", :yellow), issue[:user]]
          t.add_row [colorize("Labes", :yellow), issue[:labels].join(',')] if issue[:labels].count > 0
          t.add_row [colorize("Assignees", :yellow), issue[:assignees].join(', ')] if issue[:assignees].count > 0
          t.add_separator

          created_at = issue[:created_at].strftime("%d %B %Y, %H:%M, %A")
          updated_at = issue[:updated_at].strftime("%d %B %Y, %H:%M, %A")

          now = Time.now
          created_at_diff = TimeDifference.between(now, issue[:created_at]).in_days.to_i
          updated_at_diff = TimeDifference.between(now, issue[:updated_at]).in_days.to_i
          
          t.add_row [colorize("Created at", :yellow), "#{created_at} (#{created_at_diff} days ago)"]
          t.add_row [colorize("Updated at", :yellow), "#{updated_at} (#{updated_at_diff} days ago)"]
          if issue[:body].length > 0
            markdown = Redcarpet::Markdown.new(GhIssues::TextRenderer)
            body_text = markdown.render(issue[:body])
            t.add_separator
            t.add_row [colorize("Body", :yellow), wrap(body_text, WRAP_TEXT_AT)]
          end
        end
        puts table
      else
        issues = GhIssues.show_repos_issues(repo)
        if issues.count > 0
          table = Terminal::Table.new do |t|
            t.add_row ["", colorize(repo, :yellow), colorize("Url", :yellow)]
            t.add_separator
            issues.each do |issue|
              t.add_row [
                {value: colorize("##{issue[:number]}", :white), alignment: :left},
                issue[:title],
                "#{issue[:html_url]}",
              ]
            end
          end
          puts table
        else
          puts "Hooray! You have no issue here..."
        end
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
      
      def wrap(s, width=WRAP_TEXT_AT)
        s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
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