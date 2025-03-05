extends Node

@export var class_definition_folder_main_path: String = "res://gameplay/character/class_definitions"
@export var class_definition_folder_path_template: String = "res://gameplay/character/class_definitions/%s"

var classes: Dictionary

var setup_is_finished: bool = false
signal finished_setup

func _ready() -> void:
	load_all_classes()

func load_all_classes() -> void:
	var dir = DirAccess.open(class_definition_folder_main_path)
	if not dir:
		push_error("Error accessing %s" % class_definition_folder_main_path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			#print_debug("Found directory: " + file_name)
			load_class_definition(file_name)
		file_name = dir.get_next()
	#print_debug(classes)
	#add_testing_classes(10)
	setup_is_finished = true
	finished_setup.emit()
	# TODO : add cleaning up null class

func load_class_definition(_class_name: String) -> void:
	var folder_path = class_definition_folder_path_template % _class_name.to_lower()
	var dir = DirAccess.open(folder_path)
	if not dir:
		push_warning("Can't open %s" % folder_path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()

	var class_def: ClassDefinition = ClassDefinition.new()
	class_def.title = _class_name
	
	while file_name != "":
		if dir.current_is_dir():
			pass#print_debug("Found directory: " + file_name)
		else:
			var data = read_file(folder_path + "/%s" % file_name)
			if data.has("Error"):
				push_warning("Error found in file %s while loading class %s" % [file_name, _class_name])
				continue
			parse_data(class_def, file_name.trim_suffix(".json"), data)
		file_name = dir.get_next()
	
	## Setting node name to character class + class template to make debug prints clearer
	class_def.name = "%s Class Template" % [class_def.title.to_pascal_case()]
	## Adding the class def to the dictionary
	classes[_class_name] = class_def
	self.add_child(class_def)


func read_file(path) -> Dictionary:
	#print_debug("Accessing %s..." % path)
	var json_as_text = FileAccess.get_file_as_string(path)
	if json_as_text == "":
		return { "Error": "open error %d at %s" % [FileAccess.get_open_error(), path] }
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict
	return { "Error": "JSON File not parsed properly at path %s" % path }

# If the filename is the same as the character class, it's the base data for the class.
# Otherwise, it's probably a module !
func parse_data(class_def: ClassDefinition, file_name: String, data: Dictionary) -> void:
	if file_name == class_def.title.to_lower():
		class_def.parse_class_data(data)
	else:
		# Module loading/instancing is postponed to the actual class instancing
		class_def.register_module(file_name, data)

func get_class_by_name(_class_name: String) -> ClassDefinition:
	return classes[_class_name]

func get_class_instance_by_name(_class_name: String) -> CharacterInstance:
	var class_def = classes[_class_name]
	if class_def != null:
		return class_def.instantiate()
	push_error("Error while instancing class %s : Class not found" % _class_name)
	return null


func clone_character(original: CharacterInstance) -> CharacterInstance:
	var clone: CharacterInstance = original.duplicate()#character_scene.instantiate()
	self.add_child(clone)

	#original.clone_data(clone)

	self.remove_child(clone)
	return clone
