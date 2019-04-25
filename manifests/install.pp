# == Class: infiniband::install
#
class infiniband::install {
  yum::group { 'infiniband':
    ensure => 'present',
  }
  ensure_packages($infiniband::extra_packages)
}
