extends Node

var lobby_id: int = 0
var lobby_members: Array = []

func _ready() -> void:
	var init_result: Dictionary = Steam.steamInitEx()
	print("Steam init result: ", init_result)

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.p2p_session_request.connect(_on_p2p_session_request)

	$CreateLobbyButton.pressed.connect(_on_create_pressed)
	$JoinLobbyButton.pressed.connect(_on_join_pressed)
	$SendMessageButton.pressed.connect(_on_send_pressed)

func _process(_delta: float) -> void:
	Steam.run_callbacks() # required every frame or signals never fire
	_read_all_p2p_packets()

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
	var id_text: String = $LobbyIdinput.text
	if id_text.is_valid_int():
		join_lobby(id_text.to_int())

func _on_p2p_session_request(remote_id: int) -> void:
	var requester: String = Steam.getFriendPersonaName(remote_id)
	print("P2P session requested by: ", requester)
	Steam.acceptP2PSessionWithUser(remote_id)  # must accept or packets drop

func _refresh_lobby_members() -> void:
	lobby_members.clear()
	var count: int = Steam.getNumLobbyMembers(lobby_id)
	for i in count:
		var member_id: int = Steam.getLobbyMemberByIndex(lobby_id, i)
		lobby_members.append(member_id)
	print("Lobby members refreshed: ", lobby_members.size())

func _on_send_pressed() -> void:
	var my_id: int = Steam.getSteamID()
	var payload: Dictionary = {"message": "Hello from " + Steam.getPersonaName()}
	var data: PackedByteArray = var_to_bytes(payload)

	for member_id in lobby_members:
		if member_id != my_id:
			Steam.sendP2PPacket(member_id, data, Steam.P2P_SEND_RELIABLE, 0)
			print("Sent message to: ", member_id)

func _read_all_p2p_packets() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	while packet_size > 0:
		var packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		if packet.size() > 0:
			var sender_id: int = packet["remote_steam_id"]
			var data: PackedByteArray = packet["data"]
			var readable: Dictionary = bytes_to_var(data)
			print("RECEIVED from ", sender_id, ": ", readable)
		packet_size = Steam.getAvailableP2PPacketSize(0)
