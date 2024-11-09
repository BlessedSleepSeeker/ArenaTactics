extends Control

@export var creditsScenePath := "res://scenes/menu/credit_scene.tscn"
@export var gamePath := "res://scenes/network/online_menu/lobby.tscn"
@export var settings_screen_path := "res://scenes/menu/settings/settings_screen.tscn"

signal transition(new_scene: PackedScene, animation: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit()

func _on_credits_button_pressed():
	var creditsScene = load(creditsScenePath)
	transition.emit(creditsScene, "scene_transition")

func _on_play_button_pressed():
	var gameScene = load(gamePath)
	transition.emit(gameScene, "scene_transition")

func _on_settings_pressed():
	print_debug("coucou")
	var settings_scene = load(settings_screen_path)
	transition.emit(settings_scene, "scene_transition")
