extends Control

@export var setting_tab_scene: PackedScene = preload("res://scenes/menu/settings/setting_tab.tscn")

@export var back_scene: PackedScene = preload("res://scenes/menu/main_menu.tscn")

@onready var settings_tab: TabContainer = $MC/VB/SettingsTab
@onready var settings: Settings = get_tree().root.get_node("Root").settings

@onready var save_dialog: ConfirmationDialog = $SaveDialog
@onready var quit_dialog: ConfirmationDialog = $QuitDialog

signal transition(new_scene: PackedScene, animation: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	for section in settings.get_sections_list():
		var instance: SettingsTab = setting_tab_scene.instantiate()
		settings_tab.add_child(instance)
		instance.settings = settings.get_settings_by_section(section)
		instance.section_name = section
	save_dialog.confirmed.connect(_on_save_confirmed)
	#save_dialog.canceled.connect(_on_save_canceled)
	quit_dialog.confirmed.connect(_on_quit_confirmed)
	#quit_dialog.canceled.connect(_on_quit_canceled)


func _on_quit_button_pressed():
	var b = false
	for tabs: SettingsTab in settings_tab.get_children():
		if tabs.has_modified_settings():
			quit_dialog.show()
			b = true
	if not b:
		transition.emit(back_scene, "scene_transition")
	

func _on_save_button_pressed():
	save_dialog.show()


func _on_save_confirmed():
	for tabs: SettingsTab in settings_tab.get_children():
		tabs.save()
	settings.apply_settings()
	settings.save_settings_to_file()


func _on_quit_confirmed():
	transition.emit(back_scene, true)
