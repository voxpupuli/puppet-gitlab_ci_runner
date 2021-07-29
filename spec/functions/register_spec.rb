require 'spec_helper'
require 'webmock/rspec'

describe 'gitlab_ci_runner::register' do
  let(:url) { 'https://gitlab.example.org' }
  let(:regtoken) { 'registration-token' }
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

  it "calls 'PuppetX::Gitlab::Runner.register'" do
    allow(PuppetX::Gitlab::Runner).to receive(:register).with(url, 'token' => regtoken).and_return(return_hash)

    is_expected.to run.with_params(url, regtoken).and_return(return_hash)
    expect(PuppetX::Gitlab::Runner).to have_received(:register)
  end

  it "passes additional args to 'PuppetX::Gitlab::Runner.register'" do
    allow(PuppetX::Gitlab::Runner).to receive(:register).with(url, 'token' => regtoken, 'active' => false).and_return(return_hash)

    is_expected.to run.with_params(url, regtoken, 'active' => false).and_return(return_hash)
    expect(PuppetX::Gitlab::Runner).to have_received(:register)
  end
end
