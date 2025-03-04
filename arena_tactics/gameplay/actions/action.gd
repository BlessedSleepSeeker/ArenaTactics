extends Resource
class_name GameplayAction

var state_machine: StateMachine = null
var actor: CharacterInstance = null

@export_group("UI")
## The GameplayAction name, which is used in UI and replay files.
@export var name: String = ""
## The name of the Script being instantiated.
@export var action_class_name: String = ""
## The GameplayAction icon in the UI.
@export var icon: Texture2D = null
@export var description: String = ""

@export_group("Juice")
## The name of the action the character is going to perform when doing this action.
@export var character_animation_name: String = ""
## The sound effect the character is going to play when doing this action.
@export var character_sound_effet: AudioStream = null

@export_group("Gameplay")
## The action's cost in ActionPoints:tm:
@export var ap_cost: int = 1
## The amount of gameplay noise emitted by the action at the actor's position when the spell is begining to be cast.
@export var noise_level_actor: int = 0
## The amount of gameplay noise emitted by the action at the target's position when the spell resolve.
@export var noise_level_target: int = 0
## The amount of turn where the action is unusable after being used once. 0 = no restriction. 1 = next turn.
@export var cooldown: int = 0
## The maximum use of the action per turn.
@export var max_use_per_turn: int = 0
## The instance of a `TargetingRestrictions`.
@export var targeting_restrictions: TargetingRestrictions = null

func _init(instance: CharacterInstance = null, _data: Dictionary = {}, _name: String = "Default"):
	actor = instance
	if instance:
		state_machine = instance.state_machine
	name = _name
	for key in _data:
		if is_match("targeting_restriction", key):
			targeting_restrictions = TargetingRestrictions.new(_data[key])
		elif is_match_and_path_exist("icon_path", key, _data[key]):
			icon = load(_data[key])
		else:
			add_data_to_var(key, _data[key])

func _to_string():
	return name

func use(_target: CharacterInstance) -> void:
	pass

@export var gameplay_info_string_template: String = "[center][u][b]%s[/b][/u]\nCost : %d AP\nNoises : %d, %d\n"
func get_gameplay_infos() -> String:
	var infos = gameplay_info_string_template % [self.name, self.ap_cost, self.noise_level_actor, self.noise_level_target]
	if targeting_restrictions:
		infos += targeting_restrictions.get_gameplay_infos()
	infos += "[/center]"
	return infos

#region Helpers
func is_match(match: String, key) -> bool:
	return key is String && key.contains(match)

func is_match_and_path_exist(match: String, key, value) -> bool:
	if key is String && key.contains(match) && value:
		if FileAccess.file_exists(value):
			return true
		else:
			push_error(DebugHelper.format_debug_string(self, "ERROR", "Matched \"%s\" but path [%s] doesn't exist." % [match, value]))
	return false

func add_data_to_var(var_name: String, var_value: Variant):
	if var_name in self:
		self.set(var_name, var_value)
	else:
		push_error(DebugHelper.format_debug_string(self, "ERROR", "Can't set {%s.%s} : Member variable not found" % [self.name, var_name]))
#endregion