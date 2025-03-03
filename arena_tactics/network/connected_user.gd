extends Resource
class_name ConnectedUser

@export var id: int
@export var user_name: String
@export var is_host: bool = false

func _init(_user_name: String = ""):
	user_name = _user_name

func check_name_validity() -> bool:
	if user_name.length() == 0:
		return false
	return true

func to_dict() -> Dictionary:
	var new_dict: Dictionary = {}
	new_dict["id"] = id
	new_dict["user_name"] = user_name
	new_dict["is_host"] = is_host

	return new_dict

func from_dict(dict: Dictionary) -> ConnectedUser:
	for key in dict:
		add_data_to_var(key, dict[key])
	return self

func add_data_to_var(var_name: String, var_value: Variant):
	if var_name in self:
		self.set(var_name, var_value)