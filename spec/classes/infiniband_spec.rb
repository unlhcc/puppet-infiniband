require 'spec_helper'

def shellvars
  {
    'IPOIB_LOAD'      => { 'value' => 'yes' },
    'SRP_LOAD'        => { 'value' => 'no' },
    'ISER_LOAD'       => { 'value' => 'no' },
    'RDS_LOAD'        => { 'value' => 'no' },
    'FIXUP_MTRR_REGS' => { 'value' => 'no' },
    'NFSoRDMA_LOAD'   => { 'value' => 'yes' },
    'NFSoRDMA_PORT'   => { 'value' => '2050' },
  }
end

describe 'infiniband' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts.merge({
          has_infiniband: true,
          memorysize_mb: '64399.75',
        })
      end

      let :interfaces_example do
        { 'ib0' => {'ipaddr' => '192.168.1.1', 'netmask'  => '255.255.255.0'} }
      end

      it { should create_class('infiniband') }
      it { should contain_class('infiniband::params') }

      it { should contain_anchor('infiniband::start').that_comes_before('Class[infiniband::install]') }
      it { should contain_class('infiniband::install').that_comes_before('Class[infiniband::config]') }
      it { should contain_class('infiniband::config').that_comes_before('Class[infiniband::service]') }
      it { should contain_class('infiniband::service').that_comes_before('Class[infiniband::providers]') }
      it { should contain_class('infiniband::providers').that_comes_before('Anchor[infiniband::end]') }
      it { should contain_anchor('infiniband::end') }

      context "infiniband::install" do
        it { should contain_yum__group('infiniband').with_ensure('present') }

        context 'extra_packages defined' do
          let(:params) {{ :extra_packages => ['foo'] }}

          it { should contain_package('foo') }
        end
      end

      context "infiniband::config" do
        it { should have_shellvar_resource_count(7) }

        shellvars.each_pair do |name,params|
          it do
            should contain_shellvar("infiniband #{name}").with({
              'ensure'  => 'present',
              'target'    => '/etc/rdma/rdma.conf',
              'variable'  => name,
              'value'     => params['value'],
            })
          end
        end

        it do
          should contain_file('/etc/modprobe.d/mlx4_core.conf').with({
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        end

        it do
          verify_contents(catalogue, '/etc/modprobe.d/mlx4_core.conf', [
            'options mlx4_core log_num_mtt=22 log_mtts_per_seg=3',
          ])
        end

        context 'when log_num_mtt => 26' do
          let(:params) {{ :manage_mlx4_core_options => true, :log_num_mtt => 26 }}

          it do
            verify_contents(catalogue, '/etc/modprobe.d/mlx4_core.conf', [
              'options mlx4_core log_num_mtt=26 log_mtts_per_seg=3',
            ])
          end
        end

        context 'when log_mtts_per_seg => 1' do
          let(:params) {{ :manage_mlx4_core_options => true, :log_mtts_per_seg => 1 }}

          it do
            verify_contents(catalogue, '/etc/modprobe.d/mlx4_core.conf', [
              'options mlx4_core log_num_mtt=24 log_mtts_per_seg=1',
            ])
          end
        end

        context "when manage_mlx4_core_options => false" do
          let(:params) {{ :manage_mlx4_core_options => false }}

          it { should_not contain_file('/etc/modprobe.d/mlx4_core.conf') }
        end
      end

      context "infiniband::service" do
        it do
          should contain_service('rdma').with({
            'ensure'      => 'running',
            'enable'      => 'true',
            'name'        => 'rdma',
            'hasstatus'   => 'true',
            'hasrestart'  => 'true',
            'before'      => 'Service[ibacm]',
          })
        end

        it do
          should contain_service('ibacm').with({
            'ensure'      => 'running',
            'enable'      => 'true',
            'name'        => 'ibacm',
            'hasstatus'   => 'true',
            'hasrestart'  => 'true',
          })
        end

        context "has_infiniband is false" do
          let :facts do
            facts.merge({has_infiniband: false})
          end

          it do
            should contain_service('rdma').with({
              'ensure'      => 'stopped',
              'enable'      => 'false',
            })
          end

          it do
            should contain_service('ibacm').with({
              'ensure'      => 'stopped',
              'enable'      => 'false',
            })
          end
        end
      end

      context "infiniband::providers" do
        it { should have_infiniband__interface_resource_count(0) }

        context "with parameter interfaces defined" do
          let(:params) {{ :interfaces => interfaces_example }}

          it { should have_infiniband__interface_resource_count(1) }

          it do
            should contain_infiniband__interface('ib0').with({
              'ipaddr'  => '192.168.1.1',
              'netmask' => '255.255.255.0',
            })
          end
        end
      end
    end
  end
end
