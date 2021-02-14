arr = ['10', '11', '9', '7', '8']

puts arr.sort { |a, b| b.to_i <=> a.to_i }
