extends Control
class_name ServerLogs

@onready var log_container: VBoxContainer = $"%LogContainer"
@onready var networker = get_tree().root.get_node("Root").get_node("NetworkRoot").get_node("Networker")
@onready var chat_module = networker.chat_module

# Called when the node enters the scene tree for the first time.
func _ready():
	networker.log_me.connect(_log)
	networker.new_error.connect(_log_error)
	chat_module.received_message.connect(_received_chat_msg)

func _log(message: String):
	var msg: RichTextLabel = RichTextLabel.new()
	msg.bbcode_enabled = true
	msg.fit_content = true
	var cur_date = Time.get_datetime_string_from_system()
	var msg_str = "[%s][b]%s[/b] : %s" % [cur_date, "SERVER", message]
	msg.text = add_type_coloring(msg_str, "")
	log_container.add_child(msg)
	msg.set_focus_mode(FocusMode.FOCUS_CLICK)
	msg.grab_focus()

func _log_error(message: String):
	var msg: RichTextLabel = RichTextLabel.new()
	msg.bbcode_enabled = true
	msg.fit_content = true
	var cur_date = Time.get_datetime_string_from_system()
	var msg_str = "[%s][b]%s[/b] : %s" % [cur_date, "SERVER", message]
	msg.text = add_type_coloring(msg_str, "MAJOR_FAILURE")
	log_container.add_child(msg)
	msg.set_focus_mode(FocusMode.FOCUS_CLICK)
	msg.grab_focus()

func _received_chat_msg(_author: String, _message: String, _type: String) -> void:
	var msg: RichTextLabel = RichTextLabel.new()
	msg.bbcode_enabled = true
	msg.fit_content = true
	var cur_date = Time.get_datetime_string_from_system()
	var msg_str = "[%s][b]%s[/b] : %s" % [cur_date ,_author, _message]
	msg.text = add_type_coloring(msg_str, _type)
	log_container.add_child(msg)
	msg.set_focus_mode(FocusMode.FOCUS_CLICK)
	msg.grab_focus()

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
