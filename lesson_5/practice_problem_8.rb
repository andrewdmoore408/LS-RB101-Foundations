hsh = {first: ['the', 'quick'], second: ['brown', 'fox'], third: ['jumped'], fourth: ['over', 'the', 'lazy', 'dog']}

VOWELS = 'AEIOUaeiou'

hsh.each do |k, v|
  v.each do |word|
    word.chars.each do |char|
      puts char if VOWELS.include?(char)
    end
  end
end
