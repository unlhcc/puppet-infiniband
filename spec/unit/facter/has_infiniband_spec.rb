require 'spec_helper'
require 'facter/has_infiniband'

describe Facter::Util::Infiniband do
  before { Facter.clear }
  after  { Facter.clear }
    
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
end
