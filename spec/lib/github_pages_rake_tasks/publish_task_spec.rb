# frozen_string_literal: true

# Copyright (c) 2019 James Couball

require 'spec_helper'
require 'rake'

RSpec.describe GithubPagesRakeTasks::PublishTask do
  before { Rake.application.clear }

  let(:default_task_name) { 'github-pages:publish' }

  context 'before initializing the publish task' do
    it "should NOT have added a task named 'github-pages:publish' to Rake" do
      expect(Rake.application.tasks).not_to(
        include(an_object_having_attributes(name: default_task_name))
      )
    end
  end

  describe '#initialize' do
    it "should have added a task named 'github-pages:publish' to Rake" do
      GithubPagesRakeTasks::PublishTask.new
      expect(Rake.application.tasks).to(
        include(an_object_having_attributes(name: default_task_name))
      )
    end
  end

  let(:mocked_interface) { double('interface') }

  # Don't set these to default values
  #
  let(:staging_dir) { '/tmp/staging' }
  let(:repo_url) { 'https://github.com/jcouball/fake-test-repo.git' }
  let(:project_root) { '/Users/jcouball/fake-test-repo' }
  let(:doc_dir) { 'generated_documentation' }
  let(:branch_name) { 'my-gh-pages' }
  let(:remote_name) { 'my_origin' }
  let(:verbose) { false }
  let(:quiet) { true }

  let(:publish_task) do
    GithubPagesRakeTasks::PublishTask.new do |t|
      t.interface = mocked_interface
      t.verbose = verbose
      t.quiet = quiet
      t.staging_dir = staging_dir
      t.repo_url = repo_url
      t.project_root = project_root
      t.doc_dir = doc_dir
      t.branch_name = branch_name
      t.remote_name = remote_name
    end
  end

  describe 'when the rake task is invoked' do
    it 'should call publish' do
      expect(publish_task).to(
        receive(:publish).with(no_args).and_return(nil)
      )
      Rake.application.invoke_task(default_task_name)
    end
  end

  describe '#publish' do
    context 'the documentation branch does not exist' do
      let(:branch_exists) { false }
      it 'should create the branch and push documentation to it' do
        publish_task
        expect(mocked_interface).to(
          receive(:verbose) { |_value, &block| block.call }
            .with(verbose)
        )

        # initialize_staging_dir
        #
        expect(mocked_interface).to(
          receive(:dir_exist?)
            .with(staging_dir)
            .and_return(true)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:chdir)
            .with(staging_dir) do |&block|
            block.call(staging_dir)
          end
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with('git init')
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git remote add '#{remote_name}' '#{repo_url}'")
            .ordered
            .once
        )

        # initialize_staging_dir --> remote_branch_exists?
        #
        cmd = "git ls-remote --exit-code --heads '#{repo_url}' '#{branch_name}'"
        expect(mocked_interface).to(
          receive(:sh)
            .with(cmd) do |_cmd, &block|
            block.call(branch_exists, double('process_status'))
          end
            .ordered
            .once
        )

        # initialize_staging_dir --> create_new_branch
        #
        expect(mocked_interface).to(
          receive(:sh)
            .with("git checkout --orphan '#{branch_name}'")
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:file_write)
            .with('index.html', 'Future home of documentation')
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with('git add .')
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git commit -m 'Create the documentation branch'")
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git push 'my_origin' 'my-gh-pages'")
            .ordered
            .once
        )

        # initialize_staging_dir --> remove_staging_files
        #
        expect(mocked_interface).to(
          receive(:chdir)
            .with(staging_dir) do |&block|
            block.call(staging_dir)
          end
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with('git rm -r .')
            .ordered
            .once
        )

        # copy_doc_dir_to_staging_dir
        #
        absolute_doc_dir = File.join(project_root, doc_dir)
        expect(mocked_interface).to(
          receive(:expand_path)
            .with(doc_dir, project_root)
            .and_return(absolute_doc_dir)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:cp_r)
            .with(File.join(absolute_doc_dir, '.'), staging_dir)
            .ordered
            .once
        )

        # commit_and_push_staging_dir
        #
        expect(mocked_interface).to(
          receive(:chdir)
            .with(staging_dir) do |&block|
            block.call(staging_dir)
          end
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with('git add .')
            .and_return(true)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git commit -m 'Updating documentation'")
            .and_return(true)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git push --set-upstream #{remote_name} #{branch_name}")
            .and_return(true)
            .ordered
            .once
        )

        # clean_staging_dir
        #
        expect(mocked_interface).to(
          receive(:rm_rf)
            .with(staging_dir)
            .ordered
            .once
        )
        Rake.application.invoke_task(default_task_name)
      end
    end
    context 'the documentation branch already exists' do
      let(:branch_exists) { true }
      it 'should update the branch' do
        publish_task

        expect(mocked_interface).to(
          receive(:verbose) { |_value, &block| block.call }
            .with(verbose)
        )

        # initialize_staging_dir
        #
        expect(mocked_interface).to(
          receive(:dir_exist?)
            .with(staging_dir)
            .and_return(true)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:chdir)
            .with(staging_dir) do |&block|
            block.call(staging_dir)
          end
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with('git init')
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git remote add '#{remote_name}' '#{repo_url}'")
            .ordered
            .once
        )

        # initialize_staging_dir --> remote_branch_exists?
        #
        cmd = "git ls-remote --exit-code --heads '#{repo_url}' '#{branch_name}'"
        expect(mocked_interface).to(
          receive(:sh)
            .with(cmd) do |_cmd, &block|
              block.call(branch_exists, double('process_status'))
            end
            .ordered
            .once
        )

        # initialize_staging_dir --> checkout_existing_branch
        #
        expect(mocked_interface).to(
          receive(:sh)
            .with("git fetch '#{remote_name}' '#{branch_name}'")
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git checkout '#{branch_name}'")
            .ordered
            .once
        )

        # initialize_staging_dir --> remove_staging_files
        #
        expect(mocked_interface).to(
          receive(:chdir)
            .with(staging_dir) do |&block|
              block.call(staging_dir)
            end
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with('git rm -r .')
            .ordered
            .once
        )

        # copy_doc_dir_to_staging_dir
        #
        absolute_doc_dir = File.join(project_root, doc_dir)
        expect(mocked_interface).to(
          receive(:expand_path)
            .with(doc_dir, project_root)
            .and_return(absolute_doc_dir)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:cp_r)
            .with(File.join(absolute_doc_dir, '.'), staging_dir)
            .ordered
            .once
        )

        # commit_and_push_staging_dir
        #
        expect(mocked_interface).to(
          receive(:chdir)
            .with(staging_dir) do |&block|
            block.call(staging_dir)
          end
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with('git add .')
            .and_return(true)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git commit -m 'Updating documentation'")
            .and_return(true)
            .ordered
            .once
        )
        expect(mocked_interface).to(
          receive(:sh)
            .with("git push --set-upstream #{remote_name} #{branch_name}")
            .and_return(true)
            .ordered
            .once
        )

        # clean_staging_dir
        #
        expect(mocked_interface).to(
          receive(:rm_rf)
            .with(staging_dir)
            .ordered
            .once
        )
        Rake.application.invoke_task(default_task_name)
      end
    end
  end
end
