extends Control

@export var menuScenePath := "res://scenes/menu/main_menu.tscn"

@onready var playerNameLine: LineEdit = $MarginContainer/VBoxContainer/UserIdentity/PlayerName

@onready var serverAdressLine: LineEdit = $MarginContainer/VBoxContainer/ServerConnection/ServerAdress
@onready var serverPortLine: LineEdit = $MarginContainer/VBoxContainer/ServerConnection/ServerPort
@onready var connectButton: Button = $MarginContainer/VBoxContainer/ServerConnection/ConnectButton
@onready var returnButton: Button = $MarginContainer/VBoxContainer/SendChat/HBoxContainer/Button

@onready var playerListContainer: VBoxContainer = $MarginContainer/VBoxContainer/ConnectedData/PlayerList/ListContainer

@onready var chatContainer: VBoxContainer = $MarginContainer/VBoxContainer/ConnectedData/Chat/ScrollContainer/ChatContainer
@onready var chatSendButton: Button = $MarginContainer/VBoxContainer/SendChat/HBoxContainer2/SendMessageButton
@onready var chatMessageLine: LineEdit = $MarginContainer/VBoxContainer/SendChat/HBoxContainer2/MessageLine

signal transition(new_scene: PackedScene, animation: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	connectButton.pressed.connect(_on_connectButton_pressed)
	returnButton.pressed.connect(_on_return_button_pressed)
	chatSendButton.pressed.connect(_on_chat_send_pressed)

	NetworkClient.player_connected.connect(_on_player_connected)
	NetworkClient.player_disconnected.connect(_on_player_disconnected)
	NetworkClient.player_list_updated.connect(_on_player_list_updated)
	NetworkClient.chat_message_received.connect(_on_message_received)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_connectButton_pressed():
	var server_adress = serverAdressLine.text
	var server_port = int(serverPortLine.text)
	var player_name = playerNameLine.text

	NetworkClient.set_player_info({"name": player_name})
	NetworkClient.join_game(server_adress, server_port)


func _on_player_list_updated():
	for child in playerListContainer.get_children():
		child.queue_free()
	for player in NetworkClient.players:
		var playerName: Label = Label.new()
		playerName.text = NetworkClient.players[player]["name"]
		playerListContainer.add_child(playerName)


func _on_player_connected(_new_player_id, _new_player_info):
	_on_player_list_updated()


func _on_player_disconnected(_id):
	_on_player_list_updated()


func _on_return_button_pressed():
	NetworkClient.leave()
	var menuScene = load(menuScenePath)
	transition.emit(menuScene, "scene_transition")


func _on_chat_send_pressed():
	if chatMessageLine.text == "":
		return
	var message_content = chatMessageLine.text
	NetworkClient.send_chat_message.rpc_id(1, message_content)
	chatMessageLine.text = ""


func _on_message_received(author: String, message: String):
	var msg: Label = Label.new()
	msg.text = "%s : %s" % [author, message]
	chatContainer.add_child(msg)