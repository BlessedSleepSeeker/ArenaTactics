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

@export_group("Juice")
## The name of the action the character is going to perform when doing this action.
@export var character_animation_name: String = ""
## The sound effect the character is going to play when doing this action.
@export var character_sound_effet: AudioStream = null

@export_group("Gameplay")
## The action's cost in ActionPoints:tm:
@export var ap_cost: int = 1
## The amount of gameplay noise emitted by the action.
@export var noise_level: int = 1
## The amount of turn where the action is unusable after being used once. 0 = no restriction. 1 = next turn.
@export var cooldown: int = 0
## The maximum use of the action per turn.
@export var max_use_per_turn: int = 0
## The instance of a `TargetingRestrictions`.
@export var targeting_restrictions: TargetingRestrictions = null

func _init(instance: CharacterInstance, data: Dictionary, _name: String):
	actor = instance
	state_machine = instance.state_machine
	_name = name
	for key in data:
		if is_match("targeting_restriction", key):
			targeting_restrictions = TargetingRestrictions.new(data[key])
		elif is_match_and_path_exist("icon_texture", key, data[key]):
			icon = load(data[key])
		else:
			add_data_to_var(key, data[key])

func use():
	pass
	

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