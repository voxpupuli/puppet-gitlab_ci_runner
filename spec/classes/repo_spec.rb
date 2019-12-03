require 'spec_helper'

describe 'gitlab_ci_runner::repo' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      let(:pre_condition) do
        <<-MANIFEST
          # Fake assert_private function from stdlib to not fail within this test
          function assert_private () { }
         MANIFEST
      end

      context 'with default params' do
        let(:params) do
          {
            package_name: 'gitlab-runner',
            repo_base_url: 'https://packages.gitlab.com',
            repo_keyserver: 'keys.gnupg.net'
          }
        end

        let(:pre_condition) do
          "#{super()}
					# Ensure depencencies of the repository is satified
          package { 'gitlab-runner': }"
        end

        it { is_expected.to compile }

        case os_facts[:os]['family']
        when 'Debian'
          it do
            is_expected.to contain_apt__source('apt_gitlabci').
              with(
                comment: 'GitlabCI Runner Repo',
                location: "https://packages.gitlab.com/runner/gitlab-runner/#{facts[:lsbdistid].downcase}/",
                repos: 'main',
                key: {
                  'id' => '1A4C919DB987D435939638B914219A96E15E78F4',
                  'server' => 'keys.gnupg.net'
                },
                include: {
                  'src' => false,
                  'deb' => true
                }
              )
          end
        when 'RedHat'
          it do
            is_expected.to contain_yumrepo('runner_gitlab-runner').
              with(
                ensure: 'present',
                baseurl: "https://packages.gitlab.com/runner/gitlab-runner/el/\$releasever/\$basearch",
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
                baseurl: "https://packages.gitlab.com/runner/gitlab-runner/el/\$releasever/SRPMS",
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
    end
  end
end
