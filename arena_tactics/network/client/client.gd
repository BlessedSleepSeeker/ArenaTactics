extends Node
class_name NetworkClient

signal player_disconnected(peer_id)
signal server_disconnected
signal player_list_updated(list: Dictionary)
signal team_list_updated(list: Dictionary)
signal allowed_in_server

signal new_error(msg: String)

const TYPE: String = "CLIENT"
const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var players = {}
var teams = {}

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

#region Players
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

@rpc("authority", "reliable")
func allowed_in():
	allowed_in_server.emit()

func leave():
	players = {}
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null

@rpc("any_peer", "reliable")
func register_player(_new_player_info):
	pass

@rpc("authority", "reliable")
func get_player_list(_player_list):
	players = _player_list
	player_list_updated.emit()

@rpc("any_peer", "reliable")
func send_player_list():
	pass

# when you connect with someone (server or another player)
func _on_player_connected(_id):
	pass
	#print_debug("%d Joined" % _id)

# when someone disconnect from server
func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	send_player_list.rpc_id(1)

# when you connect to the server
func _on_connected_ok():
	register_player.rpc_id(1, player_info)
	send_player_list.rpc_id(1)
	send_team_list.rpc_id(1)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	teams.clear()
	server_disconnected.emit()
#endregion


#region Teams
func create_team(_team_name: String):
	register_team.rpc_id(1, _team_name)

@rpc("any_peer", "reliable")
func register_team(_team_name: String):
	pass

func join_team(_team_name: String):
	if not teams.has(_team_name):
		throw_error("No team with name %s was found." % _team_name)
	add_player_to_team.rpc_id(1, _team_name, player_info)

@rpc("any_peer", "reliable")
func add_player_to_team(_team_name: String, _player_info: Dictionary):
	pass

@rpc("authority", "reliable")
func get_teams_list(_teams_list):
	teams = _teams_list
	team_list_updated.emit()

@rpc("any_peer", "reliable")
func send_team_list():
	pass

#endregion

@rpc("authority", "reliable")
func throw_error(msg: String):
	new_error.emit(msg)
