extends Node
class_name State

var state_machine = null

@export var loop_anim: bool = false

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass

func play_animation(_anim_name: String = "") -> void:
	pass