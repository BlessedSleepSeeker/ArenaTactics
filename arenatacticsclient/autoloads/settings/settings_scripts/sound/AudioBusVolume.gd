extends Setting
class_name VolumeSetting

@export var bus_name: String = "Master"
@export var base_value: int = 100
@onready var audio_bus = AudioServer.get_bus_index(bus_name)

func _ready():
	value = base_value
	default = base_value

## Called when settings.apply_settings() is triggered
func apply():
	# convert a [0:100] range to [0:1] range
	var converted_to_normal: float = value / 100
	AudioServer.set_bus_volume_db(audio_bus, linear_to_db(converted_to_normal))
