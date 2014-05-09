## treydock-infiniband changelog

Release notes for the treydock-infiniband module.

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
