# puppet-infiniband [![Build Status](https://travis-ci.org/treydock/puppet-infiniband.png)](https://travis-ci.org/treydock/puppet-infiniband)

Installs the InfiniBand software stack.

## Support

* CentOS 6.4 x86_64
* Scientific Linux 6.4 x86_64

## Usage

### infiniband

Standard usage to enable InfiniBand support

    class { 'infiniband': }

Define a IBoIP interface

    class { 'infiniband':
      interfaces  => {
        'ib0' => {'ipaddr' => '192.168.1.1', 'netmask' => '255.255.255.0'}
      }
    }

### infiniband::interface

Creates the ifcfg file for an IBoIP interface

    infiniband::interface { 'ib0':
      ipaddr  => '192.168.1.1',
      netmask => '255.255.255.0',
    }

## Facts

### has_infiniband

Determine if the system's hardware supports InfiniBand.

### infiniband_fw_version

Reports the firmware version of the InfiniBand interface card.

## Development

### Dependencies

* Ruby 1.8.7
* Bundler

### Unit testing

1. Install gem dependencies

        bundle install

2. Run tests

        bundle exec rake ci

## TODO

* Additional facts for IB firmware version, card model, etc.
