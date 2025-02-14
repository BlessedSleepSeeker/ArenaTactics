extends Node3D
class_name CharacterSelect3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var scene_pivot: Node3D = $"%ScenePivot"
@onready var chara_spawn: Node3D = $"%CharacterSpawnPoint"
@onready var grid_spawn: Node3D = $"%GridSpawnPoint"
@onready var hex_grid: HexGrid = $"%HexGrid"

var spawned_character: CharacterInstance = null

signal fade_finished

func _ready():
	spawn_grid()

func build(character: CharacterInstance):
	reset_diorama()
	await fade_finished
	spawn_diorama(character)

func reset_diorama() -> void:
	# camera movement/blur ?
	await get_tree().create_timer(0.11).timeout
	if chara_spawn.get_child_count() > 0 && grid_spawn.get_child_count() > 0:
		hex_grid.fade()
		await hex_grid.fade_out_finished
		spawned_character.queue_free()
		spawned_character = null
	fade_finished.emit()


func spawn_diorama(character: CharacterInstance) -> void:
	character.transition_state("Idle")
	chara_spawn.add_child(character)
	spawned_character = character
	hex_grid.update_tiles_animations_colors(character.colors)
	play_diorama_animation("tile_animation_library/idle", 3)


func play_diorama_animation(anim_name: String, wait_multiplier: float = 1) -> void:
	if spawned_character && hex_grid:
		hex_grid.fade(false)
		await hex_grid.fade_in_finished
		hex_grid.queue_grid_anim(anim_name, wait_multiplier)

func play_character_action(action: GameplayAction):
	if spawned_character.has_state(action.name):
		spawned_character.transition_state(action.name)
	else:
		spawned_character.transition_state("Idle")

func spawn_grid():
	hex_grid.generate_grid()

	## Position everything properly
	var grid_center_global_pos = hex_grid.get_center_tile().global_position
	grid_spawn.global_position = -grid_center_global_pos
	grid_center_global_pos = hex_grid.get_center_tile().global_position
	grid_center_global_pos.y = 10
	chara_spawn.global_position = grid_center_global_pos
