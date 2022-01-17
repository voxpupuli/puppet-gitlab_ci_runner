require 'spec_helper'

describe 'gitlab_ci_runner', type: :class do
  let(:undef_value) do
    Puppet::Util::Package.versioncmp(Puppet.version, '6.0.0') < 0 ? :undef : nil
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      before do
        # Make 'gitlab_ci_runner::register_to_file' think that we already have a token on disk
        # This ensure the function won't call a Gitlab server to try getting the auth token.
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/etc/gitlab-runner/auth-token-test_runner').and_return(true)
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with('/etc/gitlab-runner/auth-token-test_runner').and_return('authtoken')
      end
      let(:facts) do
        facts
      end
      let(:params) do
        {
          'runner_defaults' => {
            'url' => 'https://git.example.com/ci',
            'registration-token' => '1234567890abcdef',
            'executor' => 'shell'
          },
          'runners' => {
            'test_runner' => {}
          }
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.not_to contain_class('docker') }
      it { is_expected.not_to contain_class('docker::images') }
      it { is_expected.to contain_package('gitlab-runner') }
      it { is_expected.to contain_service('gitlab-runner') }
      it { is_expected.to contain_class('gitlab_ci_runner::install') }
      it do
        is_expected.to contain_class('gitlab_ci_runner::config').
          that_requires('Class[gitlab_ci_runner::install]').
          that_notifies('Class[gitlab_ci_runner::service]')
      end
      it { is_expected.to contain_class('gitlab_ci_runner::service') }

      it do
        is_expected.to contain_concat('/etc/gitlab-runner/config.toml').
          with(
            ensure: 'present',
            owner: 'root',
            group: 'root',
            mode: '0444',
            ensure_newline: true
          )
      end

      it do
        is_expected.to contain_concat__fragment('/etc/gitlab-runner/config.toml - header').
          with(
            target: '/etc/gitlab-runner/config.toml',
            order: 0,
            content: '# MANAGED BY PUPPET'
          )
      end

      describe 'ca_file' do
        context 'without ca_file' do
          it { is_expected.to contain_gitlab_ci_runner__runner('test_runner').without(['ca_file']) }
        end

        context 'with ca_file' do
          let(:params) { super().merge(ca_file: '/path/to/ca_file') }

          it { is_expected.to contain_gitlab_ci_runner__runner('test_runner').with_ca_file('/path/to/ca_file') }
        end
      end

      describe 'runner ensure' do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:read).and_call_original
          allow(File).to receive(:exist?).with('/etc/gitlab-runner/auth-token-runner_with_ensure_present').and_return(true)
          allow(File).to receive(:read).with('/etc/gitlab-runner/auth-token-runner_with_ensure_present').and_return('authtoken')
          allow(File).to receive(:exist?).with('/etc/gitlab-runner/auth-token-runner_with_ensure_absent').and_return(false)
        end
        let(:params) do
          {
            runner_defaults: {
              'url' => 'https://git.example.com/ci',
              'registration-token' => '1234567890abcdef',
              'executor' => 'shell'
            },
            runners: {
              'runner_with_ensure_absent' => { 'ensure' => 'absent' },
              'runner_with_ensure_present' => { 'ensure' => 'present' },
            }
          }
        end

        it { is_expected.to contain_gitlab_ci_runner__runner('runner_with_ensure_present').with_ensure('present') }
        it { is_expected.to contain_gitlab_ci_runner__runner('runner_with_ensure_absent').with_ensure('absent') }
      end

      context 'with config permissions' do
        let(:params) do
          {
            'runner_defaults' => {},
            'runners' => {},
            'config_owner' => 'gitlab-runner',
            'config_group' => 'gitlab-runner',
            'config_mode' => '0640'
          }
        end

        it do
          is_expected.to contain_concat('/etc/gitlab-runner/config.toml').with('owner' => 'gitlab-runner',
                                                                               'group' => 'gitlab-runner',
                                                                               'mode'  => '0640')
        end
      end

      context 'with manage_config_dir => true' do
        let(:params) do
          {
            'runner_defaults' => {},
            'runners' => {},
            'manage_config_dir' => true
          }
        end

        it do
          is_expected.to contain_file('/etc/gitlab-runner').with('ensure' => 'directory')
        end
      end

      context 'with config dir permissions' do
        let(:params) do
          {
            'runner_defaults' => {},
            'runners' => {},
            'manage_config_dir' => true,
            'config_owner' => 'gitlab-runner',
            'config_group' => 'gitlab-runner',
            'config_dir_mode' => '0750'
          }
        end

        it do
          is_expected.to contain_file('/etc/gitlab-runner').with('ensure' => 'directory',
                                                                 'owner' => 'gitlab-runner',
                                                                 'group' => 'gitlab-runner',
                                                                 'mode'  => '0750')
        end
      end

      context 'with concurrent => 10' do
        let(:params) do
          {
            'concurrent' => 10
          }
        end

        it do
          is_expected.to contain_concat__fragment('/etc/gitlab-runner/config.toml - global options').
            with(
              target: '/etc/gitlab-runner/config.toml',
              order: 1,
              content: %r{concurrent = 10}
            )
        end
      end

      context 'with log_level => error' do
        let(:params) do
          {
            'log_level' => 'error'
          }
        end

        it do
          is_expected.to contain_concat__fragment('/etc/gitlab-runner/config.toml - global options').
            with(
              target: '/etc/gitlab-runner/config.toml',
              order: 1,
              content: %r{log_level = "error"}
            )
        end
      end

      context 'with log_format => json' do
        let(:params) do
          {
            'log_format' => 'json'
          }
        end

        it do
          is_expected.to contain_concat__fragment('/etc/gitlab-runner/config.toml - global options').
            with(
              target: '/etc/gitlab-runner/config.toml',
              order: 1,
              content: %r{log_format = "json"}
            )
        end
      end

      context 'with check_interval => 6' do
        let(:params) do
          {
            'check_interval' => 6
          }
        end

        it do
          is_expected.to contain_concat__fragment('/etc/gitlab-runner/config.toml - global options').
            with(
              target: '/etc/gitlab-runner/config.toml',
              order: 1,
              content: %r{check_interval = 6}
            )
        end
      end

      context 'with sentry_dsn => https://123abc@localhost/1' do
        let(:params) do
          {
            'sentry_dsn' => 'https://123abc@localhost/1'
          }
        end

        it do
          is_expected.to contain_concat__fragment('/etc/gitlab-runner/config.toml - global options').
            with(
              target: '/etc/gitlab-runner/config.toml',
              order: 1,
              content: %r{sentry_dsn = "https://123abc@localhost/1"}
            )
        end
      end

      context 'with listen_address => localhost:9252' do
        let(:params) do
          {
            'listen_address' => 'localhost:9252'
          }
        end

        it do
          is_expected.to contain_concat__fragment('/etc/gitlab-runner/config.toml - global options').
            with(
              target: '/etc/gitlab-runner/config.toml',
              order: 1,
              content: %r{listen_address = "localhost:9252"}
            )
        end
      end

      context 'with session_server' do
        context 'with session_server => { listen_address => "[::]:8093", advertise_address => "runner-host-name.tld:8093"}' do
          let(:params) do
            {
              'session_server' => {
                listen_address: '[::]:8093',
                advertise_address: 'runner-host-name.tld:8093',
              }
            }
          end

          it do
            verify_concat_fragment_exact_contents(
              catalogue,
              '/etc/gitlab-runner/config.toml - global options',
              [
                '[session_server]',
                'listen_address = "[::]:8093"',
                'advertise_address = "runner-host-name.tld:8093"',
              ]
            )
          end
        end

        context 'with session_server => { listen_address => "[::]:8093", advertise_address => "runner-host-name.tld:8093", session_timeout => 1234 }' do
          let(:params) do
            {
              'session_server' => {
                listen_address: '[::]:8093',
                advertise_address: 'runner-host-name.tld:8093',
                session_timeout: 1234,
              }
            }
          end

          it do
            verify_concat_fragment_exact_contents(
              catalogue,
              '/etc/gitlab-runner/config.toml - global options',
              [
                '[session_server]',
                'listen_address = "[::]:8093"',
                'advertise_address = "runner-host-name.tld:8093"',
                'session_timeout = 1234'
              ]
            )
          end
        end
      end

      # puppetlabs-docker doesn't support CentOS 6 anymore.
      unless facts[:os]['name'] == 'CentOS' && facts[:os]['release']['major'] == '6'
        context 'with manage_docker => true' do
          let(:params) do
            {
              manage_docker: true
            }
          end

          it { is_expected.to compile }

          it { is_expected.to contain_class('docker') }
          it do
            is_expected.to contain_class('docker::images').
              with(
                images: {
                  'ubuntu_focal' => {
                    'image'     => 'ubuntu',
                    'image_tag' => 'focal'
                  }
                }
              )
          end
        end
      end

      context 'with manage_repo => true' do
        let(:params) do
          super().merge(
            manage_repo: true
          )
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('gitlab_ci_runner::repo') }

        case facts[:os]['family']
        when 'Debian'
          it do
            is_expected.to contain_apt__source('apt_gitlabci').
              with(
                comment: 'GitlabCI Runner Repo',
                location: "https://packages.gitlab.com/runner/gitlab-runner/#{facts[:lsbdistid].downcase}/",
                repos: 'main',
                key: {
                  'id' => 'F6403F6544A38863DAA0B6E03F01618A51312F3F',
                  'server' => undef_value,
                  'content' => undef_value,
                  'source' => undef_value,
                  'weak_ssl' => false
                },
                include: {
                  'src' => false,
                  'deb' => true
                }
              )
          end
        when 'RedHat'
          os_release_version = if facts[:os]['name'] == 'Amazon'
                                 if facts[:os]['release']['major'] == '2'
                                   '7'
                                 else
                                   '6'
                                 end
                               else
                                 '$releasever'
                               end

          it do
            is_expected.to contain_yumrepo('runner_gitlab-runner').
              with(
                ensure: 'present',
                baseurl: "https://packages.gitlab.com/runner/gitlab-runner/el/#{os_release_version}/\$basearch",
                descr: 'runner_gitlab-runner',
                enabled: '1',
                gpgcheck: '0',
                gpgkey: 'https://packages.gitlab.com/gpg.key',
                repo_gpgcheck: '1',
                sslcacert: '/etc/pki/tls/certs/ca-bundle.crt',
                sslverify: '1'
              )
          end

          it do
            is_expected.to contain_yumrepo('runner_gitlab-runner-source').
              with(
                ensure: 'present',
                baseurl: "https://packages.gitlab.com/runner/gitlab-runner/el/#{os_release_version}/SRPMS",
                descr: 'runner_gitlab-runner-source',
                enabled: '1',
                gpgcheck: '0',
                gpgkey: 'https://packages.gitlab.com/gpg.key',
                repo_gpgcheck: '1',
                sslcacert: '/etc/pki/tls/certs/ca-bundle.crt',
                sslverify: '1'
              )
          end
        end
      end

      if facts[:os]['family'] == 'Debian'
        # <= v3.0.0
        context 'with manage_repo => true and repo_keyserver => keys.gnupg.net' do
          let(:params) do
            super().merge(
              manage_repo: true,
              repo_keyserver: 'keys.gnupg.net'
            )
          end

          it { is_expected.to compile }
          it { is_expected.to contain_class('gitlab_ci_runner::repo') }

          it do
            is_expected.to contain_apt__source('apt_gitlabci').with_key('id' => 'F6403F6544A38863DAA0B6E03F01618A51312F3F', 'server' => 'keys.gnupg.net', 'content' => undef_value, 'source' => undef_value, 'weak_ssl' => false)
          end
        end
      end
      if facts[:os]['family'] == 'Debian'
        context 'with manage_repo => true and repo_keysource => http://path.to/gpg.key' do
          let(:params) do
            super().merge(
              manage_repo: true,
              repo_keysource: 'http://path.to/gpg.key'
            )
          end

          it { is_expected.to compile }
          it { is_expected.to contain_class('gitlab_ci_runner::repo') }

          it do
            is_expected.to contain_apt__source('apt_gitlabci').with_key('id' => 'F6403F6544A38863DAA0B6E03F01618A51312F3F', 'server' => undef_value, 'content' => undef_value, 'source' => 'http://path.to/gpg.key', 'weak_ssl' => false)
          end
        end
      end
      if facts[:os]['family'] == 'Debian'
        context 'with manage_repo => true and repo_keycontent => "somebase64encodedContent"' do
          let(:params) do
            super().merge(
              manage_repo: true,
              repo_keycontent: 'somebase64encodedContent'
            )
          end

          it { is_expected.to compile }
          it { is_expected.to contain_class('gitlab_ci_runner::repo') }

          it do
            is_expected.to contain_apt__source('apt_gitlabci').with_key('id' => 'F6403F6544A38863DAA0B6E03F01618A51312F3F', 'server' => undef_value, 'content' => 'somebase64encodedContent', 'source' => undef_value, 'weak_ssl' => false)
          end
        end

        # allowed > 3.0.0 (see issue #101)
        context 'with manage_repo => true and repo_keyserver => hkp://keys.gnupg.net:80' do
          let(:params) do
            super().merge(
              manage_repo: true,
              repo_keyserver: 'hkp://keys.gnupg.net:80'
            )
          end

          it { is_expected.to compile }
          it { is_expected.to contain_class('gitlab_ci_runner::repo') }

          it do
            is_expected.to contain_apt__source('apt_gitlabci').with_key('id' => 'F6403F6544A38863DAA0B6E03F01618A51312F3F', 'server' => 'hkp://keys.gnupg.net:80')
          end
        end
        context 'with manage_repo => true and repo_keyserver => https://keys.gnupg.net:88' do
          let(:params) do
            super().merge(
              manage_repo: true,
              repo_keyserver: 'https://keys.gnupg.net:88'
            )
          end

          it { is_expected.to compile }
          it { is_expected.to contain_class('gitlab_ci_runner::repo') }

          it do
            is_expected.to contain_apt__source('apt_gitlabci').with_key('id' => 'F6403F6544A38863DAA0B6E03F01618A51312F3F', 'server' => 'https://keys.gnupg.net:88')
          end
        end
      end
    end
  end
end
