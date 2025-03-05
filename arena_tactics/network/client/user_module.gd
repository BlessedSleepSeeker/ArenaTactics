extends Node
class_name ClientUserModule

var networker: NetworkClient
var chat_module: ClientChatModule

var users: Array[ConnectedUser] = []
var teams: Array[ConnectedTeam] = []

@export var player_info: Dictionary = {"name": "Client", "password": ""}

signal player_list_updated(list: Array[ConnectedUser])
signal team_list_updated(list: Array[ConnectedTeam])
signal allowed_in_server

func _ready():
	networker = owner as NetworkClient
	chat_module = networker.chat_module
	## randomize name for fast forward option
	if networker.fast_forward:
		var characters = 'abcdefghijklmnopqrstuvwxyz'
		var new_word = generate_word(characters, 10)
		set_player_info({"name": new_word, "password": ""})


func generate_word(chars, length):
	var word: String = ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

#region Users
func set_player_info(_player_info: Dictionary):
	player_info = _player_info

func join_server():
	register_user.rpc_id(1, player_info["name"], player_info["password"])

@rpc("any_peer", "reliable")
func register_user(_user_name: String, _room_password: String):
	pass

@rpc("authority", "reliable")
func allowed_in():
	allowed_in_server.emit()

@rpc("authority", "reliable")
func send_user_list(_users: Dictionary):
	users.clear()
	for user in _users:
		var new_user: ConnectedUser = ConnectedUser.new().from_dict(_users[user])
		users.append(new_user)
	player_list_updated.emit()

@rpc("any_peer", "reliable")
func get_user_list():
	pass

func leave():
	users = []
	teams = []
#endregion

#region UserLib

func get_user_by_id(id: int) -> ConnectedUser:
	for user in users:
		if user.id == id:
			return user
	return null
#endregion

#region Teams
func create_team(_team_name: String):
	register_team.rpc_id(1, _team_name)

@rpc("any_peer", "reliable")
func register_team(_team_name: String):
	pass

func join_team(_team: ConnectedTeam):
	if not teams.has(_team):
		networker.throw_error("No team with name %s was found." % _team.team_name)
	add_player_to_team.rpc_id(1, _team.team_name, player_info["name"])

@rpc("any_peer", "reliable")
func add_player_to_team(_team_name: String, _player_name: String):
	pass

@rpc("authority", "reliable")
func send_team_list(_teams: Dictionary):
	teams.clear()
	for team in _teams:
		var new_team: ConnectedTeam = ConnectedTeam.new().from_dict(_teams[team])
		link_team_id_with_users(new_team)
		teams.append(new_team)
	team_list_updated.emit()

@rpc("any_peer", "reliable")
func get_team_list():
	pass

func link_team_id_with_users(team: ConnectedTeam):
	team.members.clear()
	for id in team.members_id:
		team.members.append(get_user_by_id(id))
#endregion

#region CharacterSelect
@rpc("authority", "reliable")
func get_user_class(player_id: int, _class_name: String):
	print_debug(player_id, _class_name)
	player_list_updated.emit()

@rpc("any_peer", "reliable")
func receive_user_class(_class_name: String):
	pass
#endregion