extends PlayerState

# IdleAnim should be manually looped

func enter(_msg := {}) -> void:
	if character.model_animation_player:
		print_debug("Connected to animplayer")
		character.model_animation_player.animation_finished.connect(play_animation)
	play_animation()

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	character.move_and_slide()

func exit() -> void:
	if character.model_animation_player && character.model_animation_player.animation_finished.is_connected(play_animation):
		character.model_animation_player.animation_finished.disconnect(play_animation)

func play_animation(_anim_name: String = "") -> void:
	character.play_animation("Idle")