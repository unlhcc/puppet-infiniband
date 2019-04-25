require 'spec_helper_acceptance'

describe 'infiniband class' do
  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'infiniband': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe command('yum grouplist hidden infiniband') do
      its(:stdout) { should match /Installed/ }
    end

    describe service('rdma') do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe service('ibacm') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end
end
