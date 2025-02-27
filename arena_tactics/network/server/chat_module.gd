extends Node

var networker: NetworkServer

signal received_message(_author: String, _message: String, _type: String)

func _ready():
	networker = owner as NetworkServer

@rpc("any_peer", "reliable")
func send_chat_message(message: String, type: String) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	var author = networker.players[sender_id]["name"] + ' (' + str(sender_id) + ')'
	receive_chat_message.rpc(author, message, type)
	receive_chat_message(author, message, type)

@rpc("authority", "reliable")
func receive_chat_message(_author: String, _message: String, _type: String) -> void:
	received_message.emit(_author, _message, _type)