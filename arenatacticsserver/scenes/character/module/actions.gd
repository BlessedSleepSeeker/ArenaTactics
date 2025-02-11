extends Module
class_name ActionsModule

@export var actor: CharacterInstance

var actions: Array[GameplayAction] = []

func _ready():
	super()

func print_data():
	pass

func setup(instance: CharacterInstance, _data: Dictionary):
	actor = instance
	for action_type in _data:
		for action in _data[action_type]:
			build_action(action, _data[action_type][action])

func build_action(action_name: String, action_data: Dictionary):
	var action_script_path = ""
	var action_class_name: String = "GameplayAction"
	if action_data.has("action_class_name"):
		action_class_name = action_data.get("action_class_name")
	for script in ProjectSettings.get_global_class_list():
		if script["class"] == action_class_name:
			action_script_path = script["path"]
	if not FileAccess.file_exists(action_script_path):
		push_error(DebugHelper.format_debug_string(self, "ERROR", "File not found at %s while trying to instance Action [%s] with type [%s]" % [action_script_path, action_name, action_class_name]))
		return

	var action: GameplayAction = load(action_script_path).new(actor, action_data, action_name)
	actions.append(action)


func start_game():
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
		push_error(DebugHelper.format_debug_string(self, "ERROR", "Can't set {%s.%s} : Member variable not found" % [self, var_name]))
#endregion