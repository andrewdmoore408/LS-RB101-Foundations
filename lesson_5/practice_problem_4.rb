arr1 = [1, [2, 3], 4]
arr2 = [{a: 1}, {b: 2, c: [7, 6, 5], d: 4}, 3]

hsh1 = {first: [1, 2, [3]]}
hsh2 = {['a'] => {a: ['1', :two, 3], b: 4}, 'b' => 5}

arr1[1][1] = 4
arr2[2] = 4

hsh1[:first][2][0] = 4
hsh2[['a']][:a][2] = 4

puts "arr1: #{arr1}"
puts "arr2: #{arr2}"

puts "hsh1: #{hsh1}"
puts "hsh2: #{hsh2}"
