arr = [{a: 1}, {b: 2, c: 3}, {d: 4, e: 5, f: 6}]

new_arr = arr.map do |hash|
  hash.each do |k, v|
    v += 1 
  end
end

puts new_arr

# I thought I had solved this but was mistaken. Looking at the solution, each_with_object([]) could be used, or map with a new hash being built and added to inside an inner each block. 

# I need to remember that #map always returns an array.
