require 'spec_helper'
require 'facter/util/file_read'
require 'facter/util/infiniband'

describe Facter::Util::Infiniband do
  before :each do
    Facter.clear
  end

  describe 'lspci' do
    it 'returns output' do
      allow(Facter::Util::Resolution).to receive(:exec).with('lspci -n 2>/dev/null').and_return('foo')
      expect(described_class.lspci).to eq('foo')
    end
  end

  describe 'read_sysfs' do
    it 'returns output' do
      allow(File).to receive(:exist?).with('/sys/class/infiniband/mlx4_0/fw_ver').and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with('cat /sys/class/infiniband/mlx4_0/fw_ver').and_return("2.9.1200\n")
      expect(described_class.read_sysfs('/sys/class/infiniband/mlx4_0/fw_ver')).to eq('2.9.1200')
    end

    it 'returns nil' do
      allow(File).to receive(:exist?).with('/sys/class/infiniband/mlx4_0/fw_ver').and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with('cat /sys/class/infiniband/mlx4_0/fw_ver').and_return(nil)
      expect(described_class.read_sysfs('/sys/class/infiniband/mlx4_0/fw_ver')).to be_nil
    end
  end

  describe 'count_ib_devices' do
    it 'returns 1' do
      allow(Facter::Util::Resolution).to receive(:which).with('lspci').and_return(true)
      allow(described_class).to receive(:lspci).and_return(my_fixture_read('mellanox_lspci_1'))
      expect(described_class.count_ib_devices).to eq(1)
    end

    it 'returns 0 when no ib device' do
      allow(Facter::Util::Resolution).to receive(:which).with('lspci').and_return(true)
      allow(described_class).to receive(:lspci).and_return(my_fixture_read('noib_lspci_1'))
      expect(described_class.count_ib_devices).to eq(0)
    end

    it 'returns 0 when no lspci' do
      allow(Facter::Util::Resolution).to receive(:which).with('lspci').and_return(false)
      expect(described_class.count_ib_devices).to eq(0)
    end
  end

  describe 'get_port_fw_version' do
    it 'returns fw_ver for mlx devices' do
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx4_0/fw_ver').and_return('2.9.1200')
      expect(described_class.get_port_fw_version('mlx4_0')).to eq('2.9.1200')
    end

    it 'returns nil if no fw_ver' do
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx4_0/fw_ver').and_return(nil)
      expect(described_class.get_port_fw_version('mlx4_0')).to be_nil
    end

    it 'returns nil' do
      allow(described_class).to receive(:read_sysfs).never
      expect(described_class.get_port_fw_version('foo')).to be_nil
    end
  end

  describe 'get_port_board_id' do
    it 'returns board_id' do
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx4_0/board_id').and_return('MT_0000000000')
      expect(described_class.get_port_board_id('mlx4_0')).to eq('MT_0000000000')
    end

    it 'returns nil' do
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx4_0/fw_ver').and_return(nil)
      expect(described_class.get_port_fw_version('mlx4_0')).to be_nil
    end
  end

  describe 'ports' do
    it 'returns a array with single port name' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/*').and_return(['/sys/class/infiniband/mlx4_0'])
      expect(described_class.ports).to eq(['mlx4_0'])
    end

    it 'returns a array with two port names' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/*').and_return(['/sys/class/infiniband/mlx4_0', '/sys/class/infiniband/mlx4_1'])
      expect(described_class.ports).to eq(['mlx4_0', 'mlx4_1'])
    end

    it 'returns empty array if no ports exist' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/*').and_return([])
      expect(described_class.ports).to eq([])
    end
  end

  describe 'get_port_rate' do
    it 'returns rate for DDR device' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').and_return(['/sys/class/infiniband/mlx4_0/ports/1'])
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx4_0/ports/1/rate').and_return('20 Gb/sec (4X DDR)')
      expect(described_class.get_port_rate('mlx4_0')).to eq('20 Gb/sec (4X DDR)')
    end

    it 'returns nil when Dir.glob is empty' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').and_return([])
      expect(described_class.get_port_rate('mlx4_0')).to be_nil
    end

    it 'returns nil when read_sysfs is nil' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').and_return(['/sys/class/infiniband/mlx4_0/ports/1'])
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx4_0/ports/1/rate').and_return(nil)
      expect(described_class.get_port_rate('mlx4_0')).to be_nil
    end
  end

  describe 'hcas' do
    it 'returns HCAs' do
      allow(File).to receive(:directory?).with('/sys/class/infiniband').and_return(true)
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/*').and_return(['/sys/class/infiniband/mlx5_0', '/sys/class/infiniband/mlx5_1'])
      expect(described_class.hcas).to eq(['mlx5_0', 'mlx5_1'])
    end

    it 'does not return HCAs with no infiniband' do
      allow(File).to receive(:directory?).with('/sys/class/infiniband').and_return(false)
      expect(described_class.hcas).to eq([])
    end
  end

  describe 'get_hca_port_guids' do
    it 'returns port GUIDs' do
      allow(Facter::Util::Resolution).to receive(:which).with('ibstat').and_return('/usr/sbin/ibstat')
      allow(Facter::Util::Resolution).to receive(:exec).with('ibstat -p mlx5_0').and_return("0x0202c9fffe557aae\n0x0202c9fffe557aaf\n")
      expect(described_class.get_hca_port_guids('mlx5_0')).to eq('1' => '0x0202c9fffe557aae', '2' => '0x0202c9fffe557aaf')
    end

    it 'returns nothing without ibstat' do
      allow(Facter::Util::Resolution).to receive(:which).with('ibstat').and_return(nil)
      expect(Facter::Util::Resolution).not_to receive(:exec)
      expect(described_class.get_hca_port_guids('mlx5_0')).to eq({})
    end
  end

  describe 'get_hca_board_id' do
    it 'returns value' do
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx5_0/board_id').and_return('foo')
      expect(described_class.get_hca_board_id('mlx5_0')).to eq('foo')
    end
    it 'returns nil' do
      allow(described_class).to receive(:read_sysfs).with('/sys/class/infiniband/mlx5_0/board_id').and_return(nil)
      expect(described_class.get_hca_board_id('mlx5_0')).to be_nil
    end
  end
end
