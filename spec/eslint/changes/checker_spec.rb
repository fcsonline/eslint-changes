# frozen_string_literal: true

require 'eslint/changes/checker'
require 'eslint/changes/shell'

RSpec.describe Eslint::Changes::Checker do
  let(:commit) { nil }
  let(:auto_correct) { false }

  subject do
    described_class.new(
      report: 'spec/eslint/changes/eslint.json',
      quiet: false,
      commit: commit,
      base_branch: 'master'
    ).run
  end

  context 'when the fork point is not known' do
    it 'raises an exception' do
      expect(Eslint::Changes::Shell).to receive(:run).with(
        'git merge-base HEAD origin/master'
      ).and_return('')

      expect do
        subject
      end.to raise_error(Eslint::Changes::UnknownForkPointError)
    end

    context 'by given commit id' do
      let(:commit) { 'deadbeef' }

      it 'raises an exception' do
        expect(Eslint::Changes::Shell).to receive(:run).with(
          'git log -n 1 --pretty=format:"%h" deadbeef'
        ).and_return('')

        expect do
          subject
        end.to raise_error(Eslint::Changes::UnknownForkPointError)
      end
    end
  end

  context 'when the fork point is known' do
    let(:diff_files) do
      %w[lib/eslint/changes/check.rb]
    end

    let(:git_diff) { File.read('spec/eslint/changes/sample.diff') }
    let(:offenses) { File.read('spec/eslint/changes/eslint.json') }

    let(:total_offenses) do
      JSON.parse(offenses).count
    end

    it 'runs a git diff' do
      expect(Eslint::Changes::Shell).to receive(:run).with(
        'git merge-base HEAD origin/master'
      ).and_return('deadbeef')

      expect(Eslint::Changes::Shell).to receive(:run).with(
        'git diff deadbeef'
      ).and_return(git_diff)

      expect(total_offenses).to be(1)
      expect(subject).to be(0)
    end

    context 'by given commit id' do
      let(:commit) { 'deadbeef' }

      it 'runs a git diff' do
        expect(Eslint::Changes::Shell).to receive(:run).with(
          'git log -n 1 --pretty=format:"%h" deadbeef'
        ).and_return('deadbeef')

        expect(Eslint::Changes::Shell).to receive(:run).with(
          'git diff deadbeef'
        ).and_return(git_diff)

        expect(total_offenses).to be(1)
        expect(subject).to be(0)
      end
    end

    context 'when FIXME flag is not present' do
      it do
        expect(Eslint::Changes::Shell).to receive(:run).with(
          'git merge-base HEAD origin/master'
        ).and_return('deadbeef')

        expect(Eslint::Changes::Shell).to receive(:run).with(
          'git diff deadbeef'
        ).and_return(git_diff)

        expect(subject).to be(0)
      end
    end
  end
end
