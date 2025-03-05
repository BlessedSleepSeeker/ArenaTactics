extends Node
class_name GameManager

@export var users: Array[ConnectedUser]
@export var teams: Array[ConnectedTeam]

@onready var world_view: WorldView = $WorldView
@onready var grid: HexGridCube = world_view.hex_grid

func setup_game(_users: Array[ConnectedUser], _teams: Array[ConnectedTeam]):
	users = _users
	teams = _teams

func check_win():
	pass