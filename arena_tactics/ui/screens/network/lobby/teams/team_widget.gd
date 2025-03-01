extends MarginContainer
class_name TeamWidget

@onready var team_name: Label = $"%TeamName"
@onready var join_button: Button = $"%JoinButton"
@onready var player_list: VBoxContainer = $"%TeamPlayerList"

signal want_join_team(team_name: String)

func _ready():
	join_button.pressed.connect(_on_join_pressed)

func build_widget(_team_name: String = "TeamName", team: Dictionary = {}):
	empty()
	fill_data(_team_name, team)

func empty():
	for child in player_list.get_children():
		child.queue_free()

func fill_data(_team_name: String, team: Dictionary = {}):
	team_name.text = _team_name
	for player in team:
		var lbl = build_player_tag(team[player])
		player_list.add_child(lbl)


func build_player_tag(player_info: Dictionary) -> RichTextLabel:
	var lbl: RichTextLabel = RichTextLabel.new()
	lbl.fit_content = true
	lbl.bbcode_enabled = true

	lbl.text = "- %s" % player_info["name"]

	return lbl

func _on_join_pressed():
	want_join_team.emit(team_name.text)