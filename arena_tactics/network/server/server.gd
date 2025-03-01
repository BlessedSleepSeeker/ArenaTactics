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

var players: Dictionary = {}
var teams: Dictionary = {}

@onready var settings: Settings = get_tree().root.get_node("Root").get_node("ServerSettings")
@onready var chat_module = $ChatModule

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
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

@rpc("authority", "reliable")
func throw_error(msg: String):
	new_error.emit(msg)

#region Players
func _on_player_connected(_id):
	chat_module.receive_chat_message.rpc_id(_id, "[SERVER]", 1, "Joined %s !" % lobby_name, "MAJOR_SUCCESS")
	log_me.emit("Peer " + str(_id) + " connecting to the server.")

@rpc("any_peer", "reliable")
func register_player(new_player_info):
	var new_player_id: int = multiplayer.get_remote_sender_id()
	var error: int = check_user(new_player_id, new_player_info)
	if error >= 0:
		chat_module.receive_chat_message.rpc("[SERVER]", 1, "%s tried but couldn't join. Reason : %d" % [new_player_info["name"], error], "MINOR_FAILURE")
		var error_str: String = convert_error_code(error)
		throw_error.rpc_id(new_player_id, error_str)
		throw_error(error_str)
		return

	allowed_in.rpc_id(new_player_id)
	if players.size() == 0:
		new_player_info["is_host"] = true
	else:
		new_player_info["is_host"] = false
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	log_me.emit("%s joined. Welcome !" % new_player_info["name"])
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "%s joined. Welcome !" % new_player_info["name"], "MINOR_SUCCESS")

@rpc("authority", "reliable")
func allowed_in():
	log_me.emit("Allowed in !")
	allowed_in_server.emit()

@rpc("authority", "reliable")
func get_player_list(_player_list: Dictionary):
	pass

@rpc("any_peer", "reliable")
func send_player_list():
	get_player_list.rpc(players)

func _on_player_disconnected(id):
	if not players.has(id):
		return
	log_me.emit("Peer " + str(id) + " disconnected from the server !")
	chat_module.receive_chat_message.rpc("[SERVER]", 1, "%s Left... See ya !" % players[id]["name"], "MINOR_FAIL")
	players.erase(id)
	player_disconnected.emit(id)
#endregion

#region User Checks
func check_user(_new_player_id: int, new_player_info: Dictionary) -> int:
	if check_player_name(new_player_info["name"]):
		return 0
	if not check_password(new_player_info["password"]):
		return 1
	return -1

func check_player_name(p_name: String) -> bool:
	if p_name.length() == 0:
		return true
	for player in players:
		if players[player]["name"] == p_name:
			return true
	return false

func check_password(p_pass: String) -> bool:
	var s_pass: String = settings.read_setting_value_by_key("ROOM_PASSWORD")
	if s_pass:
		return s_pass == p_pass
	return true

func convert_error_code(code: int) -> String:
	match code:
		0:
			return "ERROR : Can't connect, Name is empty or already taken."
		1:
			return "ERROR : Bad room password."
		_:
			return str(code)

#endregion

#region Teams
@rpc("any_peer", "reliable")
func register_team(_team_name: String):
	var sender: int = multiplayer.get_remote_sender_id()
	if teams.has(_team_name):
		chat_module.receive_chat_message.rpc_id(sender, "[SERVER]", 1, "Error : Team name is already taken, cannot create team.", "MINOR_FAILURE")
		throw_error.rpc_id(sender, "Error : Team name is already taken, cannot create team.")
		throw_error("Error : Team name is already taken, cannot create team.")
		return
	teams[_team_name] = {}
	log_me.emit("Created team %s" % [_team_name])
	get_teams_list.rpc(teams)

@rpc("any_peer", "reliable")
func add_player_to_team(_team_name: String, _player_info: Dictionary):
	var sender: int = multiplayer.get_remote_sender_id()
	var team = teams.get(_team_name)
	if team != null:
		remove_player_from_team(_player_info["name"])
		team[_player_info["name"]] = _player_info
		log_me.emit("Added player %s to team %s" % [_player_info["name"], _team_name])
	else:
		var error_msg: String = "Error : Team %s not found while trying to add %s." % [_team_name, _player_info["name"]]
		chat_module.receive_chat_message.rpc_id(sender, "[SERVER]", 1, error_msg, "MINOR_FAILURE")
		throw_error.rpc_id(sender, error_msg)
		throw_error(error_msg)
		return
	get_teams_list.rpc(teams)

func remove_player_from_team(_player_name: String, logs: bool = true):
	for team: String in teams:
		for player: String in teams[team]:
			if teams[team][player]["name"] == _player_name:
				teams[team].erase(player)
				if logs:
					log_me.emit("Removed player %s from team %s" % [_player_name, team])
	get_teams_list.rpc(teams)

@rpc("authority", "reliable")
func get_teams_list(_teams_list):
	pass

@rpc("any_peer", "reliable")
func send_team_list():
	get_teams_list.rpc(teams)

#endregion