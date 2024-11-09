extends Node
class_name Client

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var players = {}

var player_info: Dictionary = {"name": "Client"}


func set_player_info(_player_info: Dictionary):
	player_info = _player_info

func _ready():
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_ok)
		multiplayer.connection_failed.connect(_on_connected_fail)
		multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(adress: String = DEFAULT_SERVER_IP, _port: int = PORT):
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_client(adress, _port)
	match error:
		OK:
			print("Client successfully created!")
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
	print("Client connected to %s:%d" % [adress, PORT])


func _on_player_connected(id):
	print("Connected with id %d" % id)
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	print(players)


func _on_player_disconnected(id):
		players.erase(id)
		player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()