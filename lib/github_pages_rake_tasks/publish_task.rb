# Copyright (c) 2019 James Couball
# frozen_string_literal: true

require 'forwardable'
require 'rake'
require 'rake/tasklib'
require 'tmpdir'

require 'github_pages_rake_tasks/interface'
require 'github_pages_rake_tasks/state'

module GithubPagesRakeTasks
  # Instantiate this class to create a Rake task that pushes the contents from a
  # local documentation directory to a GitHub repository branch.
  #
  # See {GithubPagesRakeTasks::PublishTask#initialize} for more details.
  #
  # @api public
  #
  class PublishTask < ::Rake::TaskLib
    extend Forwardable

    def_delegators(
      :@state,
      :interface, :interface=, :project_root, :project_root=, :rake_namespace, :rake_namespace=,
      :doc_dir, :doc_dir=, :remote_name, :remote_name=, :repo_url, :repo_url=,
      :staging_dir, :staging_dir=, :branch_name, :branch_name=,
      :quiet, :quiet=, :verbose, :verbose=
    )

    # Create the publish task
    #
    # By default, the rake task `github-pages:publish` is created which pushes the `doc`
    # directory within the local copy of your repository to the same repository's
    # `gh-pages` branch.  The contents of the branch are completely replaced by the
    # contents of the documentation directory.
    #
    # @example with default options
    #   require 'github_pages_rake_tasks'
    #   GitHubPagesRakeTasks.Tasks.new
    #   task default: 'github-pages:publish'
    #
    # An initialization block can be passed to the initializer to set attributes
    # to customize the behavior of the rake task created.  {GithubPagesRakeTasks::State}
    # details all the attributes which can be set and what effect they have on the task.
    #
    # @example with an initialization block
    #   require 'github_pages_rake_tasks'
    #   GitHubPagesRakeTasks.Tasks.new do |task|
    #     task.doc_dir = 'documentation'
    #     task.verbose = true
    #   end
    #   task default: 'github-pages:publish'
    #
    # @param [Array<Object>] task_args arguments to pass to the task initialization
    #   block.
    #
    # @param initialization_block If given, the task initialization will yield to
    #   this block with the `task_args` to perform user initialization of the publish
    #   task.
    #
    # @yield yields to the passed `initialization_block` for user initialization of this task.
    # @yieldparam state [GithubPagesRakeTasks::State] the configuration state of this task. See
    #   {State} for a description of the configuration attributes that can be set.
    # @yieldparam task_args [Array<Object>] any args passed to this initializer
    #   are passed to the yielded block.
    #
    def initialize(*task_args, &initialization_block)
      super

      @state = State.new

      # Allow user to override defaults
      #
      yield(*[@state, task_args].slice(0, initialization_block.arity)) if initialization_block

      namespace rake_namespace do
        desc "Publish #{doc_dir} to #{repo_url}##{branch_name}"
        task :publish do
          publish_task
        end
      end
    end

    private

    # @!visibility private

    # Publish the documentation directory to the specified repository and branch
    #
    # Publishes the document directory to the specified repository and branch
    # displaying a header before publishing and a footer after publishing. The header
    # and footer are not displayed if the `quiet` flag is set.
    #
    # @see #display_header
    # @see #publish
    # @see #display_footer
    #
    # @return [void]
    #
    # @api private
    #
    def publish_task
      display_header
      publish
      display_footer
    end

    # Print a header message before the publishing
    #
    # The message includes the document directory, repository URL, and branch name.
    # The message is not printed if the `quiet` flag is set.
    # An extra line is printed if the `verbose` flag is set.
    #
    # @return [void]
    #
    # @api private
    def display_header
      print "Publishing #{doc_dir} to #{repo_url}##{branch_name}..." unless quiet
      puts if verbose
    end

    # Print a success message after the publishing
    #
    # The message is not printed if the `quiet` flag is set.
    #
    # @return [void]
    #
    # @api private
    def display_footer
      puts 'SUCCESS' unless quiet
    end

    # Executes the publishing process
    #
    # @return [void]
    #
    # @api private
    #
    def publish
      interface.verbose(verbose) do
        interface.mkdir_p(staging_dir)
        interface.chdir(staging_dir) do
          initialize_staging_dir
          copy_doc_dir_to_staging_dir
          commit_and_push_staging_dir
        end
        clean_staging_dir
      end
    end

    # Fetch and checks out an existing branch
    #
    # @return [void]
    #
    # @api private
    #
    def checkout_existing_branch
      # only download the needed branch from GitHub
      interface.sh("git fetch '#{remote_name}' '#{branch_name}'")
      interface.sh("git checkout '#{branch_name}'")
    end

    # Creates `branch_name` in the remote repository
    #
    # @return [Boolean] true if the branch exists in the remote repository, false otherwise.
    #
    # @api private
    #
    def create_new_branch
      interface.sh("git checkout --orphan '#{branch_name}'")
      interface.file_write('index.html', 'Future home of documentation')
      interface.sh('git add .')
      interface.sh("git commit -m 'Create the documentation branch'")
      interface.sh("git push '#{remote_name}' '#{branch_name}'")
    end

    # Checks if `branch_name` exists in the remote repository
    #
    # @return [Boolean] true if the branch exists in the remote repository, false otherwise
    #
    # @api private
    #
    def remote_branch_exists?
      cmd = "git ls-remote --exit-code --heads '#{repo_url}' '#{branch_name}'"
      interface.sh(cmd) do |branch_exists, _process_status|
        branch_exists
      end
    end

    # Initializes the git repository in `staging_dir`
    #
    # @return [void]
    #
    # @api private
    #
    def initialize_git
      interface.sh('git init')
      interface.sh("git remote add '#{remote_name}' '#{repo_url}'")
    end

    # Initializes the staging directory
    #
    # * Creates `staging_dir` (if needed)
    # * Clones the remote repository to it
    # * Checks out `branch_name`
    # * Creates `branch_name` in the remote if needed.
    # * Finally, removes all files using git rm
    #
    # @return [void]
    #
    # @api private
    #
    def initialize_staging_dir
      initialize_git
      if remote_branch_exists?
        checkout_existing_branch
      else
        create_new_branch
      end
      remove_staging_files
    end

    # Removes the staging directory
    #
    # @return [void]
    #
    # @api private
    #
    def clean_staging_dir
      interface.rm_rf staging_dir
    end

    # @!attribute [r] absolute_doc_dir
    #
    # The absolute path to `doc_dir` relative to `project_root`
    #
    # @return [String]
    #
    # @api private
    #
    def absolute_doc_dir
      @absolute_doc_dir ||= interface.expand_path(doc_dir, project_root)
    end

    # @!attribute [r] commit_message
    #
    # The commit message to use when committing the documentation
    #
    # @return [String]
    #
    # @api private
    #
    def commit_message
      @commit_message ||= 'Updating documentation'
    end

    # Removes all files from the staging directory
    #
    # @return [void]
    #
    # @api private
    #
    def remove_staging_files
      interface.sh('git rm -r .') do
        # ignore failure
      end
    end

    # Copies the contents of `absolute_doc_dir` to `staging_dir`
    #
    # @return [void]
    #
    # @api private
    #
    def copy_doc_dir_to_staging_dir
      interface.cp_r(File.join(absolute_doc_dir, '.'), staging_dir)
    end

    # Commits and pushes the contents of `staging_dir` to the remote repository
    #
    # @return [void]
    #
    # @api private
    #
    def commit_and_push_staging_dir
      interface.sh('git add .')
      interface.sh("git commit -m '#{commit_message}'") do |commit_successful, _process_status|
        interface.sh("git push --set-upstream #{remote_name} #{branch_name}") if commit_successful
      end
    end
  end
end
