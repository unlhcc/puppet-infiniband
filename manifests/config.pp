# @summary Manage InfiniBand config
# @api private
class infiniband::config {

  Shellvar {
    ensure  => present,
    target  => $infiniband::rdma_conf_path,
  }

  shellvar { 'infiniband IPOIB_LOAD': variable => 'IPOIB_LOAD', value => $infiniband::ipoib_load }
  shellvar { 'infiniband SRP_LOAD': variable => 'SRP_LOAD', value => $infiniband::srp_load }
  shellvar { 'infiniband SRPT_LOAD': variable => 'SRPT_LOAD', value => $infiniband::srpt_load }
  shellvar { 'infiniband ISER_LOAD': variable => 'ISER_LOAD', value => $infiniband::iser_load }
  shellvar { 'infiniband ISERT_LOAD': variable => 'ISERT_LOAD', value => $infiniband::isert_load }
  shellvar { 'infiniband RDS_LOAD': variable => 'RDS_LOAD', value => $infiniband::rds_load }
  shellvar { 'infiniband XPRTRDMA_LOAD': variable => 'XPRTRDMA_LOAD', value => $infiniband::xprtrdma_load }
  shellvar { 'infiniband SVCRDMA_LOAD': variable => 'SVCRDMA_LOAD', value => $infiniband::svcrdma_load }
  shellvar { 'infiniband TECH_PREVIEW_LOAD': variable => 'TECH_PREVIEW_LOAD', value => $infiniband::tech_preview_load }
  shellvar { 'infiniband FIXUP_MTRR_REGS': variable => 'FIXUP_MTRR_REGS', value => $infiniband::fixup_mtrr_regs }
  shellvar { 'infiniband NFSoRDMA_LOAD': variable => 'NFSoRDMA_LOAD', value => $infiniband::nfsordma_load }
  shellvar { 'infiniband NFSoRDMA_PORT': variable => 'NFSoRDMA_PORT', value => $infiniband::nfsordma_port }

  if $infiniband::manage_mlx4_core_options {
    file { '/etc/modprobe.d/mlx4_core.conf':
      ensure  => 'file',
      content => template('infiniband/modprobe.d/mlx4_core.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }

}
