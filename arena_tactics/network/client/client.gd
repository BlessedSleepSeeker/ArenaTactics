extends Node
class_name NetworkClient

signal player_disconnected(peer_id)
signal server_disconnected
signal player_list_updated(list: Array[ConnectedUser])
signal team_list_updated(list: Array[ConnectedTeam])
signal allowed_in_server

signal go_to_css

signal new_error(msg: String)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var is_host: bool = false

var users: Array[ConnectedUser] = []
var teams: Array[ConnectedTeam] = []

var player_info: Dictionary = {"name": "Client", "password": ""}

@onready var chatModule = $ChatModule

func set_player_info(_player_info: Dictionary):
	player_info = _player_info

func _ready():
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_ok)
		multiplayer.connection_failed.connect(_on_connected_fail)
		multiplayer.server_disconnected.connect(_on_server_disconnected)

#region Users
func join_game(adress: String = DEFAULT_SERVER_IP, _port: int = PORT) -> bool:
	leave()
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_client(adress, _port)
	match error:
		OK:
			pass
		ERR_ALREADY_IN_USE:
			throw_error("ERROR : You created a client already.")
			return false
		ERR_CANT_CREATE:
			throw_error("ERROR: The client could not be created!")
			return false
		_:
			throw_error("ERROR: Unknown error!")
			return false

	multiplayer.multiplayer_peer = peer
	return true
	#print_debug("Client connected to %s:%d" % [adress, PORT])

# when you connect with someone (server or another user)
func _on_player_connected(_id):
	pass
	#print_debug("%d Joined" % _id)

@rpc("any_peer", "reliable")
func register_user(_user_name: String, _room_password: String):
	pass

# when you connect to the server
func _on_connected_ok():
	register_user.rpc_id(1, player_info["name"], player_info["password"])

@rpc("authority", "reliable")
func allowed_in():
	allowed_in_server.emit()

@rpc("authority", "reliable")
func send_user_list(_users: Dictionary):
	users.clear()
	for user in _users:
		var new_user: ConnectedUser = ConnectedUser.new().from_dict(_users[user])
		users.append(new_user)
	player_list_updated.emit()

@rpc("any_peer", "reliable")
func get_user_list():
	pass

func leave():
	users = []
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null

# when someone disconnect from server
func _on_player_disconnected(id):
	player_disconnected.emit(id)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	users.clear()
	teams.clear()
	server_disconnected.emit()

@rpc("authority", "reliable")
func launch_game():
	go_to_css.emit()

@rpc("any_peer", "reliable")
func ask_launch_game():
	pass

@rpc("authority", "reliable")
func set_as_host():
	is_host = true
#endregion

#region UserLib

func get_user_by_id(id: int) -> ConnectedUser:
	for user in users:
		if user.id == id:
			return user
	return null
#endregion

#region Teams
func create_team(_team_name: String):
	register_team.rpc_id(1, _team_name)

@rpc("any_peer", "reliable")
func register_team(_team_name: String):
	pass

func join_team(_team: ConnectedTeam):
	if not teams.has(_team):
		throw_error("No team with name %s was found." % _team.team_name)
	add_player_to_team.rpc_id(1, _team.team_name, player_info["name"])

@rpc("any_peer", "reliable")
func add_player_to_team(_team_name: String, _player_name: String):
	pass

@rpc("authority", "reliable")
func send_team_list(_teams: Dictionary):
	teams.clear()
	for team in _teams:
		var new_team: ConnectedTeam = ConnectedTeam.new().from_dict(_teams[team])
		link_team_id_with_users(new_team)
		teams.append(new_team)
	team_list_updated.emit()

@rpc("any_peer", "reliable")
func get_team_list():
	pass

func link_team_id_with_users(team: ConnectedTeam):
	team.members.clear()
	for id in team.members_id:
		team.members.append(get_user_by_id(id))
#endregion

@rpc("authority", "reliable")
func throw_error(msg: String):
	new_error.emit(msg)
