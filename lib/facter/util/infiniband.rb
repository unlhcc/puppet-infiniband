class Facter::Util::Infiniband
  LSPCI_IB_REGEX = /^(.*)\sInfiniBand \[0c06\].*$/

  # Returns the number of InfiniBand interfaces found
  # in lspci output
  #
  # @return [Integer]
  #
  # @api private
  def self.count_ib_devices
    if Facter::Util::Resolution.which('lspci')
      lspci = Facter::Util::Resolution.exec('lspci -nn')
      matches = lspci.scan(LSPCI_IB_REGEX)
      matches.flatten.reject {|s| s.nil?}.length
    end
  end

  # Reads the contents of file
  #
  # @return [String]
  #
  # @api private
  def self.read_fw_version(path)
    output = Facter::Util::FileRead.read(path)
    return nil if output.nil?
    output.strip
  end

  # Returns firmware version of an InfiniBand port
  #
  # @return [String]
  #
  # @api private
  def self.get_port_fw_version(port)
    port_sysfs_path = "/sys/class/infiniband/#{port}"
    fw_version = nil

    case port
    when /^mlx/
      sysfs_fw_file = File.join(port_sysfs_path, "fw_ver")
    when /^qib/
      sysfs_fw_file = File.join(port_sysfs_path, "version")
    else
      return nil
    end

    fw_version = self.read_fw_version(sysfs_fw_file)
    fw_version
  end

  # Returns Array of InfiniBand ports
  #
  # @return [Array]
  #
  # @api private
  def self.get_ports
    ports = Dir.glob('/sys/class/infiniband/*').collect { |d| File.basename(d) }
    ports
  end
end
