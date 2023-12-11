# Copyright (c) 2019 James Couball
# frozen_string_literal: true

require 'forwardable'
require 'rake'
require 'rake/tasklib'
require 'tmpdir'
require 'github_pages_rake_tasks/interface'

module GithubPagesRakeTasks
  # Keeps all attributes for {GithubPagesRakeTasks::PublishTask}.  These attributes control
  # how the task works.
  #
  # All attributes have sensible defaults which will cause {GithubPagesRakeTasks::PublishTask}
  # to completely overwrite the project's `gh-pages` branch with the contents of the project's
  # `doc` directory.
  #
  # Most used attributes are {doc_dir}, {project_root}, {repo_url}, and {branch_name}.
  #
  # @!attribute doc_dir [rw]
  #   The directory relative to {project_root} containing the documentation
  #
  #   The default value is 'doc'.
  #
  #   @example
  #     doc_dir = 'doc'
  #     doc_dir #=> 'doc'
  #
  #   @return [String]
  #
  # @!attribute project_root [rw]
  #   The absolute path to the project's root directory
  #
  #   {doc_dir} is relative to this directory.
  #
  #   The default value is the value returned from `git rev-parse --show-toplevel` when
  #   run in the current working directory.
  #
  #   @example
  #     project_root = '/home/james/my_project'
  #     project_root #=> '/home/james/my_project'
  #
  #   @return [String]
  #
  # @!attribute repo_url [rw]
  #   The URL to the remote repository to push documentation
  #
  #   The default value is the value returned from `git config --get remote.origin.url`
  #
  #   @example
  #     repo_url = 'https://github.com/main-branch/my_project.git'
  #     repo_url #=> 'https://github.com/main-branch/my_project.git'
  #
  #   @return [String]
  #
  # @!attribute [rw] branch_name
  #   The branch to push documentation to
  #
  #   The default value is 'gh-pages'.
  #
  #   @example
  #     branch_name = 'gh-pages'
  #     branch_name #=> 'gh-pages'
  #
  #   @return [String]
  #
  # @!attribute [rw] staging_dir
  #   The directory where the documentation is staged for pushing to the Git remote
  #
  #   All files are copied from {doc_dir} to {staging_dir} where the push to the Git remote is
  #   done.
  #
  #   @note This directory is deleted at the end of the publish task.
  #
  #   The default value is a temporary directory created with
  #   [Dir.mktmpdir](https://ruby-doc.org/stdlib-2.6.3/libdoc/tmpdir/rdoc/Dir.html)
  #   with the prefix 'github-pages-publish-'
  #
  #   @example
  #     staging_dir = ''
  #     staging_dir #=> '/home/james/my_project'
  #
  #   @return [String]
  #
  # @!attribute [rw] quiet
  #   Silence all output from the `github-pages:publish` task
  #
  #   When {quiet} is true, the `github-pages:publish` task will not emit any output
  #   unless there is an error.
  #
  #   Setting {quiet} to true will also set {verbose} to false.
  #
  #   The default value is false
  #
  #   @example
  #     quiet = true
  #     quiet #=> true
  #     verbose #=> false
  #
  #   @return [Boolean]
  #
  # @!attribute verbose
  #   Make the `github-pages:publish` emit extra output
  #
  #   When {verbose} is true, the `github-pages:publish` task will emit extra output
  #     that is useful for debugging.
  #
  #   Setting {verbose} to true will also set {quiet} to false.
  #
  #   The default value is false
  #
  #   @example
  #     verbose = true
  #     verbose #=> true
  #     quiet #=> false
  #
  #   @return [Boolean]
  #
  # @!attribute [rw] rake_namespace
  #   The Rake namespace for the `publish` task
  #
  #   The default value is 'github-pages'
  #
  #   @example
  #     rake_namespace = 'my-docs'
  #     rake_namespace #=> 'my-docs'
  #
  #   @return [String] Rake namespace
  #
  # @api public
  #
  # @!attribute [rw] interface
  #   The object that implements all methods that touch the 'outside' world
  #
  #   An object that implements all methods that touch the world outside of
  #     the PublishTask class.  This includes dealing with the file system, issuing
  #     shell commands, etc.
  #
  #   The default value is a new instance of {GithubPagesRakeTasks::Interface}
  #
  #   @note {interface} is used for mocking during testing of this gem and is probably
  #     not useful for users of this gem.
  #
  #   @example
  #     interface = GithubPagesRakeTasks::Interface.new
  #
  #   @return [GithubPagesRakeTasks::Instance]
  #
  # @!attribute [rw] remote_name
  #   The name of the Git remote to use for pushing documentation
  #
  #   The default value is 'origin'
  #
  #   @example
  #     remote_name = 'my_remote'
  #     remote_name #=> 'my_remote'
  #
  #   @return [String] the Git remote name
  #
  class State
    def doc_dir
      @doc_dir ||= 'doc'
    end

    attr_writer :doc_dir, :project_root, :repo_url, :branch_name, :staging_dir, :remote_name,
                :interface, :rake_namespace

    def project_root
      @project_root ||= interface.send(:`, 'git rev-parse --show-toplevel').chomp
    end

    def repo_url
      @repo_url ||= Dir.chdir(project_root) do |_path|
        interface.send(:`, "git config --get remote.#{remote_name}.url").chomp
      end
    end

    def branch_name
      @branch_name ||= 'gh-pages'
    end

    def staging_dir
      @staging_dir ||= interface.mktmpdir('github-pages-publish-')
    end

    def quiet
      return @quiet if instance_variable_defined?(:@quiet)

      @quiet = false
    end

    def quiet=(value)
      @quiet = value
      @verbose = false if quiet
    end

    def verbose
      return @verbose if instance_variable_defined?(:@verbose)

      @verbose = false
    end

    def verbose=(value)
      @verbose = value
      @quiet = false if verbose
    end

    def remote_name
      @remote_name ||= 'origin'
    end

    def interface
      @interface ||= Interface.new
    end

    def rake_namespace
      @rake_namespace ||= 'github-pages'
    end
  end
end
