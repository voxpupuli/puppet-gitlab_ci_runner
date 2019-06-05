# == Class: gitlab_ci_runner
#
## This module installs and configures Gitlab CI Runners.
#
# === Parameters
# [*runners*]
#   Type: Hash
#   Default: unset
#   Hashkeys are used as $title in runners.pp. The subkeys have to be named as the parameter names from
#   ´gitlab-runner register´ command cause they're later joined to one entire string using 2 hyphen to
#   look like shell command parameters.
#   See ´https://docs.gitlab.com/runner/register/#one-line-registration-command´ for details.
#
#   example:
#     $example_runner = {
#       registration-token => 'gitlab-token',
#       url                => 'https://gitlab.com/',
#       tag-list           => "docker,aws",
#     },
#
# [*concurrent*]
#   Default: `undef`
#   The limit on the number of jobs that can run concurrently among
#   all runners, or `undef` to leave unmanaged.
#
# [*metrics_server*]
#   Default: `undef`
#   [host]:<port> to enable metrics server as described in
#   https://docs.gitlab.com/runner/monitoring/README.html#configuration-of-the-metrics-http-server
#
class gitlab_ci_runner (
  Hash                       $runners,
  Hash                       $runner_defaults,
  String                     $xz_package_name,
  Optional[Integer]          $concurrent               = undef,
  Optional[String]           $builds_dir               = undef,
  Optional[String]           $cache_dir                = undef,
  Optional[Pattern[/.*:.+/]] $metrics_server           = undef,
  Optional[String]           $sentry_dsn               = undef,
  Boolean                    $manage_docker            = true,
  Boolean                    $manage_repo              = true,
  String                     $package_ensure           = installed,
  String                     $package_name             = 'gitlab-runner',
  Stdlib::HTTPUrl            $repo_base_url            = 'https://packages.gitlab.com',
  Stdlib::Fqdn               $repo_keyserver           = 'keys.gnupg.net',
){
  if $manage_docker {
    # workaround for cirunner issue #1617
    # https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/issues/1617
    ensure_packages($xz_package_name)

    $docker_images = {
      ubuntu_trusty => {
        image     => 'ubuntu',
        image_tag => 'trusty',
      },
    }
    class { 'docker::images':
      images => $docker_images,
    }
  }

  if $manage_repo {
    case $::osfamily {
      'Debian': {

        apt::source { 'apt_gitlabci':
          comment  => 'GitlabCI Runner Repo',
          location => "${repo_base_url}/runner/${package_name}/${::lsbdistid.downcase}/",
          repos    => 'main',
          key      => {
            'id'     => '1A4C919DB987D435939638B914219A96E15E78F4',
            'server' => $repo_keyserver,
          },
          include  => {
            'src' => false,
            'deb' => true,
          },
        }
        Apt::Source['apt_gitlabci'] -> Package[$package_name]
        Exec['apt_update'] -> Package[$package_name]
      }
      'RedHat': {
        yumrepo { "runner_${package_name}":
          ensure        => 'present',
          baseurl       => "${repo_base_url}/runner/${package_name}/el/\$releasever/\$basearch",
          descr         => "runner_${package_name}",
          enabled       => '1',
          gpgcheck      => '0',
          gpgkey        => "${repo_base_url}/gpg.key",
          repo_gpgcheck => '1',
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => '1',
        }

        yumrepo { "runner_${package_name}-source":
          ensure        => 'present',
          baseurl       => "${repo_base_url}/runner/${package_name}/el/\$releasever/SRPMS",
          descr         => "runner_${package_name}-source",
          enabled       => '1',
          gpgcheck      => '0',
          gpgkey        => "${repo_base_url}/gpg.key",
          repo_gpgcheck => '1',
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => '1',
        }
      }
      default: {
        fail ("gitlab_ci_runner::manage_repo parameter for ${::osfamily} is not supported.")
      }
    }
  }

  package { $package_name:
    ensure => $package_ensure,
  }
  service { $package_name:
    ensure => running,
    enable => true,
  }

  if $concurrent != undef {
    file_line { 'gitlab-runner-concurrent':
      path    => '/etc/gitlab-runner/config.toml',
      line    => "concurrent = ${concurrent}",
      match   => '^concurrent = \d+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }

  if $metrics_server {
    file_line { 'gitlab-runner-metrics-server':
      path    => '/etc/gitlab-runner/config.toml',
      line    => "metrics_server = \"${metrics_server}\"",
      match   => '^metrics_server = .+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }
  if $builds_dir {
    file_line { 'gitlab-runner-builds_dir':
      path    => '/etc/gitlab-runner/config.toml',
      line    => "builds_dir = \"${builds_dir}\"",
      match   => '^builds_dir = .+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }
  if $cache_dir {
    file_line { 'gitlab-runner-cache_dir':
      path    => '/etc/gitlab-runner/config.toml',
      line    => "cache_dir = \"${cache_dir}\"",
      match   => '^cache_dir = .+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }
  if $sentry_dsn {
    file_line { 'gitlab-runner-sentry_dsn':
      path    => '/etc/gitlab-runner/config.toml',
      line    => "sentry_dsn = \"${sentry_dsn}\"",
      match   => '^sentry_dsn = .+',
      require => Package[$package_name],
      notify  => Exec['gitlab-runner-restart'],
    }
  }

  exec { 'gitlab-runner-restart':
    command     => "/usr/bin/${package_name} restart",
    refreshonly => true,
    require     => Package[$package_name],
  }

  $_runners = $runners.keys
  gitlab_ci_runner::runner { $_runners:
    binary         => $package_name,
    default_config => $runner_defaults,
    runners_hash   => $runners,
    notify         => Exec['gitlab-runner-restart'],
  }
}
