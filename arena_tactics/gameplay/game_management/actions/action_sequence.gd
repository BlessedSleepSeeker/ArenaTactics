extends Resource
class_name ActionSequence

@export var actor_id: String = "Test"

@export var actions: Array[PlayedAction] = [
	PlayedAction.new(GameplayAction.new(null, {}, "A"), Vector3i(-1, 0, 1)),
	PlayedAction.new(GameplayAction.new(null, {}, "B"), Vector3i(-4, 2, 2)),
	PlayedAction.new(GameplayAction.new(null, {}, "C"), Vector3i(-5, 2, 3))
	]

func _init(_dict: Dictionary = {}):
	if not _dict.is_empty():
		from_dict(_dict)

func _to_string():
	return "ActionSequence(%s)%s" % [actor_id, actions]

#region Dictionary

func to_dict() -> Dictionary:
	var actions_array: Array[Dictionary] = []
	var actor: CharacterInstance = actions.pick_random().action.actor
	if not actor:
		pass#return {}
	for p_action: PlayedAction in actions:
		actions_array.append(p_action.to_dict())
	var actions_dict = {}
	actions_dict[actor_id] = actions_array
	return actions_dict

func from_dict(dict: Dictionary):
	actions = []
	for player_id in dict:
		actor_id = player_id
		var player: CharacterInstance = null#server.get_instance_from_id(player_id)
		if player == null:
			pass#return
		for p_action in dict[player_id]:
			for p_action_name in p_action:
				var coords_vector: Vector3i = str_to_var("Vector3i" + p_action[p_action_name])
				var new_p_action = PlayedAction.new(GameplayAction.new(null, {}, p_action_name), coords_vector)
				#var action: GameplayAction = player.get_action_by_name(p_action_name)
				#var new_p_action = PlayedAction.new(action, p_action[p_action_name])
				actions.append(new_p_action)

#endregion

#region Sequence Manipulation

func append_action(action: GameplayAction):
	actions.append(action)

#endregion
