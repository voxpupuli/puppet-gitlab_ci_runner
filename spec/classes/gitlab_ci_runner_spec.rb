require 'spec_helper'

describe 'gitlab_ci_runner', type: :class do
  package_name = 'gitlab-runner'
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:params) do
        {
          'runner_defaults' => {
            'url' => 'https://git.example.com/ci',
            'registration-token' => '1234567890abcdef',
            'executor' => 'docker',
            'docker-image' => 'ubuntu:trusty'
          },
          'runners' => {
            'test_runner' => {}
          }
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('docker::images') }
      it { is_expected.to contain_package('gitlab-runner') }
      it { is_expected.to contain_exec('gitlab-runner-restart').that_requires("Package[#{package_name}]") }
      it do
        is_expected.to contain_exec('gitlab-runner-restart').with('command' => "/usr/bin/#{package_name} restart",
                                                                  'refreshonly' => true)
      end
      it { is_expected.to contain_gitlab_ci_runner__runner('test_runner').that_requires('Exec[gitlab-runner-restart]') }
      it { is_expected.not_to contain_file_line('gitlab-runner-concurrent') }
      it { is_expected.not_to contain_file_line('gitlab-runner-builds_dir') }

      context 'with concurrent => 10' do
        let(:params) do
          {
            'runner_defaults' => {},
            'runners' => {},
            'concurrent' => 10
          }
        end

        it { is_expected.to contain_file_line('gitlab-runner-concurrent').that_requires("Package[#{package_name}]") }
        it { is_expected.to contain_file_line('gitlab-runner-concurrent').that_notifies('Exec[gitlab-runner-restart]') }
        it do
          is_expected.to contain_file_line('gitlab-runner-concurrent').with('path' => '/etc/gitlab-runner/config.toml',
                                                                            'line'  => 'concurrent = 10',
                                                                            'match' => '^concurrent = \d+')
        end
      end
      context 'with metrics_server => localhost:9252' do
        let(:params) do
          {
            'runner_defaults' => {},
            'runners' => {},
            'metrics_server' => 'localhost:9252'
          }
        end

        it { is_expected.to contain_file_line('gitlab-runner-metrics-server').that_requires("Package[#{package_name}]") }
        it { is_expected.to contain_file_line('gitlab-runner-metrics-server').that_notifies('Exec[gitlab-runner-restart]') }
        it do
          is_expected.to contain_file_line('gitlab-runner-metrics-server').with('path' => '/etc/gitlab-runner/config.toml',
                                                                                'line'  => 'metrics_server = "localhost:9252"',
                                                                                'match' => '^metrics_server = .+')
        end
      end
      context 'with builds_dir => /tmp/builds_dir' do
        let(:params) do
          {
            'runner_defaults' => {},
            'runners' => {},
            'builds_dir' => '/tmp/builds_dir'
          }
        end

        it { is_expected.to contain_file_line('gitlab-runner-builds_dir').that_requires("Package[#{package_name}]") }
        it { is_expected.to contain_file_line('gitlab-runner-builds_dir').that_notifies('Exec[gitlab-runner-restart]') }
        it do
          is_expected.to contain_file_line('gitlab-runner-builds_dir').with('path' => '/etc/gitlab-runner/config.toml',
                                                                            'line'  => 'builds_dir = "/tmp/builds_dir"',
                                                                            'match' => '^builds_dir = .+')
        end
      end
      context 'with cache_dir => /tmp/cache_dir' do
        let(:params) do
          {
            'runner_defaults' => {},
            'runners' => {},
            'cache_dir' => '/tmp/cache_dir'
          }
        end

        it { is_expected.to contain_file_line('gitlab-runner-cache_dir').that_requires("Package[#{package_name}]") }
        it { is_expected.to contain_file_line('gitlab-runner-cache_dir').that_notifies('Exec[gitlab-runner-restart]') }
        it do
          is_expected.to contain_file_line('gitlab-runner-cache_dir').with('path' => '/etc/gitlab-runner/config.toml',
                                                                           'line'  => 'cache_dir = "/tmp/cache_dir"',
                                                                           'match' => '^cache_dir = .+')
        end
      end
    end
  end
end
