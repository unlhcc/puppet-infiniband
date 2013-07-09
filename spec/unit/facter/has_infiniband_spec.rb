require 'spec_helper'

describe 'has_infiniband fact' do

  before :each do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Util::Resolution.stubs(:which).with("lspci").returns("/sbin/lspci")
  end

  it "should return true with Mellanox card" do
    Facter::Util::Resolution.stubs(:exec).with("lspci").returns(my_fixture_read('mellanox_connectx_example1_lspci'))
    Facter.fact(:has_infiniband).value.should == true
  end

  it "should return true with QLogic card" do
    Facter::Util::Resolution.stubs(:exec).with("lspci").returns(my_fixture_read('qlogic_infiniband_lspci'))
    Facter.fact(:has_infiniband).value.should == true
  end

  it "should return false without InfiniBand" do
    Facter::Util::Resolution.stubs(:exec).with("lspci").returns(my_fixture_read('basic_vm_no_infiniband_lspci'))
    Facter.fact(:has_infiniband).value.should == false
  end
end
