extends Node3D
class_name HexGrid

enum GenerationAlgorithm {CLASSIC, CIRCLE}
## Classic create a square grid.
## Circle create multiples concentric circles from a center. Circle is a lot slower and use (limited) recursivity.
@export var generation_algorithm: GenerationAlgorithm
@export var tile_size: float = 1.0

## In Classic Mode, define the amount of tile per "line". In Circle mode, define the amount of concentric circles.
@export var grid_size_x: int = 50 #vertical
## In Classic Mode, define the amount of "line" per grid. In Circle Mode, does nothing.
@export var grid_size_y: int = 50 #horizontal
## Delay each tile spawn by this amount (in seconds).
@export var timer_between_tile: float = 0.01

## Enable or Disable elevation variation from Noise-Based Textures (See ProceduralGenerator).
@export var flat_world: bool = false

## Enable or Disable grid interactivity via not connecting signals.
@export var interactive_grid: bool = true


## The tile that is going to be generated
@export var tile_scene: PackedScene = preload("res://scenes/world/HexTile.tscn")

signal tile_hovered(hex_tile: HexTile)
signal tile_clicked(hex_tile: HexTile)
signal generation_finished
signal fade_in_finished
signal fade_out_finished

var selected_tile: HexTile = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#region Grid Generation
func free_grid() -> void:
	for child in self.get_children():
		child.queue_free()

func generate_grid() -> void:
	if not flat_world:
		if not ProcGen.setup_is_finished:
			ProcGen.finished_setup.connect(_generate_grid)
		else:
			_generate_grid()
	else:
		_generate_grid()
	generation_finished.emit()

func _generate_grid() -> void:
	match generation_algorithm:
		GenerationAlgorithm.CIRCLE:
			generate_circle_grid()
		_:
			generate_square_grid()

func generate_square_grid() -> void:
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			generate_tile(Vector2i(i, j))
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile).timeout

func generate_circle_grid() -> void:
	if grid_size_x <= 0:
		push_error("HexGrid size X can't be under 0 when generating a circle")
		return
	grid_size_y = grid_size_x
	var prev_circle_tiles: Array[HexTile] = []
	for i in range(grid_size_x):
		if i == 0:
			var first_tile: HexTile = generate_tile(get_circle_starting_position())
			prev_circle_tiles.append(first_tile)
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile).timeout
			continue
		prev_circle_tiles = await generate_circle(prev_circle_tiles, Color(255, 255, 10 * i))

func get_circle_starting_position():
	return Vector2i(ceil(float(grid_size_x) / 2), ceil(float(grid_size_y) / 2))

func generate_circle(prev_circle_tiles: Array[HexTile], tile_color: Color) -> Array[HexTile]:
	var new_tiles: Array[HexTile] = []
	if prev_circle_tiles.is_empty():
		return []
	for prev_tile in prev_circle_tiles:
		var potentials_position = prev_tile.get_neighbors_position()
		for potential_position in potentials_position:
			if not does_tile_exist_at_position(potential_position):
				var new_tile = generate_tile(potential_position)
				new_tile.set_color(tile_color)
				new_tiles.append(new_tile)
				if timer_between_tile > 0:
					await get_tree().create_timer(timer_between_tile).timeout
	return new_tiles

func does_tile_exist_at_position(grid_pos: Vector2i) -> bool:
	for child: HexTile in self.get_children():
		if child.grid_pos_x == grid_pos.x && child.grid_pos_y == grid_pos.y:
			return true
	return false

## The circle expand at a +6 per circle since we have hexagons
func calculate_tile_amount_per_circle(circle_number: int) -> int:
	if circle_number == 0:
		return 1
	return 6 * circle_number

func generate_tile(grid_pos: Vector2i) -> HexTile:
	var inst: HexTile = tile_scene.instantiate()
	inst.grid_pos_x = grid_pos.x
	inst.grid_pos_y = grid_pos.y
	if not flat_world:
		inst.height = ProcGen.set_elevation_for_tile(inst, grid_size_x, grid_size_y)
	# putting the tile at the right place in the grid
	var pos = calculate_tile_distribution(inst)
	inst.position = pos
	inst.interactive = interactive_grid
	inst.hover_enter.connect(_on_tile_hovered)
	self.add_child(inst)
	return inst

func calculate_tile_distribution(hex_tile: HexTile) -> Vector3:
	var vertical_spacing: float =  hex_tile.radius * sqrt(3)
	var vertical_pos: float = vertical_spacing * hex_tile.grid_pos_x
	var horizontal_spacing: float = (3.0/4.0 * hex_tile.radius)
	var horizontal_pos: float = 2 * horizontal_spacing * hex_tile.grid_pos_y
	var vert_offset: float = vertical_spacing / 2.0 if hex_tile.grid_pos_y % 2 == 1 else 0.0

	var vert_result = vertical_pos + vert_offset if hex_tile.grid_pos_y >= 0 else vertical_pos - vert_offset

	return Vector3(vert_result, 0, horizontal_pos)

func calculate_tile_number(x: int, y: int) -> int:
	return y + (x * grid_size_y)

#endregion

#region GridAnimation
func fade(out: bool = true) -> void:
	for tile: HexTile in get_children():
		if tile.has_node("AnimationPlayer"):
			var node_anim_player: AnimationPlayer = tile.get_node("AnimationPlayer")
			if out:
				node_anim_player.stop(true)
				node_anim_player.play_backwards("fade_in")
			else:
				node_anim_player.stop(true)
				node_anim_player.play("fade_in")
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile).timeout
	await get_tree().create_timer(1.0).timeout
	if out:
		fade_out_finished.emit()
	else:
		fade_in_finished.emit()

func queue_grid_anim(anim_name: String, wait_mult: float = 1) -> void:
	for tile: HexTile in get_children():
		if tile.has_node("AnimationPlayer"):
			var node_anim_player: AnimationPlayer = tile.get_node("AnimationPlayer")
			if node_anim_player.has_animation(anim_name):
				node_anim_player.queue(anim_name)
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile * wait_mult).timeout
#endregion

func _on_tile_hovered(hex_tile: HexTile):
	tile_hovered.emit(hex_tile)

# unselect the old tile first
func set_selected_tile(hex_tile: HexTile):
	if self.selected_tile && is_instance_valid(self.selected_tile):
		self.selected_tile.set_unselected()
	self.selected_tile = hex_tile
	hex_tile.set_selected()
	tile_clicked.emit(hex_tile)
