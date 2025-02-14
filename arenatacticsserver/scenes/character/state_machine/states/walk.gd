extends CharacterState
class_name WalkState

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var anim_to_walk_template: String = "%sToWalk"

## Will first play <Prevstate.name>ToWalk, if Idle = IdleToWalk then connect animation finished to play_animation which will be "Walk" if the node's name is "Walk"
func enter(_msg := {}) -> void:
	var anim = anim_to_walk_template % _msg["PreviousState"]
	if character.model_animation_player && loop_anim:
		character.model_animation_player.animation_finished.connect(walk)
	play_animation(anim)

func walk(prev_anim: String):
	play_animation()

func exit() -> void:
	pass