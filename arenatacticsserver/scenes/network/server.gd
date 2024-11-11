extends Node


signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var players = {}
var players_loaded = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	create_game()


func create_game():
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNEXION)
	if error:
		print(error)
		return error
	multiplayer.multiplayer_peer = peer
	print_debug("Server ready at %s:%d" % [DEFAULT_SERVER_IP, PORT])


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print_debug("Peer " + str(id) + " connected to the server!")

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	print_debug(players)
	_get_player_list.rpc(players)


@rpc("authority", "reliable")
func _get_player_list(_player_list):
	pass

@rpc("any_peer", "reliable")
func send_chat_message(message):
	var sender_id = multiplayer.get_remote_sender_id()
	var author = players[sender_id]["name"] + ':' + str(sender_id)
	print_debug(author, message)
	receive_chat_message.rpc(author, message)

@rpc("authority", "reliable")
func receive_chat_message(_author: String, _message: String):
	pass

func _on_player_disconnected(id):
	print("Peer " + str(id) + " disconnected from the server!")
	players.erase(id)
	player_disconnected.emit(id)
	print(players)
