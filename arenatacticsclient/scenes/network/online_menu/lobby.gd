extends Control

@onready var playerNameLine: LineEdit = $MarginContainer/VBoxContainer/UserIdentity/PlayerName
@onready var serverAdressLine: LineEdit = $MarginContainer/VBoxContainer/ServerConnection/ServerAdress
@onready var serverPortLine: LineEdit = $MarginContainer/VBoxContainer/ServerConnection/ServerPort
@onready var connectButton: Button = $MarginContainer/VBoxContainer/ServerConnection/ConnectButton

# Called when the node enters the scene tree for the first time.
func _ready():
	connectButton.pressed.connect(_on_connectButton_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_connectButton_pressed():
	var server_adress = serverAdressLine.text
	var server_port = int(serverPortLine.text)
	var player_name = playerNameLine.text

	NetworkClient.set_player_info({"name": player_name})
	NetworkClient.join_game(server_adress, server_port)
