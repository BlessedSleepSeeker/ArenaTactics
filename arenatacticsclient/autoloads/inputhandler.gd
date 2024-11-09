extends Node

# setting file path
var settings_folder_name := "settings"
var settings_folder_path := "user://%s/" % settings_folder_name
var controls_file_name := "controls.cfg"
var controls_file_path := "%s%s" % [settings_folder_path, controls_file_name]

@onready var user_folder = DirAccess.open("user://")
@onready var input_file = ConfigFile.new()

# custom actions definition var
var action_template: String = "p%d_%s" #p1_right for example
var possible_actions: Array = ["right", "left", "up", "down", "attack"]

func _ready():
	var err = input_file.load(controls_file_path)
	if err != OK:
		printerr("Something happened at %s, error code [%d], creating new settings file..." % [controls_file_path, err])

		var err_create = create_input_file()
		if err_create != OK:
			printerr("Could not load the settings, using default configuration instead")
		return # default action are set in the editor directly, so we do not need to set them if the input file wasn't found, as we are falling back to default.


func create_input_file() -> int:
	if not DirAccess.open(settings_folder_path):
		user_folder.make_dir(settings_folder_name)
	return save_file()

func load_players_actions_from_file(player_count: int) -> void:
	for i in range(1, player_count + 1):
		load_player_actions_from_file(i)

func load_player_actions_from_file(player_nbr: int) -> void:
	for action in possible_actions:
		load_player_action_from_file(player_nbr, action)

func load_player_action_from_file(player_nbr: int, action: String) -> void:
	var action_name = action_template % [player_nbr, action]
	var action_value = get_value("Player %d" % player_nbr, action_name)
	if action_value:
		add_action_from_string(action_name, action_value)

func add_action_from_string(action_name: String, action_value: String) -> void:
	var action_value_input: InputEventKey = InputEventKey.new()
	action_value_input.set_keycode(OS.find_keycode_from_string(action_value))
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if not InputMap.action_has_event(action_name, action_value_input):
		InputMap.action_add_event(action_name, action_value_input)

func add_action_from_event(action_name: String, action_event: InputEvent) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if not InputMap.action_has_event(action_name, action_event):
		InputMap.action_add_event(action_name, action_event)

func create_players_actions(player_count: int) -> void:
	for i in range(1, player_count + 1):
		create_player_actions(i)

func create_player_actions(player_nbr: int) -> void:
	for action in possible_actions:
		var action_name = action_template % [player_nbr, action]
		if not get_value("Player %d" % player_nbr, action_name):
			set_value("Player %d" % player_nbr, action_name, "")
	save_file()

func check_players_actions(player_count: int) -> String:
	for i in range(1, player_count + 1):
		var act = check_player_actions(i)
		if act != "":
			return act
	return ""

func check_player_actions(player_nbr: int) -> String:
	for action in possible_actions:
		var act = check_player_action(player_nbr, action)
		if act != "":
			return act
	return ""

func check_player_action(player_nbr: int, action: String) -> String:
	var act := action_template % [player_nbr, action]
	if InputMap.has_action(act) and InputMap.action_get_events(act).size() > 0:
		return ""
	return act

func flush_actions() -> void:
	for act in InputMap.get_actions():
		if not act.begins_with("ui_"):
			print_debug(act)

func get_value(section: String, setting: String) -> Variant:
	return input_file.get_value(section, setting, false)

func set_value(section: String, setting: String, value: Variant) -> void:
	input_file.set_value(section, setting, value)

func save_actions_to_file() -> void:
	for action_name in InputMap.get_actions():
		if action_name.begins_with("p"):
			var split = action_name.split("_", false, 1)
			var player_nbr = split[0].lstrip("p")
			set_value("Player %s" % player_nbr, action_name, InputMap.action_get_events(action_name)[0].as_text())
	save_file()

func save_file() -> int:
	print_debug('Saving player input file at %s.' % controls_file_path )
	var err = input_file.save(controls_file_path)

	if err != OK:
		printerr("Error code [%d]. Something went wrong saving the player input file at %s." % [err, controls_file_path])
	return err
