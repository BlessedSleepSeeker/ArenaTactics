extends MarginContainer
class_name SettingsTab

@export var setting_line_scene: PackedScene = preload("res://ui/screens/settings/settings_line.tscn")
@export var section_name: String:
	set(val):
		section_name = val
		self.name = section_name

@onready var column: VBoxContainer = $SC/VB

@export var settings: Array = []:
	set(val):
		settings = val
		build_settings_ui()


func build_settings_ui() -> void:
	for setting in settings:
		var instance: SettingLine = setting_line_scene.instantiate()
		column.add_child(instance)
		instance.setting = setting


func has_modified_settings() -> bool:
	for child: SettingLine in column.get_children():
		if child.is_modified():
			return true
	return false

func save() -> void:
	for child: SettingLine in column.get_children():
		child.save()