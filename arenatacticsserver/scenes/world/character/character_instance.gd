extends CharacterBody3D
class_name CharacterInstance

@export var class_folder_path_template = "res://scenes/world/character/class_definitions/%s.json"

@export var team_name = ""
@export var player_id = ""
@export var character_class = ""

@onready var mesh_instance = $"%MeshInstance"
@onready var hitbox = $"%Hitbox"

func build(_team_name: String, _player_id: String, _character_class: String) -> bool:
	var folder_path = class_folder_path_template % _character_class.to_lower()
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
			print("Found file: " + file_name)
		file_name = dir.get_next()
	self.team_name = _team_name
	self.player_id = _player_id
	self.character_class = _character_class
	return true


func read_file(path) -> Dictionary:
	var json_as_text = FileAccess.get_file_as_string(path)
	if json_as_text == "":
		return { "Error": "open error %d at %s" % [FileAccess.get_open_error(), path] }
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict
	return { "Error": "JSON File not parsed properly at path %s" % path }
	

func parse_data(data: Dictionary):
	for child in data:
		print_debug(child, " ", data[child])