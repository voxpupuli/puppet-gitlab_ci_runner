# @summary This module installs and configures Gitlab CI Runners.
#
# @example Simple runner registration
#		class { 'gitlab_ci_runner':
#		  runners => {
#		 	 example_runner => {
#		 		 'registration-token' => 'gitlab-token',
#		 		 'url'                => 'https://gitlab.com',
#		 		 'tag-list'           => 'docker,aws',
#		 	 },
#		  },
#		}
#
# @param runners
#   Hashkeys are used as $title in runners.pp. The subkeys have to be named as the parameter names from ´gitlab-runner register´ command cause they're later joined to one entire string using 2 hyphen to look like shell command parameters. See ´https://docs.gitlab.com/runner/register/#one-line-registration-command´ for details.
# @param runner_defaults
#   A hash with defaults which will be later merged with $runners.
# @param xz_package_name
#   The name of the 'xz' package. Needed for local docker installations.
# @param concurrent
#   Limits how many jobs globally can be run concurrently. The most upper limit of jobs using all defined runners. 0 does not mean unlimited!
# @param builds_dir
#   Absolute path to a directory where builds will be stored in context of selected executor (Locally, Docker, SSH).
# @param cache_dir
#   Absolute path to a directory where build caches will be stored in context of selected executor (locally, Docker, SSH). If the docker executor is used, this directory needs to be included in its volumes parameter.
# @param metrics_server
#   (Deprecated) [host]:<port> to enable metrics server as described in https://docs.gitlab.com/runner/monitoring/README.html#configuration-of-the-metrics-http-server.
# @param listen_address
#   Address (<host>:<port>) on which the Prometheus metrics HTTP server should be listening.
# @param sentry_dsn
#   Enable tracking of all system level errors to sentry.
# @param manage_docker
#   If docker should be installs (uses the puppetlabs-docker).
# @param manage_repo
#   If the repository should be managed.
# @param package_ensure
#   The package 'ensure' state.
# @param package_name
#   The name of the package.
# @param repo_base_url
#   The base repository url.
# @param repo_keyserver
#   The keyserver which should be used to get the repository key.
# @param config_path
#   The path to the config file of Gitlab runner.
#
class gitlab_ci_runner (
  Hash                       $runners,
  Hash                       $runner_defaults,
  String                     $xz_package_name,
  Optional[Integer]          $concurrent               = undef,
  Optional[String]           $builds_dir               = undef,
  Optional[String]           $cache_dir                = undef,
  Optional[Pattern[/.*:.+/]] $metrics_server           = undef,
  Optional[Pattern[/.*:.+/]] $listen_address           = undef,
  Optional[String]           $sentry_dsn               = undef,
  Boolean                    $manage_docker            = true,
  Boolean                    $manage_repo              = true,
  String                     $package_ensure           = installed,
  String                     $package_name             = 'gitlab-runner',
  Stdlib::HTTPUrl            $repo_base_url            = 'https://packages.gitlab.com',
  Stdlib::Fqdn               $repo_keyserver           = 'keys.gnupg.net',
  String                     $config_path              = '/etc/gitlab-runner/config.toml',
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

  file { $config_path: # ensure config exists
    ensure  => 'present',
    replace => 'no',
    content => '',
  }

  if $concurrent != undef {
    file_line { 'gitlab-runner-concurrent':
      path    => $config_path,
      line    => "concurrent = ${concurrent}",
      match   => '^concurrent = \d+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }

  if $metrics_server {
    file_line { 'gitlab-runner-metrics-server':
      path    => $config_path,
      line    => "metrics_server = \"${metrics_server}\"",
      match   => '^metrics_server = .+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }
  if $listen_address {
    file_line { 'gitlab-runner-listen-address':
      path    => $config_path,
      line    => "listen_address = \"${listen_address}\"",
      match   => '^listen_address = .+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }
  if $builds_dir {
    file_line { 'gitlab-runner-builds_dir':
      path    => $config_path,
      line    => "builds_dir = \"${builds_dir}\"",
      match   => '^builds_dir = .+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }
  if $cache_dir {
    file_line { 'gitlab-runner-cache_dir':
      path    => $config_path,
      line    => "cache_dir = \"${cache_dir}\"",
      match   => '^cache_dir = .+',
      require => Package[$package_name],
      notify  => Service[$package_name],
    }
  }
  if $sentry_dsn {
    file_line { 'gitlab-runner-sentry_dsn':
      path    => $config_path,
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
