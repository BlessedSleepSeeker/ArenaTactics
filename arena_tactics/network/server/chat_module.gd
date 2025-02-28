extends Node

var networker: NetworkServer

signal received_message(_author: String, _message: String, _type: String)

func _ready():
	networker = owner as NetworkServer

@rpc("any_peer", "reliable")
func send_chat_message(message: String, type: String) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	var author = networker.players[sender_id]["name"]
	receive_chat_message.rpc(author, sender_id, message, type)
	receive_chat_message(author, sender_id, message, type)

@rpc("authority", "reliable")
func receive_chat_message(_author: String, _sender_id: int, _message: String, _type: String) -> void:
	received_message.emit(_author, _sender_id, _message, _type)