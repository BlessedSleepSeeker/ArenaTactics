extends Node3D

@onready var camera: Camera3D = $Freecam

@export_group("Camera Speed")
@export var drag_speed: float = 0.01
@export var spin_speed: float = 0.003
@export var zoom_increment: float = 7
@export var zoom_anim_speed: float = 0.3

@export_group("Camera Limits")
@export var camera_max_zoom: float = 100.0
@export var camera_min_zoom: float = 1.0

var dragging: bool = false
var dragging_left: bool = false
var right_vec: Vector3
var forward_vec: Vector3

var screen_ratio: float = 1920.0/1080.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	screen_ratio = screen_size.y / screen_size.x
	get_move_vector()


func get_move_vector():
	var offset: Vector3 = camera.global_position - self.global_position
	right_vec = camera.transform.basis.x
	forward_vec = Vector3(offset.x, 0, offset.z).normalized()

func _unhandled_input(event):
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP || event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if dragging:
				return
			var new_zoom = camera.size + zoom_increment * (-1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0)
			var tween = get_tree().create_tween()
			tween.tween_property(camera, "size", clampf(new_zoom, camera_min_zoom, camera_max_zoom), zoom_anim_speed).set_ease(Tween.EASE_IN_OUT)
		else:
			if event.pressed:
				dragging = true
				dragging_left = event.button_index == MOUSE_BUTTON_LEFT
			else:
				dragging = false
	elif (event is InputEventMouseMotion && dragging):
		if (dragging_left):
			self.global_position += right_vec * -event.relative.x * drag_speed + forward_vec * -event.relative.y * drag_speed / screen_ratio
		else:
			self.rotate_y(-event.relative.x * spin_speed)
			get_move_vector()
