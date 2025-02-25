extends Node

@export var debug_template: String = "[%s]{%s}(%s): \"%s\""

func _ready():
	# var metadata_dict: Dictionary = {
	# 	"main_seed": "5236589362",
	# 	"p1_id": {
	# 		"ranger": "default"
	# 	},
	# 	"p2_id": {
	# 		"ranger": "default"
	# 	},
	# 	"game_turns": "14"
	# }
	# var actseq: Array[ActionSequence] = [ActionSequence.new(), ActionSequence.new(), ActionSequence.new()]
	# var actseq2: Array[ActionSequence] = [ActionSequence.new(), ActionSequence.new()]
	# var actseq3: Array[ActionSequence] = [ActionSequence.new()]
	# var game_turns: Array[Array] = [actseq, actseq2, actseq3]
	
	# var replay_writer: ReplayWriter = ReplayWriter.new()
	# replay_writer.save_replay(metadata_dict, game_turns)

	# var replay_reader: ReplayReader = ReplayReader.new(replay_writer.replay_file_path)
	# var read_metadata = replay_reader.read_metadata()
	# var read_game_turns = replay_reader.read_game_turns()

	print(format_debug_string(self, "INFO", "DebugHelper Online"))

func format_debug_string(debugged_object: Variant, message_type: String, message: String) -> String:
	var cur_date = Time.get_datetime_string_from_system()
	if debugged_object is Resource and not debugged_object.get("name"):
		return debug_template % [cur_date, debugged_object, message_type, message]
	else:
		return debug_template % [cur_date, debugged_object.name, message_type, message]
	
