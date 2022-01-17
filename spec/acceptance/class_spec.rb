require 'spec_helper_acceptance'

describe 'gitlab_ci_runner class' do
  context 'default parameters' do
    it 'idempotently with no errors' do
      pp = <<-EOS
      include gitlab_ci_runner
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('gitlab-runner') do
      it { is_expected.to be_installed }
    end

    describe service('gitlab-runner') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain '# MANAGED BY PUPPET' }
    end
  end

  context 'concurrent => 20' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          concurrent => 20,
        }
        EOS
      end
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain 'concurrent = 20' }
    end
  end

  context 'log_level => error' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          log_level => 'error',
        }
        EOS
      end
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain 'log_level = "error"' }
    end
  end

  context 'log_format => text' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          log_format => 'text',
        }
        EOS
      end
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain 'log_format = "text"' }
    end
  end

  context 'check_interval => 42' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          check_interval => 42,
        }
        EOS
      end
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain 'check_interval = 42' }
    end
  end

  context 'sentry_dsn => https://123abc@localhost/1' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          sentry_dsn => 'https://123abc@localhost/1',
        }
        EOS
      end
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain 'sentry_dsn = "https://123abc@localhost/1"' }
    end
  end

  context 'listen_address => localhost:9252' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          listen_address => 'localhost:9252',
        }
        EOS
      end
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain 'listen_address = "localhost:9252"' }
    end

    describe port('9252') do
      it { is_expected.to be_listening }
    end
  end

  context 'with session_server => { listen_address => "[::]:8093", advertise_address => "runner-host-name.tld:8093", session_timeout => 1234 }' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-EOS
        class { 'gitlab_ci_runner':
          session_server => {
            listen_address    => "[::]:8093",
            advertise_address => "runner-host-name.tld:8093",
            session_timeout   => 1234,
          }
        }
        EOS
      end
    end

    describe file('/etc/gitlab-runner/config.toml') do
      it { is_expected.to contain '[session_server]' }
      it { is_expected.to contain 'listen_address = "[::]:8093"' }
      it { is_expected.to contain 'advertise_address = "runner-host-name.tld:8093"' }
      it { is_expected.to contain 'session_timeout = 1234' }
    end

    describe port('8093') do
      it { is_expected.to be_listening }
    end
  end
end
