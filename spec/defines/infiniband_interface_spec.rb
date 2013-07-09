require 'spec_helper'

describe 'infiniband::interface' do
  let :title do
    'ib0'
  end
  
  let :default_params do
    {
      :ipaddr   => '192.168.1.1',
      :netmask  => '255.255.255.0',
    }
  end

  let :params do
    default_params
  end

  it do
    should contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Service[rdma]',
      'require' => 'Package[rdma]',
    })
  end

  it do
    should contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0') \
      .with_content(/^DEVICE="ib0"$/) \
      .with_content(/^BOOTPROTO="none"$/) \
      .with_content(/^NM_CONTROLLED="no"$/) \
      .with_content(/^ONBOOT="yes"$/) \
      .with_content(/^TYPE="InfiniBand"$/) \
      .with_content(/^IPADDR="#{params[:ipaddr]}"$/) \
      .with_content(/^NETMASK="#{params[:netmask]}"$/) \
      .with_content(/^CONNECTED_MODE="yes"$/)
  end

  context 'ensure => absent' do
    let :params do
      default_params.merge({:ensure => 'absent'})
    end
    
    it { should contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with_ensure('absent') }
  end

  context 'enable => no' do
    let :params do
      default_params.merge({:enable => 'no'})
    end
    
    it { should contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with_content(/^ONBOOT="no"$/) }
  end

  context 'connected_mode => no' do
    let :params do
      default_params.merge({:connected_mode => 'no'})
    end
    
    it { should contain_file('/etc/sysconfig/network-scripts/ifcfg-ib0').with_content(/^CONNECTED_MODE="no"$/) }
  end
end

