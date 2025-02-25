extends Setting

@export var base_value: String = "English"
@export var options: Array = ["English"]

func _ready():
	value = base_value
	default = base_value
	possible_values = options

# called when settings.apply_settings() is triggered
func apply():
	pass
