
module Facter::Util::Infiniband
  def self.count_ib_devices
    if Facter::Util::Resolution.which('lspci')
      lspci = Facter::Util::Resolution.exec('lspci')
      matches = lspci.scan(/(InfiniBand: |(Network controller|Ethernet controller|Memory controller): Mellanox Technolog)/m)
      matches.flatten.reject {|s| s.nil?}.length
    end
  end
end
