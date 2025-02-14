extends CharacterState
class_name WalkState

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var anim_to_walk_template: String = "%sToWalk"
var prev_anim_name: String = ""

## Will first play <Prevstate.name>ToWalk, if Idle = IdleToWalk then connect animation finished to play_animation which will be "Walk" if the node's name is "Walk"
func enter(_msg := {}) -> void:
	prev_anim_name = anim_to_walk_template % _msg["PreviousState"]
	if character.model_animation_player && loop_anim:
		character.model_animation_player.animation_finished.connect(walk)
	play_animation(prev_anim_name)

func walk(_prev_anim: String):
	play_animation()

func exit() -> void:
	if character.model_animation_player && character.model_animation_player.animation_finished.is_connected(walk):
		character.model_animation_player.animation_finished.disconnect(walk)
	play_animation(prev_anim_name, true)