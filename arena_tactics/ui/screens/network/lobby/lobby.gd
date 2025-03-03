extends Control
class_name Lobby

@onready var returnButton: Button = get_node("%ReturnButton")
@onready var launchGameButton: Button = get_node("%LaunchGameButton")

@onready var player_list: Control = $"%PlayerList"
@onready var lobby_team: LobbyTeams = $"%LobbyTeams"

@onready var chatContainer: VBoxContainer = get_node("%ChatContainer") 
@onready var chatSendButton: Button = get_node("%SendMessageButton")
@onready var chatMessageLine: LineEdit = get_node("%MessageLine")

@onready var networker: NetworkClient = get_tree().root.get_node("Root").get_node("NetworkRoot").get_node("Networker")

@export var lobby_connector_scene_path: String = "res://ui/screens/network/lobby_connector/LobbyConnector.tscn"
signal transition(new_scene: PackedScene, animation: String)

func _ready():
	lobby_team.setup(networker)
	returnButton.pressed.connect(_on_return_button_pressed)
	chatSendButton.pressed.connect(_on_chat_send_pressed)
	launchGameButton.pressed.connect(_on_launch_game_pressed)
	chatMessageLine.text_submitted.connect(_on_chat_line_submitted)

	networker.player_disconnected.connect(_on_player_disconnected)
	networker.player_list_updated.connect(_on_player_list_updated)
	networker.chatModule.chat_message_received.connect(_on_message_received)
	_on_player_list_updated()

func _on_player_list_updated():
	for child in player_list.get_children():
		child.queue_free()
	for player in networker.users:
		var playerName: Label = Label.new()
		playerName.text = "- %s" % [player.user_name]
		player_list.add_child(playerName)

func _on_player_disconnected(_id):
	_on_player_list_updated()


func _on_return_button_pressed():
	networker.leave()
	var menuScene = load(lobby_connector_scene_path)
	transition.emit(menuScene, "scene_transition")


func _on_chat_line_submitted(_msg: String):
	_on_chat_send_pressed()

func _on_chat_send_pressed():
	if chatMessageLine.text == "" or not networker.multiplayer.has_multiplayer_peer():
		return
	var message_content = chatMessageLine.text
	networker.chatModule.send_chat_message.rpc_id(1, message_content, "USER_MESSAGE")
	chatMessageLine.text = ""


func _on_message_received(author: String, message: String, type: String):
	var msg: RichTextLabel = RichTextLabel.new()
	msg.bbcode_enabled = true
	msg.fit_content = true
	var msg_str = "[b]%s[/b] : %s" % [author, message]
	msg.text = add_type_coloring(msg_str, type)
	chatContainer.add_child(msg)


func _on_launch_game_pressed():
	pass

func add_type_coloring(formated_message: String, type: String) -> String:
	match type:
		"MAJOR_SUCCESS":
			return "[color=lime]%s[/color]" % formated_message
		"MINOR_SUCCESS":
			return "[color=light_sky_blue]%s[/color]" % formated_message
		"MINOR_FAILURE":
			return "[color=coral]%s[/color]" % formated_message
		"MAJOR_FAILURE":
			return "[color=firebrick]%s[/color]" % formated_message
		_:
			return formated_message
