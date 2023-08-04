# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'gitlab_ci_runner class' do
  # We run a sidecar Gitlab container next to acceptance tests.
  # See puppet-gitlab_ci_runner/scripts/start-gitlab.sh
  let(:registrationtoken) do
    File.read(File.expand_path('~/INSTANCE_TOKEN')).chomp
  end

  authtoken = nil
  context 'default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          manage_docker   => false,
          runners         => {
            test_runner => {}
          },
          runner_defaults => {
            url                => 'http://gitlab',
            registration-token => '#{registrationtoken}',
            executor           => 'shell',
          }
        }
        EOS
      end
    end

    describe package('gitlab-runner') do
      it { is_expected.to be_installed }
    end

    describe service('gitlab-runner') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe 'registration' do
      it 'registered the runner' do
        authtoken = shell("grep 'token = ' /etc/gitlab-runner/config.toml | cut -d '\"' -f2").stdout.chomp
        shell("/usr/bin/env curl -X POST --form 'token=#{authtoken}' http://gitlab/api/v4/runners/verify") do |r|
          expect(JSON.parse(r.stdout)).to include('token' => authtoken.chomp)
        end
      end
    end
  end

  context 'unregistering' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          manage_docker   => false,
          runners         => {
            test_runner => {
              ensure => absent,
            }
          },
          runner_defaults => {
            url                => 'http://gitlab',
            registration-token => '#{registrationtoken}',
            executor           => 'shell',
          }
        }
        EOS
      end
    end

    describe package('gitlab-runner') do
      it { is_expected.to be_installed }
    end

    describe service('gitlab-runner') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe 'registration' do
      it 'unregistered the runner' do
        shell("/usr/bin/env curl -X POST --form 'token=#{authtoken}' http://gitlab/api/v4/runners/verify") do |r|
          expect(JSON.parse(r.stdout)).to include('message' => '403 Forbidden')
        end
      end
    end
  end

  context 'using proxy parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          http_proxy      => 'http://squid:3128',
          manage_docker   => false,
          runners         => {
            test_runner => {}
          },
          runner_defaults => {
            url                => 'http://gitlab',
            registration-token => '#{registrationtoken}',
            executor           => 'shell',
          }
        }
        EOS
      end
    end

    describe package('gitlab-runner') do
      it { is_expected.to be_installed }
    end

    describe service('gitlab-runner') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe 'registration' do
      it 'registered the runner' do
        authtoken = shell("grep 'token = ' /etc/gitlab-runner/config.toml | cut -d '\"' -f2").stdout.chomp
        shell("/usr/bin/env curl -X POST --form 'token=#{authtoken}' http://gitlab/api/v4/runners/verify") do |r|
          expect(JSON.parse(r.stdout)).to include('token' => authtoken.chomp)
        end
      end
    end
  end
end
