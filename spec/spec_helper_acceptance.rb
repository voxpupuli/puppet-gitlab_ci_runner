# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

ENV['BEAKER_FACTER_GITLAB_IP'] = File.read(File.expand_path('~/GITLAB_IP')).chomp
ENV['BEAKER_FACTER_SQUID_IP'] = File.read(File.expand_path('~/SQUID_IP')).chomp

configure_beaker do |host|
  host.install_package('puppet-bolt') if bolt_supported?(host)
  install_puppet_module_via_pmt_on(host, 'puppetlabs/docker')
end
