require 'spec_helper_acceptance'

describe 'infiniband class' do
  case fact('operatingsystemrelease')
    when '7.4', '7.4.1708'
      base_pkgs = [
        'dapl',
        'ibacm',
        'ibutils',
        'infiniband-diags',
        'iwpmd',
        'libibcm',
        'libibmad',
        'libibumad',
        'libibverbs',
        'libibverbs-utils',
        'librdmacm',
        'librdmacm-utils',
        'mstflint',
        'opa-address-resolution',
        'opa-fastfabric',
        'perftest',
        'qperf',
        'srp_daemon',
      ]

      opt_pkgs = [
        'compat-dapl',
        'compat-opensm-libs',
        'libibcommon',
        'libusnic_verbs',
        'libvma',
        'rdma-core',
        'usnic-tools',
      ]
    else
      base_pkgs = [
        'libibcm',
        'libibverbs',
        'libibverbs-utils',
        'librdmacm',
        'librdmacm-utils',
        'rdma',
        'dapl',
        'ibacm',
        'ibutils',
        'libcxgb3',
        'libibmad',
        'libibumad',
        'libipathverbs',
        'libmlx4',
        'libmthca',
        'libnes',
      ]

      opt_pkgs = [
        'compat-dapl',
        'infiniband-diags',
        'libibcommon',
        'mstflint',
        'perftest',
        'qperf',
        'srptools',
      ]
  end


  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
        class { 'infiniband': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    base_pkgs.each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end

    opt_pkgs.each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
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
