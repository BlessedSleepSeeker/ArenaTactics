extends Control
class_name CharacterSelectUI

var selected_skin: String = "default"

@onready var character_select_grid: CSSHexagonGrid = $"%CSSHexagonGrid"
@onready var char_title: Label = $"%CharacterTitle"
@onready var char_subtitle: Label = $"%CharacterSubtitle"
@onready var char_description: RichTextLabel = $"%CharacterDescription"
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var action_grid: ActionButtonGrid = $"%ActionIconsGrid"
@onready var action_data: ActionDataDisplay = $"%ActionData"

signal class_selected(selected_class: ClassDefinition)
signal action_selected(action: GameplayAction)

func build() -> void:
	character_select_grid.build_grid(ClassLoader.classes)
	character_select_grid.class_selected.connect(select_class)
	action_grid.action_selected.connect(_action_selected)
	select_random_class()


func select_class(_selected_class: ClassDefinition) -> void:
	if _selected_class == null:
		select_random_class()
		return
	class_selected.emit(_selected_class)

func _action_selected(action: GameplayAction):
	action_selected.emit(action)

func update_selected_class(character: CharacterInstance):
	anim_player.play_backwards("fade_in")
	await anim_player.animation_finished
	fill_data(character)
	await get_tree().create_timer(0.5).timeout
	anim_player.play("fade_in")

func update_selected_action(action: GameplayAction, play_anim: bool = true):
	if play_anim:
		anim_player.play_backwards("fade_in_action_data")
		await anim_player.animation_finished
	action_data.action = action
	action_grid.select_button(action)
	if play_anim:
		anim_player.play("fade_in_action_data")

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

func fill_data(character: CharacterInstance) -> void:
	char_title.text = character.character_class.to_pascal_case()
	char_subtitle.text = character.subtitle
	char_description.text = character.description
	var actions = character.get_actions()
	action_grid.build(actions)
	update_selected_action(actions.pick_random(), false)
