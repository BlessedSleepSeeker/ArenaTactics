extends GridContainer
class_name LobbyTeams

var networker: NetworkClient = null

@export var add_team_button_scene: PackedScene = preload("res://ui/screens/network/lobby/teams/AddTeamButton.tscn")
@export var team_widget_scene: PackedScene = preload("res://ui/screens/network/lobby/teams/TeamWidget.tscn")

signal picked_team(team_name: String)
signal created_team(team_name: String)

func setup(_networker: NetworkClient, _teams: Dictionary):
	networker = _networker
	networker.team_list_updated.connect(build_grid)
	build_grid()

func build_grid():
	empty_grid()
	fill_grid()

func empty_grid():
	for child in get_children():
		child.queue_free()

func fill_grid():
	for team in networker.teams:
		var team_widget: TeamWidget = team_widget_scene.instantiate()
		team_widget.want_join_team.connect(_on_team_picked)
		self.add_child(team_widget)
		team_widget.build_widget(team, networker.teams[team])
	create_add_team_button()

func create_add_team_button():
	var inst = add_team_button_scene.instantiate()
	inst.pressed.connect(_on_team_created)
	add_child(inst)

func _on_team_picked(team_name: String):
	picked_team.emit(team_name)
	networker.join_team(team_name)

func _on_team_created(team_name: String):
	created_team.emit(team_name)
	networker.create_team(team_name)