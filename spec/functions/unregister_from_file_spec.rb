require 'spec_helper'
require 'webmock/rspec'

describe 'gitlab_ci_runner::unregister_from_file' do
  let(:url) { 'https://gitlab.example.org' }
  let(:runner_name) { 'testrunner' }
  let(:filename) { "/etc/gitlab-runner/auth-token-#{runner_name}" }

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('https://gitlab.com', 1234).and_raise_error(ArgumentError) }

  context 'uses an existing auth token from file to unregister the runner' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(filename).and_return(true)
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(filename).and_return('authtoken')
      allow(PuppetX::Gitlab::Runner).to receive(:unregister).with(url, token: 'authtoken').and_return(nil)
    end

    it { is_expected.to run.with_params(url, runner_name).and_return(nil) }
  end

  context "does nothing if file doesn't exist" do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(filename).and_return(false)
    end

    it { is_expected.to run.with_params(url, runner_name).and_return(nil) }
  end
end
