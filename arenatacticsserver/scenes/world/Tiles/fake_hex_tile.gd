@tool
extends HexTile
class_name FakeHexTile

func _ready():
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

func set_vertical_position():
	#print_debug("%d:%d : %f, %d" % [grid_pos_x, grid_pos_y, distance, height])
	
	#self.position.y += abs(islandism)
	# floating island. If you remove 2m of height, you must up the y pos of 1

	# all flat bottom
	self.position.y = (height / 2)