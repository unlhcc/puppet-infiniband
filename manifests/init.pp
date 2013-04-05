# == Class: infiniband
#
# Manage the necessary packages and services to support Infiniband.
#
# === Parameters
#
# Document parameters here.
#
# [*infiniband_support_packages*]
#   Array of package names to install the infiniband support.
#
# [*optional_infiniband_packages*]
#   Array of package names to install the optional infiniband support.
#
# [*with_optional_packages*]
#   Boolean that determines if the optional packages will be installed.
#
# [*rdma_service_name*]
#   Service name for RDMA.
#
# [*rdma_service_has_status*]
#   Boolean to set if RDMA service has status option.
#
# [*rdma_service_has_restart*]
#   Boolean to set if RDMA service has restart option.
#
# === Examples
#
#  class { infiniband:
#    with_optional_packages => true
#  }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class infiniband (
  $infiniband_support_packages  = $infiniband::params::infiniband_support_packages,
  $optional_infiniband_packages = $infiniband::params::optional_infiniband_packages,
  $with_optional_packages       = $infiniband::params::with_optional_packages,
  $rdma_service_name            = $infiniband::params::rdma_service_name,
  $rdma_service_has_status      = $infiniband::params::rdma_service_has_status,
  $rdma_service_has_restart     = $infiniband::params::rdma_service_has_restart

) inherits infiniband::params {

  package { $infiniband_support_packages:
    ensure  => 'present',
  }

  if $with_optional_packages {
    package { $optional_infiniband_packages:
      ensure  => 'present',
    }
  }

  service { 'rdma':
    ensure      => 'running',
    enable      => true,
    name        => $rdma_service_name,
    hasstatus   => $rdma_service_has_status,
    hasrestart  => $rdma_service_has_restart,
    require     => Package['rdma'],
  }

}
