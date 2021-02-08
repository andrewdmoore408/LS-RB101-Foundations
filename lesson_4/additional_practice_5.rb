flintstones = %w(Fred Barney Wilma Betty BamBam Pebbles)

index_first_be = nil

flintstones.each_with_index do |name, index|
  if name.start_with?('Be') && index_first_be == nil
    index_first_be = index
  end
end

puts index_first_be
