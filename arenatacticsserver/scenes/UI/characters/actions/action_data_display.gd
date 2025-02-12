extends RichTextLabel
class_name ActionDataDisplay

@export var action: GameplayAction = null:
	set(value):
		if value:
			action = value
			_build()


func _build():
	pass
