flintstones = ["Fred", "Barney", "Wilma", "Betty", "Pebbles", "BamBam"]

flintstones_hash = {}

flintstones.each_with_index do |item, index|
  flintstones_hash[item] = index
end

puts flintstones_hash
   
