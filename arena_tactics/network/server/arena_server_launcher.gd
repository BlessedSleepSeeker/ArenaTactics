extends Resource
class_name ArenaServerLauncher

@export var unique_setting_template: String = "--%s=%s"

func _init(settings: Settings):
	var dict = settings.get_settings_as_dict()
	var args = convert_dict_to_args(dict)
	launch_server_with_args(args)

func convert_dict_to_args(dict: Dictionary) -> PackedStringArray:
	var args: PackedStringArray = []
	#args.append("--headless")
	args.append("--")
	args.append("--server")
	for setting: String in dict:
		var arg: String = unique_setting_template % [setting, str(dict[setting])]
		args.append(arg)
	return args

func launch_server_with_args(args: PackedStringArray) -> void:
	var strr = OS.get_executable_path()
	for a in args:
		strr += " "
		strr += a
	#print_debug(strr)
	# var dict = OS.execute_with_pipe(OS.get_executable_path(), args)
	# var stdio = dict["stdio"]
	# var stderr = dict["stderr"]
	# var pid = dict["pid"]
	# print(stdio, stderr, pid)