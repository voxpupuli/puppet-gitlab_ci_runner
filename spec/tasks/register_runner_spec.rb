require 'webmock/rspec'
require_relative '../../tasks/register_runner.rb'

describe RegisterRunnerTask do
  let(:params) do
    {
      token: 'registrationtoken',
      url: 'https://gitlab.example.org'
    }
  end
  let(:described_object) { described_class.new }

  describe '.task' do
    it 'can register a runner' do
      allow(PuppetX::Gitlab::Runner).to receive(:register).
        with('https://gitlab.example.org', token: 'registrationtoken').
        and_return('id' => 777, 'token' => '3bz5wqfDiYBhxoUNuGVu')

      expect(described_object.task(params)).to eq('id' => 777, 'token' => '3bz5wqfDiYBhxoUNuGVu')
    end

    it 'can raise an error' do
      params.merge(token: 'invalid-token')
      stub_request(:post, 'https://gitlab.example.org/api/v4/runners').
        to_return(status: [403, 'Forbidden'])
      expect { described_object.task(params) }.to raise_error(TaskHelper::Error, %r{Gitlab runner failed to register: Forbidden})
    end
  end
end
