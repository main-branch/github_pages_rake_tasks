# Copyright (c) 2019 James Couball
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github_pages_rake_tasks/version'

Gem::Specification.new do |spec|
  spec.name          = 'github_pages_rake_tasks'
  spec.version       = GithubPagesRakeTasks::VERSION
  spec.authors       = ['James Couball']
  spec.email         = ['jcouball@yahoo.com']

  spec.summary       = 'Rake tasks for publishing documentation to GitHub Pages'
  spec.description   = <<~DESCRIPTION
    A Rake task to publish documentation like yard or mkdocs to GitHub Pages.

    The rake task copies all files from the src_dir and pushes them to the
    GitHub repository and branch identified by repo_url and branch_name.

    The contents of the branch are completely overwritten by the contents of src_dir.
  DESCRIPTION

  spec.homepage = 'https://github.com/jcouball/github_pages_rake_tasks'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = spec.homepage
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bump', '~> 0.10'
  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'rake', '~> 13.1'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.58'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-lcov', '~> 0.8'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yardstick', '~> 0.9'
end
