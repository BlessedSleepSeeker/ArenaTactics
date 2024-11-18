extends Node3D
class_name WorldView

@onready var cam_anchor: Node3D = $CamAnchor
@onready var hex_grid: HexGrid = $HexGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	var cam_start_point = Vector3(hex_grid.grid_size_x / 2.0, 0, hex_grid.grid_size_y / 2.0)
	cam_anchor.position = cam_start_point
	regenerate_world()


func regenerate_world():
	hex_grid.free_grid()
	RngHandler.reset_seeds()