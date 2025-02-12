extends GameplayAction
class_name BasicOffensiveAction

@export var target_effect: OffensiveActionEffect = null
@export var actor_effect: OffensiveActionEffect = null

func _init(instance: CharacterInstance, _data: Dictionary, _name: String):
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


#region Helpers
func is_match(match: String, key) -> bool:
	return key is String && key.contains(match)

func is_match_and_path_exist(match: String, key, value) -> bool:
	return key is String && key.contains(match) && value is String && FileAccess.file_exists(value)

func add_data_to_var(var_name: String, var_value: Variant):
	if var_name in self:
		self.set(var_name, var_value)
	else:
		push_error(DebugHelper.format_debug_string(self, "ERROR", "Can't set {%s.%s} : Member variable not found" % [self.name, var_name]))
#endregion