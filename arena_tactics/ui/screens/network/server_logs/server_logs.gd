extends Control
class_name ServerLogs

@export var save_logs_to_file: bool = true
@export var log_folder_path: String = "user://logs/server/"
@export var log_filename: String = "server_%s.log" % format_date("%d_%d_%d_%d_%d_%d")
@onready var log_filepath: String = ""
var log_file: FileAccess = null

@onready var date_template: String = "%d/%d/%d - %d:%d:%d"

@onready var log_container: VBoxContainer = $"%LogContainer"
@onready var networker = get_tree().root.get_node("Root").get_node("NetworkRoot").get_node("Networker")
@onready var chat_module = networker.chat_module

signal log_written(line: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	networker.log_me.connect(_log)
	networker.new_error.connect(_log_error)
	chat_module.received_message.connect(_received_chat_msg)
	if save_logs_to_file:
		setup_file()
		log_written.connect(write_line)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if save_logs_to_file && log_file && log_file.is_open():
			log_file.close()

#region Logging
func _log(message: String):
	var msg: RichTextLabel = RichTextLabel.new()
	msg.bbcode_enabled = true
	msg.fit_content = true
	var msg_str = "(%s) [b]%s[/b] : %s" % [format_date(date_template), "SERVER", message]
	msg.text = add_type_coloring(msg_str, "")
	log_container.add_child(msg)
	msg.set_focus_mode(FocusMode.FOCUS_CLICK)
	msg.grab_focus()
	log_written.emit(msg_str)

func _log_error(message: String):
	var msg: RichTextLabel = RichTextLabel.new()
	msg.bbcode_enabled = true
	msg.fit_content = true
	var msg_str = "(%s) [b]%s[/b] : %s" % [format_date(date_template), "SERVER", message]
	msg.text = add_type_coloring(msg_str, "MAJOR_FAILURE")
	log_container.add_child(msg)
	msg.set_focus_mode(FocusMode.FOCUS_CLICK)
	msg.grab_focus()
	log_written.emit(msg_str)

func _received_chat_msg(_author: String, _sender_id: int, _message: String, _type: String) -> void:
	var msg: RichTextLabel = RichTextLabel.new()
	msg.bbcode_enabled = true
	msg.fit_content = true
	var msg_str = "(%s) [b]%s (%d)[/b] : %s" % [format_date(date_template), _author, _sender_id, _message]
	msg.text = add_type_coloring(msg_str, _type)
	log_container.add_child(msg)
	msg.set_focus_mode(FocusMode.FOCUS_CLICK)
	msg.grab_focus()
	log_written.emit(msg_str)

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

static func format_date(template: String) -> String:
	var date_dict = Time.get_datetime_dict_from_system()
	return template % [date_dict["year"], date_dict["month"], date_dict["day"], date_dict["hour"], date_dict["minute"], date_dict["second"]]
#endregion

#region FileHandling
func setup_file() -> void:
	if not DirAccess.dir_exists_absolute(log_folder_path):
		DirAccess.make_dir_recursive_absolute(log_folder_path)
	log_filepath = log_folder_path + log_filename
	log_file = FileAccess.open(log_filepath, FileAccess.WRITE)
	if FileAccess.get_open_error() != 0:
		push_error("Error code %d while opening [%s]." % [FileAccess.get_open_error(), log_filepath])
		_log_error("Error code %d while opening [%s]." % [FileAccess.get_open_error(), log_filepath])

## Stolen from the docs
static func strip_bbcode(line: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	return regex.sub(line, "", true)

func write_line(line: String) -> void:
	log_file.store_line(strip_bbcode(line))
#endregion

#region Toggling

func _unhandled_input(_event):
	if Input.is_action_pressed("server_log_toggle"):
		self.visible = !visible

#endregion