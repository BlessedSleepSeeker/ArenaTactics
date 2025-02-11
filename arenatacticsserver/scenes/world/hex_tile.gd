@tool
extends StaticBody3D
class_name HexTile

@export_group("Geometry Vars")
@export var radius: float = 0.5
@export var height: float = 1.0
@export var sides: int = 6

var interactive: bool = true:
	set(value):
		set_interaction(value)

@onready var mesh_inst: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

signal hover_enter(hex_tile: HexTile)
signal hover_exit(hex_tile: HexTile)

var grid_coordinate: Vector2i = Vector2i(0, 0)

var continentalness: float = 0.0
var erosion: float = 0.0
var peaks_valley: float = 0.0
var temperature: float = 0.0
var humidity: float = 0.0

var distance: float = 0.0
var islandism: float = 0.0

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

# if islandism is high = you should be (visually) at the same elevation but with a smaller model height.
# if islandism is low = you should be (visually) at the same elevation but with a taller model height.
func set_vertical_position():
	#print_debug("%d:%d : %f, %d" % [grid_coordinate.x, grid_coordinate.y, distance, height])
	
	#self.position.y += abs(islandism)
	# floating island. If you remove 2m of height, you must up the y pos of 1

	# all flat bottom
	self.position.y = (height / 2)

func set_color(color: Color) -> void:
	mesh_inst.mesh.material.albedo_color = color

## Clockwise order starting from right, we get all 6 neighbors
func get_neighbors_position() -> Array[Vector2i]:
	var right = Vector2i(grid_coordinate.x + 1, grid_coordinate.y)
	var down_right = Vector2i(grid_coordinate.x, grid_coordinate.y + 1)
	var down_left = Vector2i(grid_coordinate.x - 1, grid_coordinate.y + 1)
	var left = Vector2i(grid_coordinate.x - 1, grid_coordinate.y)
	var up_left = Vector2i(grid_coordinate.x -1 , grid_coordinate.y - 1)
	var up_right = Vector2i(grid_coordinate.x, grid_coordinate.y - 1)
	if grid_coordinate.y % 2 == 1:
		# same right
		down_right = Vector2i(grid_coordinate.x + 1, grid_coordinate.y + 1)
		down_left = Vector2i(grid_coordinate.x, grid_coordinate.y + 1)
		# same left
		up_left = Vector2i(grid_coordinate.x, grid_coordinate.y - 1)
		up_right = Vector2i(grid_coordinate.x + 1, grid_coordinate.y - 1)
	return [right, down_right, down_left, left, up_left, up_right]

## Clockwise order starting from right, we only get the first 3
func get_first_neighbors_position() -> Array[Vector2i]:
	var right = Vector2i(grid_coordinate.x + 1, grid_coordinate.y)
	var down_right = Vector2i(grid_coordinate.x, grid_coordinate.y + 1)
	var down_left = Vector2i(grid_coordinate.x - 1, grid_coordinate.y + 1)
	if grid_coordinate.y % 2 == 1:
		# same right
		down_right = Vector2i(grid_coordinate.x + 1, grid_coordinate.y + 1)
		down_left = Vector2i(grid_coordinate.x, grid_coordinate.y + 1)
	return [right, down_right, down_left]

## Clockwise order starting from left this time
func get_last_neighbors_position() -> Array[Vector2i]:
	var right = Vector2i(grid_coordinate.x + 1, grid_coordinate.y)
	var left = Vector2i(grid_coordinate.x - 1, grid_coordinate.y)
	var up_left = Vector2i(grid_coordinate.x -1 , grid_coordinate.y - 1)
	var up_right = Vector2i(grid_coordinate.x, grid_coordinate.y - 1)
	if grid_coordinate.y % 2 == 1:
		# same left
		up_left = Vector2i(grid_coordinate.x, grid_coordinate.y - 1)
		up_right = Vector2i(grid_coordinate.x + 1, grid_coordinate.y - 1)
	return [left, up_left, up_right, right]

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


func serialize_debug_data() -> Dictionary:
	var data = {
		"X": self.grid_coordinate.x,
		"Height": self.height,
		"Y": self.grid_coordinate.y,
		"Distance": self.distance,
		"Continentalness": self.continentalness,
		"Erosion": self.erosion,
		"Peaks & Valley": self.peaks_valley,
		"Temperature": self.temperature,
		"Humidity": self.humidity,
		"Islandism": self.islandism
	}
	
	return data


func set_selected():
	selected = true
	self.mesh_inst.mesh.material.albedo_color = Color(Color.ORANGE_RED)


func set_unselected():
	selected = false
	self.mesh_inst.mesh.material.albedo_color = Color(Color.SEA_GREEN)
