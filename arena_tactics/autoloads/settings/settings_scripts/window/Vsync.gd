extends Setting

@export var base_value: bool = false

func _ready():
	value = base_value
	default = base_value

# called when settings.apply_settings() is triggered
func apply():
	if value:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
