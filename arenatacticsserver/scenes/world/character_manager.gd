extends Node3D
class_name CharacterManager

@export var character_scene = preload("res://scenes/world/character/CharacterInstance.tscn")

var team_1: Array[CharacterInstance] = []
var team_2: Array[CharacterInstance] = []


func _ready() -> void:
    
    ProcGen.finished_setup.connect(call_spawn)


func call_spawn():
    var params: Dictionary = {
		"team1": {
			"1092385123": "Ranger",
			"5435234522": "Ranger"
			},
		"team2": {
			"1098374651": "Ranger",
			"1525234616": "Ranger"
			}
		}
    spawn_characters(params)


func spawn_characters(params: Dictionary) -> void:
    for team in params:
        for player in params[team]:
            load_character(team, player, params[team][player])


func load_character(team: String, player_id: String, player_class: String):
    #print_debug("%s %s %s" % [team, player_id, player_class])
    var inst: CharacterInstance = character_scene.instantiate()
    if inst.build(team, player_id, player_class):
        add_child(inst)
    else:
        inst.queue_free()


func get_team_members(team_name: String):
    pass