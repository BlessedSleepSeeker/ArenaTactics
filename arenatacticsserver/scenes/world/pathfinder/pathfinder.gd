extends Resource
class_name PathFinderSettings

var name = "PathFinderSettings"

## Enable or disable the pathfinding. if [member PathFinderSettings.pathfind_to_target] is false, pathfinding will always succeed.
@export var pathfind_to_target: bool = false
## The amount of tile traversed the pathfinding is allowed to pass by to find a way. -1 has no limit.
@export var max_distance: int = -1
## The maximum  `HexTile.height` difference between a tile and their neighbors before the pathfinding isn't allowed to take this path. -1 has no limit.
@export var elevation_difference_tolerated_between_neighbors: int = -1
## Is the pathfinding allowed to use non-empty tiles to pathfind ?
@export var allow_non_empty_tile_as_path: bool = true

func _init(data: Dictionary = {}):
	parse_data(data)


func parse_data(data: Dictionary) -> void:
	for key in data:
		add_data_to_var(key, data[key])


@export var gameplay_info_string_template: String = "[u]PathFinding[/u]\nPathFinding Distance : %d tiles.\nMax elevation between neighbors : %d\nPassing throught taken tiles is allowed : %s"
func get_gameplay_infos() -> String:
	var infos = gameplay_info_string_template % [self.max_distance, self.elevation_difference_tolerated_between_neighbors, self.allow_non_empty_tile_as_path]
	return infos

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