extends Node

@export var world_view_scene: PackedScene = preload("res://scenes/world/world_view.tscn")
@onready var server_ui: ServerUI = $"%ServerUi"
@onready var world_view: WorldView = $"%WorldView"

# Called when the node enters the scene tree for the first time.
func _ready():
	server_ui.generate_world.connect(_generate_world)


func _generate_world():
	world_view.regenerate_world()