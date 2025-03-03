extends Resource
class_name ConnectedTeam

@export var team_name: String
@export var members: Array[ConnectedUser] = []
var members_id: Array[int] = []
@export var is_spectator: bool = false

func _init(_team_name: String = ""):
	team_name = _team_name

func to_dict() -> Dictionary:
	var new_dict: Dictionary = {}
	new_dict["team_name"] = team_name
	new_dict["is_spectator"] = is_spectator
	new_dict["members"] = {}
	var i = 0
	set_members_id()
	for user_id: int in members_id:
		new_dict["members"][i] = user_id
		i += 1
	return new_dict

func from_dict(dict: Dictionary) -> ConnectedTeam:
	for key in dict:
		if key == "members":
			parse_members(dict[key])
		else:
			add_data_to_var(key, dict[key])
	return self

func set_members_id():
	var new_arr: Array[int] = []
	for user in members:
		new_arr.append(user.id)
	members_id = new_arr

func parse_members(_members: Dictionary):
	for key in _members:
		members_id.append(_members[key])

func add_data_to_var(var_name: String, var_value: Variant):
	if var_name in self:
		self.set(var_name, var_value)