# Class: infiniband::params
#
#   The infiniband configuration settings.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class infiniband::params {

  case $::osfamily {
    'RedHat': {
      $infiniband_support_packages    = [
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
      $optional_infiniband_packages   = [
        'infiniband-diags',
        'perftest',
        'mstflint',
        'qperf',
        'opensm',
      ]
      $with_optional_packages         = true
      $rdma_service_name              = 'rdma'
      $rdma_service_has_status        = true
      $rdma_service_has_restart       = true
      $opensm_service_name            = 'opensm'
      $opensm_service_has_status      = true
      $opensm_service_has_restart     = true
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only supports osfamily RedHat")
    }
  }

  case $::has_infiniband {
    true : {
      $rdma_service_ensure    = 'running'
      $rdma_service_enable    = true
      $opensm_service_ensure  = 'running'
      $opensm_service_enable  = true
    }

    default : {
      $rdma_service_ensure    = 'stopped'
      $rdma_service_enable    = false
      $opensm_service_ensure  = 'stopped'
      $opensm_service_enable  = false
    }
  }

}
