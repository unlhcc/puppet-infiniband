# infiniband.rb

module Facter::Util::Infiniband
  class << self
  def has_mellanox_card?
    lspci_match_string = "(InfiniBand|Network controller|Ethernet controller|Memory controller): Mellanox Technolog"
    count = Facter::Util::Resolution.exec("lspci 2>/dev/null | grep -E \"#{lspci_match_string}\" | wc -l").to_i
    if count > 0
      true
    else
      false
    end
  end
  end
end
