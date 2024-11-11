extends Node

signal chat_message_received(author: String, message: String)

@rpc("any_peer", "reliable")
func send_chat_message(_message: String):
	pass


@rpc("authority", "reliable")
func receive_chat_message(author: String, message: String):
	chat_message_received.emit(author, message)