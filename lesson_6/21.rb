require 'pry'
require 'pry-byebug'

# constants
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

VALUE_DEALER_STAYS = 17

WINNER = :winner
REASON = :reason

def prompt(msg)
  puts "=> #{msg}"
end

def get_valid_input(message_to_user, *valid_options)
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

def display_cards(hands, player_turn)
  system "clear"

  display_hands = hands.reverse_each

  display_hands.each do |player, cards|
    player_string = (player == "Player" ? "You have" : "Dealer has")

    card_ranks = cards.map { |card| get_rank(card) }

    if player == "Dealer" && player_turn != "Dealer"
      card_ranks[1] = "unknown card"
    end

    card_ranks_string = joinand(card_ranks)

    prompt "#{player_string}: #{card_ranks_string}"
  end
end

def wait_for_key_press
  puts "\n\nPress any key to continue"
  STDIN.getch
end

def take_turn(deck, hands, player)
  if player == "Dealer"
    dealer_takes_turn(deck, hands, player)
  else
    player_takes_turn(deck, hands, player)
  end
end

def player_takes_turn(deck, hands, current_player)
  loop do
    puts
    answer = get_valid_input("Do you want to (h)it or (s)tay?",
                             "h", "hit", "s", "stay")
    if answer == "s" || answer == "stay"
      prompt "#{current_player} stays."
      break
    end

    hit(deck, hands[current_player])
    display_cards(hands, current_player)
    # binding.pry
    if busted?(hands[current_player])
      break
    end
  end
end

def dealer_takes_turn(deck, hands, dealer)
  loop do
    display_cards(hands, dealer)

    break unless calculate_hand_value(hands[dealer]) < VALUE_DEALER_STAYS

    puts "\nDealer hits.\n"
    wait_for_key_press

    hit(deck, hands[dealer])
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

  if total > 21
    loop do
      aces.pop
      total -= DIFFERENCE_BETWEEN_ACE_VALUES
      break if total <= 21 || aces.size == 0
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

def busted?(hand)
  calculate_hand_value(hand) > 21
end

def opponent_name(current_player)
  current_player == "Player" ? "Dealer" : "Player"
end

def tie_scores?(scores)
  scores.all? { |_, score| score == scores.first.last }
end

def find_higher_score_player(hands)
  # binding.pry
  scores = {}

  hands.each do |player_name, player_hand|
    scores[player_name] = calculate_hand_value(player_hand)
  end

  return nil if tie_scores?(scores)

  scores = scores.sort_by { |_, score| score }

  scores.last.first
end

def determine_outcome(players, hands)
  outcome = {}
  # binding.pry
  players.each do |player|
    if busted?(hands[player])
      outcome[WINNER] = opponent_name(player)
      outcome[REASON] = "Bust"
      return outcome
    end
  end

  high_score_player = find_higher_score_player(hands)

  if high_score_player.nil?
    outcome[WINNER] = "Push"
  else
    outcome[WINNER] = high_score_player
    outcome[REASON] = "High Score"
  end

  outcome
end

def display_outcome(game_end, hands)
  puts

  if game_end[WINNER] == "Push"
    prompt("Push! You both had the same score.")
    return
  end

  winner_string = game_end[WINNER] == "Player" ? "You win" : "Dealer wins"
  busted_string = game_end[REASON] == "Bust" ? "Bust!\n\n" : ""
  score_string = "with #{calculate_hand_value(hands[game_end[WINNER]])}."

  prompt "#{busted_string}#{winner_string} #{score_string}"
end
# -----------------------------------------------------------------------------
# START
# -----------------------------------------------------------------------------
system "clear"

prompt "Welcome to 21! Step right up and play your cards!"

wait_for_key_press

loop do
  deck = COMPLETE_DECK.dup

  # binding.pry

  players = initialize_players
  current_player = players.first

  hands = initialize_hands(players)
  deal_cards(deck, hands)
  display_cards(hands, current_player)

  players.each do |player|
    take_turn(deck, hands, player)
    if busted?(hands[player])
      break
    end
  end
  # binding.pry
  # loser ||= calculate_loser(hands)

  game_end = determine_outcome(players, hands)
  display_outcome(game_end, hands)

  # display_outcome(loser)
  # DISPLAY FOR TESTING
  # hands.each do |hand_key, hand_value|
  #   puts "This hand is: #{hand_key} and its value is \
  #        #{calculate_hand_value(hand_value)}"
  #   puts
  # end
  # END DISPLAY FOR TESTING

  puts "\n"
  play_again = get_valid_input("Would you like to play again? (y/n)",
                               "y", "yes", "n", "no")
  break if play_again == "n" || play_again == "no"
end

prompt "Thanks for playing and come back again soon!"
