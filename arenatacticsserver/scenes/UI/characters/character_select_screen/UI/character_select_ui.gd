extends Control
class_name CharacterSelectUI

var selected_skin: String = "default"

@onready var css_hex_grid: CSSHexagonGrid = $"%CSSHexagonGrid"
@onready var char_title: Label = $"%CharacterTitle"
@onready var char_subtitle: Label = $"%CharacterSubtitle"
@onready var char_description: RichTextLabel = $"%CharacterDescription"
@onready var anim_player: AnimationPlayer = $AnimationPlayer

signal class_selected(selected_class: ClassDefinition)

func build() -> void:
	css_hex_grid.build_grid(ClassLoader.classes)
	css_hex_grid.class_selected.connect(select_class)
	select_random_class()


func select_class(_selected_class: ClassDefinition) -> void:
	if _selected_class == null:
		select_random_class()
		return
	class_selected.emit(_selected_class)

func update_selected_class(_selected_class: ClassDefinition):
	anim_player.play_backwards("fade_in")
	await anim_player.animation_finished
	fill_data(_selected_class)
	anim_player.play("fade_in")

## Get a random key from keys() then use that
## If the random class is the currently selected one, we roll again, but no more than 5 times to avoid infinite loop in the case there is only one class.
func select_random_class(current_class: ClassDefinition = null) -> void:
	var i: int = 0
	var rando_class = ClassLoader.classes[ClassLoader.classes.keys().pick_random()]
	while rando_class == current_class:
		rando_class = ClassLoader.classes[ClassLoader.classes.keys().pick_random()]
		i += 1
		if i > 4:
			break
	select_class(rando_class)

func fill_data(selected_class: ClassDefinition) -> void:
	char_title.text = selected_class.title.to_pascal_case()
	char_subtitle.text = selected_class.subtitle
	char_description.text = selected_class.description
