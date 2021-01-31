VALID_CHOICES = %w(rock paper scissors lizard spock)

DEFEATS = { 
  VALID_CHOICES[0] => [VALID_CHOICES[3], VALID_CHOICES[2]],
  VALID_CHOICES[1] => [VALID_CHOICES[0], VALID_CHOICES[4]], 
  VALID_CHOICES[2] => [VALID_CHOICES[1], VALID_CHOICES[3]], 
  VALID_CHOICES[3] => [VALID_CHOICES[4], VALID_CHOICES[1]],
  VALID_CHOICES[4] => [VALID_CHOICES[2], VALID_CHOICES[0]]
}

def win?(first, second)
  DEFEATS[first].include?(second)
end

def display_result(choice, computer_choice)
  if win?(choice, computer_choice)
    prompt("You won!")
  elsif win?(computer_choice, choice)
    prompt("Computer won!")
  else
    prompt("You tied!")
  end
end

def prompt(message)
  Kernel.puts("=> #{message}")
end

loop do
  choice = ''

  loop do
    prompt("Choose one: #{VALID_CHOICES.join(', ')}")
    choice = Kernel.gets().chomp()

    if VALID_CHOICES.include?(choice)
      break
    else
      prompt("That's not a valid choice.")
    end
  end

  computer_choice = VALID_CHOICES.sample

  prompt("You chose: #{choice}; Computer chose: #{computer_choice}")

  display_result(choice, computer_choice)

  prompt("Do you want to play again?")
  answer = Kernel.gets().chomp()

  break unless answer.downcase().start_with?("y")
end

prompt "Thank you for playing. Goodbye!"
