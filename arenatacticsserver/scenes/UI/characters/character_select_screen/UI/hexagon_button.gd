extends Control
class_name HexagonButton

@export var class_instance: ClassDefinition = null
@export var random_texture: Texture2D = preload("res://scenes/UI/characters/character_select_screen/UI/assets/random_portrait.png")

@onready var button: TextureButton = $"%HexButton"
@onready var portrait_rect: TextureRect = $"%CharaPortrait"

signal class_selected(selected_class: ClassDefinition)

func _ready():
	button.pressed.connect(_on_button_clicked)
	if class_instance == null:
		button.tooltip_text = "Let the dice decide"
		portrait_rect.texture = random_texture
		return
	setup_hex_button()


func setup_hex_button():
	#print_debug("Setting up %s button" % class_instance.character_class)
	button.tooltip_text = class_instance.title
	portrait_rect.texture = class_instance.portrait


func _on_button_clicked():
	class_selected.emit(class_instance)
