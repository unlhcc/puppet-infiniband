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

def packages
  [
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
end

def optional_packages
  [
    'compat-dapl',
    'infiniband-diags',
    'libibcommon',
    'mstflint',
    'perftest',
    'qperf',
    'srptools',
  ]
end

describe 'infiniband' do
  include_context :defaults

  let(:facts) { default_facts }

  let :interfaces_example do
    { 'ib0' => {'ipaddr' => '192.168.1.1', 'netmask'  => '255.255.255.0'} }
  end

  it { should create_class('infiniband') }
  it { should contain_class('infiniband::params') }

  it { should have_package_resource_count(18) }

  packages.each do |package|
    it { should contain_package(package).with({ 'ensure' => 'present' }) }
  end

  optional_packages.each do |optional_package|
    it { should_not contain_package(optional_package) }
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

  it { should have_shellvar_resource_count(7) }

  shellvars.each_pair do |name,params|
    it do
      should contain_shellvar("infiniband #{name}").with({
        'ensure'  => 'present',
        'target'    => '/etc/rdma/rdma.conf',
        'notify'    => 'Service[rdma]',
        'require'   => 'Package[rdma]',
        'variable'  => name,
        'value'     => params['value'],
      })
    end
  end

  context "has_infiniband is false" do
    let(:facts) { default_facts.merge({:has_infiniband => false }) }

    it do
      should contain_service('rdma').with({
        'ensure'      => 'stopped',
        'enable'      => 'false',
      })
    end

    shellvars.keys.each do |name|
      it { should contain_shellvar("infiniband #{name}").without_notify }
    end
  end

  context 'with_optional_packages => true' do
    let(:params) {{ :with_optional_packages => true }}

    it { should have_package_resource_count(25) }

    optional_packages.each do |optional_package|
      it { should contain_package(optional_package).with_ensure('present') }
    end

    context "when with_optional_packages => true and packages => ['foo']" do
      let(:params) {{ :with_optional_packages => true, :packages => ['foo'] }}

      it { should have_package_resource_count(1) }

      it { should contain_package('foo').with_ensure('present') }

      optional_packages.each do |optional_package|
        it { should_not contain_package(optional_package) }
      end

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
    let(:facts) {default_facts.merge({:infiniband_interfaces => interfaces_example }) }

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

  [
    'ipoib_load',
    'srp_load',
    'iser_load',
    'rds_load',
    'fixup_mtrr_regs',
    'nfsordma_load',
  ].each do |p|
    context "when #{p} => 'foo'" do
      let(:params) {{ p.to_sym => 'foo' }}
      it { expect { should create_class('infiniband') }.to raise_error(Puppet::Error, /does not match \["\^yes\$", "\^no\$"\]/) }
    end
  end

  [
    'packages',
    'mandatory_packages',
    'default_packages',
    'optional_packages',
  ].each do |p|
    context "when #{p} => 'foo'" do
      let(:params) {{ p.to_sym => 'foo' }}
      it { expect { should create_class('infiniband') }.to raise_error(Puppet::Error, /is not an Array/) }
    end
  end
end
