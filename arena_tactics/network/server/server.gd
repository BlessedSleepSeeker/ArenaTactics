extends Node
class_name NetworkServer

signal player_disconnected(peer_id: int)
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

enum Status {LOBBY, GAME, POSTGAME}
var status: int = Status.LOBBY

@onready var settings: Settings = get_tree().root.get_node("Root").get_node("ServerSettings")
@onready var chat_module = $ChatModule
@onready var user_module = $UserModule

#region Setup
func _ready():
	multiplayer.peer_connected.connect(_on_user_connected)
	multiplayer.peer_disconnected.connect(_on_user_disconnected)
	user_module.send_chat_message.connect(send_message_all)
	user_module.send_chat_message_to.connect(send_message_to)
	read_params()
	create_server()

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

func create_server():
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
#endregion

#region Game States
func shutdown():
	chat_module.send_chat_message.rpc("[SERVER]", 1, "Shutdown Initiated by the host...", "MAJOR_FAILURE")
	throw_error("Shutdown Initiated by the host...")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "5", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "4", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "3", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "2", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "1", "MAJOR_FAILURE")
	await get_tree().create_timer(1).timeout
	throw_error("Shutting down.")
	get_tree().quit()

@rpc("authority", "reliable")
func launch_game():
	pass

@rpc("any_peer", "reliable")
func ask_launch_game():
	var id: int = multiplayer.get_remote_sender_id()
	var user: ConnectedUser = user_module.get_user_by_id(id)
	if not user.is_host:
		chat_module.send_chat_message.rpc_id(id, "[SERVER]", 1, "Only the host can launch the game, how where you even able to access this function ?", "MAJOR_FAILURE")
		throw_error("User %s:%d tried to launch the game without being host." % [user.user_name, user.id])
		return
	chat_module.send_chat_message.rpc("[SERVER]", 1, "Game starting in 5...", "MAJOR_SUCCESS")
	log_me.emit("Starting Game in 5...")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "4", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "3", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "2", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "1", "MAJOR_SUCCESS")
	await get_tree().create_timer(1).timeout
	chat_module.send_chat_message.rpc("[SERVER]", 1, "Game starting !", "MAJOR_SUCCESS")
	log_me.emit("Starting Game !")
	status = Status.GAME
	launch_game.rpc()
#endregion

#region UserConnexion

func _on_user_connected(_id):
	chat_module.send_chat_message.rpc_id(_id, "[SERVER]", 1, "Joined %s !" % lobby_name, "MAJOR_SUCCESS")
	log_me.emit("Peer " + str(_id) + " connecting to the server.")

func _on_user_disconnected(id: int):
	var user: ConnectedUser = user_module.get_user_by_id(id)
	if user == null:
		return
	log_me.emit("Peer " + str(id) + " disconnected from the server !")
	chat_module.send_chat_message.rpc("[SERVER]", 1, "%s Left... See ya !" % user.user_name, "MINOR_FAIL")
	user_module.remove_user(id)
	player_disconnected.emit(id)
	user_module.get_user_list()

@rpc("authority", "reliable")
func set_as_host():
	pass
#endregion

#region ChatModule

func send_message_all(sender: String, sender_id: int, message: String, type: String):
	chat_module.send_chat_message.rpc(sender, sender_id, message, type)

func send_message_to(receiver_id: int, sender: String, sender_id: int, message: String, type: String):
	chat_module.send_chat_message.rpc_id(receiver_id, sender, sender_id, message, type)

#endregion
