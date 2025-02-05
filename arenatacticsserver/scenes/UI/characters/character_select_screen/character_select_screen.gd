extends Control
class_name CharacterSelectScreen

signal class_locked_in(_class: ClassDefinition)

@onready var css_ui: CharacterSelectUI = $"%CharacterSelectUI"
@onready var css_3d: CharacterSelect3D = $"%CharacterSelect3d"

func _ready():
	css_ui.class_selected.connect(on_class_selected)
	if ClassLoader.setup_is_finished == false:
		ClassLoader.finished_setup.connect(css_ui.build)
	else:
		css_ui.build()


func on_class_selected(selected_class: ClassDefinition):
	css_3d.build(selected_class)