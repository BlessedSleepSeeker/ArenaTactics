extends Setting

const UI_SCALE: Array[float] = [1.0, 1.5, 2.0]
const VALUE_STRING: Array[String] = ["Normal", "Big", "Bigger"]
var base_value: Variant = 1

func _ready():
	value = base_value
	default = base_value
	possible_values = UI_SCALE
	possible_values_strings = VALUE_STRING

## Called when settings.apply_settings() is triggered
func apply():
	get_tree().root.content_scale_factor = value
