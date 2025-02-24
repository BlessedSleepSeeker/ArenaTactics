extends Control
class_name CharacterSelectScreen

signal class_locked_in(_class: ClassDefinition)

@onready var transition_scene_path = "res://ui/screens/main_menu/main_menu.tscn"

signal transition(new_scene: PackedScene, animation: String)

@onready var css_ui: CharacterSelectUI = $"%CharacterSelectUI"
@onready var css_3d: CharacterSelect3D = $"%CharacterSelect3d"

func _ready():
	css_ui.class_selected.connect(_on_class_selected)
	css_ui.action_selected.connect(_on_action_selected)
	css_ui.return_button.pressed.connect(_return_button_clicked)
	if ClassLoader.setup_is_finished == false:
		ClassLoader.finished_setup.connect(css_ui.build)
	else:
		css_ui.build()

func _on_class_selected(selected_class: ClassDefinition):
	var new_instance: CharacterInstance = selected_class.instantiate()
	css_ui.update_selected_class(new_instance)
	css_3d.build(new_instance)

func _on_action_selected(action: GameplayAction):
	css_ui.update_selected_action(action)
	css_3d.play_character_action(action)

func _return_button_clicked():
	var packed: PackedScene = load(transition_scene_path)
	transition.emit(packed, "scene_transition")