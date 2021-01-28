# ask the user for two numbers
# ask user which operation to perform
# perform that operation on the two arguments given
# output that result

# answer = gets.chomp
# prompt answer

def prompt(message)
  puts "=> #{message}"
end

def valid_number?(num)
  num.to_i != 0
end

def operation_to_message(operator)
  message = case operator
            when 1 then 'Adding'
            when 2 then 'Subtracting'
            when 3 then 'Multiplying'
            when 4 then 'Dividing'
            end
  message
end

prompt "Welcome to Calculator! Enter your name:"

name = ''
loop do
  name = gets.chomp

  if name.empty?
    prompt "You have to enter a valid name!"
  else
    break
  end
end

prompt "Hello, #{name}!"

loop do # main loop
  num1 = ''

  loop do
    prompt "What's the first number?"
    num1 = gets.chomp.to_i

    if valid_number?(num1)
      break
    else
      prompt "Hmm... that's not a valid number"
    end
  end

  num2 = ''

  loop do
    prompt "What's the second number?"
    num2 = gets.chomp.to_i

    if valid_number?(num2)
      break
    else
      prompt "Hmm... that's not a valid number"
    end
  end

  prompt "num1 = #{num1}; num2 = #{num2}"

  operator_prompt = <<~HEREDOC
	What operation would you like to perform?
	1. add
	2. subtract
	3. multiply
	4. divide
     HEREDOC
 
  operator = nil

  prompt(operator_prompt)

  loop do
    operator = gets.chomp.to_i

    if operator > 0 && operator < 5
      break
    else
      prompt "Must choose 1, 2, 3, or 4"
    end
  end

  prompt("#{operation_to_message(operator)} the two numbers...")
  
  result = case operator
           when 1
             num1 + num2
           when 2
             num1 - num2
           when 3
             num1 * num2
           when 4
             num1.to_f / num2.to_f
           end

  prompt "Result: #{result}"

  prompt "Do you want to perform another calculation? (Y to calculate again)"

  answer = gets.chomp

  break unless answer.downcase.start_with?('y')
 
end

prompt "Thanks and Calc-YOU-Later!"
