extends VBoxContainer
class_name TileDebugContainer

@export var debug_data_string_template: String = "[b]%s[/b] = %f"

func load_debug_data(hex_tile: HexTileCube):
	# don't bother if it's not visible
	if self.visible == false:
		return
	for child in get_children():
		child.queue_free()

	var debug_data = hex_tile.serialize_debug_data()
	for field in debug_data:
		var rich_label = RichTextLabel.new()
		rich_label.bbcode_enabled = true
		rich_label.fit_content = true
		rich_label.text = debug_data_string_template % [field, debug_data[field]]
		add_child(rich_label)
