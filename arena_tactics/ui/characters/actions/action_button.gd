extends CenterContainer
class_name ActionButton

@export var action: GameplayAction = null:
	set(value):
		if value:
			action = value
			_build()

@onready var icon_holder: TextureRect = $"IconHolder"
@onready var button: TextureButton = $"Button"

signal button_clicked(button: ActionButton)

func _ready():
	button.pressed.connect(_on_button_pressed)

func _build():
	icon_holder.texture = action.icon
	if "action" in button:
		button.action = action

func _on_button_pressed():
	button_clicked.emit(self)