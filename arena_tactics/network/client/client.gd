extends Node
class_name NetworkClient

signal player_disconnected(peer_id)
signal server_disconnected
signal player_list_updated(list)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var players = {}

var player_info: Dictionary = {"name": "Client"}

@onready var chatModule = $ChatModule

func set_player_info(_player_info: Dictionary):
	player_info = _player_info


func _ready():
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_ok)
		multiplayer.connection_failed.connect(_on_connected_fail)
		multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(adress: String = DEFAULT_SERVER_IP, _port: int = PORT):
	leave()
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_client(adress, _port)
	match error:
		OK:
			pass
		ERR_ALREADY_IN_USE:
			printerr("(!) ERROR: You created a client already!")
			return false
		ERR_CANT_CREATE:
			printerr("(!) ERROR: The client could not be created!")
			return false
		_:
			printerr("|!| ERROR: Unknown error!")
			return false

	multiplayer.multiplayer_peer = peer
	#print_debug("Client connected to %s:%d" % [adress, PORT])


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


# when you connect with someone (server or another player)
func _on_player_connected(_id):
	pass
	#print_debug("%d Joined" % _id)


# when someone disconnect from server
func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


# when you connect to the server
func _on_connected_ok():
	register_player.rpc_id(1, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
