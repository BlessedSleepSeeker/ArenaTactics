extends Node3D
class_name HexGrid

enum GenerationAlgorithm {GRID, CIRCLE}
## Grid create a square grid.
## Circle create multiples concentric circles from a center. Circle is a lot slower and use (limited) recursivity.
@export var generation_algorithm: GenerationAlgorithm
@export var tile_size: float = 1.0

## In Grid Mode, define the amount of tile per "line". In Circle mode, define the amount of concentric circles.
@export var grid_size_x: int = 50 #vertical
## In Grid Mode, define the amount of "line" per grid. In Circle Mode, does nothing.
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
		child.free()

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

## Create the original tile at the center of the circle
## Find all its neighbors.
## Create all neighbors necessary.
## Repeat with the new neighbors.
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
		prev_circle_tiles = await generate_circle(i, prev_circle_tiles)

func get_circle_starting_position():
	return Vector2i(grid_size_x, grid_size_y)

func generate_circle(circle_number: int, prev_circle_tiles: Array[HexTile]) -> Array[HexTile]:
	var new_tiles: Array[HexTile] = []
	
	if prev_circle_tiles.is_empty():
		return []
	var potential_positions: Array[Vector2i] = []
	var unique_positions: Array[Vector2i] = []
	var i: int = 0
	for prev_tile in prev_circle_tiles:
		if circle_number >= 2 && i == 0:
			potential_positions.append_array(prev_tile.get_first_neighbors_position())
		elif circle_number >= 2 && i == prev_circle_tiles.size() - (circle_number - 1):
			potential_positions.append_array(prev_tile.get_last_neighbors_position())
		else:
			potential_positions.append_array(prev_tile.get_neighbors_position())
		i += 1
	## Clear any duplicates && remove existing tile positions
	for potential_position in potential_positions:
		if not unique_positions.has(potential_position) && not does_tile_exist_at_position(potential_position):
			unique_positions.append(potential_position)
	## Now that our pos are cleaned, we can generate tiles at the right spots
	for unique_pos in unique_positions:
		var new_tile = generate_tile(unique_pos)
		new_tiles.append(new_tile)
		if timer_between_tile > 0:
			await get_tree().create_timer(timer_between_tile).timeout
	return new_tiles

func does_tile_exist_at_position(grid_pos: Vector2i) -> bool:
	for child: HexTile in self.get_children():
		if child.grid_coordinate.x == grid_pos.x && child.grid_coordinate.y == grid_pos.y:
			return true
	return false

## The circle expand at a +6 per circle since we have hexagons
func calculate_tile_amount_per_circle(circle_number: int) -> int:
	if circle_number == 0:
		return 1
	return 6 * circle_number

func generate_tile(grid_pos: Vector2i) -> HexTile:
	var inst: HexTile = tile_scene.instantiate()
	inst.grid_coordinate.x = grid_pos.x
	inst.grid_coordinate.y = grid_pos.y
	if not flat_world:
		inst.height = ProcGen.set_elevation_for_tile(inst, grid_size_x, grid_size_y)
	# putting the tile at the right place in the grid
	var pos = calculate_tile_distribution(inst)
	inst.position = pos
	inst.interactive = interactive_grid
	inst.hover_enter.connect(_on_tile_hovered)
	self.add_child(inst)
	return inst

## Does not handle well negative X
func calculate_tile_distribution(hex_tile: HexTile) -> Vector3:
	var y_spacing: float = (3.0/4.0 * hex_tile.radius)
	var y_pos: float = 2 * y_spacing * hex_tile.grid_coordinate.y
	
	var x_spacing: float =  hex_tile.radius * sqrt(3)
	var x_pos: float = x_spacing * hex_tile.grid_coordinate.x
	var x_offset: float = x_spacing / 2.0 if abs(hex_tile.grid_coordinate.y) % 2 == 1 else 0.0

	var x_result = x_pos + x_offset #if hex_tile.grid_coordinate.y >= 0 else x_pos - x_offset

	return Vector3(x_result, 0, y_pos)

#endregion

#region GridAnimation
func fade(out: bool = true) -> void:
	for tile: HexTile in get_children():
		if tile.anim_player:
			if out:
				tile.anim_player.stop(true)
				tile.anim_player.play_backwards("tile_animation_library/fade_in")
			else:
				tile.anim_player.stop(true)
				tile.anim_player.play("tile_animation_library/fade_in")
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile).timeout
	await get_tree().create_timer(1.0).timeout
	if out:
		fade_out_finished.emit()
	else:
		fade_in_finished.emit()

func queue_grid_anim(anim_name: String, wait_mult: float = 1) -> void:
	for tile: HexTile in get_children():
		if tile.anim_player:
			if tile.anim_player.has_animation(anim_name):
				tile.anim_player.queue(anim_name)
			if timer_between_tile > 0:
				await get_tree().create_timer(timer_between_tile * wait_mult).timeout

func update_tiles_animations_colors(colors: Dictionary):
	var tile: HexTile = self.get_children().front()
	if tile:
		tile.update_animations_colors(colors)

#endregion

func get_camera_start_point() -> Vector3:
	match generation_algorithm:
		GenerationAlgorithm.CIRCLE:
			return Vector3(grid_size_x, 0, grid_size_x)
		_:
			return Vector3(float(grid_size_x) / 2, 0, float(grid_size_y) / 2)

func get_center_tile() -> HexTile:
	for tile: HexTile in self.get_children():
		if generation_algorithm == GenerationAlgorithm.CIRCLE:
			return get_tile_at_pos(Vector2i(grid_size_x, grid_size_x))
		elif generation_algorithm == GenerationAlgorithm.GRID:
			return get_tile_at_pos(Vector2i(ceil(float(grid_size_x) / 2), ceil(float(grid_size_y) / 2)))
	return null


func get_tile_at_pos(_position: Vector2i) -> HexTile:
	for tile: HexTile in self.get_children():
		if tile.grid_coordinate.x == _position.x && tile.grid_coordinate.y == _position.y:
			return tile
	return null


func _on_tile_hovered(hex_tile: HexTile):
	tile_hovered.emit(hex_tile)

# unselect the old tile first
func set_selected_tile(hex_tile: HexTile):
	if not self.interactive_grid:
		return
	if self.selected_tile && is_instance_valid(self.selected_tile):
		self.selected_tile.set_unselected()
	self.selected_tile = hex_tile
	hex_tile.set_selected()
	tile_clicked.emit(hex_tile)
