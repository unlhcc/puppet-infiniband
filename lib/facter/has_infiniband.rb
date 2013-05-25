Facter.add(:has_infiniband) do
  confine :kernel => "Linux"
  setcode do
    if Facter::Util::Resolution.which('lspci')
      lspci = Facter::Util::Resolution.exec('lspci')
      ib_device_count = lspci.scan(/(InfiniBand: |(Network controller|Ethernet controller|Memory controller): Mellanox Technolog)/m).flatten.reject {|s| s.nil?}
      ib_device_count.length > 0
    end
  end
end
