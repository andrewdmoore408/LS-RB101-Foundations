munsters = {
  "Herman" => { "age" => 32, "gender" => "male" },
  "Lily" => { "age" => 30, "gender" => "female" },
  "Grandpa" => { "age" => 402, "gender" => "male" },
  "Eddie" => { "age" => 10, "gender" => "male" },
  "Marilyn" => { "age" => 23, "gender" => "female"}
}


def get_age_group(num)
  age_group = case num
              when (0..17) then "kid"
              when (18..64) then "adult"
              else "senior"
              end
  age_group
end

munsters.each do |key, value|
  value['age_group'] = get_age_group(value['age'])
end

puts munsters
