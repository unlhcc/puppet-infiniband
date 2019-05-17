# == Class: infiniband
#
# See README.md for more details.
class infiniband (
  Array $extra_packages                 = [],
  String $rdma_service_ensure           = $infiniband::params::service_ensure,
  Boolean $rdma_service_enable          = $infiniband::params::service_enable,
  String $rdma_service_name             = $infiniband::params::rdma_service_name,
  Boolean $rdma_service_has_status      = $infiniband::params::rdma_service_has_status,
  Boolean $rdma_service_has_restart     = $infiniband::params::rdma_service_has_restart,
  String $ibacm_service_ensure          = $infiniband::params::service_ensure,
  Boolean $ibacm_service_enable         = $infiniband::params::service_enable,
  String $ibacm_service_name            = $infiniband::params::ibacm_service_name,
  Boolean $ibacm_service_has_status     = $infiniband::params::ibacm_service_has_status,
  Boolean $ibacm_service_has_restart    = $infiniband::params::ibacm_service_has_restart,
  Stdlib::Absolutepath $rdma_conf_path  = $infiniband::params::rdma_conf_path,
  Enum['yes', 'no'] $ipoib_load         = 'yes',
  Enum['yes', 'no'] $srp_load           = 'no',
  Enum['yes', 'no'] $iser_load          = 'no',
  Enum['yes', 'no'] $rds_load           = 'no',
  Enum['yes', 'no'] $fixup_mtrr_regs    = 'no',
  Enum['yes', 'no'] $nfsordma_load      = 'yes',
  Integer[0, 65535] $nfsordma_port      = 2050,
  Boolean $manage_mlx4_core_options     = true,
  Optional[Integer] $log_num_mtt        = undef,
  Integer $log_mtts_per_seg             = 3,
  Hash $interfaces                      = {},
) inherits infiniband::params {

  if $manage_mlx4_core_options {
    $real_log_num_mtt = $log_num_mtt ? {
      Undef   => infiniband::calc_log_num_mtt($facts.dig('memory','system','total_bytes'), $log_mtts_per_seg),
      default => $log_num_mtt,
    }
  }

  include '::infiniband::install'
  include '::infiniband::config'
  include '::infiniband::service'
  include '::infiniband::providers'

  anchor { 'infiniband::start': }
  anchor { 'infiniband::end': }

  Anchor['infiniband::start']
  -> Class['infiniband::install']
  -> Class['infiniband::config']
  -> Class['infiniband::service']
  -> Class['infiniband::providers']
  -> Anchor['infiniband::end']

}
