@tool
extends StaticBody3D
class_name HexTileCube

@export var interactive: bool = true:
	set(value):
		set_interaction(value)

@export_group("Geometry Vars")
## Mesh Radius
@export var radius: float = 0.5
## Mesh Height 
@export var height: float = 1.0
## Mesh Sides. 6 for hexagons.
@export var sides: int = 6

@export_group("Grid Data")
## The coordinates of the tile, in cube system.
@export var grid_coordinate: Vector3i = Vector3i(0, 0, 0):
	set(value):
		var sum = value.x + value.y + value.z
		if sum == 0:
			grid_coordinate = value
		else:
			push_error("Grid Coordinates can't sum to something else than 0 : %d + %d + %d = %d." % [value.x, value.y, value.z, sum])
## The coordinate of the tile, converted to the offset system.
var offset_grid_coordinate: Vector2i:
	get:
		return HexTileCube.get_offset_coordinate(grid_coordinate)

@export_subgroup("Elevation Tweaking")
@export var continentalness: float = 0.0
@export var erosion: float = 0.0
@export var peaks_valley: float = 0.0
@export var temperature: float = 0.0
@export var humidity: float = 0.0
@export var distance: float = 0.0
@export var islandism: float = 0.0

@onready var mesh_inst: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

signal hover_enter(hex_tile: HexTileCube)
signal hover_exit(hex_tile: HexTileCube)

var selected: bool = false

func _ready():
	self.set_interaction(interactive)
	var hexagon_prism := CylinderMesh.new()
	set_vertical_position()
	hexagon_prism.height = height
	hexagon_prism.top_radius = radius
	hexagon_prism.bottom_radius = radius
	hexagon_prism.radial_segments = sides
	hexagon_prism.cap_bottom = false

	hexagon_prism.material = StandardMaterial3D.new()
	hexagon_prism.material.albedo_color = Color(Color.SEA_GREEN)
	mesh_inst.mesh = hexagon_prism

	var cylinder: CylinderShape3D = CylinderShape3D.new()
	cylinder.height = 0.5
	cylinder.radius = 0.45
	collision.shape = cylinder
	collision.position.y = height / 2 - (cylinder.height / 2)

## if islandism is high = you should be (visually) at the same elevation but with a smaller model height.
## if islandism is low = you should be (visually) at the same elevation but with a taller model height.
func set_vertical_position():
	#print_debug("%d:%d : %f, %d" % [grid_coordinate.x, grid_coordinate.y, distance, height])
	
	#self.position.y += abs(islandism)
	# floating island. If you remove 2m of height, you must up the y pos of 1

	# all flat bottom
	self.position.y = (height / 2)

#region HexLib

@export var neighbors_vectors: Array[Vector3i] = [
	Vector3i(1, 0, -1), ## Right
	Vector3i(0, 1, -1), ## Down Right
	Vector3i(-1, 1, 0), ## Down Left
	Vector3i(-1, 0, 1), ## Left
	Vector3i(0, -1, 1), ## Up Left
	Vector3i(1, -1, 0), ## Up Right
]

@export var diagonals_vectors: Array[Vector3i] = [
	Vector3i(2, -1, -1), ## Up Right
	Vector3i(1, 1, -2),  ## Down Right
	Vector3i(-1, 2, -1), ## Down
	Vector3i(-2, 1, 1),  ## Down Left
	Vector3i(-1, -1, 2), ## Up Left
	Vector3i(1, -2, 1),  ## Up
]

enum NEIGHBOR_DIRECTION {RIGHT, DOWN_RIGHT, DOWN_LEFT, LEFT, UP_LEFT, UP_RIGHT}
func get_neighbor(direction: NEIGHBOR_DIRECTION) -> Vector3i:
	return neighbors_vectors[direction]

enum DIAGONAL_DIRECTION {UP_RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, UP_LEFT, UP}
func get_diagonal(direction: DIAGONAL_DIRECTION) -> Vector3i:
	return diagonals_vectors[direction]

func get_distance_with(coordinate: Vector3i):
	return abs(self.grid_coordinate - coordinate)

## Return all coordinates that exist at a distance of `_range` or lower from this tile
func get_coordinates_in_range(_range: int) -> Array[Vector3i]:
	var result = []
	for q in range(-_range, _range):
		## Of all the values of s we loop over, only one of them actually satisfies the q + r + s = 0 constraint. Instead, let's directly calculate the value of s that satisfies the constraint:
		for r in range(max(-_range, -q - _range), min(_range, -q + _range)):
			result.append(self.grid_coordinate + Vector3i(q, r, -q - r)) ## just add the vector to our position to find the new position !
	return result

