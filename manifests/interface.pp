# == Define: infiniband::interface
#
# See README.md for more details.
define infiniband::interface(
  Stdlib::Compat::Ip_address $ipaddr,
  Stdlib::Compat::Ip_address $netmask,
  Optional[Stdlib::Compat::Ip_address] $gateway = undef,
  Enum['present', 'absent'] $ensure             = 'present',
  Variant[Enum['yes', 'no'], Boolean] $enable   = true,
  Enum['yes', 'no'] $connected_mode             = 'yes',
  Optional[Integer] $mtu                        = undef,
  Boolean $notify_service                       = true,
) {

  $ifcfg_filepath = "/etc/sysconfig/network-scripts/ifcfg-${name}"

  $onboot = $enable ? {
    String  => $enable,
    Boolean => $enable ? {
      true  => 'yes',
      false => 'no',
    },
  }

  file { $ifcfg_filepath:
    ensure  => $ensure,
    content => template('infiniband/ifcfg.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Notify the network service if requested to do so
  if $notify_service {
    include network
    File[$ifcfg_filepath] ~> Service['network']
  }

}
