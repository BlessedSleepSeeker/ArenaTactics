extends CharacterState
class_name IdleState

@export var min_loop_before_fidget: int = 1
@export var fidget_chance: int = 50
var current_loop: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func enter(_msg := {}) -> void:
	current_loop = 0
	if character.model_animation_player && loop_anim:
		character.model_animation_player.animation_finished.connect(roll_for_fidget)
	play_animation()

func roll_for_fidget(_finished_animation: String):
	if current_loop >= min_loop_before_fidget && fidget_chance >= rng.randi_range(1, 100):
		play_animation("IdleFidget")
		current_loop = 0
	else:
		play_animation()
		current_loop += 1

func exit() -> void:
	if character.model_animation_player && character.model_animation_player.animation_finished.is_connected(roll_for_fidget):
		character.model_animation_player.animation_finished.disconnect(roll_for_fidget)