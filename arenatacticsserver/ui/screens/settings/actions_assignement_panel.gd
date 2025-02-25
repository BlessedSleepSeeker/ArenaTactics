class_name ActionsAssignementPanel
extends PanelContainer

@onready var current_action_lbl: Label = $MC/VB/C1/CurrentActionLabel
@onready var current_input_lbl: Label = $MC/VB/C2/CurrentInputLabel
@onready var accept_input_btn: Button = $MC/VB/C3/Ok
@onready var error_lbl: Label = $MC/VB/C4/ErrorLabel

@export var current_input_template: String = "Player %s, please input %s"

@onready var action_name: String = "If you see this_I fucked up":
	set(val):
		action_name = val
		var split = action_name.split("_", false, 1)
		var player_nbr = split[0].lstrip("p")
		var player_action = split[1].capitalize()
		current_action_lbl.text = current_input_template % [player_nbr, player_action]

var last_input_event = null:
		set(val):
			last_input_event = val
			current_input_lbl.text = last_input_event.as_text()

signal action_set

func _ready():
	accept_input_btn.pressed.connect(_on_button_pressed)
	error_lbl.hide()

func _unhandled_input(event):
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadMotion or event is InputEventJoypadButton:
		last_input_event = event

func _on_button_pressed():
	if last_input_event == null:
		error_lbl.show()
		error_lbl.text = "No input detected"
		return
	#InputHandler.add_action_from_event(action_name, last_input_event)
	action_set.emit()
	queue_free()
