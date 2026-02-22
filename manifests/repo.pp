# @summary Manages the repository for Gitlab runner
#
# @api private
#
class gitlab_ci_runner::repo (
  $repo_base_url     = $gitlab_ci_runner::repo_base_url,
  $repo_keyserver    = $gitlab_ci_runner::repo_keyserver,
  $repo_keysource    = $gitlab_ci_runner::repo_keysource,
  $package_keysource = $gitlab_ci_runner::package_keysource,
  $package_gpgcheck  = $gitlab_ci_runner::package_gpgcheck,
  $package_name      = $gitlab_ci_runner::package_name,
) {
  assert_private()
  case $facts['os']['family'] {
    'Debian': {
      apt::keyring { 'apt_gitlabci':
        source => $repo_keysource,
        name   => 'gitlab_ci_runner.asc',
      }
      apt::source { 'apt_gitlabci':
        source_format => 'sources',
        comment       => 'GitlabCI Runner Repo',
        location      => ["${repo_base_url}/runner/${package_name}/${facts['os']['distro']['id'].downcase}/",],
        keyring       => '/etc/apt/keyrings/gitlab_ci_runner.asc',
        repos         => ['main',],
        types         => ['deb',],
        require       => Apt::Keyring['apt_gitlabci'],
      }
      Apt::Source['apt_gitlabci'] -> Package[$package_name]
      Exec['apt_update'] -> Package[$package_name]
    }
    'RedHat': {
      if $facts['os']['name'] == 'Amazon' {
        if $facts['os']['release']['major'] == '2' { # Amazon Linux 2 is based off of CentOS 7
          $base_url = "${repo_base_url}/runner/${package_name}/el/7/\$basearch"
          $source_base_url = "${repo_base_url}/runner/${package_name}/el/7/SRPMS"
        } else { # Amazon Linux 1 is based off of CentOS 6 but os.release.major will differ
          $base_url = "${repo_base_url}/runner/${package_name}/el/6/\$basearch"
          $source_base_url = "${repo_base_url}/runner/${package_name}/el/6/SRPMS"
        }
      } else {
        $base_url = "${repo_base_url}/runner/${package_name}/el/\$releasever/\$basearch"
        $source_base_url = "${repo_base_url}/runner/${package_name}/el/\$releasever/SRPMS"
      }

      $_gpgkeys = [$repo_keysource,$package_keysource].delete_undef_values.join(' ')
      yumrepo { "runner_${package_name}":
        ensure        => 'present',
        baseurl       => $base_url,
        descr         => "runner_${package_name}",
        enabled       => '1',
        gpgcheck      => String(Integer($package_gpgcheck)),
        gpgkey        => $_gpgkeys,
        repo_gpgcheck => '1',
        sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
        sslverify     => '1',
      }

      yumrepo { "runner_${package_name}-source":
        ensure        => 'present',
        baseurl       => $source_base_url,
        descr         => "runner_${package_name}-source",
        enabled       => '1',
        gpgcheck      => String(Integer($package_gpgcheck)),
        gpgkey        => $_gpgkeys,
        repo_gpgcheck => '1',
        sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
        sslverify     => '1',
      }
    }
    default: {
      fail ("gitlab_ci_runner::repo isn't suppored for ${facts['os']['family']}!")
    }
  }
}
