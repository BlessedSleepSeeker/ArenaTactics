extends Node
class_name ClassDefinition

@export var title: String = "Default"
@export var subtitle: String = "Default"
## Supports BBCODE
@export var description: String = "Default Default"

@export var portrait: Texture2D = null
@export var fallback_portrait_texture_path: String = "res://scenes/UI/characters/character_select_screen/UI/assets/base_drawing_area_portrait.png"
@export var icon: Texture2D = null
@export var fallback_icon_texture_path: String = "res://icon.svg"
@export var model: PackedScene = null
@export var hitbox_shape: Shape3D = null

@export var colors: Dictionary = {}

@export var modules: Dictionary = {}
@export var module_path_template: String = "res://scenes/character/module/%s.gd"
@export var module_class_name_template: String = "%sModule"

@export var character_scene = preload("res://scenes/character/CharacterInstance.tscn")

func instantiate(load_data: bool = true, load_modules: bool = true) -> CharacterInstance:
	var instance = character_scene.instantiate()
	ClassLoader.add_child(instance)

	if load_data:
		instantiate_data(instance)
	if load_modules:
		instantiate_modules(instance)

	ClassLoader.remove_child(instance)
	return instance


func instantiate_data(instance: CharacterInstance) -> void:
	instance.character_class = self.title
	instance.subtitle = self.subtitle
	instance.portrait = self.portrait
	instance.icon = self.icon
	instance.colors = self.colors
	instance.set_model(model)
	instance.set_hitbox_shape(hitbox_shape)

#region Modules

## Register a module to the module list. Registered modules are instantiated with `instantiate_modules()`
func register_module(module_name: String, module_data: Dictionary) -> void:
	self.modules[module_name] = module_data

func instantiate_modules(instance: CharacterInstance) -> void:
	for file_name in modules:
		instantiate_module(instance, file_name, modules[file_name])

func instantiate_module(instance: CharacterInstance, file_name: String, data: Dictionary):
	var module_path: String = self.module_path_template % file_name
	var module_class_name: String = self.module_class_name_template % file_name.capitalize()

	## TODO : refactor module loading
	## We find the module script in the global class (code class, not rpg class) list and check if the file exist.
	for script in ProjectSettings.get_global_class_list():
		if script["class"] == module_class_name:
			module_path = script["path"]
	if not FileAccess.file_exists(module_path):
		push_error("File not found at %s" % module_path)
		return

	var module: Module = load(module_path).new()
	module.module_name = module_class_name
	module.setup(instance, data)
	instance.module_container.add_child(module)

#endregion

#region Data Loading

## Where we load most visuals. 3D Mesh, textures, hitboxes...
func parse_class_data(class_data: Dictionary) -> void:
	for data in class_data:
		if is_match_and_path_exist("model", data, class_data[data]):
			load_model(class_data[data])
		elif is_match("hitbox", data):
			load_hitbox_shape(class_data[data])
		elif is_match("portrait", data):
			load_portrait(class_data[data])
		elif is_match("icon", data):
			load_icon(class_data[data])
		elif is_match("css_screen", data):
			load_css_data(class_data[data])
		else:
			add_string_data_to_var(data, class_data[data])

func load_css_data(css_data: Dictionary):
	for data in css_data:
		if is_match("color", data):
			colors[data] = Color(str(css_data[data]))

func load_model(model_path: String) -> void:
	var gltf_document_load := GLTFDocument.new()
	var gltf_state_load := GLTFState.new()
	var error = gltf_document_load.append_from_file(model_path, gltf_state_load)
	if error == OK:
		var gltf_scene_root_node = gltf_document_load.generate_scene(gltf_state_load)
		model = PackedScene.new()
		model.pack(gltf_scene_root_node)
	else:
		push_error("Couldn't load model glTF (error code: %s)." % error_string(error))

func load_portrait(portrait_path: String) -> void:
	if FileAccess.file_exists(portrait_path):
		portrait = load(portrait_path)
	else:
		portrait = load(fallback_portrait_texture_path)

func load_icon(icon_path: String) -> void:
	if FileAccess.file_exists(icon_path):
		icon = load(icon_path)
	else:
		icon = load(fallback_portrait_texture_path)

func load_hitbox_shape(hitbox_path: String) -> void:
	if FileAccess.file_exists(hitbox_path):
		hitbox_shape = load(hitbox_path)
	else:
		var cylinder: CylinderShape3D = CylinderShape3D.new()
		cylinder.height = 0.01
		cylinder.radius = 0.35
		hitbox_shape = cylinder

#endregion

#region Helpers
func is_match(match: String, key) -> bool:
	return key is String && key.contains(match)

func is_match_and_path_exist(match: String, key, value) -> bool:
	return key is String && key.contains(match) && value is String && FileAccess.file_exists(value)

func add_string_data_to_var(var_name: String, var_value: String):
	if var_name in self:
		self.set(var_name, var_value)
	#print_debug("%s: %s = %s" % [var_name, var_value, instance.get(var_name)])

#endregion