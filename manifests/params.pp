# The infiniband default configuration settings.
class infiniband::params {

  case $::osfamily {
    'RedHat': {
      $rdma_service_name          = 'rdma'
      $rdma_service_has_status    = true
      $rdma_service_has_restart   = true
      $ibacm_service_name         = 'ibacm'
      $ibacm_service_has_status   = true
      $ibacm_service_has_restart  = true
      $rdma_conf_path             = '/etc/rdma/rdma.conf'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only supports osfamily RedHat")
    }
  }

  # Set default service states based on has_infiniband fact value
  case $::has_infiniband {
    true : {
      $service_ensure = 'running'
      $service_enable = true
    }
    default : {
      $service_ensure = 'stopped'
      $service_enable = false
    }
  }

}
