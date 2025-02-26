extends HBoxContainer
class_name SettingLine

var lbl: Label
var checkbox: CheckButton
var slider: Slider
var options: OptionButton
var text: LineEdit
var number: SpinBox

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
	match setting.type:
		setting.SETTING_TYPE.BOOLEAN:
			checkbox.release_focus()
		setting.SETTING_TYPE.RANGE:
			slider.release_focus()
		setting.SETTING_TYPE.OPTIONS:
			options.release_focus()
		setting.SETTING_TYPE.TEXT:
			text.release_focus()
		setting.SETTING_TYPE.NUMBER:
			number.release_focus()

func tear_down() -> void:
	if lbl != null:
		lbl.queue_free()
	if checkbox != null:
		checkbox.queue_free()
	if slider != null:
		slider.queue_free()
	if options != null:
		options.queue_free()
	if text != null:
		text.queue_free()
	if number != null:
		number.queue_free()


func build() -> void:
	setting_name.text = setting.key.capitalize()
	setting_name.tooltip_text = setting.tooltip
	match setting.type:
		setting.SETTING_TYPE.BOOLEAN:
			build_bool()
		setting.SETTING_TYPE.RANGE:
			build_range()
		setting.SETTING_TYPE.OPTIONS:
			build_options()
		setting.SETTING_TYPE.TEXT:
			build_text()
		setting.SETTING_TYPE.NUMBER:
			build_number()


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
	slider.min_value = setting.min_value_range
	slider.max_value = setting.max_value_range
	slider.step = setting.step_range
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

func build_text() -> void:
	text = LineEdit.new()
	container.add_child(text)
	text.text = setting.value

func build_number() -> void:
	number = SpinBox.new()
	container.add_child(number)
	number.min_value = setting.min_value_nbr
	number.max_value = setting.max_value_nbr
	number.step = setting.step_nbr
	number.value = setting.value


func is_modified() -> bool:
	match setting.type:
		setting.SETTING_TYPE.BOOLEAN:
			return setting.value != checkbox.button_pressed
		setting.SETTING_TYPE.RANGE:
			return setting.value != slider.value
		setting.SETTING_TYPE.OPTIONS:
			return setting.value != setting.possible_values[options.get_selected_id()]
		setting.SETTING_TYPE.TEXT:
			return setting.value != text.text
		setting.SETTING_TYPE.NUMBER:
			return setting.value != number.value
	return true

func save() -> void:
	match setting.type:
		setting.SETTING_TYPE.BOOLEAN:
			setting.value = checkbox.button_pressed
		setting.SETTING_TYPE.RANGE:
			setting.value = slider.value
		setting.SETTING_TYPE.OPTIONS:
			setting.value = setting.possible_values[options.get_selected_id()]
		setting.SETTING_TYPE.TEXT:
			setting.value = text.text
		setting.SETTING_TYPE.NUMBER:
			setting.value = number.value
