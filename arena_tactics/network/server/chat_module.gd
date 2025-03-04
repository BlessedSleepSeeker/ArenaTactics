extends Node
class_name ServerChatModule

var networker: NetworkServer

signal received_message(_author: String, _message: String, _type: String)

func _ready():
	networker = owner as NetworkServer

@rpc("any_peer", "reliable")
func receive_chat_message(message: String, type: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	var author: ConnectedUser = networker.user_module.get_user_by_id(sender_id)
	if message.begins_with("/"): # interpret chat command
		parse_command(author, message)
	else:
		send_chat_message.rpc(author.user_name, sender_id, message, type)
		send_chat_message(author.user_name, sender_id, message, type)

@rpc("authority", "reliable")
func send_chat_message(_author: String, _sender_id: int, _message: String, _type: String) -> void:
	received_message.emit(_author, _sender_id, _message, _type)

func parse_command(author: ConnectedUser, message: String):
	if not author.is_host:
		send_chat_message("SERVER", 1, "User %s tried to use a command (%s) without being host." % [author.user_name, message], "MAJOR_FAILURE")
		send_chat_message.rpc_id(author.id, "SERVER", 1, "Only the host can use commands !", "MAJOR_FAILURE")
		return
	var parse = message.split(" ") # parse[0] == command. parse[1 and others] == args
	match parse[0]:
		"/help":
			send_help_text(author)
		"/shutdown":
			networker.shutdown()

func send_help_text(author: ConnectedUser) -> void:
	var help_text: String = ""
	send_chat_message.rpc_id(author.id, "SERVER", 1, help_text, "")
