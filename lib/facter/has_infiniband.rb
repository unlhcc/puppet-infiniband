require 'facter/util/infiniband'

Facter.add(:has_infiniband) do
  confine :kernel => "Linux"
  setcode do
    if Facter::Util::Infiniband.has_mellanox_card?
      has_infiniband = true
    else
      has_infiniband = false
    end
    has_infiniband
  end
end
