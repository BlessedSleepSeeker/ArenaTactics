extends Setting

const GAME_RESOLUTION: Array = ["640x360", "1280x720", "1920x1080", "2560x1440", "3200x1800", "3840x2160"]
@export var base_value: String = "640x360"

func _ready():
	value = base_value
	default = base_value
	possible_values = GAME_RESOLUTION

# called when settings.apply_settings() is triggered
func apply():
	var split_res = value.split_floats("x")
	DisplayServer.window_set_size(Vector2(split_res[0], split_res[1]))
