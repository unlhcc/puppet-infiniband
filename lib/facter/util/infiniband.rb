class Facter::Util::Infiniband
  # Returns the number of InfiniBand interfaces found
  # in lspci output
  #
  # @return [Integer]
  #
  # @api private
  def self.count_ib_devices
    if Facter::Util::Resolution.which('lspci')
      lspci = Facter::Util::Resolution.exec('lspci')
      matches = lspci.scan(/(InfiniBand: |(Network controller|Ethernet controller|Memory controller): Mellanox Technolog)/m)
      matches.flatten.reject {|s| s.nil?}.length
    end
  end

  # Returns the PCI device ID of the InfiniBand interface card
  #
  # @return [String]
  #
  # @api private
  def self.get_device_id
    if Facter::Util::Resolution.which('lspci')
      output = Facter::Util::Resolution.exec('lspci -d 15b3:')
      id = output.split(" ").first unless output.nil?
      id
    end
  end

  # Returns the firmware version of the InfiniBand interface card
  #
  # @return [String]
  #
  # @api private
  def self.get_fw_version
    device_id = Facter::Util::Infiniband.get_device_id
    return nil unless device_id

    if Facter::Util::Resolution.which('mstflint')
      output = Facter::Util::Resolution.exec("mstflint -device #{device_id} -qq query")
      return nil unless output
      matches = output.scan(/^FW Version:\s+([0-9\.]+)$/m)
      fw_version = matches.flatten.reject { |o| o.nil? }.first
      return fw_version
    end
  end
end
