extends Setting

@export var base_value: int = 2

func _ready():
	value = base_value
	default = base_value

# called when settings.apply_settings() is triggered
func apply():
	pass
