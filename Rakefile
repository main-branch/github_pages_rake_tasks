# Copyright (c) 2019 James Couball
# frozen_string_literal: true

desc 'Run the same tasks that the CI build will run'
if RUBY_PLATFORM == 'java'
  task default: %w[spec rubocop bundle:audit build]
else
  task default: %w[spec rubocop yard yard:audit yard:coverage bundle:audit build]
end

# Bundler Audit

require 'bundler/audit/task'
Bundler::Audit::Task.new

# Bundler Gem Build

require 'bundler'
require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

# Make it so that calling `rake release` just calls `rake release:rubygems_push` to
# avoid creating and pushing a new tag.

Rake::Task['release'].clear
desc 'Customized release task to avoid creating a new tag'
task release: 'release:rubygem_push'

CLEAN << 'pkg'
CLEAN << 'Gemfile.lock'

# RSpec

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do
  if RUBY_PLATFORM == 'java'
    ENV['JAVA_OPTS'] = '-Djdk.io.File.enableADS=true'
    ENV['JRUBY_OPTS'] = '--debug'
    ENV['NOCOV'] = 'TRUE'
  end
end

CLEAN << 'coverage'
CLEAN << '.rspec_status'
CLEAN << 'rspec-report.xml'

# Rubocop

require 'rubocop/rake_task'

RuboCop::RakeTask.new do |t|
  t.options = %w[
    --format progress
    --format json --out rubocop-report.json
  ]
end

CLEAN << 'rubocop-report.json'

unless RUBY_PLATFORM == 'java'
  # YARD

  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = %w[lib/**/*.rb examples/**/*]
  end

  CLEAN << '.yardoc'
  CLEAN << 'doc'

  # Yardstick

  desc 'Run yardstick to show missing YARD doc elements'
  task :'yard:audit' do
    sh "yardstick 'lib/**/*.rb'"
  end

  # Yardstick coverage

  require 'yardstick/rake/verify'

  Yardstick::Rake::Verify.new(:'yard:coverage') do |verify|
    verify.threshold = 100
  end
end
