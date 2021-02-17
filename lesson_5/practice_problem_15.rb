arr = [{a: [1, 2, 3]}, {b: [2, 4, 6], c: [3, 6], d: [4]}, {e: [8], f: [6, 10]}]

only_evens = arr.select do |hash|
  hash.reduce(true) do |memo, (_, value)|
    is_all_even = value.all? {|num| num.even?}
    memo && is_all_even ? true : false
  end
end

puts only_evens

# NOTE: The LS solution is simpler to read. Rather than using #reduce, I could've nested an additional call to #all? As long as the outer #select block is receiving the appropriate boolean value, it will work out.

# Staff solution is:
# arr.select do |hsh|
#   hsh.all? do |_, value|
#     value.all? do |num|
#       num.even?
#     end
#   end
# end
