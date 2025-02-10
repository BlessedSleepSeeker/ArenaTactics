extends HexTile
class_name FakeHexTile

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	var hexagon_prism := CylinderMesh.new()
	#set_vertical_position()
	hexagon_prism.height = height
	hexagon_prism.top_radius = radius
	hexagon_prism.bottom_radius = radius
	hexagon_prism.radial_segments = sides
	hexagon_prism.cap_bottom = false

	hexagon_prism.material = StandardMaterial3D.new()
	hexagon_prism.material.albedo_color = Color(Color.SEA_GREEN)
	hexagon_prism.material.albedo_color.a = 0
	hexagon_prism.material.transparency = 1
	mesh_inst.mesh = hexagon_prism

	anim_player.play("fade_in")

func set_vertical_position():
	self.position.y = (height / 2)