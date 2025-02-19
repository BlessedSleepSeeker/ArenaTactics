extends Node3D
class_name HexGridCube
## HexGrid using a Cube coordinate system.


enum GenerationAlgorithm {GRID, CIRCLE}
## Grid create a square grid.
## Circle create multiples concentric circles from a center. Circle is a lot slower and use (limited) recursivity.
@export var generation_algorithm: GenerationAlgorithm
## Delay each tile spawn by this amount (in seconds).
@export_range(0, 5, 0.01, "or_greater") var tile_spawn_delay: float = 0.0

## Enable or disable elevation variation from Noise-Based Textures (See [ProceduralGenerator]).
@export var flat_world: bool = false
## Enable or disable grid interactivity with signals.
@export var interactive_grid: bool = true
## The tile that is going to be generated
@export var tile_scene: PackedScene = preload("res://scenes/world/tiles/HexTileCube.tscn")

@export_subgroup("Animations")
## Delay each fade animation by this amount (in seconds).
@export_range(0, 5, 0.01, "or_greater") var fade_animation_delay: float = 0.03
## Delay each tile animation by this amount (in seconds).
@export_range(0, 5, 0.01, "or_greater") var tile_animation_delay: float = 0.03
## Delay each grid circle animation by this amount (in seconds).
@export_range(0, 5, 0.01, "or_greater") var circle_animation_delay: float = 0.3

@export_subgroup("Grid Generation Settings")
## Define the amount of tile per "line", AKA Columns.
@export_range(1, 100, 1, "or_greater") var grid_size_x: int = 50:
	set(value):
		if value > 0:
			grid_size_x = value
		else:
			push_error("member HexGridCube.grid_size_x must be superior to 0")
## Define the amount of Line per grid.
@export_range(1, 100, 1, "or_greater") var grid_size_y: int = 50:
	set(value):
		if value > 0:
			grid_size_y = value
		else:
			push_error("member HexGridCube.grid_size_y must be superior to 0")

@export_subgroup("Circle Generation Settings")
## The amount of concentric circles generated.
@export_range(1, 20, 1, "or_greater") var circle_diameter: int = 5:
	set(value):
		if value > 0:
			circle_diameter = value
		else:
			push_error("member HexGridCube.circle_diameter must be > 0.")

var maximum_x_size: int:
	get():
		return get_maximum_size().x

var maximum_y_size: int:
	get():
		return get_maximum_size().y

var circle_rings: Array[Array] = []

signal tile_hovered(hex_tile: HexTileCube)
signal tile_clicked(hex_tile: HexTileCube)
signal fade_in_finished
signal fade_out_finished

var is_generation_finished: bool = false
signal generation_finished

var selected_tile: HexTileCube = null

#region Generation
func free_grid() -> void:
	for child in self.get_children():
		child.free()

func generate_grid() -> void:
	if not flat_world:
		if not ProcGen.setup_is_finished && not ProcGen.finished_setup.is_connected(_generate_grid):
			ProcGen.finished_setup.connect(_generate_grid)
		else:
			await _generate_grid()
	else:
		await _generate_grid()

func _generate_grid() -> void:
	match generation_algorithm:
		GenerationAlgorithm.CIRCLE:
			await generate_circle_grid()
		_:
			await generate_square_grid()

func get_maximum_size() -> Vector2i:
	match generation_algorithm:
		GenerationAlgorithm.CIRCLE:
			return Vector2i((circle_diameter * 2) - 1, (circle_diameter * 2) - 1)
		_:
			return Vector2i(grid_size_x, grid_size_y)


func generate_tile(grid_pos: Vector3i) -> HexTileCube:
	var inst: HexTileCube = tile_scene.instantiate()
	inst.grid_coordinate = grid_pos
	if not flat_world:
		inst.height = ProcGen.set_elevation_for_tile(inst, maximum_x_size, maximum_y_size)
	# putting the tile at the right place in the grid
	var pos = calculate_tile_distribution(inst)
	inst.position = pos
	inst.interactive = interactive_grid
	inst.hover_enter.connect(_on_tile_hovered)
	self.add_child(inst)
	return inst

## Does not handle well negative X. Use offset coordinates. Return a space position.
func calculate_tile_distribution(hex_tile: HexTileCube) -> Vector3:
	var y_spacing: float = (3.0/4.0 * hex_tile.radius)
	var y_pos: float = 2 * y_spacing * hex_tile.offset_grid_coordinate.y

	var x_spacing: float =  hex_tile.radius * sqrt(3)
	var x_pos: float = x_spacing * hex_tile.offset_grid_coordinate.x
	var x_offset: float = x_spacing / 2.0 if abs(hex_tile.offset_grid_coordinate.y) % 2 == 1 else 0.0

	var x_result = x_pos + x_offset #if hex_tile.grid_coordinate.y >= 0 else x_pos - x_offset

	return Vector3(x_result, 0, y_pos)

#region Grid Generation
func generate_square_grid() -> void:
	for i in range(grid_size_x):
		for j in range(grid_size_y):
			generate_tile(HexTileCube.get_cube_coordinate(Vector2i(i, j)))
			if tile_spawn_delay > 0:
				await get_tree().create_timer(tile_spawn_delay).timeout
	is_generation_finished = true
	generation_finished.emit()
#endregion

#region Circle Generation

