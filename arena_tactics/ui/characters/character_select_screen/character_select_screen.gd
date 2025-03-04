extends Control
class_name CharacterSelectScreen

## If true, the class will automatically be locked in after [member CharacterSelectScreen.selection_timer_duration] has timed out.
@export var selection_timer: bool = true
@export var selection_timer_duration: int = 30

signal class_locked_in(_class: ClassDefinition)

@onready var transition_scene_path = "res://ui/screens/main_menu/main_menu.tscn"

signal transition(new_scene: PackedScene, animation: String)

@onready var css_ui: CharacterSelectUI = $"%CharacterSelectUI"
@onready var css_3d: CharacterSelect3D = $"%CharacterSelect3d"

var selected_class: ClassDefinition = null

func _ready():
	css_ui.class_selected.connect(_on_class_selected)
	css_ui.action_selected.connect(_on_action_selected)
	css_ui.return_button.pressed.connect(_return_button_clicked)
	css_ui.class_locked_in.connect(lock_in_class)
	if selection_timer:
		css_ui.selection_timer = true
		css_ui.selection_timer_duration = selection_timer_duration
	if ClassLoader.setup_is_finished == false:
		ClassLoader.finished_setup.connect(css_ui.build)
	else:
		css_ui.build()

func _on_class_selected(_selected_class: ClassDefinition):
	selected_class = _selected_class
	var new_instance: CharacterInstance = selected_class.instantiate()
	css_ui.update_selected_class(new_instance)
	css_3d.build(new_instance)

func _on_action_selected(action: GameplayAction):
	css_ui.update_selected_action(action)
	css_3d.play_character_action(action)

func _return_button_clicked():
	var packed: PackedScene = load(transition_scene_path)
	transition.emit(packed, "scene_transition")

func lock_in_class():
	class_locked_in.emit(selected_class)
