extends Node3D
class_name CharacterSelect3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var scene_pivot: Node3D = $"%ScenePivot"
@onready var chara_spawn: Node3D = $"%CharacterSpawnPoint"
@onready var grid_spawn: Node3D = $"%GridSpawnPoint"
@onready var hex_grid: HexGridCube = $"%HexGrid"

var spawned_character: CharacterInstance = null

func _ready():
	spawn_grid()

func build(character: CharacterInstance):
	await reset_diorama()
	spawn_diorama(character)

func reset_diorama() -> void:
	# camera movement/blur ?
	if chara_spawn.get_child_count() > 0 && grid_spawn.get_child_count() > 0:
		await hex_grid.fade()
		spawned_character.queue_free()
		spawned_character = null


func spawn_diorama(character: CharacterInstance) -> void:
	character.transition_state("Idle")
	chara_spawn.add_child(character)
	spawned_character = character
	hex_grid.update_tiles_animations_colors(character.colors)
	play_diorama_animation("tile_animation_library/idle")


func play_diorama_animation(anim_name: String) -> void:
	if spawned_character && hex_grid:
		await hex_grid.fade(false)
		hex_grid.queue_rings_anim(anim_name, true, true)

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
	if not hex_grid.is_generation_finished:
		await hex_grid.generation_finished
	hex_grid.fade(true, true)