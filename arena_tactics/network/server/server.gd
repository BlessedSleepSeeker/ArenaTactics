extends Node
class_name NetworkServer

signal player_connected(peer_id)
signal player_disconnected(peer_id)

signal allowed_in_server()
signal new_error(msg: String)

signal log_me(msg: String)

const TYPE: String = "SERVER"
var PORT: int = 7000
var DEFAULT_SERVER_IP: String = "127.0.0.1"
var MAX_CONNEXION: int = 4

var lobby_name = "Tintalabus's Awesome Lobby"

var MAX_TEAMS: int = 2
var MAX_PLAYERS_PER_TEAM: int = 1
var MAX_SPECTATORS: int = 0

enum Status {LOBBY, GAME, POSTGAME}
var status: int = Status.LOBBY

var users: Array[ConnectedUser] = []
var teams: Array[ConnectedTeam] = []

@onready var settings: Settings = get_tree().root.get_node("Root").get_node("ServerSettings")
@onready var chat_module = $ChatModule

func _ready():
	multiplayer.peer_connected.connect(_on_user_connected)
	multiplayer.peer_disconnected.connect(_on_user_disconnected)
	read_params()
	create_game()

func read_params() -> void:
	settings.parse_user_params()
	PORT = int(settings.read_setting_value_by_key("IP_PORT"))
	MAX_TEAMS = clampi(int(settings.read_setting_value_by_key("MAXIMUM_TEAMS")), 1, 100)
	MAX_PLAYERS_PER_TEAM = clampi(int(settings.read_setting_value_by_key("MAXIMUM_PLAYERS_PER_TEAM")), 1, 100)
	MAX_SPECTATORS = int(settings.read_setting_value_by_key("MAXIMUM_SPECTATORS"))
	if int(settings.read_setting_value_by_key("MAXIMUM_SPECTATORS")) == 0:
		MAX_CONNEXION = 4095
	else:
		## Making sure that settings are interpreted as positive integer and clamped between 1 and 4095.
		MAX_CONNEXION = clampi(abs(MAX_TEAMS) * abs(MAX_PLAYERS_PER_TEAM) + abs(MAX_SPECTATORS), 1, 4095)


func create_game():
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNEXION)
	if error:
		push_error(error_string(error))
		return error
	multiplayer.multiplayer_peer = peer

	log_me.emit("Server ready at %s:%d" % [DEFAULT_SERVER_IP, PORT])

	register_team("Spectator")

@rpc("authority", "reliable")
func throw_error(msg: String):
	new_error.emit(msg)

func shutdown():
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "Shutdown Initiated by the host...", "MAJOR_FAILURE")
	throw_error("Shutdown Initiated by the host...")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "5", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "4", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "3", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "2", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "1", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	throw_error("Shutting down.")
	get_tree().quit()

@rpc("authority", "reliable")
func launch_game():
	pass

@rpc("any_peer", "reliable")
func ask_launch_game():
	var id: int = multiplayer.get_remote_sender_id()
	var user: ConnectedUser = get_user_by_id(id)
	if not user.is_host:
		chat_module.receive_chat_message.rpc("[SERVER]", 1, "Only the host can launch the game, how where you even able to access this function ?", "MAJOR_FAILURE")
		throw_error("User %s:%d tried to launch the game without being host." % [user.user_name, user.id])
		return
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "Game starting in 5...", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "4", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "3", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "2", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "1", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "Game starting !", "MAJOR_SUCCESS")
	status = Status.GAME
	launch_game.rpc()

#region Users
func _on_user_connected(_id):
	chat_module.receive_chat_message.rpc_id(_id, "[SERVER]", 1, "Joined %s !" % lobby_name, "MAJOR_SUCCESS")
	log_me.emit("Peer " + str(_id) + " connecting to the server.")

@rpc("any_peer", "reliable")
func register_user(user_name: String, room_password: String):
	var new_user: ConnectedUser = ConnectedUser.new(user_name)
	new_user.id = multiplayer.get_remote_sender_id()
	var error: int = check_user(new_user, room_password)
	if error >= 0:
		chat_module.receive_chat_message.rpc("[SERVER]", 1, "%s tried but couldn't join. Reason : %d" % [new_user.user_name, error], "MINOR_FAILURE")
		var error_str: String = convert_error_code(error)
		throw_error.rpc_id(new_user.id, error_str)
		throw_error(error_str)
		return

	allowed_in.rpc_id(new_user.id)
	if users.size() == 0:
		new_user.is_host = true
		set_as_host.rpc_id(new_user.id)
	users.append(new_user)
	player_connected.emit(new_user.id, new_user)
	log_me.emit("%s joined. Welcome !" % new_user.user_name)
	if status == Status.GAME:
		add_player_to_team("Spectator", new_user.user_name)
	else:
		chat_module.receive_chat_message.rpc("[SERVER]", 1, "%s joined, welcome !" % new_user.user_name, "MINOR_SUCCESS")
	get_user_list()
	get_team_list()

