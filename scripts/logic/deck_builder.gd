class_name DeckBuilder
extends RefCounted

## Builds the full 20-card deck in code (4 countries x 5 cards)
## For Phase 3 this is enough, cards will become editable .tres resources later
## Abilities are assigned where they already exist, others are left null for now

static func build_full_deck() -> Array:
	var deck: Array = []
	
	var speedy: Ability = load("res://scripts/abilities/france/speedy.tres")
	var strong_header: Ability = load("res://scripts/abilities/france/header.tres")
	var rocket: Ability = load("res://scripts/abilities/croatia/rocket.tres")
	var laser_pass: Ability = load("res://scripts/abilities/croatia/laser_pass.tres")
	
	# ability names per country, last one is the special card
	var country_abilities := {
		"Brazil":  [null, null, null, null, null],
		"Croatia": [rocket, laser_pass, null,  null, null],
		"Japan":   [null, null, null, null, null],
		"France":  [speedy, strong_header, null, null, null],
	}

	for country in country_abilities:
		var abilities: Array = country_abilities[country]
		for i in 5:
			var card := Card.new()
			card.player_name = country + " " + str(i + 1)
			card.country = country
			card.is_special = (i == 4)
			card.ability = abilities[i]   # may be null
			deck.append(card)

	return deck
