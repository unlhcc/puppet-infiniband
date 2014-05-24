# == Class: infiniband
#
# See README.md for more details.
class infiniband (
  $packages                     = 'UNSET',
  $mandatory_packages           = $infiniband::params::infiniband_support_mandatory_packages,
  $default_packages             = $infiniband::params::infiniband_support_default_packages,
  $optional_packages            = $infiniband::params::infiniband_support_optional_packages,
  $with_optional_packages       = false,
  $rdma_service_ensure          = $infiniband::params::rdma_service_ensure,
  $rdma_service_enable          = $infiniband::params::rdma_service_enable,
  $rdma_service_name            = $infiniband::params::rdma_service_name,
  $rdma_service_has_status      = $infiniband::params::rdma_service_has_status,
  $rdma_service_has_restart     = $infiniband::params::rdma_service_has_restart,
  $ibacm_service_ensure         = $infiniband::params::ibacm_service_ensure,
  $ibacm_service_enable         = $infiniband::params::ibacm_service_enable,
  $ibacm_service_name           = $infiniband::params::ibacm_service_name,
  $ibacm_service_has_status     = $infiniband::params::ibacm_service_has_status,
  $ibacm_service_has_restart    = $infiniband::params::ibacm_service_has_restart,
  $interfaces                   = $infiniband::params::interfaces,
  $rdma_conf_path               = $infiniband::params::rdma_conf_path,
  $ipoib_load                   = 'yes',
  $srp_load                     = 'no',
  $iser_load                    = 'no',
  $rds_load                     = 'no',
  $fixup_mtrr_regs              = 'no',
  $nfsordma_load                = 'yes',
  $nfsordma_port                = 2050,
  $manage_mlx4_core_options     = false,
  $log_num_mtt                  = 'UNSET',
  $log_mtts_per_seg             = '3',
) inherits infiniband::params {

  if $interfaces { validate_hash($interfaces) }
  validate_re($ipoib_load, ['^yes$', '^no$'])
  validate_re($srp_load, ['^yes$', '^no$'])
  validate_re($iser_load, ['^yes$', '^no$'])
  validate_re($rds_load, ['^yes$', '^no$'])
  validate_re($fixup_mtrr_regs, ['^yes$', '^no$'])
  validate_re($nfsordma_load, ['^yes$', '^no$'])
  validate_bool($manage_mlx4_core_options)

  if $packages != 'UNSET' {
    validate_array($packages)

    $infiniband_support_packages = $packages
  } else {
    validate_array($mandatory_packages)
    validate_array($default_packages)
    validate_array($optional_packages)
    validate_bool($with_optional_packages)

    $infiniband_support_packages = $with_optional_packages ? {
      true  => flatten([$mandatory_packages, $default_packages, $optional_packages]),
      false => flatten([$mandatory_packages, $default_packages]),
    }
  }

  if ! $rdma_service_ensure or $rdma_service_ensure == 'stopped' {
    $shellvar_notify    = undef
  } else {
    $shellvar_notify    = Service['rdma']
  }

  $_log_num_mtt = $log_num_mtt ? {
    'UNSET' => calc_log_num_mtt($::memorysize_mb, $log_mtts_per_seg),
    default => $log_num_mtt,
  }

  ensure_packages($infiniband_support_packages)

  service { 'rdma':
    ensure      => $rdma_service_ensure,
    enable      => $rdma_service_enable,
    name        => $rdma_service_name,
    hasstatus   => $rdma_service_has_status,
    hasrestart  => $rdma_service_has_restart,
    require     => Package['rdma'],
  }

  service { 'ibacm':
    ensure      => $ibacm_service_ensure,
    enable      => $ibacm_service_enable,
    name        => $ibacm_service_name,
    hasstatus   => $ibacm_service_has_status,
    hasrestart  => $ibacm_service_has_restart,
    require     => [ Package['ibacm'], Service['rdma'] ],
  }

  if $interfaces and !empty($interfaces) {
    create_resources('infiniband::interface', $interfaces)
  }

  Shellvar {
    ensure  => present,
    target  => $rdma_conf_path,
    notify  => $shellvar_notify,
    require => Package['rdma'],
  }

  shellvar { 'infiniband IPOIB_LOAD': variable => 'IPOIB_LOAD', value => $ipoib_load }
  shellvar { 'infiniband SRP_LOAD': variable => 'SRP_LOAD', value => $srp_load }
  shellvar { 'infiniband ISER_LOAD': variable => 'ISER_LOAD', value => $iser_load }
  shellvar { 'infiniband RDS_LOAD': variable => 'RDS_LOAD', value => $rds_load }
  shellvar { 'infiniband FIXUP_MTRR_REGS': variable => 'FIXUP_MTRR_REGS', value => $fixup_mtrr_regs }
  shellvar { 'infiniband NFSoRDMA_LOAD': variable => 'NFSoRDMA_LOAD', value => $nfsordma_load }
  shellvar { 'infiniband NFSoRDMA_PORT': variable => 'NFSoRDMA_PORT', value => $nfsordma_port }

  if $manage_mlx4_core_options {
    file { '/etc/modprobe.d/mlx4_core.conf':
      ensure  => 'file',
      content => template('infiniband/modprobe.d/mlx4_core.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      before  => Service['rdma'],
    }
  }
}
