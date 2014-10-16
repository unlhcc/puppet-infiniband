## treydock-infiniband changelog

Release notes for the treydock-infiniband module.

------------------------------------------

#### 2014-10-16 Release 1.0.0

This release is a fairly large rewrite of the module with backwards incompatible changes.

##### Backwards-incompatible changes:

* `manage_mlx4_core_options` parameter now defaults to true
* `with_optional_packages` parameter now defaults to true
* parameters for mandator, default and optional packages removed
* Remove documented support for Scientific Linux 6
  * packages exist that conflict with upstream package names
* Replace dependency of domcleal/augeasproviders with herculesteam/augeasproviders_shellvar

##### Changes:

* Support EL7
* Manage the ibacm service
* Add infiniband_rate fact to detect an Infiniband port's reported rate
* Shellvar resources no longer notify the rdma service
* Add dependency for razorsedge-network to ensure network service is restarted
* Updated unit and acceptance tests
* Replace Modulefile with metadata.json

------------------------------------------

#### 2014-06-18 Release 0.1.1

* Fix LICENSE file - wget fail!

------------------------------------------

#### 2014-05-22 Release 0.1.0

This release contains new backwards compatible features.

Detailed Changes:

* Feature: Add option to manage mlx4_core kernel parameters log_num_mtt and log_mtts_per_seg
* Feature: Add calc_log_num_mtt parser function to simplify determining the correct value for log_num_mtt
* Feature: Add gateway parameter to infiniband::interface that can be used to set the interface's GATEWAY value.
* Bug fix: Make beaker nodeset default.yml a copy of centos-65-x64.yml instead of a symlink.
* Update README

------------------------------------------

#### 2014-05-09 Release 0.0.4

This release contains a bug fix breaking the infiniband facts for Facter less than 2.0.

Added facter version test matrix to travis-ci tests.

------------------------------------------

#### 2014-05-09 Release 0.0.3

This release contains bug fixes to the 'has_infiniband' fact
and the associated unit tests.

------------------------------------------

#### 2014-05-09 Release 0.0.2

This releaes contains only minor bug fixes.

Detailed Changes:

* Fix issue where Shellvar resources notified rdma service even if ensure was 'stopped'
* Remove version dependency for rake
* Pin beaker to version 1.8.x
* Test rdma service in acceptance tests
* Move variables in the rspec-puppet tests to methods
* Use Hash to define Shellvar unit tests
* Test Puppet 3.5.x in Travis-CI

------------------------------------------

#### 2014-03-27 Release 0.0.1

* Initial release
