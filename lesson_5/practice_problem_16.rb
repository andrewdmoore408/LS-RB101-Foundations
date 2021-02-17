def get_uuid
  pattern = [8, 4, 4, 4, 12]

  hex_string_arr = rand(3.4e38).to_s(16).chars

  while hex_string_arr.size < 32
    hex_string_arr.unshift('0')
  end

  uuid_string = []

  pattern.each do |num|
    uuid_string << hex_string_arr.shift(num)

    if hex_string_arr.size > 0
      uuid_string << '-'
    end
  end

  uuid_string.flatten!.join  
  
end

puts get_uuid


  
