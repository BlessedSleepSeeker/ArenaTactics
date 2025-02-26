extends Node

@onready var arguments: Dictionary = {}

func _ready():
	for argument in OS.get_cmdline_user_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			arguments[argument.trim_prefix("--")] = ""
	#print_debug(arguments)

func get_arg(arg_name: String) -> String:
	if arguments.has(arg_name):
		return arguments[arg_name]
	push_error("No argument found named \"%s\"" % arg_name)
	return ""

func has_arg(arg_name: String) -> bool:
	return arguments.has(arg_name)