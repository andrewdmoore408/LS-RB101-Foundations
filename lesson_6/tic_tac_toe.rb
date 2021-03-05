require 'pry'
require 'pry-byebug'

# Constants for square values
PLAYER_MARKER = 'X'
COMPUTER_MARKER_ZERO = 'O'
COMPUTER_MARKER_ONE = 'L'
MARKERS = { 'Player' => 'X',
            'Computer0' => COMPUTER_MARKER_ZERO,
            'Computer1' => COMPUTER_MARKER_ONE }
INITIAL_MARKER = ' '

GAMES_TO_WIN_A_ROUND = 3

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

def calculate_winning_lines(board_side_length)
  lines = []

  rows = calculate_winning_rows(board_side_length)
  columns = calculate_winning_columns(board_side_length)
  diagonals = calculate_winning_diagonals(board_side_length)

  rows.each { |row| lines.push(row) }
  columns.each { |column| lines.push(column) }
  diagonals.each { |diagonal| lines.push(diagonal) }

  lines
end

def prompt(msg)
  puts "=>  #{msg}"
end

def initialize_board(board_num_squares)
  new_board = {}
  (1..board_num_squares).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def initialize_board_row_arr
  row = []
  4.times { |_| row.push('|') }

  row
end

def display_header
  system 'clear'

  header_string = ""

  PLAYERS.each do |player|
    player_name = player[:name]
    header_string += "#{player_name} plays #{MARKERS[player_name]}.  "
  end

  puts header_string
end

def calculate_top_row(row_length)
  top_row = ['|']

  row_length.times do |_|
    top_row[0] += '-------+'
  end

  top_row
end

def display_board(board, board_side_length)
  display_header

  board_arr = []

  board_arr << calculate_top_row(board_side_length)

  board_side_length.times do |row|
    row_offset = (row) * board_side_length
    row_arr = initialize_board_row_arr

    board_side_length.times do |square|
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

  board[computer_choice] = MARKERS[computer_name]
end

def board_full?(board)
  empty_squares(board).empty?
end

# rubocop:disable Metrics/CyclomaticComplexity
def detect_winner_game(board)
  WINNING_LINES.each do |line|
    if line.all? { |square| board[square] == PLAYER_MARKER }
      return "Player"
    elsif line.all? { |square| board[square] == COMPUTER_MARKER_ZERO }
      return "Computer0"
    elsif line.all? { |square| board[square] == COMPUTER_MARKER_ONE }
      return "Computer1"
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

  joinor_array = arr.dup

  last_item = joinor_array.pop.to_s
  joinor_string = joinor_array.join(separator)
  joinor_string.concat(separator, word, ' ', last_item)
  joinor_string
end

def display_scores(scores)
  prompt "The scores for this round:"

  scores_string = ""

  scores.each do |name, score|
    scores_string += "#{name}: #{score}\t"
  end

  prompt scores_string

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
  computer_choice = select_square(board, MARKERS[computer_name])

  # AI defense: try to block other PLAYERS
  computer_choice ||= select_square(board, PLAYER_MARKER)

  if NUM_COMPUTERS == 2
    other_computer = (computer_name == 'Computer0' ? 'Computer1' : 'Computer0')
    computer_choice ||= select_square(board, MARKERS[other_computer])
  end

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

def alternate_player(player_index)
  next_turn_index = (PLAYERS[player_index + 1].nil? ? 0 : player_index + 1)

  next_turn_index
end

def decide_player_one
  if FIRST_PLAYER == "Choose"
    prompt "Which player will be player one?"
    prompt "Input 'p' for player—-otherwise computer will play first"
    answer = gets.chomp.downcase

    answer.start_with?('p') ? "Player" : "Computer0"
  else
    FIRST_PLAYER
  end
end

def decide_board_size
  options = [3, 5, 7, 9]

  board_size = nil

  loop do
    prompt "How big would you like each side of the board to be? " \
           "(#{joinor(options)})"
    board_size = gets.chomp.to_i

    break if options.include?(board_size)

    prompt "That number is not valid." \
          "Please enter a valid side length for the board."
    puts
  end

  board_size
end

def decide_number_computer_players
  puts
  prompt "How many computer opponents would you like to face?"
  prompt "Input 2 to select 2--otherwise you will face 1"

  answer = gets.chomp.to_i

  num_computers = answer == 2 ? 2 : 1

  num_computers
end

def initialize_round_scores
  round_scores = {}

  PLAYERS.each do |player|
    player_name = player[:name]
    round_scores[player_name] = 0
  end

  round_scores
end

def initialize_players(first_player)
  player_names = [first_player]

  if NUM_COMPUTERS == 2 && first_player.start_with?('Computer')
    # rubocop:disable Layout/LineLength
    names_to_push = (rand(2).odd? ? ["Player", "Computer1"] : ["Computer1", "Player"])
    # rubocop:enable Layout/LineLength
  elsif NUM_COMPUTERS == 1 && first_player.start_with?('Computer')
    names_to_push = ["Player"]
  else
    names_to_push = ["Computer0"]
  end

  player_names.push(*names_to_push)

  players = []
  player_names.each do |name|
    players.push({ name: name.to_s, score: 0 })
  end

  players
end

# Main loop
# Start of a round (best of 5 games wins)
loop do
  player_one_name = decide_player_one

  NUM_COMPUTERS = decide_number_computer_players

  PLAYERS = initialize_players(player_one_name)

  board_side_length = decide_board_size
  board_num_squares = board_side_length**2

  LINE_ALMOST_COMPLETE = board_side_length - 1

  CENTER_SQUARE = (board_num_squares / 2.0).round

  WINNING_LINES = calculate_winning_lines(board_side_length)

  current_round_scores = initialize_round_scores

  round_winner = nil
  play_another_game = nil

  # Start of a game
  loop do
    board = initialize_board(board_num_squares)
    current_player_index = 0
    current_player = PLAYERS[current_player_index][:name]

    loop do
      display_board(board, board_side_length)

      place_piece!(board, current_player)
      current_player_index = alternate_player(current_player_index)
      current_player = PLAYERS[current_player_index][:name]

      break if someone_won_game?(board) || board_full?(board)
    end

    display_board(board, board_side_length)

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
