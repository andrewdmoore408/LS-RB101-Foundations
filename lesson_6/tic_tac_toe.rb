require 'pry'

# Constants for square values
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
INITIAL_MARKER = ' '

# Constant for winning condition
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                [[1, 5, 9], [3, 5, 7]]              # diagonals

def prompt(msg)
  puts "=>  #{msg}"
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

# rubocop: disable Metrics/AbcSize
def display_board(squares)
  system 'clear'
  puts "You play #{PLAYER_MARKER}. Computer plays #{COMPUTER_MARKER}."
  puts
  puts "     |     |     "
  puts "  #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}  "
  puts "     |     |     "
  puts
end
# rubocop: enable Metrics/AbcSize

def empty_squares(board)
  board.keys.select { |num| board[num] == INITIAL_MARKER }
end

def player_places_piece!(board)
  player_choice = ''

  loop do
    prompt "Choose a square: #{joinor(empty_squares(board))}"
    player_choice = gets.chomp.to_i

    break if empty_squares(board).include?(player_choice)

    prompt "Sorry, that choice is invalid."
  end

  board[player_choice] = PLAYER_MARKER
end

def computer_places_piece!(board)
  computer_choice = empty_squares(board).sample
  board[computer_choice] = COMPUTER_MARKER
end

def board_full?(board)
  empty_squares(board).empty?
end

def detect_winner_game(board)
  WINNING_LINES.each do |line|
    if line.all? { |square| board[square] == PLAYER_MARKER }
      return "Player"
    elsif line.all? { |square| board[square] == COMPUTER_MARKER }
      return "Computer"
    end
  end

  nil
end

def detect_winner_round(scores)
  winner_arr = scores.select { |k, v| v == 5 }.to_a
  round_winner = winner_arr.flatten.first
  round_winner
end

def someone_won_game?(board)
  !!detect_winner_game(board)
end

def someone_won_round?(scores)
  !!detect_winner_round(scores)
end

def joinor(arr, separator = ', ', word = 'or')
  if arr.size == 1
    return arr[0].to_s
  elsif arr.size == 2
    return arr.join(" #{word} ")
  end

  last_item = arr.pop.to_s
  joinor_string = arr.join(separator)
  joinor_string.concat(separator, word, ' ', last_item)
  joinor_string
end

def display_scores(scores)
  prompt "The scores for this round:"
  prompt "Player: #{scores['Player']}\tComputer: #{scores['Computer']}"
  puts
end

# Main loop
# Start of a round (best of 5 games wins)
loop do

  games_won = { 'Player' => 0, 'Computer' => 0 }
  round_winner = nil
  play_another_game = nil

  # Start of a game 
  loop do
    board = initialize_board

    loop do
      display_board(board)

      player_places_piece!(board)
      break if someone_won_game?(board) || board_full?(board)

      computer_places_piece!(board)
      break if someone_won_game?(board) || board_full?(board)
    end

    display_board(board)

    if someone_won_game?(board)
      winner = detect_winner_game(board)
      prompt "#{winner} won!"
      games_won[winner] += 1
    else
      prompt "It's a tie..."
    end

    display_scores(games_won)

    # Break out of the round loop if someone won enough games
    if someone_won_round?(games_won)
      round_winner = detect_winner_round(games_won)
      break
    end

    prompt "Continue this round? (y/n)"
    play_another_game = gets.chomp.downcase

    break unless play_another_game.start_with?('y')
  end

  # Quit the main loop if player already asked to quit 
  break unless play_another_game.start_with?('y')

  prompt "#{round_winner} won the round!"

  prompt "Would you like to play another round? (y/n)"
  play_another_round = gets.chomp.downcase

  break unless play_another_round.start_with?('y')
end

prompt "Thanks for playing Tic Tac Toe! Goodbye."
