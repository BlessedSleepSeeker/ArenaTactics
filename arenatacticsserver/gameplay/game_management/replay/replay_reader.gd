extends Node
class_name ReplayReader

@export var replay_file_path: String = ""
## Must have 1 `%d` and no more
@export var turn_tag_template: String = ">%d"

var replay_file: FileAccess = null

func _init(_replay_file_path: String):
	replay_file_path = _replay_file_path
	open_file()

func open_file():
	replay_file = FileAccess.open(replay_file_path, FileAccess.READ)
	if FileAccess.get_open_error() != 0:
		push_error("Error code %d while opening [%s]." % [FileAccess.get_open_error(), replay_file_path])

func read_file() -> GameResult:
	var metadata: Dictionary = read_metadata()
	var game_result: GameResult = GameResult.new(metadata)
	game_result.turns = read_game_turns()

	return game_result

## Will read the metadata from [member ReplayReader.replay_file] and transform it back to a [Dictionary]
func read_metadata() -> Dictionary:
	var data = JSON.parse_string(replay_file.get_line())
	if not data:
		push_error("Something went wrong when parsing JSON replay file %s." % replay_file_path)
		return {}
	return data

## Will read the game next_turn from [member ReplayReader.replay_file] and convert it back to an array of array of [ActionSequence]
func read_game_turns() -> Array[Array]:
	var game_turns: Array[Array] = []
	var line: String = replay_file.get_line()
	var next_turn: int = 1
	var turn_actions: Array[ActionSequence] = []
	while line:
		if line == turn_tag_template % (next_turn): ## means we gotta save what we found and increment next_turn !
			if not turn_actions.is_empty():
				game_turns.append(turn_actions.duplicate()) ## duplicate required because array are references
				turn_actions = []
			next_turn += 1
		else:
			var act_dict = JSON.parse_string(line)
			if not act_dict:
				push_error("Something went wrong when parsing JSON replay line [%s]." % line)
				return []
			var act_sequence: ActionSequence = ActionSequence.new(act_dict)
			turn_actions.append(act_sequence)
		line = replay_file.get_line()
	if not turn_actions.is_empty():
		game_turns.append(turn_actions.duplicate()) ## duplicate required because array are references
	return game_turns
