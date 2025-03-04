extends Control

@export var creditsScenePath: String = "res://ui/screens/credits/credit_scene.tscn"
@export var gamePath: String = "res://ui/screens/network/lobby_connector/LobbyConnector.tscn"
@export var settings_screen_path: String = "res://ui/screens/settings/settings_screen.tscn"

signal transition(new_scene: PackedScene, animation: String)

@onready var networker: NetworkClient = get_tree().root.get_node("Root").get_node("NetworkRoot").get_node("Networker")

# Called when the node enters the scene tree for the first time.
func _ready():
	if networker.fast_forward:
		_on_play_button_pressed()

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
