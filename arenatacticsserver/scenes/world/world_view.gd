extends Node3D
class_name WorldView

@onready var cam_anchor: Node3D = $CamAnchor
@onready var camera: Camera3D = $CamAnchor/Freecam
@onready var hex_grid: HexGridCube = $HexGrid

signal tile_hovered(hex_tile: HexTileCube)
signal tile_selected(hex_tile: HexTileCube)

# Called when the node enters the scene tree for the first time.
func _ready():
	hex_grid.tile_hovered.connect(_on_tile_hovered)
	hex_grid.tile_clicked.connect(_on_tile_selected)
	regenerate_world()
	cam_anchor.position = hex_grid.get_camera_start_point()


func regenerate_world():
	hex_grid.free_grid()
	RngHandler.reset_seeds()
	hex_grid.generate_grid()


func _on_tile_hovered(hex_tile: HexTileCube):
	tile_hovered.emit(hex_tile)


func _on_tile_selected(hex_tile: HexTileCube):
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
	if node is HexTileCube:
		return node
	return null
