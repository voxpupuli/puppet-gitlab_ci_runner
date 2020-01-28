require 'webmock/rspec'
require_relative '../../tasks/unregister_runner.rb'

describe UnregisterRunnerTask do
  let(:params) do
    {
      url: 'https://gitlab.example.org',
      token: 'abcdef1234'
    }
  end
  let(:described_object) { described_class.new }

  describe '.task' do
    it 'can unregister a runner' do
      allow(PuppetX::Gitlab::Runner).to receive(:unregister).
        with('https://gitlab.example.org', token: 'abcdef1234').
        and_return({})

      expect(described_object.task(params)).to eq(status: 'success')
    end

    it 'can raise an error' do
      params.merge(token: 'invalid-token')
      stub_request(:delete, 'https://gitlab.example.org/api/v4/runners').
        to_return(status: [403, 'Forbidden'])
      expect { described_object.task(params) }.to raise_error(TaskHelper::Error, %r{Gitlab runner failed to unregister: Forbidden})
    end
  end
end
