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


### Functions

#### calc\_log\_num\_mtt

This function calculates the appropriate value for mlx4_core module's 'log\_num\_mtt' parameter.

The formula is `max_reg_mem = (2^log_num_mtt) * (2^log_mtts_per_seg) * (page_size_bytes)`.  This function finds the
 log\_num\_mtt necessary to make 'max\_reg\_mem' twice the size of system's RAM.  Ref: http://community.mellanox.com/docs/DOC-1120.

*Usage*:

calc_log_num_mtt(`memorysize_mb`, `log_mtts_per_seg`, `page_size_bytes`)

* memorysize_mb - The system's memory size in MBs.  This argument is required.
* log\_mtts\_per\_seg - The value for log\_mtts\_per\_seg.  Defaults to '3' if undefined.
* page\_size\_bytes - The system's page size in bytes.  Defaults to '4096' if undefined.

*Examples*:

If `$::memorysize_mb` is 129035.57

    calc_log_num_mtt($::memorysize_mb, 3)

Would return 23

    calc_log_num_mtt($::memorysize_mb, 1)

Would return 25

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
