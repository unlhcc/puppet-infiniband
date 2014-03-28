# puppet-infiniband

[![Build Status](https://travis-ci.org/treydock/puppet-infiniband.png)](https://travis-ci.org/treydock/puppet-infiniband)

Installs the InfiniBand software stack.

## Support

* CentOS 6 x86_64
* Scientific Linux 6 x86_64

## Usage

### Class: `infiniband`

Standard usage to enable InfiniBand support

    class { 'infiniband': }

Define a IBoIP interface

    class { 'infiniband':
      interfaces  => {
        'ib0' => {'ipaddr' => '192.168.1.1', 'netmask' => '255.255.255.0'}
      }
    }

#### Parameters for `infiniband` class

#####`packages`

The packges to install infiniband support.  Default is 'UNSET'.

If 'UNSET' the packages installed are pulled from the `mandatory_packages`, `default_packages` and `optional_packages` (if `with_optinal_packages` is true).

#####`mandatory_packages`

The 'mandatory' packages as defined by the 'Infiniband Support' package group in EL6.

#####`default_packages`

The 'default' packages as defined by the 'Infiniband Support' package group in EL6.

#####`optional_packages`

The 'optional' packages as defined by the 'Infiniband Support' package group in EL6 with exception of 'glusterfs-rdma' and 'opensm' packages.

#####`with_optional_packages`

If true, the packages in `optional_packages` are installed (defaults to true).

#####`rdma_service_ensure`

RDMA service ensure parameter.  Default to 'running' if `has_infiniband` fact is 'true', and 'stopped' if 'has_infiniband' fact is 'false'.

#####`rdma_service_enable`

RDMA service enable parameter.  Default to true if `has_infiniband` fact is 'true', and false if 'has_infiniband' fact is 'false'.

#####`rdma_service_name`

RDMA service name (defaults to 'rdma').

#####`rdma_service_has_status`

RDMA service has_status parameter (defaults to true).

#####`rdma_service_has_restart`

RDMA service has_restart parameter (defaults to true).

#####`interfaces`

This Hash can be used to define `infiniband::interface` resources (defaults to false).  This parameter can also be defined using the top-scope variable `infiniband_interfaces`.

#####`rdma_conf_path`

The RDMA service configuration path (defaults to '/etc/rdma/rdma.conf').

#####`ipoib_load`

Sets the `IPOIB_LOAD` setting for the RDMA service (defaults to 'yes').

#####`srp_load`

Sets the `SRP_LOAD` setting for the RDMA service (defaults to 'no').

#####`iser_load`

Sets the `ISER_LOAD` setting for the RDMA service (defaults to 'no').

#####`rds_load`

Sets the `RDS_LOAD` setting for the RDMA service (defaults to 'no').

#####`fixup_mtrr_regs`

Sets the `FIXUP_MTRR_REGS` setting for the RDMA service (defaults to 'no').

#####`nfsordma_load`

Sets the `NFSoRDMA_LOAD` setting for the RDMA service (defaults to 'yes').

#####`nfsordma_port`

Sets the `NFSoRDMA_PORT` setting for the RDMA service (defaults to '2050').

### Defined type: `infiniband::interface`

Creates the ifcfg file for an IBoIP interface

    infiniband::interface { 'ib0':
      ipaddr  => '192.168.1.1',
      netmask => '255.255.255.0',
    }

#### Parameters for `infiniband::interface` defined type

#####`name`

String: the resource title.  Sets the interfaces name, for example 'ib0'.

#####`ipaddr`

String: required, no default.  The IPADDR for the infiniband interface.

#####`netmask`

String: required, no default.  The NETMASK for the infiniband interface.

#####`ensure`

String: defaults to 'present'.  Sets if the infiniband::interface should be present or absent.

#####`enable`

Boolean: defaults to true.  Sets if the infiniband::interface should be enabled.

#####`connected_mode`

String: defaults to 'yes'.  The CONNECTED_MODE for the infiniband interface.

## Facts

### `has_infiniband`

Determine if the system's hardware supports InfiniBand.

### `infiniband_fw_version`

Reports the firmware version of the InfiniBand interface card.

**NOTE:** Only supports getting the value from the first interface card found.

### `infiniband_board_id`

Returns the board_id (PSID) of the InfiniBand interface card.

**NOTE:** Only supports getting the value from the first interface card found.

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

        bundle install

Run unit tests

        bundle exec rake test

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake acceptance

## TODO

* Additional facts for IB firmware version, card model, etc.
