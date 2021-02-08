ages = { "Herman" => 32, "Lily" => 30, "Grandpa" => 5843, "Eddie" => 10, "Marilyn" => 22, "Spot" => 237 }

minimum_age = nil

ages.each do |key, value| 

  if minimum_age.nil?
    minimum_age = value
  elsif value < minimum_age
    minimum_age = value
  end
end

puts "minimum_age is: #{minimum_age}"
