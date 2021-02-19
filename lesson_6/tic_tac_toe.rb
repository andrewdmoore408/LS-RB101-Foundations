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

def detect_winner(board)
  WINNING_LINES.each do |line|
    if line.all? { |square| board[square] == PLAYER_MARKER }
      return "Player"
    elsif line.all? { |square| board[square] == COMPUTER_MARKER }
      return "Computer"
    end
  end

  nil
end

def someone_won?(board)
  !!detect_winner(board)
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

loop do
  board = initialize_board

  loop do
    display_board(board)

    player_places_piece!(board)
    break if someone_won?(board) || board_full?(board)

    computer_places_piece!(board)
    break if someone_won?(board) || board_full?(board)
  end

  display_board(board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"
  else
    prompt "It's a tie..."
  end

  prompt "Would you like to play again? (y/n)"
  play_again = gets.chomp.downcase

  break unless play_again.start_with?('y')
end

prompt "Thanks for playing Tic Tac Toe! Goodbye."
