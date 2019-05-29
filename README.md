# Publish Documentation to GitHub Pages

[![Build Status](https://travis-ci.com/jcouball/github_pages_rake_tasks.svg?branch=master)](https://travis-ci.com/jcouball/github_pages_rake_tasks)

The `github_pages_rake_tasks` gem creates a rake task that pushes the contents
from a local documentation directory to a remote Git repository branch.

By default, the rake task `github-pages:publish` is created which pushes the `doc`
directory within the local copy of your repository to the same repository's
`gh-pages` branch.  The contents of the branch are completely replaced by the
contents of the documentation directory.

This task is useful for publishing `rdoc` or `yard` documentation using
[GitHub Pages](https://pages.github.com).

## Installation

Add this line to your application's Gemfile:

    gem 'github_pages_rake_tasks'

And then execute:

    $ bundle

Or install it directly with the `gem` command line:

    $ gem install github_pages_rake_tasks

## Usage

Add the `github-pages:publish` task to Rake by adding the following lines in your Rakefile:

```Ruby
require 'github_pages_rake_tasks'
GitHubPagesRakeTasks.Tasks.new
```

You can also configure the task by providing a block during initialization:

```Ruby
require 'github_pages_rake_tasks'
GitHubPagesRakeTasks.Tasks.new do |task|
  task.doc_dir = 'documentation'
  task.repo_url = 'https://github.com/jcouball/github_pages_documentation'
  task.branch_name = 'master'
end
```

See [the full usage documentation](https://github.com/pages/jcouball/guthub_pages_rake_tasks) for more details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run 
`bundle exec rake release`, which will create a git tag for the version, push git 
commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcouball/github_pages_rake_tasks.
