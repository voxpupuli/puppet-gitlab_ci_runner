require 'spec_helper'
require 'webmock/rspec'

describe 'gitlab_ci_runner::unregister' do
  let(:url) { 'https://gitlab.example.org' }
  let(:authtoken) { 'registration-token' }
  let(:return_hash) { { 'status' => 'success' } }

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('ftp://foooo.bar').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('https://gitlab.com', 1234).and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('https://gitlab.com', 'registration-token', project: 1234).and_raise_error(ArgumentError) }

  it "calls 'PuppetX::Gitlab::Runner.unregister'" do
    allow(PuppetX::Gitlab::Runner).to receive(:unregister).with(url, token: authtoken).and_return(return_hash)

    is_expected.to run.with_params(url, authtoken).and_return(return_hash)
    expect(PuppetX::Gitlab::Runner).to have_received(:unregister)
  end
end
