extends CharacterBody3D
class_name CharacterInstance

@export var class_definition_folder_path_template: String = "res://scenes/world/character/class_definitions/%s"
@export var module_path_template: String = "res://scenes/world/character/module/%s.gd"
@export var module_class_name_template: String = "%sModule"

@export var team_name: String = ""
@export var player_id: String = ""
@export var character_class: String = ""

@onready var mesh_instance: MeshInstance3D = $"%MeshInstance"
@onready var hitbox: CollisionShape3D = $"%Hitbox"
@export var portrait: Texture2D = null
@export var icon: Texture2D = null


func build(_team_name: String, _player_id: String, _character_class: String) -> bool:
	self.team_name = _team_name
	self.player_id = _player_id
	self.character_class = _character_class
	
	var folder_path = class_definition_folder_path_template % _character_class.to_lower()
	var dir = DirAccess.open(folder_path)
	if not dir:
		print_debug("Error accessing %s" % folder_path)
		return false
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			print("Found directory: " + file_name)
		else:
			var data = read_file(folder_path + "/%s" % file_name)
			if data.has("Error"):
				return false
			self.parse_data(file_name.trim_suffix(".json"), data)
		file_name = dir.get_next()
	return true


func read_file(path) -> Dictionary:
	var json_as_text = FileAccess.get_file_as_string(path)
	if json_as_text == "":
		return { "Error": "open error %d at %s" % [FileAccess.get_open_error(), path] }
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict
	return { "Error": "JSON File not parsed properly at path %s" % path }

# If the filename is the same as the character class, it's the base data for the class.
# Otherwise, it's probably a module !
func parse_data(file_name: String, data: Dictionary) -> void:
	if file_name == self.character_class.to_lower():
		return parse_class_data(data)
	var module_path: String = self.module_path_template % file_name
	if not FileAccess.file_exists(module_path):
		print_debug("File not found at %s" % module_path)
		return
	var module = load(module_path).new()
	print_debug(module)
	# if not module is Module:
	# 	print_debug("Is not module")
	# 	return
	for child: StringName in data:
		if child in module:
			module.set(child, data[child])
	self.add_child(module)


# Where we load most visuals. 3D Mesh, textures, hitboxes...
func parse_class_data(class_data: Dictionary) -> void:
	for data in class_data:
		if check_if_match_and_path_exist("mesh", data, class_data[data]):
			mesh_instance.mesh = load(class_data[data])
		elif check_if_match_and_path_exist("hitbox", data, class_data[data]):
			hitbox.shape = load(class_data[data])
		elif check_if_match_and_path_exist("portrait", data, class_data[data]):
			portrait = load(class_data[data])
		elif check_if_match_and_path_exist("icon", data, class_data[data]):
			icon = load(class_data[data])


func check_if_match_and_path_exist(match: String, key, value) -> bool:
	return key is String && key.contains(match) && value is String && FileAccess.file_exists(value)
