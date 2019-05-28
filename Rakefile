# Copyright (c) 2019 James Couball
# frozen_string_literal: true

require 'bundler/gem_tasks'
CLOBBER << 'Gemfile.lock'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
CLEAN << '.rspec_status'
CLEAN << 'coverage'

require 'bundler/audit/task'
Bundler::Audit::Task.new

require 'bump/tasks'

require 'rubocop/rake_task'
RuboCop::RakeTask.new do |t|
  t.options = %w[--format progress --format json --out rubocop-report.json]
end
CLEAN << 'rubocop-report.json'

require 'yard'
YARD::Rake::YardocTask.new
CLEAN << '.yardoc'
CLEAN << 'doc'

require 'yardstick/rake/verify'
require 'yaml'
options = YAML.load_file('.yardstick.yml')
Yardstick::Rake::Verify.new('yardstick:verify', options)

require 'yardstick/rake/measurement'
Yardstick::Rake::Measurement.new('yardstick:measure', options) do |task|
  # task.output = Object.new do
  #   def write(&block)
  #     block.call(STDOUT)
  #   end
  #   def to_s
  #     'STDOUT'
  #   end
  # end
end
CLEAN << 'measurements'

desc 'Run yardstick to check yard docs'
task :yardstick do
  sh "yardstick 'lib/**/*.rb'"
end

task default: [:spec, 'bundle:audit', :rubocop, :yard, :build]
