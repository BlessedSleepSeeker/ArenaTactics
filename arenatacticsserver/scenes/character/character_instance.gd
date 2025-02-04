extends CharacterBody3D
class_name CharacterInstance

@export var team_name: String = ""
@export var player_id: String = ""
@export var character_class: String = ""

@export var subtitle: String = ""

## Supports BBCODE
@export var description: String = ""

@export var fallback_portrait_texture_path: String = "res://scenes/UI/characters/character_select_screen/assets/base_drawing_area_portrait.png"
@export var fallback_icon_texture_path: String = "res://icon.svg"

@onready var module_container: Node = $"%ModuleContainer"
@onready var model_container: Node3D = $"%ModelContainer"
@onready var hitbox: CollisionShape3D = $"%Hitbox"
@export var portrait: Texture2D = null
@export var icon: Texture2D = null

func set_data(_team_name: String, _player_id: String, _character_class: String) -> bool:
	self.team_name = _team_name
	self.player_id = _player_id
	self.character_class = _character_class

	return true


func get_module_by_name(value: String) -> Module:
	for child: Module in module_container.get_children():
		if child.module_name == value:
			return child
	return null


func modules_start_game():
	for module: Module in self.module_container.get_children():
		module.start_game()


func load_model(model_path: String) -> void:
	var gltf_document_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
	var error = gltf_document_load.append_from_file(model_path, gltf_state_load)
	if error == OK:
		var gltf_scene_root_node = gltf_document_load.generate_scene(gltf_state_load)
		model_container.add_child(gltf_scene_root_node)
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
		hitbox.shape = load(hitbox_path)
	else:
		var cylinder: CylinderShape3D = CylinderShape3D.new()
		cylinder.height = 2
		cylinder.radius = 0.35
		hitbox.shape = cylinder