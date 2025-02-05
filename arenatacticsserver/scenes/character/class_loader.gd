extends Node

@export var class_definition_folder_main_path: String = "res://scenes/character/class_definitions"
@export var class_definition_folder_path_template: String = "res://scenes/character/class_definitions/%s"
@export var module_path_template: String = "res://scenes/character/module/%s.gd"
@export var module_class_name_template: String = "%sModule"
@export var character_scene = preload("res://scenes/character/CharacterInstance.tscn")

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
			load_class(file_name)
		file_name = dir.get_next()
	#print_debug(classes)
	#add_testing_classes(10)
	setup_is_finished = true
	finished_setup.emit()
	# TODO : add cleaning up null class

func load_class(_class_name: String) -> void:
	var folder_path = class_definition_folder_path_template % _class_name.to_lower()
	var dir = DirAccess.open(folder_path)
	if not dir:
		push_warning("Can't open %s" % folder_path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var instance: CharacterInstance = character_scene.instantiate()
	instance.hide()
	instance.character_class = _class_name
	self.add_child(instance)
	while file_name != "":
		if dir.current_is_dir():
			pass#print_debug("Found directory: " + file_name)
		else:
			var data = read_file(folder_path + "/%s" % file_name)
			if data.has("Error"):
				push_warning("Error found in file %s while loading class %s" % [file_name, _class_name])
				continue
			parse_data(instance, file_name.trim_suffix(".json"), data)
		file_name = dir.get_next()
	## Setting node name to character class + class template to make debug prints clearer
	instance.name = "%s Class Template" % [instance.character_class.to_pascal_case()]
	classes[_class_name] = instance


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
func parse_data(instance: CharacterInstance, file_name: String, data: Dictionary) -> void:
	if file_name == instance.character_class.to_lower():
		parse_class_data(instance, data)
		return
	var module_path: String = self.module_path_template % file_name
	var module_class_name: String = self.module_class_name_template % file_name.capitalize()
	
	for script in ProjectSettings.get_global_class_list():
		if script["class"] == module_class_name:
			module_path = script["path"]
	if not FileAccess.file_exists(module_path):
		push_error("File not found at %s" % module_path)
		return

	var module: Module = load(module_path).new()
	module.module_name = module_class_name
	# if not module is Module:
	# 	print_debug("Is not module")
	# 	return
	for child: StringName in data:
		if child in module:
			module.set(child, data[child])
	instance.module_container.add_child(module)


# Where we load most visuals. 3D Mesh, textures, hitboxes...
func parse_class_data(instance: CharacterInstance, class_data: Dictionary) -> void:
	for data in class_data:
		if check_if_match_and_path_exist("model", data, class_data[data]):
			instance.load_model(class_data[data])
		elif check_if_match_and_path_exist("hitbox", data, class_data[data]):
			instance.hitbox.shape = load(class_data[data])
		elif check_if_match_and_path_exist("portrait", data, class_data[data]):
			instance.load_portrait(class_data[data])
		elif check_if_match_and_path_exist("icon", data, class_data[data]):
			instance.load_icon(class_data[data])
		else:
			add_string_data_to_var(instance, data, class_data[data])

func check_if_match_and_path_exist(match: String, key, value) -> bool:
	return key is String && key.contains(match) && value is String && FileAccess.file_exists(value)

func add_string_data_to_var(instance: CharacterInstance, var_name: String, var_value: String):
	if var_name in instance:
		instance.set(var_name, var_value)
	#print_debug("%s: %s = %s" % [var_name, var_value, instance.get(var_name)])


func get_class_instance(_class_name: String) -> CharacterInstance:
	for instance_key: String in classes:
		var class_template = classes[instance_key]
		if class_template.character_class == _class_name:
			return clone_character(class_template)
	push_error("Error while instancing class %s : Class not found" % _class_name)
	return null


func clone_character(original: CharacterInstance) -> CharacterInstance:
	var clone: CharacterInstance = original.duplicate()#character_scene.instantiate()
	self.add_child(clone)

	#original.clone_data(clone)

	self.remove_child(clone)
	return clone

func add_testing_classes(numbers_to_add: int) -> void:
	for i in numbers_to_add:
		var fake_class = character_scene.instantiate()
		self.add_child(fake_class)
		fake_class.character_class = str(i)
		fake_class.load_model("class_data[data]")
		fake_class.hitbox.shape = null
		fake_class.load_portrait("aaa")
		fake_class.load_icon("class_data[data]")
		classes[i] = fake_class
