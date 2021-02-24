require 'pry'
require 'pry-byebug'

# Constants for square values
PLAYER_MARKER = 'X'
COMPUTER_MARKER_ONE = 'O'
COMPUTER_MARKER_TWO = 'L'
COMPUTER_MARKERS = { 'Computer1' => COMPUTER_MARKER_ONE,
                     'Computer2' => COMPUTER_MARKER_TWO }
INITIAL_MARKER = ' '

GAMES_TO_WIN_A_ROUND = 5

BOARD_SIDE_LENGTH = 5
BOARD_NUM_SQUARES = BOARD_SIDE_LENGTH**2

LINE_ALMOST_COMPLETE = BOARD_SIDE_LENGTH - 1

CENTER_SQUARE = (BOARD_NUM_SQUARES / 2.0).round

FIRST_PLAYER = "Choose"

def calculate_winning_rows(length)
  rows = []

  (0...length).each do |row_offset|
    row = []

    (1..length).each do |square|
      row.push(row_offset * length + square)
    end

    rows.push(row)
  end

  rows
end

def calculate_winning_columns(length)
  columns = []

  (1..length).each do |square|
    column = []

    (0...length).each do |column_offset|
      column.push(column_offset * length + square)
    end

    columns.push(column)
  end

  columns
end

def calculate_winning_diagonals(length)
  # down_diagonal is constructed from top left to bottom right of board
  # up_diagonal is constructed from top right to bottom left of board
  down_diagonal_square = 1
  up_diagonal_square = length

  down_diagonal_line = [down_diagonal_square]
  up_diagonal_line = [up_diagonal_square]

  down_diagonal_shift = length + 1
  up_diagonal_shift = length - 1

  (1...length).each do |_|
    down_diagonal_square += down_diagonal_shift
    up_diagonal_square += up_diagonal_shift

    down_diagonal_line.push(down_diagonal_square)
    up_diagonal_line.push(up_diagonal_square)
  end

  [down_diagonal_line, up_diagonal_line]
end

def calculate_winning_lines
  length = BOARD_SIDE_LENGTH

  lines = []

  rows = calculate_winning_rows(length)
  columns = calculate_winning_columns(length)
  diagonals = calculate_winning_diagonals(length)

  rows.each { |row| lines.push(row) }
  columns.each { |column| lines.push(column) }
  diagonals.each { |diagonal| lines.push(diagonal) }

  lines
end

WINNING_LINES = calculate_winning_lines

def prompt(msg)
  puts "=>  #{msg}"
end

def initialize_board
  new_board = {}
  (1..BOARD_NUM_SQUARES).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def initialize_row_arr
  row = []
  4.times { |_| row.push('|') }

  row
end

def initialize_display
  system 'clear'
  puts "You play #{PLAYER_MARKER}. Computer 1 plays #{COMPUTER_MARKER_ONE}. " \
       "Computer 2 plays #{COMPUTER_MARKER_TWO}.\n"
end

def display_board(board)
  initialize_display

  board_arr = []

  BOARD_SIDE_LENGTH.times do |row|
    row_offset = (row) * BOARD_SIDE_LENGTH
    row_arr = initialize_row_arr

    BOARD_SIDE_LENGTH.times do |square|
      row_arr[0] += '       |'
      row_arr[1] += "   #{board[row_offset + square + 1]}   |"
      row_arr[2] += '       |'
      row_arr[3] += '-------+'
    end

    board_arr << row_arr
  end

  puts board_arr
end

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

def computer_places_piece!(board, computer_name)
  # byebug
  computer_choice = if square_to_choose?(board, computer_name)
                      find_computer_move(board, computer_name)
                    else
                      empty_squares(board).sample
                    end

  board[computer_choice] = COMPUTER_MARKERS[computer_name]
end

def board_full?(board)
  empty_squares(board).empty?
end

# rubocop:disable Metrics/CyclomaticComplexity
def detect_winner_game(board)
  WINNING_LINES.each do |line|
    if line.all? { |square| board[square] == PLAYER_MARKER }
      return "Player"
    elsif line.all? { |square| board[square] == COMPUTER_MARKER_ONE }
      return "Computer1"
    elsif line.all? { |square| board[square] == COMPUTER_MARKER_TWO }
      return "Computer2"
    end
  end

  nil
end
# rubocop:enable Metrics/CyclomaticComplexity

def detect_winner_round(scores)
  winner_arr = scores.select { |_, v| v == GAMES_TO_WIN_A_ROUND }.to_a
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
  prompt "Player: #{scores['Player']}\tComputer 1: #{scores['Computer1']}\t" \
         "Computer 2: #{scores['Computer2']}"
  puts
end

def square_to_choose?(board, current_player)
  !!find_computer_move(board, current_player)
end

def select_square(board, marker)
  WINNING_LINES.each do |line|
    squares_arr = board.values_at(*line)

    if squares_arr.count(marker) == LINE_ALMOST_COMPLETE &&
       squares_arr.count(INITIAL_MARKER) == 1
      line.each do |square_num|
        return square_num if board[square_num] == INITIAL_MARKER
      end
    end
  end

  nil
end

def find_computer_move(board, computer_name)
  # AI offense: try to win
  computer_choice = select_square(board, COMPUTER_MARKERS[computer_name])

  # AI defense: try to block other players
  computer_choice ||= select_square(board, PLAYER_MARKER)

  other_computer = (computer_name == 'Computer1' ? 'Computer2' : 'Computer1')
  computer_choice ||= select_square(board, COMPUTER_MARKERS[other_computer])

  if computer_choice.nil? && empty_squares(board).include?(CENTER_SQUARE)
    computer_choice = CENTER_SQUARE
  end

  computer_choice
end

def place_piece!(board, current_player)
  if current_player == "Player"
    player_places_piece!(board)
  else
    computer_places_piece!(board, current_player)
  end
end

def alternate_player(current_player)
  case current_player
  when "Player" then "Computer1"
  when "Computer1" then "Computer2"
  when "Computer2" then "Player"
  end
end

# Set player order
if FIRST_PLAYER == "Choose"
  prompt "Which player will be player one?"
  prompt "Input 'p' for player, otherwise computer will play first"
  answer = gets.chomp.downcase
  PLAYER_ONE = (answer.start_with?('p') ? "Player" : "Computer1")
else
  PLAYER_ONE = FIRST_PLAYER
end

# Main loop
# Start of a round (best of 5 games wins)
loop do
  current_round_scores = { 'Player' => 0, 'Computer1' => 0, 'Computer2' => 0 }
  round_winner = nil
  play_another_game = nil

  # Start of a game
  loop do
    board = initialize_board
    current_player = PLAYER_ONE

    loop do
      display_board(board)

      place_piece!(board, current_player)
      current_player = alternate_player(current_player)

      break if someone_won_game?(board) || board_full?(board)
    end

    display_board(board)

    if someone_won_game?(board)
      winner = detect_winner_game(board)
      prompt "#{winner} won!"
      current_round_scores[winner] += 1
    else
      prompt "It's a tie..."
    end

    display_scores(current_round_scores)

    # Break out of the round loop if someone won enough games
    if someone_won_round?(current_round_scores)
      round_winner = detect_winner_round(current_round_scores)
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
