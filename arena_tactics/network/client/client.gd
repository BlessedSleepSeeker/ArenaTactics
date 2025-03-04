extends Node
class_name NetworkClient

signal player_disconnected(peer_id)
signal server_disconnected


signal go_to_css

signal new_error(msg: String)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNEXION = 4

var is_host: bool = false

@onready var chat_module = $ChatModule
@onready var user_module = $UserModule

func _ready():
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_ok)
		multiplayer.connection_failed.connect(_on_connected_fail)
		multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_server(adress: String = DEFAULT_SERVER_IP, _port: int = PORT) -> bool:
	user_module.leave()
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


@rpc("authority", "reliable")
func throw_error(msg: String):
	new_error.emit(msg)

func leave():
	user_module.leave()
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null

#region Users
func _on_player_connected(_id):
	pass

# when you connect to the server
func _on_connected_ok():
	user_module.join_server()

# when someone disconnect from server
func _on_player_disconnected(id):
	player_disconnected.emit(id)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	user_module.leave()
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
