extends GridContainer
class_name ActionButtonGrid

@export var action_button_scene: PackedScene = preload("res://scenes/UI/characters/actions/ActionButton.tscn")

signal action_selected(action: GameplayAction)

func build(actions: Array[GameplayAction]):
	reset_button_grid()
	create_button_grid(actions)

func reset_button_grid() -> void:
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
	return button

func _on_button_pressed(action: GameplayAction):
	action_selected.emit(action)