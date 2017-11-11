require 'spec_helper'

describe 'infiniband_rate fact' do
  
  before :each do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:has_infiniband).stubs(:value).returns(true)
  end
  
  it "should handle a single port" do
    Facter::Util::Infiniband.stubs(:get_ports).returns(["mlx4_0"])
    Facter::Util::Infiniband.stubs(:get_port_rate).with("mlx4_0").returns("20 Gb/sec (4X DDR)")
    expect(Facter.fact(:infiniband_rate).value).to eq("20")
  end

  it "should handle multiple ports" do
    Facter::Util::Infiniband.stubs(:get_ports).returns(["mlx4_0","mlx4_1"])
    Facter::Util::Infiniband.stubs(:get_port_rate).with("mlx4_0").returns("20 Gb/sec (4X DDR)")
    expect(Facter.fact(:infiniband_rate).value).to eq("20")
  end
  
  it "should return nil for unknown port name" do
    Facter::Util::Infiniband.stubs(:get_ports).returns(["foo"])
    Facter::Util::Infiniband.stubs(:get_port_rate).with("foo").returns(nil)
    expect(Facter.fact(:infiniband_rate).value).to be_nil
  end

  it "should return nil if no ports found" do
    Facter::Util::Infiniband.stubs(:get_ports).returns([])
    expect(Facter.fact(:infiniband_rate).value).to be_nil
  end
end
