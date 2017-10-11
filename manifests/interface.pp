# == Define: infiniband::interface
#
# See README.md for more details.
define infiniband::interface(
  $ipaddr,
  $netmask,
  $gateway        = 'UNSET',
  $ensure         = 'present',
  $enable         = true,
  $connected_mode = 'yes',
  $mtu            = 'UNSET',
  $notify_service = true,
) {

  $ifcfg_filepath = "/etc/sysconfig/network-scripts/ifcfg-${name}"

  validate_re($ensure, ['^present$','^absent$'])

  $enable_real = is_string($enable) ? {
    true  => str2bool($enable),
    false => $enable,
  }
  validate_bool($enable_real)

  $notify_service_real = is_string($notify_service) ? {
    true  => str2bool($notify_service),
    false => $notify_service
  }

  validate_re($connected_mode, ['^yes$','^no$'])

  if $enable_real {
    $onboot = 'yes'
  } else {
    $onboot = 'no'
  }

  file { $ifcfg_filepath:
    ensure  => $ensure,
    content => template('infiniband/ifcfg.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Notify the network service if requested to do so
  if $notify_service_real {
    include network
    File[$ifcfg_filepath] ~> Service['network']
  }

}
