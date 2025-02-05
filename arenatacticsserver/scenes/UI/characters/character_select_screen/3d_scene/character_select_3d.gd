extends Node3D
class_name CharacterSelect3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var chara_spawn: Node3D = $"%CharacterSpawnPoint"

func _ready():
	pass

func build(class_def: ClassDefinition):
	reset_diorama()
	spawn_diorama(class_def)

func reset_diorama():
	# fade anim here
	# camera movement/blur ?
	for child in chara_spawn.get_children():
		child.queue_free()

func spawn_diorama(class_def: ClassDefinition):
	# fade in here/play fade out in reverse
	var new_instance = class_def.instantiate()
	print_debug("Spawing %s on Diorama" % new_instance.character_class)
	chara_spawn.add_child(new_instance)
