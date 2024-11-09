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
	print("Server ready at %s:%d" % [DEFAULT_SERVER_IP, PORT])
	print(players)

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print("Peer " + str(id) + " connected to the server!")
	players[id] = id
	player_connected.emit(id, id)
	print(players)



# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	players_loaded += 1
	if players_loaded == players.size():
		print("SHOULD START GAME")
		players_loaded = 0


func _on_player_disconnected(id):
	print("Peer " + str(id) + " disconnected from the server!")
	players.erase(id)
	player_disconnected.emit(id)
	print(players)
