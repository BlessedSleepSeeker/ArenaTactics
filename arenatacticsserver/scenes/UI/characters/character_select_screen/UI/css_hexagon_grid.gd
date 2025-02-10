extends CenterContainer
class_name CSSHexagonGrid

@export var columns: int = 2
@export var pos_x_offset: int = -2
@export var pos_y_offset: int = -2
@export var hex_button_scene: PackedScene = preload("res://scenes/UI/characters/character_select_screen/UI/HexagonButton.tscn")
@onready var hex_tilemap: TileMapLayer = $"%HexTile"

signal class_selected(selected_class: ClassDefinition)

func _ready():
	pass


func build_grid(classes: Dictionary):
	reset_grid()
	var x: int = 0
	var y: int = 0
	for classe in classes:
		if x >= columns:
			x = 0
			y += 1
		hex_tilemap.set_cell(Vector2i(x + pos_x_offset, y + pos_y_offset), 0, Vector2i(0, 0), 1)
		x += 1
	# random button
	if x >= columns:
			x = 0
			y += 1
	hex_tilemap.set_cell(Vector2i(x + pos_x_offset, y + pos_y_offset), 0, Vector2i(0, 0), 1)
	
	# one frame delay for the childs to appear in the tilemaplayer
	get_tree().process_frame.connect(fill_buttons.bind(classes), CONNECT_ONE_SHOT)


func fill_buttons(classes: Dictionary) -> void:
	var hex_buttons = hex_tilemap.get_children()
	var i = 0
	for classe in classes:
		var hex_button: HexagonButton = hex_buttons[i]
		hex_button.class_instance = classes[classe]
		hex_button.class_selected.connect(button_clicked)
		hex_button.setup_hex_button()
		i += 1
	fill_rando_button(hex_buttons[i])
	hex_buttons[i].setup_hex_button()

func fill_rando_button(rando_button: HexagonButton) -> void:
	rando_button.class_instance = null
	rando_button.class_selected.connect(button_clicked)


func reset_grid():
	hex_tilemap.clear()


## Throw signals from the buttons back to the CSS
func button_clicked(_selected_class: ClassDefinition):
	class_selected.emit(_selected_class)
