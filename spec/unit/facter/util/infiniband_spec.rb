require 'spec_helper'
require 'facter/util/infiniband'

describe Facter::Util::Infiniband do

  before :each do
    Facter.clear
  end
  
  describe 'count_ib_devices' do
    it "should return 1 with Mellanox card" do
      Facter::Util::Resolution.stubs(:exec).with("lspci -nn").returns(my_fixture_read('mellanox_lspci_1'))
      Facter::Util::Infiniband.count_ib_devices == 1
    end

    it "should return 1 with QLogic card" do
      Facter::Util::Resolution.stubs(:exec).with("lspci -nn").returns(my_fixture_read('qlogic_lspci_1'))
      Facter::Util::Infiniband.count_ib_devices == 1
    end

    it "should return 0 without InfiniBand" do
      Facter::Util::Resolution.stubs(:exec).with("lspci -nn").returns(my_fixture_read('noib_lspci_1'))
      Facter::Util::Infiniband.count_ib_devices == 0
    end
  end

  describe 'get_port_fw_version' do
    it 'should return fw_ver for mlx devices' do
      Facter::Util::Infiniband.expects(:read_fw_version).with("/sys/class/infiniband/mlx4_0/fw_ver").returns("2.9.1200")
      Facter::Util::Infiniband.get_port_fw_version("mlx4_0").should == "2.9.1200"
    end
  end

  describe 'get_ports' do
    before :each do
      Facter::Util::Resolution.stubs(:which).with("ibstat").returns("/usr/sbin/ibstat")
    end

    it "should return a array with single port name" do
      Facter::Util::Resolution.stubs(:exec).with("ibstat -l").returns("mlx4_0")
      Facter::Util::Infiniband.get_ports.should == ["mlx4_0"]
    end

    it "should return a array with two port names" do
      Facter::Util::Resolution.stubs(:exec).with("ibstat -l").returns("mlx4_0\nmlx4_1")
      Facter::Util::Infiniband.get_ports.should == ["mlx4_0","mlx4_1"]
    end
    
    it "should return nil if ibstat not found" do
      Facter::Util::Resolution.stubs(:which).with("ibstat").returns(nil)
      Facter::Util::Infiniband.get_ports.should be_nil
    end

    it "should return nil if ibstat -l returns nothing" do
      Facter::Util::Resolution.stubs(:exec).with("ibstat -l").returns("")
      Facter::Util::Infiniband.get_ports.should be_nil
    end
  end
end