@rpc("authority", "reliable")
func allowed_in():
	log_me.emit("Allowed in !")
	allowed_in_server.emit()

@rpc("authority", "reliable")
func send_user_list(_users: Dictionary):
	pass

@rpc("any_peer", "reliable")
func get_user_list():
	var users_as_dict: Dictionary = {}
	for user in users:
		users_as_dict[user.id] = user.to_dict()
	send_user_list.rpc(users_as_dict)

func _on_user_disconnected(id: int):
	var user: ConnectedUser = get_user_by_id(id)
	if user == null:
		return
	log_me.emit("Peer " + str(id) + " disconnected from the server !")
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "%s Left... See ya !" % user.user_name, "MINOR_FAIL")
	remove_user(id)
	player_disconnected.emit(id)
	get_user_list()

@rpc("authority", "reliable")
func set_as_host():
	pass
#endregion

#region UserLib
func get_user_by_id(id: int) -> ConnectedUser:
	for user in users:
		if user.id == id:
			return user
	return null

func get_user_by_name(user_name: String) -> ConnectedUser:
	for user in users:
		if user.user_name == user_name:
			return user
	return null

func remove_user(id: int):
	for user in users:
		if user.id == id:
			remove_player_from_team(user)
			users.erase(user)
#endregion

#region User Checks
func check_user(user: ConnectedUser, room_password: String) -> int:
	if not user.check_name_validity() and check_user_name_exist(user.user_name):
		return 0
	if not check_password(room_password):
		return 1
	return -1

func check_user_name_exist(_name: String) -> bool:
	for user: ConnectedUser in users:
		if user.name == _name:
			return true
	return false

func check_password(room_pass: String) -> bool:
	var s_pass: String = settings.read_setting_value_by_key("ROOM_PASSWORD")
	if s_pass:
		return s_pass == room_pass
	return true

func convert_error_code(code: int) -> String:
	match code:
		0:
			return "ERROR : Can't connect, Name is empty or already taken."
		1:
			return "ERROR : Bad room password."
		_:
			return str(code)

func is_user_host(p_name: String) -> bool:
	if p_name.length() == 0:
		return false
	for user in users:
		if users[user]["name"] == p_name:
			return users[user]["is_host"]
	return false

#endregion

#region Teams
@rpc("any_peer", "reliable")
func register_team(_team_name: String):
	var sender: int = multiplayer.get_remote_sender_id()
	if team_name_already_exist(_team_name) or _team_name.length() == 0:
		chat_module.receive_chat_message.rpc_id(sender, "[SERVER]", 1, "Error : Team name is empty or already taken, cannot create team.", "MINOR_FAILURE")
		throw_error.rpc_id(sender, "Error : Team name is empty or already taken, cannot create team.")
		throw_error("Error : Team name is empty or already taken, cannot create team.")
		return
	var new_team: ConnectedTeam = ConnectedTeam.new(_team_name)
	teams.append(new_team)
	log_me.emit("Created team %s" % [_team_name])
	get_team_list()

@rpc("any_peer", "reliable")
func add_player_to_team(_team_name: String, _player_name: String):
	var sender: int = multiplayer.get_remote_sender_id()
	var team = get_team(_team_name)
	var user = get_user_by_name(_player_name)
	if team != null:
		remove_player_from_team(user)
		team.members.append(user)
		log_me.emit("Added user %s to team %s" % [user.user_name, team.team_name])
	else:
		var error_msg: String = "Error : Team %s not found while trying to add %s." % [_team_name, user.user_name]
		chat_module.receive_chat_message.rpc_id(sender, "[SERVER]", 1, error_msg, "MINOR_FAILURE")
		throw_error.rpc_id(sender, error_msg)
		throw_error(error_msg)
		return
	get_team_list()

func remove_player_from_team(user: ConnectedUser, logs: bool = true):
	for team: ConnectedTeam in teams:
		if team.members.has(user):
			team.members.erase(user)
			if logs:
				log_me.emit("Removed user %s from team %s" % [user.user_name, team.team_name])
	get_team_list()

@rpc("authority", "reliable")
func send_team_list(_teams: Dictionary):
	pass

@rpc("any_peer", "reliable")
func get_team_list():
	send_team_list.rpc(convert_teams_to_dict())

func convert_teams_to_dict() -> Dictionary:
	var teams_as_dict: Dictionary = {}
	for team: ConnectedTeam in teams:
		teams_as_dict[team.team_name] = team.to_dict()
	return teams_as_dict

func get_team(_team_name: String) -> ConnectedTeam:
	for team: ConnectedTeam in teams:
		if team.team_name == _team_name:
			return team
	return null

func team_name_already_exist(_team_name: String) -> bool:
	for team: ConnectedTeam in teams:
		if team.team_name == _team_name:
			return true
	return false
#endregion