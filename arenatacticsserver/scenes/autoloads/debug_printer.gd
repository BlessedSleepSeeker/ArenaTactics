extends Node

@export var debug_template: String = "[%s]{%s}(%s): \"%s\""

func _ready():
	print(format_debug_string(self, "INFO", "DebugHelper Online"))

func format_debug_string(debugged_object: Variant, message_type: String, message: String) -> String:
	var cur_date = Time.get_datetime_string_from_system()
	if debugged_object is Resource and not debugged_object.get("name"):
		return debug_template % [cur_date, debugged_object, message_type, message]
	else:
		return debug_template % [cur_date, debugged_object.name, message_type, message]
	
