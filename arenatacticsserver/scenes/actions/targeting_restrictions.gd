extends Resource
class_name TargetingRestrictions

var name = "TargetingRestrictions"

## Mininum Targeting Range. Negative numbers throw an error.
@export var min_range: int = 0:
	set(value):
		if value < 0:
			push_error(DebugHelper.format_debug_string(self, "ERROR", "Minimum Targeting Range can't be negative."))
			min_range = 0
		else:
			min_range = value

## Maximum Targeting Range. Negative numbers throw an error.
@export var max_range: int = 99:
	set(value):
		if value < 0:
			push_error(DebugHelper.format_debug_string(self, "ERROR", "Maximum Targeting Range can't be negative."))
			min_range = 0
		else:
			max_range = value

## Should we check line of sight with the targeted tile ?
@export var line_of_sight: bool = false
## Should be in a straight line with the targeted tile ?
@export var aligned: bool = false
## Should the targeted tile be empty ?
@export var must_be_empty: bool = false

## Should be try to pathfind to the target ?
@export var pathfind_to_target: bool = false
@export var pathfinder_settings: PathFinderSettings = null

#region Parsing Data
func _init(data: Dictionary):
	parse_data(data)

func parse_data(data: Dictionary) -> void:
	for key in data:
		if is_match("target_tile", key):
			parse_target_data(data[key])
		else:
			add_data_to_var(key, data[key])

func parse_target_data(data: Dictionary) -> void:
	for key in data:
		if is_match("pathfind", key):
			pathfind_to_target = true
			pathfinder_settings = PathFinderSettings.new(data[key])
		else:
			add_data_to_var(key, data[key])
#endregion

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