# Publish Documentation to GitHub Pages

[![Gem Version](https://badge.fury.io/rb/github_pages_rake_tasks.svg)](https://badge.fury.io/rb/github_pages_rake_tasks)
[![Documentation](https://img.shields.io/badge/Documentation-Latest-green)](https://rubydoc.info/gems/github_pages_rake_tasks/)
[![Change Log](https://img.shields.io/badge/CHANGELOG-Latest-green)](https://rubydoc.info/gems/github_pages_rake_tasks/file/CHANGELOG.md)
[![Build Status](https://github.com/main-branch/github_pages_rake_tasks/workflows/CI%20Build/badge.svg?branch=main)](https://github.com/main-branch/github_pages_rake_tasks/actions?query=workflow%3ACI%20Build)
[![Maintainability](https://api.codeclimate.com/v1/badges/a67ad0b61d3687e33181/maintainability)](https://codeclimate.com/github/main-branch/github_pages_rake_tasks/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a67ad0b61d3687e33181/test_coverage)](https://codeclimate.com/github/main-branch/github_pages_rake_tasks/test_coverage)

The `github_pages_rake_tasks` gem creates a rake task that pushes files
from a local documentation directory to a remote Git repository branch.

By default, the rake task `github-pages:publish` is created which pushes the `doc`
directory within the local copy of a repository to the same repository's
`gh-pages` branch.  The contents of the branch are completely replaced by the
contents of the documentation directory.

This task is useful for publishing `rdoc` or `yard` documentation using
[GitHub Pages](https://pages.github.com).

## Installation

Add this line to your application's Gemfile:

```Shell
gem 'github_pages_rake_tasks'
```

And then execute:

```Shell
bundle
```

Or install it directly with the `gem` command line:

```Shell
gem install github_pages_rake_tasks
```

## Usage

Add the `github-pages:publish` task to Rake by adding the following lines in your Rakefile:

```Ruby
require 'github_pages_rake_tasks'
GitHubPagesRakeTasks::PublishTask.new
```

You can also configure the task by providing a block during initialization:

```Ruby
require 'github_pages_rake_tasks'
GitHubPagesRakeTasks::PublishTask.new do |task|
  task.doc_dir = 'documentation'
  task.repo_url = 'https://github.com/jcouball/github_pages_documentation'
  task.branch_name = 'master'
end
```

An instance of [GithubPagesRakeTasks::State](https://rubydoc.info/gems/github_pages_rake_tasks/GithubPagesRakeTasks/State)
is passed to the initialization block (named `task` in the example above).

See [the full usage documentation](https://github.com/pages/jcouball/guthub_pages_rake_tasks) for more details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push git
commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jcouball/github_pages_rake_tasks.

## Copyright and License

Copyright © 2019 James Couball. Free use of this software is granted under the terms of the MIT License. See LICENSE for details.
