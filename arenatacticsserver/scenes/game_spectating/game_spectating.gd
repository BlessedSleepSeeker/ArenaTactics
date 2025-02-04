extends Node

@export var world_view_scene: PackedScene = preload("res://scenes/world/WorldView.tscn")
@onready var server_ui: ServerUI = $"%ServerUi"
@onready var world_view: WorldView = $"%WorldView"
#@onready var character_manager: CharacterManager = $"%CharacterManager"

# Called when the node enters the scene tree for the first time.
func _ready():
	server_ui.generate_world.connect(_generate_world)
	world_view.tile_hovered.connect(_on_tile_hovered)
	world_view.tile_selected.connect(_on_tile_selected)


func _generate_world():
	world_view.regenerate_world()


func _on_tile_hovered(hex_tile: HexTile):
	server_ui.hovered_tile_container.load_debug_data(hex_tile)


func _on_tile_selected(hex_tile: HexTile):
	server_ui.selected_tile_container.load_debug_data(hex_tile)
