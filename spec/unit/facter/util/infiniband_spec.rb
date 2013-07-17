require 'spec_helper'
require 'facter/util/infiniband'

describe Facter::Util::Infiniband do

  before :each do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:has_infiniband).stubs(:value).returns(true)
    Facter::Util::Resolution.stubs(:which).with("lspci").returns("/sbin/lspci")
    Facter::Util::Resolution.stubs(:which).with("mstflint").returns("/usr/bin/mstflint")
  end

  describe 'get_device_id' do
    it "should return a device ID" do
      Facter::Util::Resolution.stubs(:exec).with("lspci -d 15b3:").returns(my_fixture_read('mellanox_lspci'))
      Facter::Util::Infiniband.get_device_id.should == '03:00.0'
    end
  end

  describe 'get_fw_version' do
    it "should return a FW Version" do
      Facter::Util::Resolution.stubs(:exec).with("mstflint -device 03:00.0 -qq query").returns(my_fixture_read('mellanox_mstflint'))
      Facter::Util::Infiniband.get_fw_version.should == '2.9.1200'
    end
  end
end
