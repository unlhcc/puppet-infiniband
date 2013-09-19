require 'spec_helper'

describe 'has_infiniband fact' do

  before :each do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Util::Resolution.stubs(:which).with("lspci").returns("/sbin/lspci")
  end

  it "should return true when count_ib_devices is 1" do
    Facter::Util::Infiniband.stubs(:count_ib_devices).with().returns(1)
    Facter.fact(:has_infiniband).value.should == true
  end

  it "should return true when count_ib_devices is 2" do
    Facter::Util::Infiniband.stubs(:count_ib_devices).with().returns(2)
    Facter.fact(:has_infiniband).value.should == true
  end

  it "should return false count_ib_devices is 0" do
    Facter::Util::Infiniband.stubs(:count_ib_devices).with().returns(0)
    Facter.fact(:has_infiniband).value.should == false
  end
end
