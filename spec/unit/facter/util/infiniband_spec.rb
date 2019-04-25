require 'spec_helper'
require 'facter/util/file_read'
require 'facter/util/infiniband'

describe Facter::Util::Infiniband do

  before :each do
    Facter.clear
  end

  describe 'lspci' do
    it 'should return output' do
      allow(Facter::Util::Resolution).to receive(:exec).with('lspci -n 2>/dev/null').and_return("foo")
      expect(described_class.lspci).to eq("foo")
    end
  end

  describe 'read_sysfs' do
    it 'should return output' do
      allow(File).to receive(:exist?).with('/sys/class/infiniband/mlx4_0/fw_ver').and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with("cat /sys/class/infiniband/mlx4_0/fw_ver").and_return("2.9.1200\n")
      expect(described_class.read_sysfs("/sys/class/infiniband/mlx4_0/fw_ver")).to eq("2.9.1200")
    end

    it 'should return nil' do
      allow(File).to receive(:exist?).with('/sys/class/infiniband/mlx4_0/fw_ver').and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with("cat /sys/class/infiniband/mlx4_0/fw_ver").and_return(nil)
      expect(described_class.read_sysfs("/sys/class/infiniband/mlx4_0/fw_ver")).to be_nil
    end
  end

  describe 'count_ib_devices' do
    it 'should return 1' do
      allow(Facter::Util::Resolution).to receive(:which).with('lspci').and_return(true)
      allow(described_class).to receive(:lspci).and_return(my_fixture_read('mellanox_lspci_1'))
      expect(described_class.count_ib_devices).to eq(1)
    end

    it 'should return 0' do
      allow(Facter::Util::Resolution).to receive(:which).with('lspci').and_return(true)
      allow(described_class).to receive(:lspci).and_return(my_fixture_read('noib_lspci_1'))
      expect(described_class.count_ib_devices).to eq(0)
    end

    it 'should return 0' do
      allow(Facter::Util::Resolution).to receive(:which).with('lspci').and_return(false)
      expect(described_class.count_ib_devices).to eq(0)
    end
  end

  describe 'get_port_fw_version' do
    it 'should return fw_ver for mlx devices' do
      allow(described_class).to receive(:read_sysfs).with("/sys/class/infiniband/mlx4_0/fw_ver").and_return("2.9.1200")
      expect(described_class.get_port_fw_version("mlx4_0")).to eq("2.9.1200")
    end

    it 'should return nil' do
      allow(described_class).to receive(:read_sysfs).with("/sys/class/infiniband/mlx4_0/fw_ver").and_return(nil)
      expect(described_class.get_port_fw_version("mlx4_0")).to be_nil
    end

    it 'should return nil' do
      allow(described_class).to receive(:read_sysfs).never
      expect(described_class.get_port_fw_version("foo")).to be_nil
    end
  end

  describe 'get_port_board_id' do
    it 'should return board_id' do
      allow(described_class).to receive(:read_sysfs).with("/sys/class/infiniband/mlx4_0/board_id").and_return("MT_0000000000")
      expect(described_class.get_port_board_id("mlx4_0")).to eq("MT_0000000000")
    end

    it 'should return nil' do
      allow(described_class).to receive(:read_sysfs).with("/sys/class/infiniband/mlx4_0/fw_ver").and_return(nil)
      expect(described_class.get_port_fw_version("mlx4_0")).to be_nil
    end
  end

  describe 'get_ports' do
    it "should return a array with single port name" do
      allow(Dir).to receive(:glob).with("/sys/class/infiniband/*").and_return(["/sys/class/infiniband/mlx4_0"])
      expect(described_class.get_ports).to eq(["mlx4_0"])
    end

    it "should return a array with two port names" do
      allow(Dir).to receive(:glob).with("/sys/class/infiniband/*").and_return(["/sys/class/infiniband/mlx4_0","/sys/class/infiniband/mlx4_1"])
      expect(described_class.get_ports).to eq(["mlx4_0","mlx4_1"])
    end

    it "should return empty array if no ports exist" do
      allow(Dir).to receive(:glob).with("/sys/class/infiniband/*").and_return([])
      expect(described_class.get_ports).to eq([])
    end
  end

  describe 'get_port_rate' do
    it 'should return rate for DDR device' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').and_return(['/sys/class/infiniband/mlx4_0/ports/1'])
      allow(described_class).to receive(:read_sysfs).with("/sys/class/infiniband/mlx4_0/ports/1/rate").and_return("20 Gb/sec (4X DDR)")
      expect(described_class.get_port_rate("mlx4_0")).to eq("20 Gb/sec (4X DDR)")
    end

    it 'should return nil when Dir.glob is empty' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').and_return([])
      expect(described_class.get_port_rate("mlx4_0")).to be_nil
    end

    it 'should return nil when read_sysfs is nil' do
      allow(Dir).to receive(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').and_return(['/sys/class/infiniband/mlx4_0/ports/1'])
      allow(described_class).to receive(:read_sysfs).with("/sys/class/infiniband/mlx4_0/ports/1/rate").and_return(nil)
      expect(described_class.get_port_rate("mlx4_0")).to be_nil
    end
  end
end
