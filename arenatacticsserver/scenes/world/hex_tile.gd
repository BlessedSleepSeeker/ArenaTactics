@tool
extends StaticBody3D
class_name HexTile

@export_group("Geometry Vars")
@export var radius: float = 0.5
@export var height: float = 1.0
@export var sides: int = 6

@onready var mesh_inst: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

signal hover_enter(hex_tile: HexTile)
signal hover_exit(hex_tile: HexTile)

var grid_pos_x: int = 0
var grid_pos_y: int = 0

var continentalness: float = 0.0
var erosion: float = 0.0
var peaks_valley: float = 0.0
var temperature: float = 0.0
var humidity: float = 0.0

var distance: float = 0.0
var islandism: float = 0.0

func _ready():
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

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
	cylinder.height = height
	cylinder.radius = 0.45
	collision.shape = cylinder


# if islandism is high = you should be (visually) at the same elevation but with a smaller model height.
# if islandism is low = you should be (visually) at the same elevation but with a taller model height.
func set_vertical_position():
	#print_debug("%d:%d : %f, %d" % [grid_pos_x, grid_pos_y, distance, height])
	
	#self.position.y += abs(islandism)
	# floating island. If you remove 2m of height, you must up the y pos of 1

	# all flat bottom
	self.position.y = (height / 2)

func on_mouse_entered():
	self.mesh_inst.mesh.material.albedo_color = Color(Color.WHITE)
	hover_enter.emit(self)


func on_mouse_exited():
	self.mesh_inst.mesh.material.albedo_color = Color(Color.SEA_GREEN)
	hover_exit.emit(self)