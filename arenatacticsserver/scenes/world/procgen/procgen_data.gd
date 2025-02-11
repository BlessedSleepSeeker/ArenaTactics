extends Node
class_name ProceduralGenerator

@export var WORLD_MIN_HEIGHT: int = 1
@export var WORLD_MAX_HEIGHT: int = 150

@onready var continentalness: NoiseTexture2D = preload("res://scenes/world/procgen/continentalness/continentalness.tres")
@onready var erosion: NoiseTexture2D = preload("res://scenes/world/procgen/erosion/erosion.tres")
@onready var peaks_valley: NoiseTexture2D = preload("res://scenes/world/procgen/peaks/peaks.tres")
@onready var temperature: NoiseTexture2D = preload("res://scenes/world/procgen/temperature/temperature.tres")
@onready var humidity: NoiseTexture2D = preload("res://scenes/world/procgen/humidity/humidity.tres")

@onready var c_curve: Curve = preload("res://scenes/world/procgen/continentalness/continentalness_curve.tres")
@onready var e_curve: Curve = preload("res://scenes/world/procgen/erosion/erosion_curve.tres")
@onready var p_curve: Curve = preload("res://scenes/world/procgen/peaks/peaks_curve.tres")
@onready var t_curve: Curve = preload("res://scenes/world/procgen/temperature/temperature_curve.tres")
@onready var h_curve: Curve = preload("res://scenes/world/procgen/humidity/humidity_curve.tres")
@onready var islandism_curve: Curve = preload("res://scenes/world/procgen/islandism/islandism_curve.tres")

var continentalness_data: Image
var erosion_data: Image
var peaks_valley_data: Image
var temperature_data: Image
var humidity_data: Image

var setup_is_finished: bool = false
signal finished_setup

# Called when the node enters the scene tree for the first time.
func _ready():
	RngHandler.main_seed_changed.connect(_on_main_seed_changed)


func update_seeds(new_value: int) -> void:
	setup_is_finished = false
	set_noise_seed(continentalness, new_value)
	await continentalness.changed
	continentalness_data = continentalness.get_image()

	set_noise_seed(erosion, new_value)
	await erosion.changed
	erosion_data = erosion.get_image()

	set_noise_seed(peaks_valley, new_value)
	await peaks_valley.changed
	peaks_valley_data = peaks_valley.get_image()

	set_noise_seed(temperature, new_value)
	await temperature.changed
	temperature_data = temperature.get_image()

	set_noise_seed(humidity, new_value)
	await humidity.changed
	humidity_data = humidity.get_image()

	finished_setup.emit()
	setup_is_finished = true
	#print_debug("set seed to %s" % RngHandler.MAIN_SEED)


func set_noise_seed(texture: NoiseTexture2D, new_value: int) -> void:
	texture.noise.seed = new_value


func set_elevation_for_tile(hex_tile: HexTile, full_size_x: int, full_size_y: int) -> float:
	hex_tile.continentalness = c_curve.sample(continentalness_data.get_pixel(hex_tile.grid_coordinate.x, hex_tile.grid_coordinate.y).v)
	hex_tile.peaks_valley = p_curve.sample(peaks_valley_data.get_pixel(hex_tile.grid_coordinate.x, hex_tile.grid_coordinate.y).v)
	hex_tile.erosion = e_curve.sample(erosion_data.get_pixel(hex_tile.grid_coordinate.x, hex_tile.grid_coordinate.y).v)
	#print_debug("%d:%d = %f %f %f" % [hex_tile.grid_coordinate.x, hex_tile.grid_coordinate.y, hex_tile.continentalness, hex_tile.peaks_valley, hex_tile.erosion])
	
	# Distance from grid edge.
	var nx = pow(2 * float(hex_tile.grid_coordinate.x) / full_size_x - 1, 2)
	var ny = pow(2 * float(hex_tile.grid_coordinate.y) / full_size_y - 1, 2)
	hex_tile.distance = 1 - (1 - nx) * (1 - ny)
	hex_tile.islandism = islandism_curve.sample(hex_tile.distance)
	var algo = (hex_tile.continentalness - hex_tile.erosion) + hex_tile.peaks_valley
	return clampi(int(algo), WORLD_MIN_HEIGHT, WORLD_MAX_HEIGHT)


func _on_main_seed_changed(new_value):
	update_seeds(int(new_value))
