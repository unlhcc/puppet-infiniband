require 'spec_helper'

describe 'infiniband_fw_version fact' do

  before :each do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:has_infiniband).stubs(:value).returns(true)
    Facter::Util::Resolution.stubs(:which).with("lspci").returns("/sbin/lspci")
    Facter::Util::Resolution.stubs(:which).with("mstflint").returns("/usr/bin/mstflint")
  end

  it "should return infiniband_fw_version fact" do
    Facter::Util::Infiniband.stubs(:get_fw_version).returns('2.9.1200')
    Facter.fact(:infiniband_fw_version).value.should == '2.9.1200'
  end

  it "should be nil if device_id not found" do
    Facter::Util::Resolution.stubs(:exec).with('lspci -nn').returns(nil)
    Facter::Util::Infiniband.expects(:get_fw_version).returns(nil)
    Facter.fact(:infiniband_fw_version).value.should == nil
  end

  it "should be nil if mstflint is not installed" do
    Facter::Util::Resolution.stubs(:which).with("mstflint").returns(nil)
    Facter::Util::Infiniband.expects(:get_fw_version).returns(nil)
    Facter.fact(:infiniband_fw_version).value.should == nil
  end

  it "should be nil if mstflint query returns nil" do
    Facter::Util::Resolution.stubs(:exec).with("mstflint -device 83:00.0 -qq query").returns(nil)
    Facter::Util::Infiniband.expects(:get_fw_version).returns(nil)
    Facter.fact(:infiniband_fw_version).value.should == nil
  end
end
