@tool
extends StaticBody3D
class_name HexTile

@export_group("Geometry Vars")
@export var radius: float = 0.5
@export var height: float = 1.0
@export var sides: int = 6

@onready var mesh_inst: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var grid_pos_x: int = 0
var grid_pos_y: int = 0

func _ready():
	var hexagon_prism := CylinderMesh.new()
	hexagon_prism.height = height
	hexagon_prism.top_radius = radius
	hexagon_prism.bottom_radius = radius
	hexagon_prism.radial_segments = sides
	hexagon_prism.cap_bottom = false

	mesh_inst.mesh = hexagon_prism

	var cylinder: CylinderShape3D = CylinderShape3D.new()
	cylinder.height = height
	cylinder.radius = 0.45
	collision.shape = cylinder
	self.position.y = height / 2
