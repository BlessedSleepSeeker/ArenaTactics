extends MarginContainer
class_name ProgressiveTimerUI

@export var timer: Timer = null
@export var time_str_template = "%02d'%02d''"
@export var color_ramp: Gradient = null


@onready var progbar: ProgressBar = $ProgressBar
@onready var label: Label = $"%Label"

func _ready():
	setup()

func setup():
	if timer:
		progbar.max_value = timer.wait_time
		label.text = get_timer_as_text()

func _physics_process(_delta):
	if timer:
		progbar.value = timer.time_left
		label.text = get_timer_as_text()
		if color_ramp:
			var percent: float = timer.time_left / timer.wait_time
			progbar.modulate = color_ramp.sample(percent)

func get_timer_as_text() -> String:
	var remaining_time: float = timer.time_left
	var time_str: String = time_str_template % [int(remaining_time), int((remaining_time - int(remaining_time)) * 100)]

	return time_str