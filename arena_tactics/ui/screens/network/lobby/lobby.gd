extends Control

@export var menuScenePath := "res://ui/screens/main_menu/main_menu.tscn"

@onready var playerNameLine: LineEdit = get_node("%PlayerName")

@onready var serverAdressLine: LineEdit = get_node("%ServerAdress")
@onready var serverPortLine: LineEdit = get_node("%ServerPort")
@onready var connectButton: Button = get_node("%ConnectButton")
@onready var returnButton: Button = get_node("%ReturnButton")
@onready var disconnectButton: Button = get_node("%DisconnectButton")
@onready var launchGameButton: Button = get_node("%LaunchGameButton")

@onready var playerListContainer: VBoxContainer = get_node("%ListContainer")

@onready var chatContainer: VBoxContainer = get_node("%ChatContainer") 
@onready var chatSendButton: Button = get_node("%SendMessageButton")
@onready var chatMessageLine: LineEdit = get_node("%MessageLine")

@onready var networker: NetworkClient = get_tree().root.get_node("Root").get_node("NetworkRoot").get_node("Networker")

signal transition(new_scene: PackedScene, animation: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	connectButton.pressed.connect(_on_connect_button_pressed)
	returnButton.pressed.connect(_on_return_button_pressed)
	disconnectButton.pressed.connect(_on_disconnect_button_pressed)
	chatSendButton.pressed.connect(_on_chat_send_pressed)
	launchGameButton.pressed.connect(_on_launch_game_pressed)

	networker.player_disconnected.connect(_on_player_disconnected)
	networker.player_list_updated.connect(_on_player_list_updated)
	networker.chatModule.chat_message_received.connect(_on_message_received)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_connect_button_pressed():
	var server_adress = serverAdressLine.text
	var server_port = int(serverPortLine.text)
	var player_name = playerNameLine.text

	networker.set_player_info({"name": player_name})
	networker.join_game(server_adress, server_port)


func _on_player_list_updated():
	for child in playerListContainer.get_children():
		child.queue_free()
	for player in networker.players:
		var playerName: Label = Label.new()
		playerName.text = "- %s (%s)" % [networker.players[player]["name"], player]
		playerListContainer.add_child(playerName)


func _on_player_disconnected(_id):
	_on_player_list_updated()


func _on_disconnect_button_pressed():
	networker.leave()
	for child in chatContainer.get_children():
		child.queue_free()


func _on_return_button_pressed():
	networker.leave()
	var menuScene = load(menuScenePath)
	transition.emit(menuScene, "scene_transition")


func _on_chat_send_pressed():
	if chatMessageLine.text == "" or not networker.multiplayer.has_multiplayer_peer():
		return
	var message_content = chatMessageLine.text
	networker.chatModule.send_chat_message.rpc_id(1, message_content)
	chatMessageLine.text = ""


func _on_message_received(author: String, message: String):
	var msg: Label = Label.new()
	msg.text = "%s : %s" % [author, message]
	chatContainer.add_child(msg)


func _on_launch_game_pressed():
	pass
