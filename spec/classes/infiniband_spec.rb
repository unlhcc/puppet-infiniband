require 'spec_helper'

describe 'infiniband' do

  let :facts do
    {
      :osfamily                 => 'RedHat',
    }
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

  packages.each do |package|
    it { should contain_package(package).with({ 'ensure' => 'present' }) }
  end

  optional_packages = [
    'infiniband-diags',
    'perftest',
    'mstflint',
  ]

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
end
