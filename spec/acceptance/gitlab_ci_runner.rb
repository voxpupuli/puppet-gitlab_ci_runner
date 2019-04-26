require 'spec_helper_acceptance'

describe 'gitlab_ci_runner class' do
  context 'default parameters' do
    it 'idempotently with no errors' do
      pp = <<-EOS
      class { 'gitlab_ci_runner':
        runners         => {
          test_runner => {}
        },
        runner_defaults => {
          url                => 'https://git.example.com/ci',
          registration-token => '1234567890abcdef',
          executor           => 'docker',
          docker-image       => 'ubuntu:trusty'
        }
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)

      shell('sleep 15') # give it some time to start up
    end

    describe package('gitlab-runner') do
      it { is_expected.to be_installed }
    end
  end
end
