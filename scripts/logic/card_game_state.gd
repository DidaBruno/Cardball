class_name CardGameState
extends RefCounted

# Turn phases - state machine
enum Phase {
	PICK_CARD,        # active player choosing which of their cards to play
	PICK_OPPONENT,    # active player choosing who to duel
	OPPONENT_PICKS,   # the chosen opponent picks their own card (sees only the flag/back)
	REVEAL,           # both cards revealed, ready to start the duel
	RESOLVED,         # duel finished, result recorded, ready to advance turn
}

# Config
const POINTS_TO_WIN: int = 10
const HAND_SIZE: int = 5

# Players
var player_count: int = 4
var player_names: Array[String] = []
var scores: Array[int] = []
var hands: Array = []

# Deck / pot
var pot: Array = []
var used_pile: Array = [] # cards that have been played, awaiting reshuffle

# Turn state
var active_player: int = 0
var phase: int = Phase.PICK_CARD

# Current selection (reset each turn)
var selected_card_index: int = -1 # index into active player's hand
var selected_card: Card = null
var target_player: int = -1 # who the active player chose to duel
var opponent_card_index: int = -1 # index into target player's hand
var opponent_card: Card = null

# Result of the most recent duel
var last_winner: int = -1 # -1 = none/draw, else player index
var winner: int = -1 # overall match winner, -1 until someone hits POINTS_TO_WIN


# Initialize a fresh match
func setup(num_players: int, shuffled_deck: Array, names: Array[String] = []) -> void:
	player_count = num_players
	scores = []
	hands = []
	player_names = []
	for i in num_players:
		scores.append(0)
		hands.append([])
		if i < names.size():
			player_names.append(names[i])
		else:
			player_names.append("Player %d" % i)
	pot = shuffled_deck.duplicate()
	used_pile = []
	active_player = 0
	winner = -1
	_deal_hands()
	_begin_turn()

# Deal up to HAND_SIZE cards to each player from the pot
func _deal_hands() -> void:
	for i in player_count:
		while hands[i].size() < HAND_SIZE and pot.size() > 0:
			hands[i].append(pot.pop_front())


# Reset per-turn selection state and set phase to the start of a turn
func _begin_turn() -> void:
	phase = Phase.PICK_CARD
	selected_card_index = -1
	selected_card = null
	target_player = -1
	opponent_card_index = -1
	opponent_card = null
	last_winner = -1

# ACTIONS

# Active player picks which card from their hand to play
func pick_card(card_index: int) -> void:
	if phase != Phase.PICK_CARD:
		return
	if card_index < 0 or card_index >= hands[active_player].size():
		return
	selected_card_index = card_index
	selected_card = hands[active_player][card_index]
	phase = Phase.PICK_OPPONENT

# Active player picks which other player to duel
func pick_opponent(player_index: int) -> void:
	if phase != Phase.PICK_OPPONENT:
		return
	if player_index == active_player:
		return
	if player_index < 0 or player_index >= player_count:
		return
	if not _has_cards(player_index):   # can't duel an empty-handed player
		return
	target_player = player_index
	phase = Phase.OPPONENT_PICKS

# The chosen opponent picks their own card to respond with
func opponent_pick_card(card_index: int) -> void:
	if phase != Phase.OPPONENT_PICKS:
		return
	if card_index < 0 or card_index >= hands[target_player].size():
		return
	opponent_card_index = card_index
	opponent_card = hands[target_player][card_index]
	phase = Phase.REVEAL

# Both cards are now revealed; the driver would trigger the 1v1 here
# No real 1V1 yet, so the driver just calls resolve_duel next
func begin_duel() -> void:
	if phase != Phase.REVEAL:
		return
	# The duel happens in the 1v1 layer (Phase 4)
	# Phase stays REVEAL until resolve_duel is called with an outcome

# Record the duel outcome, winner_index is decided OUTSIDE (random in Phase 3,
# real 1v1 result in Phase 4), Pass -1 for a draw (nobody scores)
func resolve_duel(winner_index: int) -> void:
	if phase != Phase.REVEAL:
		return
	last_winner = winner_index
	if winner_index >= 0:
		scores[winner_index] += 1
		if scores[winner_index] >= POINTS_TO_WIN:
			winner = winner_index
	# Remove the used cards from both hands
	_discard_card(active_player, selected_card_index)
	_discard_card(target_player, opponent_card_index)
	phase = Phase.RESOLVED

func advance_turn(reshuffled_deck: Array = []) -> void:
	if phase != Phase.RESOLVED:
		return
	if winner >= 0:
		return

	# Round ends when fewer than 2 players can still duel.
	if _players_with_cards() < 2:
		if reshuffled_deck.size() > 0:
			pot = reshuffled_deck.duplicate()
			used_pile = []
			_deal_hands()
		# after redealing, just move to the next player normally
		active_player = (active_player + 1) % player_count
		_begin_turn()
		return

	# Otherwise advance to the next player who still HAS cards (skip empty ones).
	var next := (active_player + 1) % player_count
	var safety := 0
	while not _has_cards(next) and safety < player_count:
		next = (next + 1) % player_count
		safety += 1
	active_player = next
	_begin_turn()

# Helper functions
func _discard_card(player_index: int, card_index: int) -> void:
	if card_index >= 0 and card_index < hands[player_index].size():
		used_pile.append(hands[player_index][card_index])
		hands[player_index].remove_at(card_index)

func _all_hands_empty() -> bool:
	for i in player_count:
		if hands[i].size() > 0:
			return false
	return true

func is_match_over() -> bool:
	return winner >= 0

func get_phase_name() -> String:
	return Phase.keys()[phase]

func name_of(player_index: int) -> String:
	if player_index >= 0 and player_index < player_names.size():
		return player_names[player_index]
	return "Player %d" % player_index

func _players_with_cards() -> int:
	var count := 0
	for i in player_count:
		if hands[i].size() > 0:
			count += 1
	return count

func _has_cards(player_index: int) -> bool:
	return hands[player_index].size() > 0
