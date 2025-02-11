extends Node3D
class_name CharacterSelect3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var chara_spawn: Node3D = $"%CharacterSpawnPoint"
@onready var grid_spawn: Node3D = $"%GridSpawnPoint"

@export var hex_grid_scene: PackedScene = preload("res://scenes/world/HexGrid.tscn")
@export var hex_grid_tile: PackedScene = preload("res://scenes/world/Tiles/FakeHexTile.tscn")
@export var hex_grid_size_x: int = 2
@export var hex_grid_size_y: int = 3
@export var hex_grid_timer: float = 0.1
@export var hex_grid_flatworld: bool = true

signal fade_finished

func _ready():
	spawn_grid()

func build(class_def: ClassDefinition):
	reset_diorama()
	await fade_finished
	spawn_diorama(class_def)

func reset_diorama() -> void:
	# camera movement/blur ?
	await get_tree().create_timer(0.11).timeout
	if chara_spawn.get_child_count() > 0 && grid_spawn.get_child_count() > 0:
		for hex_grid: HexGrid in grid_spawn.get_children():
			hex_grid.fade()
			await hex_grid.fade_out_finished
		for chara: CharacterInstance in chara_spawn.get_children():
			chara.queue_free()
	fade_finished.emit()


func spawn_diorama(class_def: ClassDefinition) -> void:
	var new_instance: CharacterInstance = class_def.instantiate()
	new_instance.transition_state("Idle")
	chara_spawn.add_child(new_instance)
	play_diorama_animation("idle", 5)


func play_diorama_animation(anim_name: String, wait_multiplier: float = 1) -> void:
	if chara_spawn.get_child_count() > 0 && grid_spawn.get_child_count() > 0:
		for hex_grid: HexGrid in grid_spawn.get_children():
			hex_grid.fade(false)
			await hex_grid.fade_in_finished
			hex_grid.queue_grid_anim(anim_name, wait_multiplier)

func spawn_grid():
	var grid_instance: HexGrid = hex_grid_scene.instantiate()
	grid_instance.tile_scene = hex_grid_tile
	grid_instance.grid_size_x = hex_grid_size_x
	grid_instance.grid_size_y = hex_grid_size_y
	grid_instance.timer_between_tile = hex_grid_timer
	grid_instance.flat_world = hex_grid_flatworld
	grid_instance.generation_algorithm = grid_instance.GenerationAlgorithm.CIRCLE
	grid_spawn.position = Vector3(-hex_grid_size_x, 0, -hex_grid_size_x)
	grid_spawn.add_child(grid_instance)
	grid_instance.generate_grid()
	var grid_center_global_pos = grid_instance.get_center_tile().global_position
	grid_center_global_pos.y = 10
	chara_spawn.global_position = grid_center_global_pos
