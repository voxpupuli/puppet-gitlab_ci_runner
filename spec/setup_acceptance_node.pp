# The omnibus installer use the following algorithm to know what to do.
# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-cookbooks/runit/recipes/default.rb
# If this peace of code trigger docker case, the installer hang indefinitly.
file {'/.dockerenv':
  ensure => absent,
}

package { 'curl':
  ensure => present,
}

# https://gitlab.com/gitlab-org/omnibus-gitlab/issues/2229
# There is no /usr/share/zoneinfo in latest Docker image for ubuntu 16.04
# Gitlab installer fail without this file
if $facts['os']['release']['major'] in ['16.04', '18.04'] {
  package { 'tzdata':
    ensure => present,
  }
}

# Setup Puppet Bolt
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
  line => "${facts['gitlab_ip']} gitlab",
}
file_line { '/etc/hosts-squid':
  path => '/etc/hosts',
  line => "${facts['squid_ip']} squid",
}
