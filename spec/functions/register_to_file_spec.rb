# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe 'gitlab_ci_runner::register_to_file' do
  let(:url) { 'https://gitlab.example.org' }
  let(:token) do
    {
      reg_token: 'registration-token',
      auth_token: 'glrt-authentication-token'
    }
  end
  let(:runner_name) { 'testrunner' }
  let(:filename) { "/etc/gitlab-runner/auth-token-#{runner_name}" }
  let(:return_hash) do
    {
      'id' => 1234,
      'token' => 'auth-token'
    }
  end

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('ftp://foooo.bar').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('https://gitlab.com', 1234).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('https://gitlab.com', 'registration-token', project: 1234).and_raise_error(ArgumentError) }

  context 'uses an existing auth token from file' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(filename).and_return(true)
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(filename).and_return(return_hash['token'])
    end

    it { is_expected.to run.with_params(url, token[:reg_token], runner_name).and_return(return_hash['token']) }
    it { is_expected.to run.with_params(url, token[:auth_token], runner_name).and_return(return_hash['token']) }
  end

  context 'retrieves from Gitlab and writes auth token to file if it doesn\'t exist' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(File.dirname(filename)).and_return(true)
      allow(File).to receive(:chmod).with(0o400, filename)
    end

    context 'with registration token' do
      before do
        allow(PuppetX::Gitlab::Runner).to receive(:register).with(url, { 'registration-token' => token[:reg_token] }, nil, nil).and_return(return_hash)
        allow(File).to receive(:write).with(filename, return_hash['token'])
      end

      it { is_expected.to run.with_params(url, token[:reg_token], runner_name).and_return(return_hash['token']) }

      context 'with existing file ca_file option' do
        before do
          allow(PuppetX::Gitlab::Runner).to receive(:register).with(url, { 'registration-token' => token[:reg_token] }, nil, '/tmp').and_return(return_hash)
        end

        it { is_expected.to run.with_params(url, token[:reg_token], runner_name, {}, nil, '/tmp').and_return(return_hash['token']) }
      end

      context 'with non existent ca_file option' do
        before do
          allow(PuppetX::Gitlab::Runner).to receive(:register).with(url, { 'registration-token' => token[:reg_token] }, nil, '/path/to/ca_file').and_return(return_hash)
        end

        it { is_expected.to run.with_params(url, token[:reg_token], runner_name, {}, nil, '/path/to/ca_file').and_return('Specified CA file doesn\'t exist, not attempting to create authtoken') }
      end

      context 'with sensitive token value' do
        before do
          allow(PuppetX::Gitlab::Runner).to receive(:register).with(url, { 'registration-token' => token[:reg_token] }, nil, '/tmp').and_return(return_hash)
        end

        it { is_expected.to run.with_params(url, sensitive(token[:reg_token]), runner_name, {}, nil, '/tmp').and_return(return_hash['token']) }
      end
    end

    context 'with authentication token' do
      before do
        allow(PuppetX::Gitlab::Runner).to receive(:verify).with(url, token[:auth_token], nil, nil).and_return(return_hash.merge('token' => token[:auth_token]))
        allow(File).to receive(:write).with(filename, token[:auth_token])
      end

      it { is_expected.to run.with_params(url, token[:auth_token], runner_name).and_return(token[:auth_token]) }

      context 'with existing file ca_file option' do
        before do
          allow(PuppetX::Gitlab::Runner).to receive(:verify).with(url, token[:auth_token], nil, '/tmp').and_return(return_hash.merge('token' => token[:auth_token]))
        end

        it { is_expected.to run.with_params(url, token[:auth_token], runner_name, {}, nil, '/tmp').and_return(token[:auth_token]) }
      end

      context 'with non existent ca_file option' do
        before do
          allow(PuppetX::Gitlab::Runner).to receive(:verify).with(url, token[:auth_token], nil, '/path/to/ca_file').and_return(return_hash.merge('token' => token[:auth_token]))
        end

        it { is_expected.to run.with_params(url, token[:auth_token], runner_name, {}, nil, '/path/to/ca_file').and_return('Specified CA file doesn\'t exist, not attempting to create authtoken') }
      end

      context 'with sensitive token value' do
        before do
          allow(PuppetX::Gitlab::Runner).to receive(:verify).with(url, token[:auth_token], nil, '/tmp').and_return(return_hash.merge('token' => token[:auth_token]))
        end

        it { is_expected.to run.with_params(url, sensitive(token[:auth_token]), runner_name, {}, nil, '/tmp').and_return(token[:auth_token]) }
      end
    end
  end

  context 'noop does not register runner and returns dummy token' do
    before do
      allow(Puppet.settings).to receive(:[]).and_call_original
      allow(Puppet.settings).to receive(:[]).with(:noop).and_return(true)
    end

    it { is_expected.to run.with_params(url, token[:reg_token], runner_name).and_return('DUMMY-NOOP-TOKEN') }
    it { is_expected.to run.with_params(url, token[:auth_token], runner_name).and_return('DUMMY-NOOP-TOKEN') }
  end
end
