# Copyright (c) 2019 James Couball
# frozen_string_literal: true

require 'forwardable'
require 'rake'

module GithubPagesRakeTasks
  # Whenever the publish task has to interact with things outside of itself,
  # it uses an instance of the interface class.  This makes the tests easy to
  # mock.
  #
  # @example
  #   interface = Interface.new
  #   interface.chdir(path) do |path|
  #     interface.sh('git clone https://github.com/jcouball/project')
  #   end
  #
  # Inject an object into an instance of PublishTask in order to mock the
  # task's interaction with the outside world.
  #
  # @example
  #   PublishTask.new do |t|
  #     t.interface = Object.new
  #       def chdir(path); end
  #       ...
  #     end
  #   end
  #
  # @see https://docs.ruby-lang.org/en/2.6.0/Dir.html Dir documentation
  # @see https://docs.ruby-lang.org/en/2.6.0/File.html File documentation
  # @see https://docs.ruby-lang.org/en/2.6.0/FileUtils.html FileUtils documentation
  #
  # @api public
  #
  class Interface
    extend Forwardable

    def_delegators :@file_utils, :chdir, :rm_rf, :cp_r, :sh, :verbose
    def_delegators :@dir, :mktmpdir
    def_delegator  :@dir, :exist?, :dir_exist?
    def_delegators :@file, :expand_path
    def_delegator  :@file, :write, :file_write

    # Creates a new interface object
    #
    # This object will delegate methods to the objects passed in as defined in
    # the Forwardable def_delegators above.
    #
    # @example
    #   interface = GithubPagesRakeTasks.new
    #   interface.chdir('test') do
    #     interface.cp_r(src, dest)
    #   end
    #
    # @return [void]
    #
    def initialize
      @file_utils = Rake::FileUtilsExt
      @dir = Dir
      @file = File
    end

    # Delegates call to Kernel::`
    #
    # @example
    #   interface = GithubPagesRakeTasks::Interface.new
    #   project_root = interface.send(:`, 'git rev-parse --show-toplevel').chomp
    #
    # @param cmd the command to run
    #
    # @return [String] the output of the command
    #
    def `(cmd)
      super
    end
  end
end
