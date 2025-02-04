extends Control

var selected_class: CharacterInstance = null
var selected_skin: String = "default"

@onready var css_hex_grid: CSSHexagonGrid = $"%CSSHexagonGrid"
@onready var char_title: Label = $"%CharacterTitle"
@onready var char_subtitle: Label = $"%CharacterSubtitle"
@onready var char_description: RichTextLabel = $"%CharacterDescription"

func _ready():
	if ClassLoader.setup_is_finished == false:
		ClassLoader.finished_setup.connect(build_css())
	else:
		build_css()

func build_css():
	css_hex_grid.build_grid(ClassLoader.classes)
	css_hex_grid.selected_class.connect(select_class)
	select_random_class()


func select_class(_selected_class: CharacterInstance):
	if _selected_class == null:
		select_random_class()
		return
	selected_class = _selected_class
	print_debug("Class selected : %s" % selected_class)
	build_3d()
	fill_data()


## Get a random key from keys() then use that
## If the random class is the currently selected one, we roll again, but no more than 5 times to avoid infinite loop in the case there is only one class.
func select_random_class():
	var i: int = 0
	var rando_class = ClassLoader.classes[ClassLoader.classes.keys().pick_random()]
	while rando_class == selected_class:
		rando_class = ClassLoader.classes[ClassLoader.classes.keys().pick_random()]
		i += 1
		if i > 4:
			break
	select_class(rando_class)

func build_3d():
	pass

func fill_data():
	char_title.text = selected_class.character_class.to_pascal_case()
	char_subtitle.text = selected_class.subtitle
	char_description.text = selected_class.description
