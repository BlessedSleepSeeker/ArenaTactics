extends Node3D
class_name WorldView

@onready var cam_anchor: Node3D = $CamAnchor
@onready var camera: Camera3D = $CamAnchor/Freecam
@onready var hex_grid: HexGrid = $HexGrid

signal tile_hovered(hex_tile: HexTile)
signal tile_selected(hex_tile: HexTile)

# Called when the node enters the scene tree for the first time.
func _ready():
	hex_grid.tile_hovered.connect(_on_tile_hovered)
	hex_grid.tile_clicked.connect(_on_tile_selected)
	var cam_start_point = Vector3(hex_grid.grid_size_x / 2.0, 0, hex_grid.grid_size_y / 2.0)
	cam_anchor.position = cam_start_point
	regenerate_world()


func regenerate_world():
	hex_grid.free_grid()
	RngHandler.reset_seeds()


func _on_tile_hovered(hex_tile: HexTile):
	tile_hovered.emit(hex_tile)


func _on_tile_selected(hex_tile: HexTile):
	tile_selected.emit(hex_tile)


func _unhandled_input(event):
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var raycasted = raycaster()
			if raycasted != null:
				hex_grid.set_selected_tile(raycasted)

func raycaster() -> Variant:
	var RAYCAST_DISTANCE = 1000
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * RAYCAST_DISTANCE
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var node = result["collider"]
	if node is HexTile:
		return node
	return null
