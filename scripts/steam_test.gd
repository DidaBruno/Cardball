extends Node

func _ready() -> void:
	var init_result: Dictionary = Steam.steamInitEx()
	print("Steam init result: ", init_result)

	if init_result["status"] == 0:
		print("Steam initialized successfully!")
		print("Steam ID: ", Steam.getSteamID())
		print("Persona name: ", Steam.getPersonaName())
	else:
		print("Steam failed to initialize. Status: ", init_result["status"], " Verbal: ", init_result["verbal"])
