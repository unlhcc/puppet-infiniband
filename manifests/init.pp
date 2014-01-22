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
  $rdma_service_ensure          = $infiniband::params::rdma_service_ensure,
  $rdma_service_enable          = $infiniband::params::rdma_service_enable,
  $rdma_service_name            = $infiniband::params::rdma_service_name,
  $rdma_service_has_status      = $infiniband::params::rdma_service_has_status,
  $rdma_service_has_restart     = $infiniband::params::rdma_service_has_restart,
  $interfaces                   = $infiniband::params::interfaces,
  $rdma_conf_path               = $infiniband::params::rdma_conf_path,
  $ipoib_load                   = 'yes',
  $srp_load                     = 'no',
  $iser_load                    = 'no',
  $rds_load                     = 'no',
  $fixup_mtrr_regs              = 'no',
  $nfsordma_load                = 'yes',
  $nfsordma_port                = 2050
) inherits infiniband::params {

  validate_array($infiniband_support_packages)
  validate_array($optional_infiniband_packages)
  validate_bool($with_optional_packages)
  if $interfaces { validate_hash($interfaces) }

  validate_re($ipoib_load, ['^yes$', '^no$'])
  validate_re($srp_load, ['^yes$', '^no$'])
  validate_re($iser_load, ['^yes$', '^no$'])
  validate_re($rds_load, ['^yes$', '^no$'])
  validate_re($fixup_mtrr_regs, ['^yes$', '^no$'])
  validate_re($nfsordma_load, ['^yes$', '^no$'])

  ensure_packages($infiniband_support_packages)

  if $with_optional_packages {
    ensure_packages($optional_infiniband_packages)
  }

  service { 'rdma':
    ensure      => $rdma_service_ensure,
    enable      => $rdma_service_enable,
    name        => $rdma_service_name,
    hasstatus   => $rdma_service_has_status,
    hasrestart  => $rdma_service_has_restart,
    require     => Package['rdma'],
  }

  if $interfaces and !empty($interfaces) {
    create_resources('infiniband::interface', $interfaces)
  }

  Shellvar {
    ensure  => present,
    target  => $rdma_conf_path,
    notify  => Service['rdma'],
    require => Package['rdma'],
  }

  shellvar { 'infiniband IPOIB_LOAD': variable => 'IPOIB_LOAD', value => $ipoib_load }
  shellvar { 'infiniband SRP_LOAD': variable => 'SRP_LOAD', value => $srp_load }
  shellvar { 'infiniband ISER_LOAD': variable => 'ISER_LOAD', value => $iser_load }
  shellvar { 'infiniband RDS_LOAD': variable => 'RDS_LOAD', value => $rds_load }
  shellvar { 'infiniband FIXUP_MTRR_REGS': variable => 'FIXUP_MTRR_REGS', value => $fixup_mtrr_regs }
  shellvar { 'infiniband NFSoRDMA_LOAD': variable => 'NFSoRDMA_LOAD', value => $nfsordma_load }
  shellvar { 'infiniband NFSoRDMA_PORT': variable => 'NFSoRDMA_PORT', value => $nfsordma_port }

}
