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

@export var modules: Dictionary = {}
@export var module_path_template: String = "res://scenes/character/module/%s.gd"
@export var module_class_name_template: String = "%sModule"

@export var character_scene = preload("res://scenes/character/CharacterInstance.tscn")

func instantiate() -> CharacterInstance:
	var instance = character_scene.instantiate()
	ClassLoader.add_child(instance)

	instantiate_data(instance)
	instantiate_modules(instance)

	ClassLoader.remove_child(instance)
	return instance


func instantiate_data(instance: CharacterInstance):
	instance.character_class = self.title
	instance.subtitle = self.subtitle
	instance.portrait = self.portrait
	instance.icon = self.icon
	instance.set_model(model)
	instance.set_hitbox_shape(hitbox_shape)


func instantiate_modules(instance: CharacterInstance):
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
	for child: StringName in data:
		if child in module:
			module.set(child, data[child])
	instance.module_container.add_child(module)

func load_model(model_path: String) -> void:
	var gltf_document_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
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
		cylinder.height = 2
		cylinder.radius = 0.35
		hitbox_shape = cylinder
