extends Node
class_name Setting

# Class for defining a single setting.
@export var type: SETTING_TYPE = SETTING_TYPE.BOOLEAN
@export var key: String
@export_multiline var tooltip: String
var value: Variant
var default: Variant

enum SETTING_TYPE {
	BOOLEAN,
	RANGE,
	OPTIONS,
	TEXT,
	NUMBER
}



@export_group("Range Type")
@export var min_value_range: int = 0
@export var max_value_range: int = 100
@export var step_range: float = 1

@export_group("Option Type")
@export var possible_values: Array:
	set(val):
		possible_values = val

@export var possible_values_strings: Array = []

@export_group("Number Type")
@export var min_value_nbr: int = 0
@export var max_value_nbr: int = 100
@export var step_nbr: float = 1

func clear() -> void:
	value = null


func reset_to_default() -> void:
	value = default


func get_print_string() -> String:
	return "%s = %s (default = %s) (type = %d)" % [key, value, default, type]


func set_value(_value: Variant) -> void:
	value = _value
	print_debug("%s updated to %s" % [key, value])