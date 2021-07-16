require 'voxpupuli/acceptance/spec_helper_acceptance'

ENV['BEAKER_FACTER_GITLAB_IP'] = File.read(File.expand_path('~/GITLAB_IP')).chomp

configure_beaker do |host|
  install_module_from_forge_on(host, 'puppetlabs/docker', '>= 0')
end
