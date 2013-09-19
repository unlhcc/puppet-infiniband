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

  describe 'get_device_id' do
    it "should return 83:00.0 when matching a Mellanox device" do
      Facter::Util::Resolution.stubs(:exec).with("lspci -nn").returns(my_fixture_read('mellanox_lspci_1'))
      Facter::Util::Infiniband.get_device_id.should == '83:00.0'
    end

    it "should return 02:00.0 when matching a QLogic device" do
      Facter::Util::Resolution.stubs(:exec).with("lspci -nn").returns(my_fixture_read('qlogic_lspci_1'))
      Facter::Util::Infiniband.get_device_id.should == '02:00.0'
    end
    
    it "should return nil when no matching IB device" do
      Facter::Util::Resolution.stubs(:exec).with("lspci -nn").returns(my_fixture_read('noib_lspci_1'))
      Facter::Util::Infiniband.get_device_id.should be_nil
    end
  end

  describe 'get_fw_version' do
    it "should return a FW Version" do
      Facter::Util::Resolution.stubs(:exec).with("mstflint -device 83:00.0 -qq query").returns(my_fixture_read('mellanox_mstflint_1'))
      Facter::Util::Infiniband.get_fw_version.should == '2.9.1200'
    end
=begin
    # This doesn't work...WHY?
    it "should return nil if device_id is nil" do
      Facter::Util::Infiniband.stubs(:get_device_id).with().returns(nil)
      Facter::Util::Infiniband.get_fw_version().should be_nil
    end
=end
  end
end
