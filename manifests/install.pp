# @summary Install InfiniBand support
# @api private
class infiniband::install {
  yum::group { 'infiniband':
    ensure => 'present',
  }
  ensure_packages($infiniband::extra_packages)
}
