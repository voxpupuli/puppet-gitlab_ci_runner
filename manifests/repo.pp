# @summary Manages the repository for Gitlab runner
#
# @api private
#
class gitlab_ci_runner::repo (
  $repo_base_url  = $gitlab_ci_runner::repo_base_url,
  $repo_keyserver = $gitlab_ci_runner::repo_keyserver,
  $package_name   = $gitlab_ci_runner::package_name,
) {
  assert_private()
  case $facts['os']['family'] {
    'Debian': {
      apt::source { 'apt_gitlabci':
        comment  => 'GitlabCI Runner Repo',
        location => "${repo_base_url}/runner/${package_name}/${facts['os']['distro']['id'].downcase}/",
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
      fail ("gitlab_ci_runner::repo isn't suppored for ${facts['os']['family']}!")
    }
  }
}
