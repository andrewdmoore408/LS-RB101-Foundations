statement = 'This is a test string. This is only a test of the method system.'

frequency_hash = Hash.new(0)

LETTERS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

statement.chars.each_with_object(frequency_hash) do |letter, hash|
  if LETTERS.include?(letter) 
    hash[letter] += 1
  end
end

puts frequency_hash

