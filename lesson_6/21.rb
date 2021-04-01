require 'io/console'

# constants
MAXIMUM_VALID_SCORE = 21
VALUE_DEALER_STAYS = 17

GAMES_TO_WIN_A_ROUND = 5

CARD_RANKS = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen",
              "King", "Ace"]
CARD_SUITS = ["Clubs", "Diamonds", "Hearts", "Spades"]
CARD_VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5,
                "6" => 6, "7" => 7, "8" => 8, "9" => 9,
                "10" => 10, "Jack" => 10, "Queen" => 10, "King" => 10 }
ACE_HIGH_VALUE = 11
ACE_LOW_VALUE = 1
DIFFERENCE_BETWEEN_ACE_VALUES = ACE_HIGH_VALUE - ACE_LOW_VALUE
PLAYER_NAMES = ["Player", "Dealer"]
NUM_CARDS_DEALT = 2

WINNER = :winner
REASON = :reason

YES_AND_NO_OPTIONS = "y", "yes", "n", "no"

def prompt(msg, pause = false)
  puts "=> #{msg}"

  wait_for_key_press if pause
end

def get_valid_input(message_to_user, *valid_options)
  # get all options if they were passed as a nested array
  valid_options = valid_options.first if valid_options.size == 1

  input = nil

  loop do
    prompt(message_to_user)
    input = gets.chomp.downcase
    break input if valid_options.include?(input)

    prompt "That's not a valid option. Try again."
  end

  input
end

def joinand(arr, separator = ', ', word = 'and')
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

def initialize_deck
  CARD_RANKS.product(CARD_SUITS)
end

COMPLETE_DECK = initialize_deck

def initialize_totals
  totals = {}

  PLAYER_NAMES.each do |player|
    totals[player] = 0
  end

  totals
end

def initialize_players
  PLAYER_NAMES
end

def initialize_hands(players)
  hands = {}

  players.each { |player| hands[player] = [] }

  hands
end

def get_rank(card)
  card.first
end

def aces?(hand)
  hand.any? { |card| get_rank(card) == "Ace" }
end

def hit(deck, hand)
  dealt_card = deck.sample
  hand.push(dealt_card)
  deck.delete(dealt_card)
end

def deal_cards(deck, hands)
  cards_dealt = 0

  loop do
    hands.values.each do |hand|
      hit(deck, hand)
    end

    cards_dealt += 1
    break if cards_dealt == 2
  end
end

def display_cards(hands, player_turn, totals)
  system "clear"

  display_hands = hands.reverse_each

  display_hands.each do |player, cards|
    player_string = (player == "Player" ? "You have" : "Dealer has")

    card_ranks = cards.map { |card| get_rank(card) }

    if player == "Dealer" && player_turn != "Dealer"
      card_ranks[1] = "???"
    end

    card_ranks_string = joinand(card_ranks)
    hand_total = card_ranks_string.include?('???') ? 'unknown' : totals[player]

    prompt "#{player_string}: #{card_ranks_string}"
    prompt "#{player_string} #{hand_total}"
    prompt "-------------------------------"
  end
end

def wait_for_key_press
  output_blank_lines(2)
  puts "(Press any key to continue)"
  STDIN.getch
end

def take_turn(deck, hands, player, totals)
  if player == "Dealer"
    dealer_takes_turn(deck, hands, player, totals)
  else
    player_takes_turn(deck, hands, player, totals)
  end
end

def player_takes_turn(deck, hands, current_player, totals)
  loop do
    answer = get_valid_input("Do you want to (h)it or (s)tay?",
                             "h", "hit", "s", "stay")
    if answer == "s" || answer == "stay"
      prompt("You stay at #{totals[current_player]}.", true)
      break
    end

    prompt("You choose to hit...", true)

    hit(deck, hands[current_player])
    update_totals(hands, current_player, totals)
    display_cards(hands, current_player, totals)

    if busted?(current_player, totals)
      break
    end
  end
end

def dealer_takes_turn(deck, hands, dealer, totals)
  loop do
    display_cards(hands, dealer, totals)

    break unless totals[dealer] < VALUE_DEALER_STAYS

    output_blank_lines
    prompt "Dealer hits..."
    output_blank_lines
    wait_for_key_press

    hit(deck, hands[dealer])
    update_totals(hands, dealer, totals)
  end
end

def calculate_hand_value_no_aces(hand)
  total = 0

  hand.each do |card|
    card_rank = get_rank(card)
    total += CARD_VALUES[card_rank]
  end

  total
end

