extends HBoxContainer
class_name SettingLine

var lbl: Label
var checkbox: CheckButton
var slider: Slider
var options: OptionButton

@onready var setting_name = $NameContainer/SettingName
@onready var container = $Container

var setting: Setting = null:
	set(val):
		setting = val
		tear_down()
		build()

func _ready():
	pass

func _on_mouse_exited():
	if setting.type == setting.SETTING_TYPE.BOOLEAN:
		checkbox.release_focus()
	elif setting.type == setting.SETTING_TYPE.RANGE:
		slider.release_focus()
	elif setting.type == setting.SETTING_TYPE.OPTIONS:
		options.release_focus()

func tear_down() -> void:
	if lbl != null:
		lbl.queue_free()
	if checkbox != null:
		checkbox.queue_free()
	if slider != null:
		slider.queue_free()
	if options != null:
		options.queue_free()


func build() -> void:
	setting_name.text = setting.key.capitalize()
	setting_name.tooltip_text = setting.tooltip
	if setting.type == setting.SETTING_TYPE.BOOLEAN:
		build_bool()
	elif setting.type == setting.SETTING_TYPE.RANGE:
		build_range()
	elif setting.type == setting.SETTING_TYPE.OPTIONS:
		build_options()


func build_bool() -> void:
	checkbox = CheckButton.new()
	checkbox.toggle_mode = true
	checkbox.set_pressed_no_signal(setting.value)
	checkbox.mouse_exited.connect(_on_mouse_exited)
	container.add_child(checkbox)


func build_range() -> void:
	lbl = Label.new()
	slider = HSlider.new()
	slider.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	slider.value_changed.connect(_on_slider_value_changed)
	slider.mouse_exited.connect(_on_mouse_exited)
	container.add_child(slider)
	container.add_child(lbl)
	slider.tick_count = 5
	slider.ticks_on_borders = true
	slider.min_value = setting.min_value
	slider.max_value = setting.max_value
	slider.step = setting.step
	slider.value = setting.value


func _on_slider_value_changed(value: float) -> void:
	lbl.text = "%3d" % value


func build_options() -> void:
	options = OptionButton.new()
	if setting.possible_values_strings.is_empty():
		for option in setting.possible_values:
			if option is String:
				options.add_item(option)
			elif option is int or option is float:
				options.add_item(String.num(option))
	else:
		for option_string in setting.possible_values_strings:
			options.add_item(option_string)
	var value_index = setting.possible_values.find(setting.value)
	options.select(value_index)
	options.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	options.fit_to_longest_item = false
	options.mouse_exited.connect(_on_mouse_exited)
	container.add_child(options)


func is_modified() -> bool:
	if setting.type == setting.SETTING_TYPE.BOOLEAN:
		return setting.value != checkbox.button_pressed
	elif setting.type == setting.SETTING_TYPE.RANGE:
		return setting.value != slider.value
	elif setting.type == setting.SETTING_TYPE.OPTIONS:
		return setting.value != setting.possible_values[options.get_selected_id()]
	return true

func save() -> void:
	if setting.type == setting.SETTING_TYPE.BOOLEAN:
		setting.value = checkbox.button_pressed
	elif setting.type == setting.SETTING_TYPE.RANGE:
		setting.value = slider.value
	elif setting.type == setting.SETTING_TYPE.OPTIONS:
		setting.value = setting.possible_values[options.get_selected_id()]
