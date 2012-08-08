all_streets = result.each_value.flat_map(&:values).flatten(1)
counts      = Hash.new(0)
all_streets.each do |street|
  counts[street] += 1
end
