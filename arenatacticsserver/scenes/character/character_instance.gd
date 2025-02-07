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

@onready var state_machine: StateMachine = $StateMachine
@onready var module_container: Node = $"%ModuleContainer"
@onready var model_container: Node3D = $"%ModelContainer"
@onready var hitbox: CollisionShape3D = $"%Hitbox"
@export var portrait: Texture2D = null
@export var icon: Texture2D = null

var model_animation_player: AnimationPlayer = null

func set_data(_team_name: String, _player_id: String, _character_class: String) -> bool:
	self.team_name = _team_name
	self.player_id = _player_id
	self.character_class = _character_class

	return true


func set_model(model: PackedScene) -> void:
	if model:
		var inst = model.instantiate()
		if inst.has_node("AnimationPlayer"):
			model_animation_player = inst.get_node("AnimationPlayer")
		model_container.add_child(inst)

func transition_state(state_name: String, msg: Dictionary = {}):
	state_machine.transition_to(state_name, msg)


func play_animation(animation_name: String, reverse: bool = false):
	if model_animation_player == null:
		return
	if not reverse:
		model_animation_player.play(animation_name)
	else:
		model_animation_player.play_backwards(animation_name)
	model_animation_player.advance(0)

func set_hitbox_shape(shape: Shape3D) -> void:
	hitbox.shape = shape


func get_module_by_name(value: String) -> Module:
	for child: Module in module_container.get_children():
		if child.module_name == value:
			return child
	return null

func modules_start_game() -> void:
	for module: Module in self.module_container.get_children():
		module.start_game()


func clone_from(original: CharacterInstance):
	var og_data = original.export_data()
	import_data(og_data)

func export_data() -> Dictionary:
	var data = {}
	return data

func import_data(source: Dictionary) -> void:
	for key in source:
		pass
