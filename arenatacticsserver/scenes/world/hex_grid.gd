extends Node3D
class_name HexGrid


@export var tile_size: float = 1.0
@export var grid_size_x: int = 50 #vertical
@export var grid_size_y: int = 50 #horizontal
@export var timer_between_tile: float = 0.001
@export var flat_world: bool = false

@export var tile_scene: PackedScene = preload("res://scenes/world/HexTile.tscn")

signal tile_hovered(hex_tile: HexTile)
signal tile_clicked(hex_tile: HexTile)
signal generation_finished
signal fade_finished

var selected_tile: HexTile = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if not flat_world:
		if ProcGen.setup_is_finished:
			generate_new_grid()
		else:
			ProcGen.finished_setup.connect(generate_new_grid)
	else:
		generate_flat_world()


func free_grid() -> void:
	for child in self.get_children():
		child.queue_free()

func generate_new_grid() -> void:
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var inst: HexTile = tile_scene.instantiate()
			inst.grid_pos_x = i
			inst.grid_pos_y = j
			inst.height = ProcGen.set_elevation_for_tile(inst, grid_size_x, grid_size_y)
			var pos = calculate_tile_position(inst)
			inst.position = pos
			inst.hover_enter.connect(_on_tile_hovered)
			self.add_child(inst)
			if inst.distance >= 0.8:
				inst.queue_free()
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile).timeout

func generate_flat_world() -> void:
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var inst: HexTile = tile_scene.instantiate()
			inst.grid_pos_x = i
			inst.grid_pos_y = j
			var pos = calculate_tile_position(inst)
			inst.position = pos
			self.add_child(inst)
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile).timeout
	generation_finished.emit()


func fade_out():
	for tile: HexTile in get_children():
		if tile.has_node("AnimationPlayer"):
			var node_anim_player: AnimationPlayer = tile.get_node("AnimationPlayer")
			node_anim_player.play_backwards("fade_in")
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile).timeout
	await get_tree().create_timer(0.2).timeout
	fade_finished.emit()


func calculate_tile_position(hex_tile: HexTile):
	var vertical_spacing: float =  hex_tile.radius * sqrt(3)
	var vertical_pos: float = vertical_spacing * hex_tile.grid_pos_x
	var horizontal_spacing: float = (3.0/4.0 * hex_tile.radius)
	var horizontal_pos: float = 2 * horizontal_spacing * hex_tile.grid_pos_y
	var vert_offset: float = vertical_spacing / 2.0 if hex_tile.grid_pos_y % 2 == 1 else 0.0

	return Vector3(vertical_pos + vert_offset, 0, horizontal_pos)


func _on_tile_hovered(hex_tile: HexTile):
	tile_hovered.emit(hex_tile)

# unselect the old tile first
func set_selected_tile(hex_tile: HexTile):
	if self.selected_tile && is_instance_valid(self.selected_tile):
		self.selected_tile.set_unselected()
	self.selected_tile = hex_tile
	hex_tile.set_selected()
	tile_clicked.emit(hex_tile)
