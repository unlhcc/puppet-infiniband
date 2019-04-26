# == Define: infiniband::interface
#
# See README.md for more details.
define infiniband::interface (
  Stdlib::Compat::Ip_address $ipaddr,
  Stdlib::Compat::Ip_address $netmask,
  Optional[Stdlib::Compat::Ip_address] $gateway = undef,
  Enum['present', 'absent'] $ensure             = 'present',
  Boolean $enable                               = true,
  Enum['yes', 'no'] $connected_mode = 'yes',
  Optional[Integer] $mtu                        = undef,
) {

  $onboot = $enable ? {
    String  => $enable,
    Boolean => $enable ? {
      true  => 'yes',
      false => 'no',
    },
  }

  $options_extra_redhat = {
    'CONNECTED_MODE' => $connected_mode,
  }

  network::interface { $name:
    ensure               => $ensure,
    enable               => $enable,
    onboot               => $onboot,
    type                 => 'InfiniBand',
    ipaddress            => $ipaddr,
    netmask              => $netmask,
    gateway              => $gateway,
    nm_controlled        => 'no',
    mtu                  => $mtu,
    options_extra_redhat => $options_extra_redhat,
  }

}
