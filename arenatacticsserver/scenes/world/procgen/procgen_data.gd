extends Node
class_name ProceduralGenerator


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

var continentalness_data: Image
var erosion_data: Image
var peaks_valley_data: Image
var temperature_data: Image
var humidity_data: Image

signal finished_setup

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func generate_noise() -> void:
	RngHandler.reset_seeds()
	set_seed_noise(continentalness)
	set_seed_noise(erosion)
	set_seed_noise(peaks_valley)
	set_seed_noise(temperature)
	set_seed_noise(humidity)
	print_debug("set seed to %s" % RngHandler.MAIN_SEED)

func set_seed_noise(texture: NoiseTexture2D) -> void:
	texture.noise.seed = int(RngHandler.MAIN_SEED)


func setup_elevation():
	await continentalness.changed
	continentalness_data = continentalness.get_image()

	await erosion.changed
	erosion_data = erosion.get_image()

	await peaks_valley.changed
	peaks_valley_data = peaks_valley.get_image()

	await temperature.changed
	temperature_data = temperature.get_image()

	await humidity.changed
	humidity_data = humidity.get_image()

	finished_setup.emit()


func get_elevation_for_point(x: int, y: int) -> float:
	var base = c_curve.sample(continentalness_data.get_pixel(x, y).v)
	var eroded = e_curve.sample(erosion_data.get_pixel(x, y).v) * -1
	var peaks = p_curve.sample(peaks_valley_data.get_pixel(x, y).v)
	return abs(base + eroded + peaks)
