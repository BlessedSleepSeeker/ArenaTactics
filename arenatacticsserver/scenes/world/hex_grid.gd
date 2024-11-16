extends Node3D


@export var tile_size: float = 1.0
@export var grid_size_x: int = 50 #vertical
@export var grid_size_y: int = 50 #horizontal
@export var timer_between_tile: float = 0.001

@export var tile_scene: PackedScene = preload("res://scenes/world/hex_tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_grid()


func generate_grid():
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			var inst: HexTile = tile_scene.instantiate()
			inst.grid_pos_x = i
			inst.grid_pos_y = j
			inst.height = randi() % 1 + randf()
			var pos = calculate_tile_position(inst)
			inst.position = pos
			self.add_child(inst)
			#await get_tree().create_timer(timer_between_tile).timeout


func calculate_tile_position(hex_tile: HexTile):
	var vertical_spacing: float = sqrt(3) * hex_tile.radius
	var vertical_pos = vertical_spacing * hex_tile.grid_pos_x
	var horizontal_spacing: float = (3.0/4.0 * hex_tile.radius)
	var horizontal_pos = 2 * horizontal_spacing * hex_tile.grid_pos_y
	var vert_offset = horizontal_spacing if hex_tile.grid_pos_y % 2 == 1 else 0.0

	return Vector3(vertical_pos + vert_offset, 0, horizontal_pos)
