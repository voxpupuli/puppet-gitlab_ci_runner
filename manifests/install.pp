# @summary Manages the package of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::install (
  $package_name   = $gitlab_ci_runner::package_name,
  $package_ensure = $gitlab_ci_runner::package_ensure,
) {
  assert_private()

  case $gitlab_ci_runner::install_method {
    'repo': {
      package { $package_name:
        ensure => $package_ensure,
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
    }
    default: {
      fail("Unsupported install method: ${gitlab_ci_runner::install_method}")
    }
  }
}
