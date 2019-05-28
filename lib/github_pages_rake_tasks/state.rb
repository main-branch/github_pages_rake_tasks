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
  class State
    # The directory, relative to {project_root}, that contains the documentation to
    # publish to GitHub.
    #
    # The default value is 'doc'
    #
    # @return [String] directory
    #
    def doc_dir
      @doc_dir ||= 'doc'
    end
    attr_writer :doc_dir

    # The absolute path to the project's Git repository. {doc_dir} is relative to this
    # path.
    #
    # The default value is the value returned from `git rev-parse --show-toplevel` when
    # run in the current working directory
    #
    # @return [String] directory
    #
    def project_root
      @project_root ||= interface.send(:`, 'git rev-parse --show-toplevel').chomp
    end
    attr_writer :project_root

    # The URL to the remote repository to push documentation.
    #
    # The default value is the value returned from `git config --get remote.origin.url`
    #
    # @return [String] url
    #
    def repo_url
      @repo_url ||= Dir.chdir(project_root) do |_path|
        interface.send(:`, "git config --get remote.#{remote_name}.url").chomp
      end
    end
    attr_writer :repo_url

    # The branch to push documentation to.
    #
    # The default value is 'gh-pages'
    #
    # @return [String] the branch name
    #
    def branch_name
      @branch_name ||= 'gh-pages'
    end
    attr_writer :branch_name

    # The directory where the documentation is staged prior to pushing to the Git remote.
    # All files are copied from {doc_dir} to {staging_dir} where the push to the Git remote is
    # done.
    #
    # @note This directory is deleted at the end of the publish task.
    #
    # The default value is a temporary directory created with
    # [Dir.mktmpdir](https://ruby-doc.org/stdlib-2.6.3/libdoc/tmpdir/rdoc/Dir.html)
    # with the prefix 'github-pages-publish-'
    #
    # @return [String] a temporary directory.
    #
    def staging_dir
      @staging_dir ||= interface.mktmpdir('github-pages-publish-')
    end
    attr_writer :staging_dir

    # @!attribute quiet
    # Silence all output from the `github-pages:publish` task.
    #
    # When {quiet} is true, the `github-pages:publish` task will not emit any output
    #   unless there is an error.
    #
    # Setting {quiet} to true will also set {verbose} to false.
    #
    # The default value is false
    #
    # @return [Boolean] the quiet flag value
    #
    def quiet
      return @quiet if instance_variable_defined?(:@quiet)

      @quiet = false
    end

    def quiet=(value)
      @quiet = value
      @verbose = false if quiet
    end

    # @!attribute verbose
    # Make the `github-pages:publish` emit extra output.
    #
    # When {verbose} is true, the `github-pages:publish` task will emit extra output
    #   that is useful for debugging.
    #
    # Setting {verbose} to true will also set {quiet} to false.
    #
    # The default value is false
    #
    # @return [Boolean] the verbose flag value
    #
    def verbose
      return @verbose if instance_variable_defined?(:@verbose)

      @verbose = false
    end

    def verbose=(value)
      @verbose = value
      @quiet = false if verbose
    end

    # The name of the Git remote to use for pushing documentation.
    #
    # The default value is 'origin'
    #
    # @return [String] the Git remote name
    #
    def remote_name
      @remote_name ||= 'origin'
    end
    attr_writer :remote_name

    # An object that implements all methods that touch the world outside of
    # the PublishTask class.  This includes dealing with the file system, issuing
    # shell commands, etc.
    #
    # The default value is a new instance of {GithubPagesRakeTasks::Interface}
    #
    # @note {interface} is used for mocking during testing of this gem and is probably
    #   not useful for users of this gem.
    #
    # @return [GithubPagesRakeTasks::Instance] an interface object
    #
    def interface
      @interface ||= Interface.new
    end
    attr_writer :interface

    # The Rake namespace for the publish task.
    #
    # The default value is 'github-pages'
    #
    # @return [String] Rake namespace
    #
    def rake_namespace
      @rake_namespace ||= 'github-pages'
    end
    attr_writer :rake_namespace
  end
end
