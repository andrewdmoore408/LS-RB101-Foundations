def prompt(msg)
  puts "~~> #{msg}"
end

def valid_loan_or_apr?(string_num)
  string_num.to_f.positive? && ((string_num.to_f.to_s == string_num) || (string_num.to_i.to_s == string_num))
end

def valid_duration?(string_num)
  string_num.to_i.positive? && (string_num.to_i.to_s == string_num)
end

prompt 'Welcome to the Mortgage Calculator! Enter your name:'

NAME = gets.chomp

prompt "Hi, #{NAME}! Let's get your loan calculated."

loop do

  prompt "What's the total loan amount?"
  
  loan_amount = 0
  
  loop do
    loan_amount = gets.chomp
    if valid_loan_or_apr?(loan_amount)
      loan_amount = loan_amount.to_f
      break
    else
      prompt "That's not a valid loan amount. Try again:"
    end
  end
  
  prompt 'Now, enter the APR for the loan as it reads as a percentage.'
  prompt "For example: if it's 7.5%, you would enter 7.5:"
  
  annual_interest_rate = 0
  
  loop do
    annual_interest_rate = gets.chomp
    if valid_loan_or_apr?(annual_interest_rate)
      annual_interest_rate = annual_interest_rate.to_f / 100
      break
    else
      prompt "That's not a valid interest rate. Try again:"
    end
  end
  
  prompt 'How many months is the duration of your loan?'
  
  loan_duration = 0
  
  loop do
    loan_duration = gets.chomp
    if valid_duration?(loan_duration)
      loan_duration = loan_duration.to_i
      break
    else
      prompt "That's not a valid loan duration. Try again:"
    end
  end
  
  prompt "Thanks! I'm calculating your information now:"
  
  monthly_interest_rate = annual_interest_rate / 12
  
  monthly_payment = loan_amount *
                    (monthly_interest_rate /
                    (1 - (1 + monthly_interest_rate)**(-loan_duration)))
  
  monthly_payment = monthly_payment.round(2)
  
  prompt "Your monthly payment is #{monthly_payment}"

  prompt "Do you want to calculate another monthly payment? (y/n)"

  calculate_again = gets.chomp.downcase[0]

  break unless calculate_again == 'y'

end

prompt "Thanks and see you next time!"
