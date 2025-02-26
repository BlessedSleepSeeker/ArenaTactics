extends Node
class_name NetworkServer

signal player_connected(peer_id)
signal player_disconnected(peer_id)

const TYPE: String = "SERVER"
var PORT: int = 7000
var DEFAULT_SERVER_IP: String = "127.0.0.1"
var MAX_CONNEXION: int = 4

var lobby_name = "Tintalabus's Awesome Lobby"
var players = {}

@onready var settings: Settings = get_tree().root.get_node("Root").get_node("ServerSettings")

@onready var chatModule = $ChatModule

func _ready():
	print_debug("coucou")
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	read_params()
	create_game()

func read_params() -> void:
	settings.parse_user_params()
	PORT = int(settings.read_setting_value_by_key("IP_PORT"))
	if int(settings.read_setting_value_by_key("MAXIMUM_SPECTATORS")) == 0:
		MAX_CONNEXION = 4095
	else:
		## Making sure that settings are interpreted as positive integer and clamped between 1 and 4095.
		MAX_CONNEXION = clampi(abs(int(settings.read_setting_value_by_key("MAXIMUM_TEAMS"))) * abs(int(settings.read_setting_value_by_key("MAXIMUM_PLAYERS_PER_TEAM"))) + abs(int(settings.read_setting_value_by_key("MAXIMUM_SPECTATORS"))), 1, 4095)

func create_game():
	var peer := ENetMultiplayerPeer.new()
	print_debug(PORT, ":", MAX_CONNEXION)
	var error = peer.create_server(PORT, MAX_CONNEXION)
	if error:
		push_error(error_string(error))
		return error
	multiplayer.multiplayer_peer = peer
	print("Server ready at %s:%d" % [DEFAULT_SERVER_IP, PORT])


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
