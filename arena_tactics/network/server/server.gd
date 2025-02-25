extends Node
class_name NetworkServer

signal player_connected(peer_id)
signal player_disconnected(peer_id)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var lobby_name = "Tintalabus's Awesome Lobby"
var players = {}

@onready var chatModule = $ChatModule

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


func _on_player_connected(_id):
	chatModule.receive_chat_message.rpc_id(_id, "[SERVER]", "Joined %s !" % lobby_name)
	#print_debug("Peer " + str(_id) + " connected to the server!")

@rpc("any_peer", "reliable")
func register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	get_player_list.rpc(players)
	chatModule.receive_chat_message.rpc("[SERVER]", "%s Joined. Welcome !" % new_player_info["name"])


@rpc("authority", "reliable")
func get_player_list(_player_list):
	pass

func _on_player_disconnected(id):
	#print_debug("Peer " + str(id) + " disconnected from the server!")
	chatModule.receive_chat_message.rpc("[SERVER]", "%s Left... See ya !" % players[id]["name"])
	players.erase(id)
	player_disconnected.emit(id)
