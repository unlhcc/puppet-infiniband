# @summary Convenience class to call defined types provided by this module.
# @api private
class infiniband::providers {
  create_resources('infiniband::interface', $infiniband::interfaces)
}
