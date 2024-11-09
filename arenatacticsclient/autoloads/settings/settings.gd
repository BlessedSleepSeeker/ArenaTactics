extends Node
class_name Settings

@export var user_settings_file_path: String = "user://settings/game_settings.cfg"

#setting file path
@onready var settings_file := ConfigFile.new()

## On boot, we first create the basic settings due to them being defined in our scene tree.
## Then we load the setting file and change the values of our settings based on the value inside the file.
## We then apply the settings and save the settings value to the settings file.
func _ready():
	if load_setting_file() == OK:
		load_settings_from_file()
	apply_settings()
	save_settings_to_file()

## Return an array with the names of the sections.
## Used for UI creation.
func get_sections_list() -> Array:
	var sections: Array = []
	for sett in get_children():
		if !sections.has(sett.name):
			sections.append(sett.name)
	return sections

## Return an array with all the settings of a specific section.
## Used for UI creation.
func get_settings_by_section(section: String) -> Array:
	var sect = get_node_or_null(section)
	if sect != null:
		return sect.get_children()
	return []


## Change the path to the settings file.
func change_settings_file_path(new_path: String) -> void:
	user_settings_file_path = new_path

## Load the setting file in memory.
func load_setting_file() -> int:
	var err = settings_file.load(user_settings_file_path)
	if err != OK:
		printerr("Something happened at %s, error code [%d]" % [user_settings_file_path, err])
	return err

## Does not create any settings. Only change the values of the defined settings in the settings.tscn scene.
func load_settings_from_file() -> void:
	for section in get_children():
		for setting in section.get_children():
			if settings_file.has_section(section.name) and settings_file.has_section_key(section.name, setting.key):
				setting.value = get_file_value(section.name, setting.key)

## save_settings_to_file() will get the values inside the settings array and put them in the file.
## We need to call save_to_file() only when the settings are saved by the user.
func save_settings_to_file() -> int:
	print_debug('Saving file at %s' % user_settings_file_path)

	for section in get_children():
		for setting in section.get_children():
			set_file_value(section.name, setting.key, setting.value)

	var err = settings_file.save(user_settings_file_path)
	if err != OK:
		printerr("Error code [%d]. Something went wrong saving the file at %s." % [err, user_settings_file_path])
	return err


func get_file_value(section: String, setting: String) -> Variant:
	return settings_file.get_value(section, setting, "")


func set_file_value(section: String, setting: String, value: Variant) -> void:
	settings_file.set_value(section, setting, value)

## Settings Interaction

func print_settings() -> void:
	for seti in get_children():
		print_debug(seti.get_print_string())


#func create_bool_setting(key: String, value: Variant): #automaticaly set the default value to the value you give him at creation
#	add_setting(Setting.new(key, value, value, Setting.SETTING_TYPE.BOOLEAN))
#
#
#func create_range_setting(key: String, value: Variant, min_value: int, max_value: int):
#	add_setting(Setting.new(key, value, value, Setting.SETTING_TYPE.RANGE, min_value, max_value))
#
#
#func create_option_setting(key: String, value: Variant, options: Array):
#	add_setting(Setting.new(key, value, value, Setting.SETTING_TYPE.OPTIONS, -8888, -8888, options))


#func add_setting(_setting: Setting) -> void:
#	pass #settings.append(setting)

# not functional
func remove_setting(_setting_key: String) -> void:
	pass
	#settings.pop_at(settings.bsearch(setting_key))


func apply_settings() -> void:
	for section in get_children():
		for setting in section.get_children():
			if setting.has_method("apply"):
				setting.apply()
