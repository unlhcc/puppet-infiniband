class Facter::Util::Infiniband
  # REF: http://cateee.net/lkddb/web-lkddb/INFINIBAND.html
  LSPCI_IB_REGEX = /\s(1077|15b3|1678|1867|18b8|1fc1):/

  # lspci is a delegating helper method intended to make it easier to stub the
  # system call without affecting other calls to Facter::Core::Execution.exec
  def self.lspci(command = "lspci -n 2>/dev/null")
    #TODO: Deprecated in facter-2.0
    Facter::Util::Resolution.exec command
    #TODO: Not supported in facter < 2.0
    #Facter::Core::Execution.exec command
  end

  # Returns the number of InfiniBand interfaces found
  # in lspci output
  #
  # @return [Integer]
  #
  # @api private
  def self.count_ib_devices
    count = 0
    if Facter::Util::Resolution.which('lspci')
      output = self.lspci
      matches = output.scan(LSPCI_IB_REGEX)
      count = matches.flatten.reject {|s| s.nil?}.length
    end
    count
  end

  # Reads the contents of path in sysfs
  #
  # @return [String]
  #
  # @api private
  def self.read_sysfs(path)
    output = Facter::Util::Resolution.exec(['cat ',path].join()) if File.exist?(path)
    return nil if output.nil?
    output.strip
  end

  # Returns firmware version of an InfiniBand port
  #
  # @return [String]
  #
  # @api private
  def self.get_port_fw_version(port)
    sysfs_base_path = File.join("/sys/class/infiniband/", port)
    fw_version = nil

    case port
    when /^mlx/
      sysfs_fw_file = File.join(sysfs_base_path, "fw_ver")
    when /^qib/
      sysfs_fw_file = File.join(sysfs_base_path, "version")
    else
      return nil
    end

    fw_version = self.read_sysfs(sysfs_fw_file)
    fw_version
  end

  # Returns board_id of an InfiniBand port
  #
  # @return [String]
  #
  # @api private
  def self.get_port_board_id(port)
    sysfs_path = File.join("/sys/class/infiniband", port, "board_id")
    board_id = self.read_sysfs(sysfs_path)
    board_id
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

  # Returns rate of InifniBand port
  #
  # @return [String]
  #
  # @api private
  def self.get_port_rate(port)
    port_sysfs_path = Dir.glob(File.join('/sys/class/infiniband', port, 'ports', '*')).first
    return nil if port_sysfs_path.nil?

    rate_sysfs_path = File.join(port_sysfs_path, 'rate')
    rate = self.read_sysfs(rate_sysfs_path)
    rate
  end

  # Returns array of HCAs on the system
  #
  # @return [Array]
  #
  # @api private
  def self.get_hcas
    hcas = []
    if File.directory?('/sys/class/infiniband')
      Dir.glob('/sys/class/infiniband/*').each do |dir|
        hca = File.basename(dir)
        hcas << hca
      end
    end
    hcas
  end

  # Returns hash of HCA ports and their GUIDs
  #
  # @return [Hash]
  #
  # @api private
  def self.get_hca_port_guids(hca)
    port_guids = {}
    if ! Facter::Util::Resolution.which('ibstat')
      return {}
    end
    output = Facter::Util::Resolution.exec("ibstat -p #{hca}")
    output.each_line.with_index do |line, index|
      guid = line.strip()
      port = index + 1
      port_guids[port.to_s] = guid
    end
    port_guids
  end

  # Returns HCA board ID
  #
  # @return [String]
  #
  # @api private
  def self.get_hca_board_id(hca)
    sysfs_path = File.join("/sys/class/infiniband", hca, "board_id")
    board_id = self.read_sysfs(sysfs_path)
    board_id
  end
  
  # Returns rate of InifniBand port
  #
  # @return [String]
  #
  # @api private
  def self.get_real_port_rate(hca, port)
    port_sysfs_path = Dir.glob(File.join('/sys/class/infiniband', hca, 'ports', port))
    return nil if port_sysfs_path.nil?

    rate_sysfs_path = File.join(port_sysfs_path, 'rate')
    rate = self.read_sysfs(rate_sysfs_path)
    rate[/^(\d+)\s/,1]
  end

  # Returns state of InifniBand port
  #
  # @return [String]
  #
  # @api private
  def self.get_real_port_state(hca, port)
    port_sysfs_path = Dir.glob(File.join('/sys/class/infiniband', hca, 'ports', port))
    return nil if port_sysfs_path.nil?

    state_sysfs_path = File.join(port_sysfs_path, 'state')
    state = self.read_sysfs(state_sysfs_path)
    state[/: (.*)/,1]
  end

  # Returns link layer of Infiniband port (Ethernet or InfiniBand)
  #
  # @return [String]
  #
  # @api private
  def self.get_real_port_linklayer(hca, port)
    port_sysfs_path = Dir.glob(File.join('/sys/class/infiniband', hca, 'ports', port)) 
    return nil if port_sysfs_path.nil?
    
    linklayer_sysfs_path = File.join(port_sysfs_path, 'link_layer')
    linklayer = self.read_sysfs(linklayer_sysfs_path)
    linklayer
  end

  # Returns hash of net device names (ib0, p1p1) and data about each
  #
  # @return [Hash]
  #
  # @api private
  def self.get_netdev_to_hcaport
    netdevs = {}
    if ! Facter::Util::Resolution.which('ibdev2netdev')
      return {}
    end
    output = Facter::Util::Resolution.exec('ibdev2netdev')
    output.each_line do |line|
      split = line.split(' ')
      netdevs[split[4]] = {
        'hca' => split[0],
        'port' => split[2],
        'state' => self.get_real_port_state(split[0], split[2]),
        'rate' => self.get_real_port_rate(split[0], split[2]),
        'link_layer' => self.get_real_port_linklayer(split[0], split[2]),
      }

    end
    netdevs
  end  
end
