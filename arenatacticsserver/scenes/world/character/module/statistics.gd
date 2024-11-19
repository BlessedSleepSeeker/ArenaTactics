extends Node
class_name StatisticsModule

@export var actor: CharacterInstance

@export_group("Basic Statistics")
@export var max_health: int = -1
@export var starting_health: int = -1
@export var current_health: int = -1

@export var max_shield: int = -1
@export var starting_shield: int = -1
@export var current_shield: int = -1


func _ready():
    self.print_data()


func print_data():
    print_debug("%d %d %d %d %d %d" % [max_health, starting_health, current_health, max_shield, starting_shield, current_shield])