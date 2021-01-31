VALID_CHOICES = %w(rock paper scissors lizard spock)

DEFEATS = {
  VALID_CHOICES[0] => [VALID_CHOICES[3], VALID_CHOICES[2]],
  VALID_CHOICES[1] => [VALID_CHOICES[0], VALID_CHOICES[4]],
  VALID_CHOICES[2] => [VALID_CHOICES[1], VALID_CHOICES[3]],
  VALID_CHOICES[3] => [VALID_CHOICES[4], VALID_CHOICES[1]],
  VALID_CHOICES[4] => [VALID_CHOICES[2], VALID_CHOICES[0]]
}

CHOICE_ABBREVIATIONS = {
  'r' => 'rock',
  'p' => 'paper',
  's' => 'scissors',
  'l' => 'lizard',
  'k' => 'spock'
}

def win?(first, second)
  DEFEATS[first].include?(second)
end

def get_result(choice, computer_choice)
  if win?(choice, computer_choice)
    :player 
  elsif win?(computer_choice, choice)
    :computer 
  else
    :tie
  end
end

def display_result(winner)
  case winner
  when :player then prompt "You won!"
  when :computer then prompt "Computer won!"
  when :tie then prompt "Tie...no winner..."
  end
end

def prompt(message)
  Kernel.puts("=> #{message}")
end

def display_points(points)
  scores = <<-SCORE
  You: #{points[:player]}     -     Computer: #{points[:computer]}
            Ties: #{points[:tie]}
  SCORE

  prompt("\n\n#{scores}\n\n")
end

# main game loop
loop do

  points = { player: 0, computer: 0, tie: 0 }
  keep_playing = 'n'
  
  loop do
    choice = ''
  
    loop do
      prompt("Choose one: #{VALID_CHOICES.join(', ')}")
      prompt("You can also just use first letter (k for spock)")
      choice = Kernel.gets().chomp()
  
      if choice.size == 1 && CHOICE_ABBREVIATIONS[choice]
        choice = CHOICE_ABBREVIATIONS[choice]
      end
  
      if VALID_CHOICES.include?(choice)
        break
      else
        prompt("That's not a valid choice.")
      end
    end
  
    computer_choice = VALID_CHOICES.sample
  
    prompt("You chose: #{choice}; Computer chose: #{computer_choice}")
  
    result = get_result(choice, computer_choice)
    display_result(result)

    points[result] += 1

    if points[:player] == 5 || points[:computer] == 5
      prompt("\n\nGAME OVER!\n\n#{points[:player] == 5 ? "You" : "Computer"} won!")
      break
    else
      display_points(points)
    end
    
    prompt("Do you want to keep going?")
    keep_playing = Kernel.gets().chomp()
  
    break unless keep_playing.downcase().start_with?("y")
  end 

  break if keep_playing != 'y'

  prompt("Good game! Another round?")

  answer = Kernel.gets().chomp()
  break unless answer.downcase().start_with?('y')
end

prompt "Thank you for playing. Goodbye!"
