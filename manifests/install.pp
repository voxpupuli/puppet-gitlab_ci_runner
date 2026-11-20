# @summary Manages the package of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::install (
  $package_name   = $gitlab_ci_runner::package_name,
  $package_ensure = $gitlab_ci_runner::package_ensure,
) {
  assert_private()

  if $gitlab_ci_runner::manage_user {
    $_managehome = $gitlab_ci_runner::user_home ? {
      undef   => undef,
      default => true,
    }

    group { $gitlab_ci_runner::group:
      ensure => present,
      gid    => $gitlab_ci_runner::group_gid,
    }
    user { $gitlab_ci_runner::user:
      ensure     => present,
      uid        => $gitlab_ci_runner::user_uid,
      gid        => $gitlab_ci_runner::group,
      home       => $gitlab_ci_runner::user_home,
      managehome => $_managehome,
      shell      => $gitlab_ci_runner::user_shell,
    }
  }

  case $gitlab_ci_runner::install_method {
    'repo': {
      package { $package_name:
        ensure => $package_ensure,
      }

      if $gitlab_ci_runner::manage_user {
        # The package keeps an existing user and uses its home as the service's working directory
        User[$gitlab_ci_runner::user] -> Package[$package_name]
      }
    }
    'binary': {
      $_package_ensure = $package_ensure ? {
        'installed' => 'present',
        default  => $package_ensure,
      }
      archive { $gitlab_ci_runner::binary_path:
        ensure  => $_package_ensure,
        source  => $gitlab_ci_runner::binary_source,
        extract => false,
        creates => $gitlab_ci_runner::binary_path,
      }
      file { $gitlab_ci_runner::binary_path:
        ensure => file,
        mode   => '0755',
      }
    }
    default: {
      fail("Unsupported install method: ${gitlab_ci_runner::install_method}")
    }
  }
}
