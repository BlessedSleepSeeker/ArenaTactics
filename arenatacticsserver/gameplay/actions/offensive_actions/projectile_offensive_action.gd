extends BasicOffensiveAction
class_name ProjectileOffensiveAction

@export var projectile: PackedScene = null

func _init(instance: CharacterInstance, _data: Dictionary, _name: String):
	super(instance, _data, _name)
