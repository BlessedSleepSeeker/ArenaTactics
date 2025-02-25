extends Resource
class_name PlayedAction

## The action which is used
@export var action: GameplayAction = null
## The grid coordinates where the action is used
@export var target_coordinates: Vector3i = Vector3i()
@export var played: bool = false

func _to_string():
	return "%s(%s)" % [action, target_coordinates]

func _init(_action: GameplayAction = null, _target_coordinates: Vector3i = Vector3i()):
	action = _action
	target_coordinates = _target_coordinates

func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	dict[action.name] = target_coordinates
	return dict

func from_dict(dict: Dictionary):
	pass