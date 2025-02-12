extends GameplayAction
class_name BasicMovementAction

@export var default_movement_icon: Texture2D = preload("res://scenes/actions/movement_actions/assets/default_movement_icon_placeholder.png")

func _init(instance: CharacterInstance, _data: Dictionary, _name: String):
	self.icon = default_movement_icon
	super(instance, _data, _name)
