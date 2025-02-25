class_name Module
extends Node

@export var module_name: String

func _ready():
    self.name = module_name

func setup( _instance: CharacterInstance, _data: Dictionary) -> void:
    pass

# override me in module scripts !
func start_game():
    pass