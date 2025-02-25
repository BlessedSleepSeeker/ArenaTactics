extends Node
class_name StateMachine

signal transitioned(state_name)

@export var initial_state := NodePath()

@onready var state: CharacterState = get_node(initial_state)


func _ready() -> void:
	await owner.ready
	for child in get_children():
		child.state_machine = self
	state.enter()


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		push_error("No State with Name {%s} was found" % [target_state_name])
		return
	msg["PreviousState"] = state.name
	state.exit()
	if state.wait_for_animation_end_before_exit:
		await state.character.model_animation_player.animation_finished
	state = get_node(target_state_name)
	state.enter(msg)
	transitioned.emit(state.name)
