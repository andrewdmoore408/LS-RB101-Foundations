hsh = {
  'grape' => {type: 'fruit', colors: ['red', 'green'], size: 'small'},
  'carrot' => {type: 'vegetable', colors: ['orange'], size: 'medium'},
  'apple' => {type: 'fruit', colors: ['red', 'green'], size: 'medium'},
  'apricot' => {type: 'fruit', colors: ['orange'], size: 'medium'},
  'marrow' => {type: 'vegetable', colors: ['green'], size: 'large'},
}

arr = hsh.each_with_object([]) do |(key, value), a|
  if value[:type] == 'fruit'
    a << (value[:colors].map {|color| color.capitalize!})
  else
    a << (value[:size].upcase)
  end
end

p arr