func generate_circle_grid() -> void:
	if circle_diameter < 0:
		push_error("Circle Diameter can't be under 0 when generating a circle")
		return
	var center_tile = generate_tile(get_circle_starting_position())
	var circle_coordinates = center_tile.get_circle_coordinates(circle_diameter)
	for coord: Vector3i in circle_coordinates:
		generate_tile(coord)
		if tile_spawn_delay > 0:
			await get_tree().create_timer(tile_spawn_delay).timeout
	circle_rings = get_rings(center_tile, circle_coordinates)
	is_generation_finished = true
	generation_finished.emit()
	

func get_rings(center_tile: HexTileCube, coordinates: Array[Vector3i]) -> Array[Array]:
	var rings: Array[Array] = [[center_tile]]
	var remaining_rings = circle_diameter - 1
	for i in range(remaining_rings):
		var tiles_in_ring: Array[HexTileCube] = []
		for j in range(get_tile_count_per_ring(i + 1)):
			tiles_in_ring.append(get_tile_at_cube_coords(coordinates.pop_front()))
		rings.append(tiles_in_ring)
	return rings

func get_tile_count_per_ring(ring_number: int) -> int:
	return ring_number * 6

func get_circle_starting_position() -> Vector3i:
	return HexTileCube.get_cube_coordinate(Vector2i(circle_diameter, circle_diameter))

#enregion

#region Animation
func fade(out: bool = true, fast_forward_to_end: bool = false) -> void:
	for tile: HexTileCube in get_children():
		if tile.anim_player:
			if out:
				tile.anim_player.stop(true)
				tile.anim_player.play_backwards("tile_animation_library/fade_in")
			else:
				tile.anim_player.stop(true)
				tile.anim_player.play("tile_animation_library/fade_in")
			if fast_forward_to_end:
				tile.anim_player.advance(1)
			if fade_animation_delay > 0 && not fast_forward_to_end:
				await get_tree().create_timer(fade_animation_delay).timeout
	await get_tree().create_timer(1.0).timeout
	if out:
		fade_out_finished.emit()
	else:
		fade_in_finished.emit()

## Add an animation to each tile in the hex grid. The animations are played in the generation order and can be delayed with [member HexGridCube.tile_animation_delay] (in seconds).
func queue_grid_anim(anim_name: String) -> void:
	for tile: HexTileCube in get_children():
		if tile.anim_player:
			if tile.anim_player.has_animation(anim_name):
				tile.anim_player.queue(anim_name)
			if tile_animation_delay > 0:
				await get_tree().create_timer(tile_animation_delay).timeout

## Add an animation to each tile in the hex grid.[br]
## The animations of every tiles in a ring are synchronised and each rings trigger can be delayed with [member HexGridCube.tile_animation_delay] (in seconds).[br]
## `reverse_order` make the animation start at the outermost ring if `true`.[br]
## `delay_inside_rings` delay each animation by [member HexGridCube.tile_animation_delay] inside a ring if true.
func queue_rings_anim(anim_name: String, reverse_order: bool = false, delay_inside_rings: bool = false):
	var rings: Array[Array] = circle_rings.duplicate()
	if reverse_order:
		rings.reverse()
	for ring: Array[HexTileCube] in rings:
		for tile: HexTileCube in ring:
			if tile.anim_player:
				if tile.anim_player.has_animation(anim_name):
					tile.anim_player.queue(anim_name)
				if delay_inside_rings && tile_animation_delay > 0:
					await get_tree().create_timer(tile_animation_delay).timeout
		if circle_animation_delay > 0:
			await get_tree().create_timer(circle_animation_delay).timeout

func update_tiles_animations_colors(colors: Dictionary):
	var tile: HexTileCube = self.get_children().front()
	if tile:
		tile.update_animations_colors(colors)


#endregion

func get_camera_start_point() -> Vector3:
	match generation_algorithm:
		GenerationAlgorithm.CIRCLE:
			return Vector3(circle_diameter, 120, circle_diameter)
		_:
			return Vector3(float(grid_size_x) / 2, 120, float(grid_size_y) / 2)

func get_camera_height() -> int:
	var height_array: Array[float] = []
	for child: HexTileCube in get_children():
		height_array.append(child.height)
	return height_array.max() * 1.25


func get_center_tile() -> HexTileCube:
	for tile: HexTileCube in self.get_children():
		match generation_algorithm:
			GenerationAlgorithm.CIRCLE:
				return get_tile_at_offset_coords(Vector2i(circle_diameter, circle_diameter))
			_:
				return get_tile_at_offset_coords(Vector2i(ceil(float(maximum_x_size) / 2), ceil(float(maximum_y_size) / 2)))
	return null

func get_tile_at_offset_coords(_offset_coordinate: Vector2i) -> HexTileCube:
	for tile: HexTileCube in self.get_children():
		if tile.offset_grid_coordinate == _offset_coordinate:
			return tile
	return null

func get_tile_at_cube_coords(_cube_coordinate: Vector3i) -> HexTileCube:
	for tile: HexTileCube in self.get_children():
		if tile.grid_coordinate == _cube_coordinate:
			return tile
	return null


func _on_tile_hovered(hex_tile: HexTileCube):
	tile_hovered.emit(hex_tile)

# unselect the old tile first
func set_selected_tile(hex_tile: HexTileCube):
	if not self.interactive_grid:
		return
	if self.selected_tile && is_instance_valid(self.selected_tile):
		self.selected_tile.set_unselected()
	self.selected_tile = hex_tile
	hex_tile.set_selected()
	tile_clicked.emit(hex_tile)
