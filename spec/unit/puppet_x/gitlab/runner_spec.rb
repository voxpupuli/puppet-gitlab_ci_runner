require 'spec_helper'
require 'webmock/rspec'
require_relative '../../../../lib/puppet_x/gitlab/runner.rb'

module PuppetX::Gitlab
  describe APIClient do
    describe 'self.delete' do
      it 'returns an empty hash' do
        stub_request(:delete, 'https://example.org').
          with(
            body: '{}',
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Ruby'
            }
          ).
          to_return(status: 204, body: '', headers: {})

        expect(described_class.delete('https://example.org', {})).to eq({})
      end

      it 'raises an exception on non 200 http code' do
        stub_request(:delete, 'https://example.org').
          to_return(status: 403)

        expect { described_class.delete('https://example.org', {}) }.to raise_error(Net::HTTPError)
      end
    end

    describe 'self.post' do
      it 'returns a hash' do
        stub_request(:post, 'https://example.org').
          with(
            body: '{}',
            headers: {
              'Accept' => 'application/json',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => 'Ruby'
            }
          ).
          to_return(status: 201, body: '{ "id": "12345", "token": "6337ff461c94fd3fa32ba3b1ff4125" }', headers: {})

        expect(described_class.post('https://example.org', {})).to eq('id' => '12345', 'token' => '6337ff461c94fd3fa32ba3b1ff4125')
      end

      it 'raises an exception on non 200 http code' do
        stub_request(:delete, 'https://example.org').
          to_return(status: 501)

        expect { described_class.delete('https://example.org', {}) }.to raise_error(Net::HTTPError)
      end
    end

    describe 'self.request' do
      context 'when doing a request' do
        before do
          stub_request(:post, 'example.org')
          described_class.request('http://example.org/', Net::HTTP::Post, {})
        end

        it 'uses Accept: application/json' do
          expect(a_request(:post, 'example.org').
            with(headers: { 'Accept' => 'application/json' })).
            to have_been_made
        end

        it 'uses Content: application/json' do
          expect(a_request(:post, 'example.org').
            with(headers: { 'Content-Type' => 'application/json' })).
            to have_been_made
        end
      end

      context 'when doing a HTTPS request' do
        before do
          stub_request(:post, 'https://example.org/')
          described_class.request('https://example.org/', Net::HTTP::Post, {})
        end

        it 'uses SSL if url contains https://' do
          expect(a_request(:post, 'https://example.org/')).to have_been_made
        end
      end
    end
  end

  describe Runner do
    describe 'self.register' do
      before do
        PuppetX::Gitlab::APIClient.
          stub(:post).
          with('https://gitlab.example.org/api/v4/runners', token: 'registrationtoken').
          and_return('id' => 1234, 'token' => '1234567890abcd')
      end
      let(:response) { described_class.register('https://gitlab.example.org', token: 'registrationtoken') }

      it 'returns a token' do
        expect(response['token']).to eq('1234567890abcd')
      end
    end

    describe 'self.unregister' do
      before do
        PuppetX::Gitlab::APIClient.
          stub(:delete).
          with('https://gitlab.example.org/api/v4/runners', token: '1234567890abcd').
          and_return({})
      end
      let(:response) { described_class.unregister('https://gitlab.example.org', token: '1234567890abcd') }

      it 'returns an empty hash' do
        expect(response).to eq({})
      end
    end
  end
end
