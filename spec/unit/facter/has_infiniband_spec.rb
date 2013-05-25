require 'spec_helper'
require 'facter/has_infiniband'

describe 'has_infiniband fact' do

  before :each do
    Facter::Util::Resolution.stubs(:which).with("lspci").returns("/sbin/lspci")
  end

  it "should return true with Mellanox card" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Util::Resolution.stubs(:exec).with("lspci").returns(my_fixture_read('mellanox_connectx_example1_lspci'))
    Facter.fact(:has_infiniband).value.should == true
  end

  it "should return true with QLogic card" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter::Util::Resolution.stubs(:exec).with("lspci").returns(my_fixture_read('qlogic_infiniband_lspci'))
    Facter.fact(:has_infiniband).value.should == true
  end
=begin    
  context "has_infiniband is true" do
    it "should return true" do
      Facter::Util::Resolution.expects(:exec).with("lspci 2>/dev/null | grep -E \"(InfiniBand|Network controller|Ethernet controller|Memory controller): Mellanox Technolog\" | wc -l").returns('1')
      Facter::Util::Infiniband.has_mellanox_card?.should == true
    end
  end
  
  context "has_infiniband is false" do
    it "should return false" do
      Facter::Util::Resolution.expects(:exec).with("lspci 2>/dev/null | grep -E \"(InfiniBand|Network controller|Ethernet controller|Memory controller): Mellanox Technolog\" | wc -l").returns('0')
      Facter::Util::Infiniband.has_mellanox_card?.should == false
    end
  end
=end
end
