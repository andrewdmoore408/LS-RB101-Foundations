# ask the user for two numbers
# ask user which operation to perform
# perform that operation on the two arguments given
# output that result

# answer = gets.chomp
# puts answer 

puts "Welcome to Calculator!"

puts "What's the first number?"
num1 = gets.chomp.to_i

puts "What's the second number?"
num2 = gets.chomp.to_i

puts "num1 = #{num1}; num2 = #{num2}"

puts "Which operation would you like to perform? 1. add 2. subtract 3. multiply 4. divide"
operator = gets.chomp.to_i

if operator == 1
  result = num1 + num2
elsif operator == 2
  result = num1 - num2
elsif operator == 3
  result = num1 * num2
elsif operator == 4
  result = num1.to_f / num2.to_f
end

puts "Result: #{result}"
