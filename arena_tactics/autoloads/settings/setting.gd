extends Node
class_name Setting

# Class for defining a single setting.
@export_group("Mandatory")
@export var key: String
@export_multiline var tooltip: String
var value: Variant
var default: Variant

enum SETTING_TYPE {
	BOOLEAN,
	RANGE,
	OPTIONS,
}

@export var type: SETTING_TYPE = SETTING_TYPE.BOOLEAN

@export_group("Only when type is range")
@export var min_value: int = 0
@export var max_value: int = 100
@export var step: float = 1

@export_group("Only when type is option")
@export var possible_values: Array:
	set(val):
		possible_values = val

@export var possible_values_strings: Array = []

func clear() -> void:
	value = null


func reset_to_default() -> void:
	value = default


func get_print_string() -> String:
	return "%s = %s (default = %s) (type = %d)" % [key, value, default, type]


func set_value(_value: Variant) -> void:
	value = _value
	print_debug("%s updated to %s" % [key, value])