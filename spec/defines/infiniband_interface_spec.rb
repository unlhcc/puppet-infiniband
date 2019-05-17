require 'spec_helper'

describe 'infiniband::interface' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts.merge(has_infiniband: true,
                    memorysize_mb: '64399.75')
      end

      let :title do
        'ib0'
      end

      let :default_params do
        {
          ipaddr: '192.168.1.1',
          netmask: '255.255.255.0',
        }
      end

      let :params do
        default_params
      end

      it { is_expected.to contain_class('network') }

      it do
        is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with('ensure' => 'present',
                                                                                     'owner'   => 'root',
                                                                                     'group'   => 'root',
                                                                                     'mode'    => '0644')
      end

      it do
        is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0') \
          .with_content(my_fixture_read('ifcfg-ib0_with_connected_mode'))
      end

      context 'ensure => absent' do
        let :params do
          default_params.merge(ensure: 'absent')
        end

        it { is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with_ensure('absent') }
      end

      context 'enable => false' do
        let :params do
          default_params.merge(enable: false)
        end

        it { is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with_content(my_fixture_read('ifcfg-ib0_with_onboot_no')) }
      end

      context 'connected_mode => no' do
        let :params do
          default_params.merge(connected_mode: 'no')
        end

        it { is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with_content(my_fixture_read('ifcfg-ib0_without_connected_mode')) }
      end

      context 'mtu => 65520' do
        let :params do
          default_params.merge(mtu: 65_520)
        end

        it { is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0'). with_content(my_fixture_read('ifcfg-ib0_with_mtu')) }
      end

      context 'gateway => 192.168.1.254' do
        let :params do
          default_params.merge(gateway: '192.168.1.254')
        end

        it { is_expected.to contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with_content(my_fixture_read('ifcfg-ib0_with_gateway')) }
      end
    end
  end
end
