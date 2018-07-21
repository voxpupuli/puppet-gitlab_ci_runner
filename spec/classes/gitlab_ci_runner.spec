require 'spec-helper'

describe 'gitlab_ci_runner' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      it { is_expected.to compile }
    end
  end
end
