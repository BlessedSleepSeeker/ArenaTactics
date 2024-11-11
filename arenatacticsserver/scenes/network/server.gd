extends Node
class_name NetworkServer

signal player_connected(peer_id)
signal player_disconnected(peer_id)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var players = {}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	create_game()


func create_game():
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNEXION)
	if error:
		print_debug(error)
		return error
	multiplayer.multiplayer_peer = peer
	#print_debug("Server ready at %s:%d" % [DEFAULT_SERVER_IP, PORT])


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(_id):
	pass
	#print_debug("Peer " + str(id) + " connected to the server!")

@rpc("any_peer", "reliable")
func register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	get_player_list.rpc(players)


@rpc("authority", "reliable")
func get_player_list(_player_list):
	pass

func _on_player_disconnected(id):
	#print_debug("Peer " + str(id) + " disconnected from the server!")
	players.erase(id)
	player_disconnected.emit(id)
