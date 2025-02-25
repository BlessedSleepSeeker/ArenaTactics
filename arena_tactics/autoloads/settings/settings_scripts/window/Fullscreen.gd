extends Setting

const WINDOW_MODE = ["Windowed", "Fullscreen", "Borderless Fullscreen"]
@export var base_value: String = "Windowed"


func _ready():
	value = base_value
	default = base_value
	possible_values = WINDOW_MODE


# called when settings.apply_settings() is triggered
func apply():
	match value:
		"Windowed":
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, false)
		"Fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, false)
		"Borderless Fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_BORDERLESS, true)