def calculate_hand_value_with_aces(hand)
  aces, not_aces = hand.partition { |card| get_rank(card) == "Ace" }

  total = calculate_hand_value_no_aces(not_aces)

  total += aces.size * ACE_HIGH_VALUE

  if total > MAXIMUM_VALID_SCORE
    loop do
      aces.pop
      total -= DIFFERENCE_BETWEEN_ACE_VALUES
      break if total <= MAXIMUM_VALID_SCORE || aces.empty?
    end
  end

  total
end

def calculate_hand_value(hand)
  hand_value = if aces?(hand)
                 calculate_hand_value_with_aces(hand)
               else
                 calculate_hand_value_no_aces(hand)
               end

  hand_value
end

def busted?(player, totals)
  totals[player] > MAXIMUM_VALID_SCORE
end

def opponent_name(current_player)
  current_player == "Player" ? "Dealer" : "Player"
end

def tie_scores?(scores)
  scores.all? { |_, score| score == scores.first.last }
end

def find_higher_score_player(totals)
  return nil if totals["Dealer"] == totals["Player"]

  totals.max_by { |_, score| score }.first
end

def resolve_outcome_when_no_bust!(high_score_player, outcome)
  if high_score_player.nil?
    outcome[WINNER] = "Push"
  else
    outcome[WINNER] = high_score_player
    outcome[REASON] = "High Score"
  end
end

def determine_game_outcome(players, totals)
  outcome = {}

  players.each do |player|
    if busted?(player, totals)
      outcome[WINNER] = opponent_name(player)
      outcome[REASON] = "Bust"
      return outcome
    end
  end

  high_score_player = find_higher_score_player(totals)

  resolve_outcome_when_no_bust!(high_score_player, outcome)

  outcome
end

def display_game_outcome(game_end, totals)
  puts

  if game_end[WINNER] == "Push"
    prompt("Push! You both had the same score.")
    return
  end

  # rubocop:disable Style/TernaryParentheses
  winner_string = (game_end[WINNER] == "Player") ? "You win" : "Dealer wins"
  busted_string = (game_end[REASON] == "Bust") ? "BUST!\n\n" : ""
  # rubocop:enable Style/TernaryParentheses

  score_string = if game_end[REASON] == "Bust"
                   "\b!"
                 else
                   "with #{totals[game_end[WINNER]]}."
                 end

  prompt "#{busted_string}#{winner_string} #{score_string}"
end

def update_totals(hands, player, totals)
  totals[player] = calculate_hand_value(hands[player])
end

def initialize_games_won
  points = {}
  PLAYER_NAMES.each { |player| points[player] = 0 }
  points
end

def round_over?(games_won)
  games_won.any? { |_, wins| wins == 5 }
end

def update_games_won(game_outcome, games_won)
  return if game_outcome[WINNER] == "Push"

  games_won[game_outcome[WINNER]] += 1
end

def display_games_won(games_won)
  puts
  prompt "The current scores are:"
  games_won.each do |player, num_games|
    prompt "#{player} has won #{num_games} game(s)."
  end

  wait_for_key_press
end

def display_round_outcome(games_won)
  round_winner = games_won.key(5)

  prompt "#{round_winner} wins the round!"
end

def welcome_player
  system "clear"

  prompt "Welcome to 21! Step right up and play your cards!"
  prompt "First player to win #{GAMES_TO_WIN_A_ROUND} games wins the round."
  wait_for_key_press
end

def output_blank_lines(num = 1)
  num.times { |_| print "\n" }
end

# -----------------------------------------------------------------------------
# START GAME
# -----------------------------------------------------------------------------

welcome_player

# beginning of a round
loop do
  games_won = initialize_games_won
  play_another_game = nil

  # beginning of one game
  loop do
    totals = initialize_totals
    deck = COMPLETE_DECK.dup

    players = initialize_players
    current_player = players.first

    hands = initialize_hands(players)

    deal_cards(deck, hands)

    players.each { |player| update_totals(hands, player, totals) }

    display_cards(hands, current_player, totals)

    players.each do |player|
      take_turn(deck, hands, player, totals)
      if busted?(player, totals)
        break
      end
    end

    game_outcome = determine_game_outcome(players, totals)
    display_game_outcome(game_outcome, totals)
    update_games_won(game_outcome, games_won)

    output_blank_lines(2)

    break if round_over?(games_won)

    display_games_won(games_won)

    play_another_game = get_valid_input("Continue this round? (y/n)",
                                        YES_AND_NO_OPTIONS)
    break if play_another_game.include?("n")

    # end of a game
  end

  break if play_another_game.include?("n")

  display_round_outcome(games_won)

  play_another_round = get_valid_input("Play another round? (y/n)",
                                       YES_AND_NO_OPTIONS)
  break if play_another_round.include?("n")

  # end of a round
end

prompt "Thanks for playing and see you next time!"
