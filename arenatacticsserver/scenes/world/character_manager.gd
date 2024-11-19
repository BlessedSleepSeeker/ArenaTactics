extends Node3D
class_name CharacterManager

@export var ranger_scene: PackedScene = preload("res://scenes/world/character/ranger/Ranger.tscn")

var team_1: Array[BaseCharacter] = []
var team_2: Array[BaseCharacter] = []