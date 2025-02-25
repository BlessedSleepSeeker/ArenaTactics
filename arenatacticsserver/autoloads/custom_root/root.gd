class_name Root
extends Node

@export var first_scene: PackedScene = preload("res://ui/screens/title_sequence/title_sequence.tscn")
@onready var settings = $Settings
@onready var scene_root = $SceneRoot
@onready var animator: AnimationPlayer = $Animator
@onready var transition_sprite: Control = $TransitionSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	add_scene(first_scene)
	transition_sprite.position = Vector2(-1920, 0)

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

func _on_transition(new_scene: PackedScene, animation: String):
	if animation != "":
		animator.play("%s_in" % animation)
		await animator.animation_finished
		change_scene(new_scene)
		await get_tree().create_timer(0.2).timeout
		animator.play("%s_out" % animation)
	else:
		change_scene(new_scene)
	
