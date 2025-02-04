extends VBoxContainer
class_name CSSHexagonGrid

@export var columns: int = 2
@export var hex_button_scene: PackedScene = preload("res://scenes/UI/characters/character_select_screen/UI/HexagonButton.tscn")

signal selected_class(_class)

func _ready():
	pass


func build_grid(classes: Dictionary):
	reset_grid()
	var buttons_in_column: int = 0
	var current_row_nbr: int = 0
	var active_row: HBoxContainer = create_row(0)
	for classe in classes:
		if buttons_in_column >= columns:
			buttons_in_column = 0
			current_row_nbr += 1
			active_row = create_row(current_row_nbr)
		var new_button: HexagonButton = hex_button_scene.instantiate()
		new_button.class_instance = classes[classe]
		new_button.class_selected.connect(button_clicked)
		active_row.add_child(new_button)
		buttons_in_column += 1
	active_row.add_child(create_rando_button())


func create_row(row_number: int) -> HBoxContainer:
	var new_row := HBoxContainer.new()
	# Even row are normal
	if row_number % 2 == 0:
		self.add_child(new_row)
	# # Odds row must be padded to the right so we get that sweet sweet hexagon pattern
	else:
		var padding := MarginContainer.new()
		padding.add_theme_constant_override("margin_left", 58)
		padding.add_child(new_row)
		self.add_child(padding)
	return new_row


func create_rando_button() -> HexagonButton:
	var new_button: HexagonButton = hex_button_scene.instantiate()
	new_button.class_instance = null
	new_button.class_selected.connect(button_clicked)
	return new_button


func reset_grid():
	for child in get_children():
		child.free()


## Throw signals from the buttons back to the CSS
func button_clicked(_selected_class: CharacterInstance):
	selected_class.emit(_selected_class)