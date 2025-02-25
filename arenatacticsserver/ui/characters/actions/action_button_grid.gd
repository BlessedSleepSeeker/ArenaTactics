extends GridContainer
class_name ActionButtonGrid

@export var action_button_scene: PackedScene = preload("res://ui/characters/actions/ActionButton.tscn")

var selected_button: ActionButton = null

var buttons: Array[ActionButton] = []

signal action_selected(action: GameplayAction)

func build(actions: Array[GameplayAction]):
	reset_button_grid()
	create_button_grid(actions)

func reset_button_grid() -> void:
	selected_button = null
	buttons = []
	for child in get_children():
		child.queue_free()

func create_button_grid(actions: Array[GameplayAction]) -> void:
	self.columns = roundi(float(actions.size()) / 2)
	for action in actions:
		create_button(action)

func create_button(action: GameplayAction) -> ActionButton:
	var panel = PanelContainer.new()
	var margin = MarginContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	margin.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	margin.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var button = action_button_scene.instantiate()
	button.button_clicked.connect(_on_button_pressed)
	margin.add_child(button)
	panel.add_child(margin)
	add_child(panel)
	button.action = action
	buttons.append(button)
	return button

func select_button(action: GameplayAction):
	for btn: ActionButton in buttons:
		if btn.action.name == action.name:
			selected_button = btn
			btn.button.set_pressed_no_signal(true)

func _on_button_pressed(button: ActionButton):
	if selected_button:
		selected_button.button.set_pressed_no_signal(false)
	selected_button = button
	action_selected.emit(button.action)