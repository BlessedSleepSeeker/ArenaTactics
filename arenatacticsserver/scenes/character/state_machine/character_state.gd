class_name PlayerState
extends State

var character: CharacterInstance

func _ready() -> void:
	character = owner as CharacterInstance