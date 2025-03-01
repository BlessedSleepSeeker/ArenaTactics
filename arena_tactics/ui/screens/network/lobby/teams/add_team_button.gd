extends Control
class_name AddTeamButton

@onready var btn: Button = $"%CreateButton"
@onready var team_name_edit: LineEdit = $"%TeamName"

signal pressed(team_name: String)

func _ready():
	btn.pressed.connect(_on_btn_pressed)

func _on_btn_pressed():
	pressed.emit(team_name_edit.text)