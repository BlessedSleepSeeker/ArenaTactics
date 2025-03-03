extends MarginContainer
class_name TeamWidget

@onready var team_name: Label = $"%TeamName"
@onready var join_button: Button = $"%JoinButton"
@onready var player_list: VBoxContainer = $"%TeamPlayerList"

var team: ConnectedTeam = null

signal want_join_team(team: ConnectedTeam)

func _ready():
	join_button.pressed.connect(_on_join_pressed)

func build_widget(_team):
	team = _team
	empty()
	fill_data()

func empty():
	for child in player_list.get_children():
		child.queue_free()

func fill_data():
	team_name.text = team.team_name
	for player: ConnectedUser in team.members:
		var lbl = build_player_tag(player)
		player_list.add_child(lbl)


func build_player_tag(player: ConnectedUser) -> IconRichTextLabel:
	var lbl: IconRichTextLabel = IconRichTextLabel.new()
	lbl.fit_content = true
	lbl.bbcode_enabled = true

	if player.is_host:
		lbl.parse_and_set_text("- [b]%s[/b] [img]ap_star[/img]")
	else:
		lbl.parse_and_set_text("- %s")

	lbl.text = "- %s" % player.user_name

	return lbl

func _on_join_pressed():
	want_join_team.emit(team)
