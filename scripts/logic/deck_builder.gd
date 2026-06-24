class_name DeckBuilder
extends RefCounted

## Builds the full 20-card deck in code (4 countries x 5 cards)
## For Phase 3 this is enough, cards will become editable .tres resources later
## Abilities are assigned where they already exist, others are left null for now

static func build_full_deck() -> Array:
	var deck: Array = []

	# ability names per country, last one is the special card
	var ability_styles := {
		"Brazil":  ["Hulk", "Spikes", "Rainbow Flick", "Magic Trick", "Curve Ball"],
		"Croatia": ["Rocket", "Second Wind", "Laser Pass", "Check Mate", "Fireball"],
		"Japan":   ["Mirror", "Reset", "Tiny Ball", "Flood", "Invisibility"],
		"France":  ["Speedy", "Strong Header", "Fake Out", "Baguette", "Teleport"],
	}

	for country in ability_styles:
		for i in 5:
			var card := Card.new()
			card.player_name = country + " " + str(i + 1) # temp names like Brazil 1
			card.country = country
			card.is_special = (i == 4) # 5th card is the special
			# player_image left null for now
			# ability left null for now
			deck.append(card)

	return deck
