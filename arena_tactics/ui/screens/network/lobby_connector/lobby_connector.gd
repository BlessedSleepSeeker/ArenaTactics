extends Control
class_name LobbyConnector

@onready var networker: NetworkClient = get_tree().root.get_node("Root").get_node("NetworkRoot").get_node("Networker")

@onready var player_name: LineEdit = $"%PlayerName"
@onready var server_adress: LineEdit = $"%ServerAdress"
@onready var server_port: LineEdit = $"%ServerPort"
@onready var server_pass: LineEdit = $"%ServerPass"
@onready var connect_button: Button = $"%ConnectButton"
@onready var return_button: Button = $"%ReturnButton"

@onready var error_panel: PanelContainer = $"%ErrorPanel"
@onready var error_label: RichTextLabel = $"%ErrorLabel"


@export var menu_scene_path: String = "res://ui/screens/main_menu/main_menu.tscn"
@export var lobby_scene_path: String = "res://ui/screens/network/lobby/Lobby.tscn"
signal transition(new_scene: PackedScene, animation: String)

func _ready():
	error_panel.hide()
	connect_button.pressed.connect(_on_connect_button_pressed)
	return_button.pressed.connect(_on_return_button_pressed)
	networker.new_error.connect(_on_error_received)
	networker.user_module.allowed_in_server.connect(_on_allowed_in)
	if networker.fast_forward:
		_on_allowed_in()

func _on_return_button_pressed() -> void:
	networker.leave()
	var menuScene = load(menu_scene_path)
	transition.emit(menuScene, "scene_transition")

func _on_connect_button_pressed() -> void:
	var _player_name = player_name.text
	var _server_adress = server_adress.text
	var _server_port = int(server_port.text)
	var _pass = server_pass.text

	networker.user_module.set_player_info({"name": _player_name, "password": _pass})
	networker.join_server(_server_adress, _server_port)

func _on_allowed_in():
	var new_scene: PackedScene = load(lobby_scene_path)
	transition.emit(new_scene, "scene_transition")

func _on_error_received(msg: String) -> void:
	error_label.text = "[color=red]%s[/color]" % msg
	error_panel.show()
