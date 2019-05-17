# puppet-infiniband

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/infiniband.svg)](https://forge.puppetlabs.com/treydock/infiniband)
[![Build Status](https://travis-ci.org/treydock/puppet-infiniband.svg?branch=master)](https://travis-ci.org/treydock/puppet-infiniband)

Installs the InfiniBand software stack.

## Support

* CentOS 6 & 7 x86_64

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

## Reference

[http://treydock.github.io/puppet-infiniband/](http://treydock.github.io/puppet-infiniband/)

### Facts

#### has_infiniband

Determine if the system's hardware supports InfiniBand.

#### infiniband\_fw\_version

Reports the firmware version of the InfiniBand interface card.

**NOTE:** Only supports getting the value from the first interface card found.

#### infiniband\_board\_id

Returns the board_id (PSID) of the InfiniBand interface card.

**NOTE:** Only supports getting the value from the first interface card found.

#### infiniband_rate

Returns the rate of the InfiniBand interface card.

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

    bundle exec rake beaker

## TODO
