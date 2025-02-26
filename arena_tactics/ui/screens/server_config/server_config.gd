extends Control
class_name ServerConfigUI


@export var setting_tab_scene: PackedScene = preload("res://ui/screens/settings/setting_tab.tscn")

@export var back_scene: PackedScene = preload("res://ui/screens/main_menu/main_menu.tscn")

@onready var settings_tab: TabContainer = $"%SettingsContainer"
@onready var settings: Settings = get_tree().root.get_node("Root").get_node("ServerSettings")

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
	quit_dialog.show()

func _on_save_confirmed():
	for tabs: SettingsTab in settings_tab.get_children():
		tabs.save()
	launch_server()

func _on_quit_confirmed():
	get_tree().quit()


func _on_launch_button_pressed():
	save_dialog.show()

func launch_server() -> void:
	var launcher = ArenaServerLauncher.new(settings)