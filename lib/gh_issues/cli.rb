require 'thor'
require 'terminal-table'
require 'date'
require 'time_difference'
require 'redcarpet'
require 'redcarpet/render_strip'
require 'gh_issues'

TERMINAL_WIDTH = `tput cols`.strip.to_i
WRAP_TEXT_AT = 78
DEFAULT_DATE_FORMAT = ENV['GH_ISSUES_DATE_FORMAT'] || "%d %B %Y, %H:%M, %A"

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
    long_desc <<-LONGDESC
      List all available repos with open issues according to your GitHub Token.
      Do not forget to set your `GH_ISSUES_TOKEN` environment variable.\n
      
      $ gh_issues all\n
      $ gh_issues all --sort-by=count\n
      $ gh_issues all --sort-by=count --sort-order=desc\n
      $ gh_issues all --sort-by=count --sort-order=desc --color
    LONGDESC
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
    long_desc <<-LONGDESC
      List issues of selected repo. You need to get all issues first. You can
      only list your repos issues.\n
      
      $ gh_issues list pyistanbul\n
      $ gh_issues list pyistanbul --sort-by=count\n
      $ gh_issues list pyistanbul --sort-by=count --sort-order=desc\n
      $ gh_issues list pyistanbul --sort-by=count --sort-order=desc --color
    LONGDESC
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
    
    desc "show [REPO_NAME] [ISSUE_NUMBER]", "Show issues of REPO_NAME / current repo or ISSUE"
    long_desc <<-LONGDESC
      Show issues of selected repo or current repo if you are in a git repository
      with GitHub origin pointed at. If you specify issue number, you'll get
      details of that issue.\
      
      $ gh_issues show   # current dir/github repo
      $ gh_issues show 2 # current dir/github repo issue 2 
      $ gh_issues show pyistanbul/website
      $ gh_issues show pyistanbul/website 48
      $ gh_issues show pyistanbul/website 48 --color
    LONGDESC
    def show(repo=nil, issue_number=0)
      ENV['GH_ISSUES_COLORIZE'] = '1' if options[:color]
      
      origin_url=`git remote get-url origin 2>/dev/null`.strip
      current_repo = nil
      if GhIssues.in_github_repo?(origin_url)
        current_repo = GhIssues.get_repo_name(origin_url)
      end

      unless repo
        repo = current_repo if current_repo
      else
        if is_numeric?(repo)
          issue_number = repo.to_i
          repo = current_repo
        end
      end
      
      issue_number = issue_number.to_i

      puts "Listing current GitHub repo: #{repo}" if repo == current_repo

      if issue_number > 0
        markdown = Redcarpet::Markdown.new(GhIssues::TextRenderer)
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

          created_at = issue[:created_at].strftime(DEFAULT_DATE_FORMAT)
          updated_at = issue[:updated_at].strftime(DEFAULT_DATE_FORMAT)

          now = Time.now
          created_at_diff = TimeDifference.between(now, issue[:created_at]).in_days.to_i
          updated_at_diff = TimeDifference.between(now, issue[:updated_at]).in_days.to_i

          t.add_row [colorize("Created at", :yellow), "#{created_at} (#{created_at_diff} #{pluralize("day", "days", created_at_diff)} ago)"]
          t.add_row [colorize("Updated at", :yellow), "#{updated_at} (#{updated_at_diff} #{pluralize("day", "days", updated_at_diff)} ago)"]
          if issue[:body].length > 0
            body_text = markdown.render(issue[:body])
            t.add_separator
            t.add_row [colorize("Body", :yellow), wrap(body_text, WRAP_TEXT_AT)]
          end
          
          if issue[:comments].length > 0
            t.add_separator
            t.add_row [{value: "#{colorize(pluralize('Comment', 'Comments', issue[:comments].length), :yellow)} (#{issue[:comments].length})", colspan: 2, alignment: :center}]
            issue[:comments].each do |comment|
              t.add_separator
              comment_created_at = comment[:created_at].strftime(DEFAULT_DATE_FORMAT)
              comment_created_at_diff = TimeDifference.between(now, comment[:created_at]).in_days.to_i
              comment_text = "#{markdown.render(comment[:body])}\n---\n#{comment_created_at} (#{comment_created_at_diff} #{pluralize("day", "days", comment_created_at_diff)} ago)"
              t.add_row [colorize(comment[:user], :green), wrap(comment_text, WRAP_TEXT_AT)]
            end
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
      def is_numeric?(input)
        input.to_f.to_s == input.to_s || input.to_i.to_s == input.to_s
      end
      
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