## Return the coordinates
## Ring of factor 1 : only the neighbors.
## Ring of factor 2 : only the external neighbors of neighbors...
func get_ring_coordinates(ring_radius: int) -> Array[Vector3i]:
	var ring_coords: Array[Vector3i] = []
	if ring_radius == 0:
		return [grid_coordinate]
	var grid_coord = grid_coordinate + (get_neighbor(NEIGHBOR_DIRECTION.UP_LEFT) * ring_radius) ## get the starting point of the circle
	for i in range(6): # one loop for each direction
		for j in range(ring_radius):
			ring_coords.append(grid_coord)
			grid_coord = grid_coord + get_neighbor(i)
	return ring_coords

func get_circle_coordinates(circle_radius: int) -> Array[Vector3i]:
	var circle_coords: Array[Vector3i] = [grid_coordinate]
	for i in range(1, circle_radius):
		circle_coords.append_array(get_ring_coordinates(i))
	return circle_coords

static func get_offset_coordinate(cube_coordinate: Vector3i) -> Vector2i:
	@warning_ignore("integer_division") # divided number is always even.
	var offset_x = cube_coordinate.x + (cube_coordinate.y - (cube_coordinate.y&1)) / 2
	var offset_y = cube_coordinate.y
	return Vector2i(offset_x, offset_y)

static func get_cube_coordinate(offset_coordinate: Vector2i) -> Vector3i:
	@warning_ignore("integer_division") # divided number is always even.
	var cube_q = offset_coordinate.x - (offset_coordinate.y - (offset_coordinate.y&1)) / 2
	var cube_r = offset_coordinate.y
	return Vector3i(cube_q, cube_r, -cube_q - cube_r)

#endregion

#region Animations

## Change the mesh material color. If multiples meshes uses this material, the color change will be reflected in all meshes.
func set_color(color: Color) -> void:
	mesh_inst.mesh.material.albedo_color = color

func update_animations_colors(colors: Dictionary) -> void:
	tweak_idle_animation_colors(colors["base_tile_color"], colors["idle_tile_popup_color"])
	tweak_fade_animation_color(colors["base_tile_color"])

func tweak_idle_animation_colors(base_color: Color = Color(0, 0, 0), pop_up_color: Color = Color(0, 0, 0, 0)) -> void:
	var idle_anim: Animation = get_animation_library().get_animation("idle")
	var albedo_track: int = idle_anim.find_track("MeshInstance3D:mesh:material:albedo_color", Animation.TYPE_VALUE)
	idle_anim.track_set_key_value(albedo_track, 0, base_color)
	idle_anim.track_set_key_value(albedo_track, 1, Color(base_color, 0.5))
	idle_anim.track_set_key_value(albedo_track, 2, pop_up_color)
	idle_anim.track_set_key_value(albedo_track, 3, base_color)

func tweak_fade_animation_color(base_color: Color = Color(0, 0, 0)) -> void:
	var fade_anim: Animation = get_animation_library().get_animation("fade_in")
	var albedo_track: int = fade_anim.find_track("MeshInstance3D:mesh:material:albedo_color", Animation.TYPE_VALUE)
	fade_anim.track_set_key_value(albedo_track, 0, Color(base_color, 0))
	fade_anim.track_set_key_value(albedo_track, 1, base_color)

func get_animation_library() -> AnimationLibrary:
	return anim_player.get_animation_library("tile_animation_library")

#endregion

#region Interactions
func set_interaction(value: bool):
	if value:
		if not mouse_entered.is_connected(on_mouse_entered):
			mouse_entered.connect(on_mouse_entered)
		if not mouse_exited.is_connected(on_mouse_exited):
			mouse_exited.connect(on_mouse_exited)
	else:
		if mouse_entered.is_connected(on_mouse_entered):
			mouse_entered.disconnect(on_mouse_entered)
		if mouse_exited.is_connected(on_mouse_exited):
			mouse_exited.disconnect(on_mouse_exited)


func on_mouse_entered():
	if not selected:
		set_color(Color(Color.WHITE))
		hover_enter.emit(self)


func on_mouse_exited():
	if not selected:
		set_color(Color(Color.SEA_GREEN))
		hover_exit.emit(self)


func set_selected():
	selected = true
	self.mesh_inst.mesh.material.albedo_color = Color(Color.ORANGE_RED)


func set_unselected():
	selected = false
	self.mesh_inst.mesh.material.albedo_color = Color(Color.SEA_GREEN)

#endregion

func serialize_debug_data() -> Dictionary:
	var data = {
		"Q": self.grid_coordinate.x,
		"R": self.grid_coordinate.y,
		"S": self.grid_coordinate.z,
		"X": self.offset_grid_coordinate.x,
		"Y": self.offset_grid_coordinate.y,
		"Height": self.height,
		"Distance": self.distance,
		"Continentalness": self.continentalness,
		"Erosion": self.erosion,
		"Peaks & Valley": self.peaks_valley,
		"Temperature": self.temperature,
		"Humidity": self.humidity,
		"Islandism": self.islandism
	}
	
	return data
