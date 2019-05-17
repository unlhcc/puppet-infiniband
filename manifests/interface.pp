# @summary Manage IPoIB interface
#
# @example Creates the ifcfg file for an IBoIP interface
#   infiniband::interface { 'ib0':
#     ipaddr  => '192.168.1.1',
#     netmask => '255.255.255.0',
#   }
#
#
# @param name
#   The resource title.  Sets the interfaces name, for example 'ib0'.
# @param ipaddr
#   The IPADDR for the infiniband interface.
# @param netmask
#   The NETMASK for the infiniband interface.
# @param gateway
#   The GATEWAY for the infiniband interface.
# @param ensure
#   Sets if the infiniband::interface should be present or absent.
# @param enable
#   Sets if the infiniband::interface should be enabled at boot.
# @param connected_mode
#   The CONNECTED_MODE value for the infiniband interface.
# @param mtu
#   The MTU for the infiniband interface.
#
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
