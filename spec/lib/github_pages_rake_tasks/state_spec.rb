# Copyright (c) 2019 James Couball
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GithubPagesRakeTasks::State do
  let(:state) { described_class.new }
  context 'with a newly initialized State object' do
    describe '#interface' do
      subject { state.interface }
      it { is_expected.to be_a(GithubPagesRakeTasks::Interface) }
    end
    describe '#interface=' do
      let(:new_interface) { double('interface') }
      before { state.interface = new_interface }
      subject { state }
      it { is_expected.to have_attributes(interface: new_interface) }
    end
  end
  context 'with a newly initialized State object with a mocked interface' do
    let(:mocked_interface) { double('interface') }
    describe '#project_root' do
      subject { state.project_root }
      let(:default_project_root) { '/Users/jcouball/project_root' }
      it 'should use git to determine the default project root' do
        expect(mocked_interface).to(
          receive(:`)
            .with('git rev-parse --show-toplevel')
            .and_return(default_project_root)
        )
        state.interface = mocked_interface
        expect(subject).to eq(default_project_root)
      end
    end
    describe '#quiet' do
      subject { state.quiet }
      let(:default_quiet) { false }
      it 'the default for quiet should be false' do
        expect(subject).to eq(default_quiet)
      end
    end
    describe '#verbose' do
      subject { state.verbose }
      let(:default_verbose) { false }
      it 'the default for verbose should be false' do
        expect(subject).to eq(default_verbose)
      end
    end
  end
end
