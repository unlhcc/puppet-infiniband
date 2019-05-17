require 'spec_helper_acceptance'

describe 'infiniband class' do
  context 'default parameters' do
    it 'runs successfully' do
      pp = <<-EOS
        class { 'infiniband': }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('yum grouplist hidden infiniband') do
      its(:stdout) { is_expected.to match %r{Installed} }
    end

    describe service('rdma') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end

    describe service('ibacm') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end
  end
end
