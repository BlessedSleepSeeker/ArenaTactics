extends Node3D
class_name HexGrid


@export var tile_size: float = 1.0
@export var grid_size_x: int = 50 #vertical
@export var grid_size_y: int = 50 #horizontal
@export var timer_between_tile: float = 0.001

@export var tile_scene: PackedScene = preload("res://scenes/world/hex_tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	ProcGen.finished_setup.connect(generate_new_grid)


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
			self.add_child(inst)
			if inst.distance >= 0.8:
				inst.queue_free()
			#await get_tree().create_timer(timer_between_tile).timeout


func calculate_tile_position(hex_tile: HexTile):
	var vertical_spacing: float =  hex_tile.radius * sqrt(3)
	var vertical_pos: float = vertical_spacing * hex_tile.grid_pos_x
	var horizontal_spacing: float = (3.0/4.0 * hex_tile.radius)
	var horizontal_pos: float = 2 * horizontal_spacing * hex_tile.grid_pos_y
	var vert_offset: float = vertical_spacing / 2.0 if hex_tile.grid_pos_y % 2 == 1 else 0.0

	return Vector3(vertical_pos + vert_offset, 0, horizontal_pos)
