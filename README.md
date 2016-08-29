# GitHub Issues

Manage your GitHub issues from command-line. If you are dealing with huge
amount of repos, this tool will become more handy.

## Idea

I need this tool for couple of reasons:

1. I need to list all issues of my all repositories without knowing the repo url.
1. I need to list a specific issue from a specific repo with full details.
1. I need to see my current issues which are related to GitHub account.

## Installation

This is a command-line client. You can install via:

```bash
gem install gh_issues
```

## Usage

You need to create a [GitHub token](https://github.com/settings/tokens/new) or 
use existing token of yours. Set your environment variable as:

```bash
export GH_ISSUES_TOKEN=your-token-here
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, 
run `rake test` to run the tests. You can also run `bin/console` for an 
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To 
release a new version, update the version number in `version.rb`, and then 
run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/vigo/gh_issues. This project is intended to be a safe, 
welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).
