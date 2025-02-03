extends CharacterBody3D
class_name CharacterInstance

@export var team_name: String = ""
@export var player_id: String = ""
@export var character_class: String = ""

@onready var module_container: Node = $"%ModuleContainer"
@onready var mesh_instance: MeshInstance3D = $"%MeshInstance"
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
