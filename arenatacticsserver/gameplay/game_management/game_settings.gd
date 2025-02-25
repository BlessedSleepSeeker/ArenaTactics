extends Resource
class_name GameplaySettings
## Hold the gameplay setting of an unique game

## The main seed used to by the procedural generation.
@export var main_seed: String = ""
## The list of players in their teams.
@export var players: Dictionary = {}