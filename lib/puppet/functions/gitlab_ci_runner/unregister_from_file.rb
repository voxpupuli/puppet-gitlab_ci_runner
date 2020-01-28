require_relative '../../../puppet_x/gitlab/runner.rb'

# A function that unregisters a Gitlab runner from a Gitlab instance, if the local token is there.
# This is meant to be used in conjunction with the gitlab_ci_runner::register_to_file function.
Puppet::Functions.create_function(:'gitlab_ci_runner::unregister_from_file') do
  # @param url The url to your Gitlab instance. Please only provide the host part (e.g https://gitlab.com)
  # @param runner_name The name of the runner. Use as identifier for the retrived auth token.
  # @param filename The filename where the token should be saved.
  # @example Using it as a Deferred function with a file resource
  #   file { '/etc/gitlab-runner/auth-token-testrunner':
  #     file    => absent,
  #     content => Deferred('gitlab_ci_runner::unregister_from_file', ['http://gitlab.example.org'])
  #   }
  #
  dispatch :unregister_to_file do
    # We use only core data types because others aren't synced to the agent.
    param 'String[1]', :url
    param 'String[1]', :runner_name
    optional_param 'String[1]', :filename
  end

  def unregister_to_file(url, runner_name, filename = "/etc/gitlab-runner/auth-token-#{runner_name}")
    return unless File.exist?(filename)

    authtoken = File.read(filename).strip
    PuppetX::Gitlab::Runner.unregister(url, token: authtoken) unless Puppet.settings[:noop]
  end
end
