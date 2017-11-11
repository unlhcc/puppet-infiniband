require 'spec_helper'
require 'facter/util/file_read'
require 'facter/util/infiniband'

describe Facter::Util::Infiniband do

  before :each do
    Facter.clear
  end

  describe 'lspci' do
    it 'should return output' do
      Facter::Util::Resolution.expects(:exec).with('lspci -n 2>/dev/null').returns("foo")
      expect(Facter::Util::Infiniband.lspci).to eq("foo")
    end
  end

  describe 'read_sysfs' do
    it 'should return output' do
      File.expects(:exist?).with('/sys/class/infiniband/mlx4_0/fw_ver').returns(true)
      Facter::Util::Resolution.expects(:exec).with("cat /sys/class/infiniband/mlx4_0/fw_ver").returns("2.9.1200\n")
      expect(Facter::Util::Infiniband.read_sysfs("/sys/class/infiniband/mlx4_0/fw_ver")).to eq("2.9.1200")
    end

    it 'should return nil' do
      File.expects(:exist?).with('/sys/class/infiniband/mlx4_0/fw_ver').returns(true)
      Facter::Util::Resolution.expects(:exec).with("cat /sys/class/infiniband/mlx4_0/fw_ver").returns(nil)
      expect(Facter::Util::Infiniband.read_sysfs("/sys/class/infiniband/mlx4_0/fw_ver")).to be_nil
    end
  end

  describe 'count_ib_devices' do
    it 'should return 1' do
      Facter::Util::Resolution.expects(:which).with('lspci').returns(true)
      Facter::Util::Infiniband.expects(:lspci).with().returns(my_fixture_read('mellanox_lspci_1'))
      expect(Facter::Util::Infiniband.count_ib_devices).to eq(1)
    end

    it 'should return 0' do
      Facter::Util::Resolution.expects(:which).with('lspci').returns(true)
      Facter::Util::Infiniband.expects(:lspci).with().returns(my_fixture_read('noib_lspci_1'))
      expect(Facter::Util::Infiniband.count_ib_devices).to eq(0)
    end

    it 'should return 0' do
      Facter::Util::Resolution.expects(:which).with('lspci').returns(false)
      expect(Facter::Util::Infiniband.count_ib_devices).to eq(0)
    end
  end

  describe 'get_port_fw_version' do
    it 'should return fw_ver for mlx devices' do
      Facter::Util::Infiniband.expects(:read_sysfs).with("/sys/class/infiniband/mlx4_0/fw_ver").returns("2.9.1200")
      expect(Facter::Util::Infiniband.get_port_fw_version("mlx4_0")).to eq("2.9.1200")
    end

    it 'should return nil' do
      Facter::Util::Infiniband.expects(:read_sysfs).with("/sys/class/infiniband/mlx4_0/fw_ver").returns(nil)
      expect(Facter::Util::Infiniband.get_port_fw_version("mlx4_0")).to be_nil
    end

    it 'should return nil' do
      Facter::Util::Infiniband.expects(:read_sysfs).never
      expect(Facter::Util::Infiniband.get_port_fw_version("foo")).to be_nil
    end
  end

  describe 'get_port_board_id' do
    it 'should return board_id' do
      Facter::Util::Infiniband.expects(:read_sysfs).with("/sys/class/infiniband/mlx4_0/board_id").returns("MT_0000000000")
      expect(Facter::Util::Infiniband.get_port_board_id("mlx4_0")).to eq("MT_0000000000")
    end

    it 'should return nil' do
      Facter::Util::Infiniband.expects(:read_sysfs).with("/sys/class/infiniband/mlx4_0/fw_ver").returns(nil)
      expect(Facter::Util::Infiniband.get_port_fw_version("mlx4_0")).to be_nil
    end
  end

  describe 'get_ports' do
    it "should return a array with single port name" do
      Dir.stubs(:glob).with("/sys/class/infiniband/*").returns(["/sys/class/infiniband/mlx4_0"])
      expect(Facter::Util::Infiniband.get_ports).to eq(["mlx4_0"])
    end

    it "should return a array with two port names" do
      Dir.stubs(:glob).with("/sys/class/infiniband/*").returns(["/sys/class/infiniband/mlx4_0","/sys/class/infiniband/mlx4_1"])
      expect(Facter::Util::Infiniband.get_ports).to eq(["mlx4_0","mlx4_1"])
    end

    it "should return empty array if no ports exist" do
      Dir.stubs(:glob).with("/sys/class/infiniband/*").returns([])
      expect(Facter::Util::Infiniband.get_ports).to eq([])
    end
  end

  describe 'get_port_rate' do
    it 'should return rate for DDR device' do
      Dir.expects(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').returns(['/sys/class/infiniband/mlx4_0/ports/1'])
      Facter::Util::Infiniband.expects(:read_sysfs).with("/sys/class/infiniband/mlx4_0/ports/1/rate").returns("20 Gb/sec (4X DDR)")
      expect(Facter::Util::Infiniband.get_port_rate("mlx4_0")).to eq("20 Gb/sec (4X DDR)")
    end

    it 'should return nil when Dir.glob is empty' do
      Dir.expects(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').returns([])
      expect(Facter::Util::Infiniband.get_port_rate("mlx4_0")).to be_nil
    end

    it 'should return nil when read_sysfs is nil' do
      Dir.expects(:glob).with('/sys/class/infiniband/mlx4_0/ports/*').returns(['/sys/class/infiniband/mlx4_0/ports/1'])
      Facter::Util::Infiniband.expects(:read_sysfs).with("/sys/class/infiniband/mlx4_0/ports/1/rate").returns(nil)
      expect(Facter::Util::Infiniband.get_port_rate("mlx4_0")).to be_nil
    end
  end
end
