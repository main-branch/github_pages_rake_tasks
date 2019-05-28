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
      @state = State.new

      # Allow user to override defaults
      #
      yield(*[@state, task_args].slice(0, initialization_block.arity)) if initialization_block

      namespace rake_namespace do
        desc "Publish #{doc_dir} to #{repo_url}##{branch_name}"
        task :publish do
          display_header
          publish
          display_footer
        end
      end
    end

    private

    # @!visibility private

    def display_header
      print "Publishing #{doc_dir} to #{repo_url}##{branch_name}..." unless quiet
      puts if verbose
    end

    def display_footer
      puts 'SUCCESS' unless quiet
    end

    def publish
      interface.verbose(verbose) do
        initialize_staging_dir
        copy_doc_dir_to_staging_dir
        commit_and_push_staging_dir
        clean_staging_dir
      end
    end

    def checkout_existing_branch
      # only download the needed branch from GitHub
      interface.sh("git fetch '#{remote_name}' '#{branch_name}'")
      interface.sh("git checkout '#{branch_name}'")
    end

    def create_new_branch
      interface.sh("git checkout --orphan '#{branch_name}'")
      interface.file_write('index.html', 'Future home of documentation')
      interface.sh('git add .')
      interface.sh("git commit -m 'Create the documentation branch'")
      interface.sh("git push '#{remote_name}' '#{branch_name}'")
    end

    def remote_branch_exists?
      cmd = "git ls-remote --exit-code --heads '#{repo_url}' '#{branch_name}'"
      interface.sh(cmd) do |branch_exists, _process_status|
        branch_exists
      end
    end

    def initialize_staging_repo
      interface.mkdir_p(staging_dir) unless interface.dir_exist?(staging_dir)

      interface.sh('git init')
      interface.sh("git remote add '#{remote_name}' '#{repo_url}'")
    end

    # Creates `staging_dir` (if needed), clones the remote repository to it, and checks
    # out `branch_name`.  Creates `branch_name` in the remote is needed.
    #
    # Finally, removes all files using git rm
    #
    def initialize_staging_dir
      initialize_staging_repo
      if remote_branch_exists?
        checkout_existing_branch
      else
        create_new_branch
      end
      remove_staging_files
    end

    def clean_staging_dir
      interface.rm_rf staging_dir
    end

    def absolute_doc_dir
      @absolute_doc_dir ||= interface.expand_path(doc_dir, project_root)
    end

    def commit_message
      @commit_message ||= 'Updating documentation'
    end

    def remove_staging_files
      interface.chdir staging_dir do
        interface.sh('git rm -r .') do
          # ignore failure
        end
      end
    end

    def copy_doc_dir_to_staging_dir
      interface.cp_r(File.join(absolute_doc_dir, '.'), staging_dir)
    end

    def commit_and_push_staging_dir
      interface.chdir staging_dir do
        interface.sh('git add .')
        interface.sh("git commit -m '#{commit_message}'")
        interface.sh("git push --set-upstream #{remote_name} #{branch_name}")
      end
    end
  end
end
