extends Setting

@export var main_menu = preload("res://ui/screens/main_menu/main_menu.tscn")
@onready var sprite: AnimatedSprite2D = $"%LogoAnimation"
@onready var subviewport_container: SubViewportContainer = $"%SubViewportContainer"

signal transition(new_scene: PackedScene, animation: String)

func _ready():
	if OS.has_feature("editor"):
		transition.emit(main_menu, "")
	subviewport_container.size = DisplayServer.window_get_size()
	sprite.scale = Vector2(subviewport_container.size.x / 64, subviewport_container.size.y / 36)
	sprite.play("logo")
	await sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	transition.emit(main_menu, "")

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		transition.emit(main_menu, "")