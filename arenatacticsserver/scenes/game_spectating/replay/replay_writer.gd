extends Node
class_name ReplayWriter

@export var group_replays_by_month: bool = true
@export var max_replay: int = 200



@export_subgroup("Replay Paths")
@export var replay_folder_path: String = "user://replay/"
@export var replay_file_extension: String = ".tactics"
@export var replay_file_path_template: String = "%s%s%s%s"

## Built with [method ReplayWriter.build_filepath]
@export var replay_file_path: String = ""

@export_subgroup("Replay Parsing")
## Must have 1 `%d` and no more
@export var turn_tag_template: String = ">%d"


var replay_file: FileAccess = null

func _init():
	build_filepath()
	create_file()

func build_filepath():
	var date_dict: Dictionary = Time.get_datetime_dict_from_system()
	var filename: String = "%s_%s_%s_%s_%s_%s" % [date_dict["year"], date_dict["month"], date_dict["day"], date_dict["hour"], date_dict["minute"], date_dict["second"]]
	if group_replays_by_month:
		var subfolder: String = "%s_%s" % [date_dict["year"], date_dict["month"]]
		replay_folder_path = "%s%s/" % [replay_folder_path, subfolder]
	replay_file_path = "%s%s%s" % [replay_folder_path, filename, replay_file_extension]

func create_file():
	if not DirAccess.dir_exists_absolute(replay_folder_path):
		DirAccess.make_dir_recursive_absolute(replay_folder_path)
	replay_file = FileAccess.open(replay_file_path, FileAccess.WRITE)
	if FileAccess.get_open_error() != 0:
		push_error("Error code %d while opening [%s]." % [FileAccess.get_open_error(), replay_file_path])

func save_replay(meta_dict: Dictionary, game_turns: Array[Array]):
	write_game_metadata(meta_dict)
	write_game_actions(game_turns)
	replay_file.close()

func write_game_metadata(metadata: Dictionary) -> void:
	replay_file.store_line(str(metadata))

func write_game_actions(game_turns: Array[Array]) -> void:
	var i = 1
	for turn_actions: Array[ActionSequence] in game_turns:
		replay_file.store_line(turn_tag_template % i)
		i += 1
		for player_actions: ActionSequence in turn_actions:
			replay_file.store_line(JSON.stringify(player_actions.to_dict()))