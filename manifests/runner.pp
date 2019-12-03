# @summary This module installs and configures Gitlab CI Runners.
#
# @param binary
#   The name of the Gitlab runner binary.
# @param runners_hash
#   Hash with configuration for runners.
# @param default_config
#   Hash with default configration for runners. This will be merged with the runners_hash config.
#
define gitlab_ci_runner::runner (
  String $binary,
  Hash $runners_hash,
  Hash $default_config = {},
) {
  # Set resource name as name for the runner and replace under_scores for later use
  $title_no_underscore = regsubst($title, '_', '-', 'G')
  $name_config = {
    name => $title_no_underscore,
  }
  $_default_config = merge($default_config, $name_config)
  $config = $runners_hash[$title]

  # Pull out ensure key, which shouldn't be passed to command
  $ensure = $config['ensure']
  $config_without_ensure = delete($config, 'ensure')

  # Merge default config with actual config
  $_config = merge($_default_config, $config_without_ensure)

  # Convert configuration into a string
  $parameters_array = join_keys_to_values($_config, '=')
  $parameters_array_no_underscores = regsubst($parameters_array, '_', '-', 'G')
  $parameters_array_dashes = prefix($parameters_array_no_underscores, '--')
  $parameters_string = join($parameters_array_dashes, ' ')

  $runner_name = $_config['name']
  $toml_file = '/etc/gitlab-runner/config.toml'

  if $ensure == 'absent' {
      # Execute gitlab ci multirunner unregister
      exec {"Unregister_runner_${title}":
        command => "/usr/bin/${binary} unregister -n ${runner_name}",
        onlyif  => "/bin/grep \'${runner_name}\' ${toml_file}",
      }
    } else {
      # Execute gitlab ci multirunner register
      exec {"Register_runner_${title}":
        command => "/usr/bin/${binary} register -n ${parameters_string}",
        unless  => "/bin/grep \'${runner_name}\' ${toml_file}",
      }
    }

}
