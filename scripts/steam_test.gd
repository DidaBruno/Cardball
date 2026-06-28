extends Node

var lobby_id: int = 0

func _ready() -> void:
	var init_result: Dictionary = Steam.steamInitEx()
	print("Steam init result: ", init_result)

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)

func _process(_delta: float) -> void:
	Steam.run_callbacks() # required every frame or signals never fire

func create_lobby() -> void:
	print("Requesting lobby creation...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func join_lobby(target_lobby_id: int) -> void:
	print("Attempting to join lobby: ", target_lobby_id)
	Steam.joinLobby(target_lobby_id)

func _on_lobby_created(connect_result: int, this_lobby_id: int) -> void:
	if connect_result == 1:
		lobby_id = this_lobby_id
		print("Lobby created successfully! Lobby ID: ", lobby_id)
		print("Give this ID to the other machine to join.")
	else:
		print("Lobby creation FAILED. Result code: ", connect_result)

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = this_lobby_id
		print("Joined lobby successfully! Lobby ID: ", lobby_id)
		print("Members in lobby: ", Steam.getNumLobbyMembers(lobby_id))
	else:
		print("Failed to join lobby. Response code: ", response)

func _on_create_pressed() -> void:
	create_lobby()

func _on_join_pressed() -> void:
	var id_text: String = $LineEdit.text
	if id_text.is_valid_int():
		join_lobby(id_text.to_int())
