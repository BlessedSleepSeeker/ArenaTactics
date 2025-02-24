class_name CharacterState
extends State

var character: CharacterInstance

@export var loop_anim: bool = false
@export var physics_on: bool = true
@export var wait_for_animation_end_before_exit: bool = false

func _ready() -> void:
	character = owner as CharacterInstance

func enter(_msg := {}) -> void:
	if character.model_animation_player && loop_anim:
		character.model_animation_player.animation_finished.connect(play_animation)
	play_animation()

func physics_update(_delta: float) -> void:
	if physics_on:
		character.velocity.y += _delta * character.gravity
		character.move_and_slide()

func exit() -> void:
	if character.model_animation_player && character.model_animation_player.animation_finished.is_connected(play_animation):
		character.model_animation_player.animation_finished.disconnect(play_animation)

func play_animation(_anim_name: String = "", reverse: bool = false) -> void:
	if _anim_name:
		character.play_animation(_anim_name, reverse)
	else:
		character.play_animation(self.name, reverse)
