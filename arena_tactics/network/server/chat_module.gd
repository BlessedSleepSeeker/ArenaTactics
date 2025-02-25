extends Node

@rpc("any_peer", "reliable")
func send_chat_message(message):
	var sender_id = multiplayer.get_remote_sender_id()
	#var author = Networker.players[sender_id]["name"] + ' (' + str(sender_id) + ')'
	#receive_chat_message.rpc(author, message)

@rpc("authority", "reliable")
func receive_chat_message(_author: String, _message: String):
	pass