extends Node3D

@onready var cam_anchor: Node3D = $CamAnchor
@onready var hex_grid: HexGrid = $HexGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	var cam_start_point = Vector3(hex_grid.grid_size_x / 2.0, 0, hex_grid.grid_size_y / 2.0)
	cam_anchor.position = cam_start_point
