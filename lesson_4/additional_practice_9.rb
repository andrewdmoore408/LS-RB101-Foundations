def titleize(string)

counter = 0

string.each_char do |char|
  if string[counter - 1] == ' ' || counter == 0
    string[counter] = char.upcase
  end
  counter += 1
end

string

end

puts titleize("this is a test")
puts titleize('i hope this works?')
puts titleize('  curious about these spaces...   ')
