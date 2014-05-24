# The infiniband default configuration settings.
class infiniband::params {

  case $::osfamily {
    'RedHat': {
      $infiniband_support_mandatory_packages = [
        'libibcm',
        'libibverbs',
        'libibverbs-utils',
        'librdmacm',
        'librdmacm-utils',
        'rdma',
      ]

      $infiniband_support_default_packages = [
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

      $infiniband_support_optional_packages = [
        'compat-dapl',
        'infiniband-diags',
        'libibcommon',
        'mstflint',
        'perftest',
        'qperf',
        'srptools',
      ]

      $rdma_service_name = 'rdma'
      $rdma_service_has_status = true
      $rdma_service_has_restart = true
      $ibacm_service_name = 'ibacm'
      $ibacm_service_has_status = true
      $ibacm_service_has_restart = true
      $rdma_conf_path = '/etc/rdma/rdma.conf'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only supports osfamily RedHat")
    }
  }

  case $::has_infiniband {
    /true/ : {
      $rdma_service_ensure    = 'running'
      $rdma_service_enable    = true
      $ibacm_service_ensure   = 'running'
      $ibacm_service_enable   = true
    }

    default : {
      $rdma_service_ensure    = 'stopped'
      $rdma_service_enable    = false
      $ibacm_service_ensure   = 'stopped'
      $ibacm_service_enable   = false
    }
  }

  $interfaces = $::infiniband_interfaces ? {
    undef   => false,
    default => $::infiniband_interfaces,
  }

}
