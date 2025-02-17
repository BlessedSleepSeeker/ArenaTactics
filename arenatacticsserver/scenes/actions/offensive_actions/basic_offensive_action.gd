extends GameplayAction
class_name BasicOffensiveAction

@export var target_effect: OffensiveActionEffect = null
@export var actor_effect: OffensiveActionEffect = null
@export var default_offensive_icon: Texture2D = preload("res://scenes/actions/offensive_actions/assets/offensive_icon_placeholder.png")

func _init(instance: CharacterInstance = null, _data: Dictionary = {}, _name: String = "Default"):
	self.icon = default_offensive_icon
	super(instance, _data, _name)
	for key in _data:
		if is_match("target_effect", key):
			parse_target_effect(_data[key])
		elif is_match("actor_effect", key):
			parse_actor_effect(_data[key])

func parse_target_effect(effect_data: Dictionary):
	target_effect = OffensiveActionEffect.new(effect_data)

func parse_actor_effect(effect_data: Dictionary):
	actor_effect = OffensiveActionEffect.new(effect_data)

func use(target: CharacterInstance, is_backstab: bool = false):
	if target_effect:
		target_effect.apply_effect(target, is_backstab)
	if actor_effect:
		actor_effect.apply_effect(actor, is_backstab)

func get_gameplay_infos() -> String:
	var infos = gameplay_info_string_template % [self.name, self.ap_cost, self.noise_level_actor, self.noise_level_target]
	if targeting_restrictions:
		infos += targeting_restrictions.get_gameplay_infos()
	if target_effect:
		infos += target_effect.get_gameplay_infos("Target")
	if actor_effect:
		infos += actor_effect.get_gameplay_infos("Actor")
	infos += "[/center]"
	return infos