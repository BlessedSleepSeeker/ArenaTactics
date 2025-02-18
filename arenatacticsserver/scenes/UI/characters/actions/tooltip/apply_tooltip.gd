extends Control

@export var tooltip_scene: PackedScene = preload("res://scenes/UI/characters/actions/tooltip/ActionTooltip.tscn")

@export var action: GameplayAction = null

func _make_custom_tooltip(_for_text: String):
	var inst: ActionTooltip = tooltip_scene.instantiate()
	if action:
		inst.action = action
	return inst