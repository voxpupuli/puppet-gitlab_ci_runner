require 'spec_helper'

valid_values = [
  {
    listen_address: '127.0.0.1:8093',
    advertise_address: '127.0.0.1:8093',
  },
  {
    listen_address: 'localhost:8093',
    advertise_address: 'runner-host-name.tld:8093',
  },
  {
    listen_address: '[::]:8093',
    advertise_address: 'runner-host-name.tld:8093',
  }
]

describe 'Gitlab_ci_runner::Session_server' do
  valid_values.each do |value|
    it { is_expected.to allow_value(value) }
    it { is_expected.to allow_value(value.merge(session_timeout: 1234)) }
  end

  [:undef, { listen_address: '127.0.0.1:8093' }, { advertise_address: 'runner-host-name.tld:8093' }, { session_timeout: 1234 }].each do |value|
    it { is_expected.not_to allow_value(value) }
  end
end
