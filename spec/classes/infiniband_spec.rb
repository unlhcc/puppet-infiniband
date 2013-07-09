require 'spec_helper'

describe 'infiniband' do

  let :interfaces_example do
    { 'ib0' => {'ipaddr' => '192.168.1.1', 'netmask'  => '255.255.255.0'} }
  end

  packages = [
    'libibcm',
    'libibverbs',
    'libibverbs-utils',
    'librdmacm',
    'librdmacm-utils',
    'rdma',
    'dapl',
    'ibacm',
    'ibsim',
    'ibutils',
    'libcxgb3',
    'libibmad',
    'libibumad',
    'libipathverbs',
    'libmlx4',
    'libmthca',
    'libnes',
    'rds-tools',
  ]

  optional_packages = [
    'compat-dapl',
    'infiniband-diags',
    'libibcommon',
    'mstflint',
    'opensm',
    'perftest',
    'qperf',
    'srptools',
  ]

  packages.each do |package|
    it { should contain_package(package).with({ 'ensure' => 'present' }) }
  end

  optional_packages.each do |optional_package|
    it { should contain_package(optional_package).with({ 'ensure' => 'present' }) }
  end

  it do
    should contain_service('rdma').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'name'        => 'rdma',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => 'Package[rdma]',
    })
  end
  
  context "has_infiniband is false" do
    let(:facts) {{ :has_infiniband => false }}

    it do
      should contain_service('rdma').with({
        'ensure'      => 'stopped',
        'enable'      => 'false',
      })
    end
  end

  context 'with_optional_packages => false' do
    let(:params) {{ :with_optional_packages => false }}
    
    optional_packages.each do |optional_package|
      it { should_not contain_package(optional_package) }
    end
  end

  shared_context "interfaces" do
    it { should have_infiniband__interface_resource_count(1) }

    it do
      should contain_infiniband__interface('ib0').with({
        'ipaddr'  => '192.168.1.1',
        'netmask' => '255.255.255.0',
      })
    end
  end 

  context "with parameter interfaces defined" do
    let(:params) {{ :interfaces => interfaces_example }}

    include_context 'interfaces'
  end

  context "with top-scope variable infiniband_interfaces defined" do
    let(:facts) {{ :infiniband_interfaces => interfaces_example }}

    include_context 'interfaces'
  end

  context "with interfaces => {}" do
    let(:params) {{:interfaces => {}}}
    it { should have_infiniband__interface_resource_count(0) }
  end

  context "with interfaces => false" do
    let(:params) {{:interfaces => false}}
     it 'should raise error' do
       expect raise_error(Puppet::Error, /false is not a Hash/)
     end
  end
end
