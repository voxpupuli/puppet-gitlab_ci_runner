require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_module_from_forge_on(host, 'puppetlabs/docker', '>= 0')

  # The omnibus installer use the following algorithm to know what to do.
  # https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-cookbooks/runit/recipes/default.rb
  # If this peace of code trigger docker case, the installer hang indefinitly.
  pp = %(
    file {'/.dockerenv':
      ensure => absent,
    }
    package { ['curl']:
      ensure => present,
    }
  )

  apply_manifest_on(host, pp, catch_failures: true)

  # https://gitlab.com/gitlab-org/omnibus-gitlab/issues/2229
  # There is no /usr/share/zoneinfo in latest Docker image for ubuntu 16.04
  # Gitlab installer fail without this file
  tzdata = %(
    package { ['tzdata']:
      ensure => present,
    }
  )

  apply_manifest_on(host, tzdata, catch_failures: true) if fact('os.release.major') =~ %r{(16.04|18.04)}

  # Setup Puppet Bolt
  gitlab_ip = File.read(File.expand_path('~/GITLAB_IP')).chomp
  bolt = <<-MANIFEST
  $bolt_config = @("BOLTPROJECT"/L)
  modulepath: "/etc/puppetlabs/code/modules:/etc/puppetlabs/code/environments/production/modules"
  analytics: false
  | BOLTPROJECT

  package { 'puppet-bolt':
    ensure => installed,
  }

  file { [ '/root/.puppetlabs', '/root/.puppetlabs/bolt', '/root/.puppetlabs/etc', '/root/.puppetlabs/etc/bolt']:
    ensure => directory,
  }

  # Needs to existing to not trigger a warning sign...
  file { '/root/.puppetlabs/etc/bolt/analytics.yaml':
    ensure  => file,
  }

  file { '/root/.puppetlabs/bolt/bolt-project.yaml':
    ensure  => file,
    content => $bolt_config,
  }

  file_line { '/etc/hosts-gitlab':
    path => '/etc/hosts',
    line => '#{gitlab_ip} gitlab',
  }
  MANIFEST
  apply_manifest_on(host, bolt, catch_failures: true)
end
