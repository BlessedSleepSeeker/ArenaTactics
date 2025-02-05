extends Node3D
class_name CharacterSelect3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var chara_spawn: Node3D = $"%CharacterSpawnPoint"

func _ready():
	pass

func build(character: CharacterInstance):
	reset_diorama()
	spawn_diorama(character)

func reset_diorama():
	# fade anim here
	# camera movement/blur ?
	for child in chara_spawn.get_children():
		child.free()

func spawn_diorama(character: CharacterInstance):
	# fade in here/play fade out in reverse
	var new_instance = ClassLoader.get_class_instance(character.character_class)
	print_debug("Spawing %s on Diorama" % new_instance.character_class)
	chara_spawn.add_child(new_instance)