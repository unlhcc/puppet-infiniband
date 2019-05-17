Puppet::Functions.create_function(:'infiniband::calc_log_num_mtt') do
  dispatch :calc do
    optional_param 'Variant[Undef,Integer,Float]', :mem
    optional_param 'Integer', :log_mtts_per_seg
    optional_param 'Integer', :page_size_bytes
  end

  def calc(mem = 0, log_mtts_per_seg = 3, page_size_bytes = 4096)
    return 0 if mem.nil?

    log_mtts_per_seg_multiplier = 2**log_mtts_per_seg.to_i

    reg_mem = mem * 2

    result = 0
    i = 1
    while result == 0 do
      target = (2**i) * page_size_bytes.to_i * log_mtts_per_seg_multiplier
      target_next = (2**(i+1)) * page_size_bytes.to_i * log_mtts_per_seg_multiplier

      if target > reg_mem
        break
      elsif target == reg_mem
        result = i
      elsif target < reg_mem and target_next > reg_mem
        result = i + 1
      end

      i += 1
    end

    result
  end
end
