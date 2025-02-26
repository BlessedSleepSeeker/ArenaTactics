class_name Root
extends Node

@export var first_client_scene: PackedScene = preload("res://ui/screens/title_sequence/title_sequence.tscn")
@export var first_server_scene: PackedScene = preload("res://ui/screens/server_config/ServerConfig.tscn")
@onready var settings = $Settings
@onready var scene_root = $SceneRoot
@onready var animator: AnimationPlayer = $Animator
@onready var transition_sprite: Control = $"%TransitionSprite"

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_sprite.position = Vector2(-1920, 0)
	if UserArguments.has_arg("server"):
		add_scene(first_server_scene)
	else:
		add_scene(first_client_scene)

func flush_scenes():
	for child in scene_root.get_children():
		child.queue_free()

func add_scene(new_scene: PackedScene):
	var instance = new_scene.instantiate()
	if instance.has_signal("transition") and not instance.transition.is_connected(_on_transition):
		instance.transition.connect(_on_transition)
	scene_root.add_child(instance)

func change_scene(new_scene: PackedScene):
	flush_scenes()
	add_scene(new_scene)

func _on_transition(new_scene: PackedScene, animation: String = ""):
	if animation != "":
		animator.play("%s" % animation)
		await animator.animation_finished
		change_scene(new_scene)
		await get_tree().create_timer(0.2).timeout
		animator.play_backwards("%s" % animation)
	else:
		change_scene(new_scene)
	
