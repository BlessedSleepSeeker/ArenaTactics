extends Control

@export var mainMenu = preload("res://ui/screens/main_menu/main_menu.tscn")

signal transition(new_scene: PackedScene, animation: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_button_pressed():
	transition.emit(mainMenu, "scene_transition")
