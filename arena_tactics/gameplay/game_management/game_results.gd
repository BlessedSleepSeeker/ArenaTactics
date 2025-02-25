extends Resource
class_name GameResult
## Hold the result of an unique game

## Pointer to the gameplay settings
@export var settings: GameplaySettings = null
## In turns
@export var duration: int = 0
## Represent the winning team
@export var winner_id: String = ""
## DateTime of when the game was played
@export var datetime: String = ""
## The game version this was played on
@export var game_version: String = "0.1"

## All the turns played and their actions
@export var turns: Array[Array] = []

func _init(dict: Dictionary = {}):
	if not dict.is_empty():
		parse_dict(dict)

func parse_dict(dict: Dictionary) -> void:
	for data in dict:
		add_string_data_to_var(data, dict[data])

#region Helpers

func add_string_data_to_var(var_name: String, var_value: String):
	if var_name in self:
		self.set(var_name, var_value)
	#print_debug("%s: %s = %s" % [var_name, var_value, instance.get(var_name)])
#endregion