# Copyright (c) 2019 James Couball
# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
require 'simplecov-lcov'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Setup simplecov
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = [
  SimpleCov::Formatter::LcovFormatter,
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

require 'github_pages_rake_tasks'
