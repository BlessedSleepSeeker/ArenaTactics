extends Node
class_name ProceduralGenerator


@onready var continentalness: NoiseTexture2D = preload("res://scenes/world/procgen/continentalness/continentalness.tres")
@onready var erosion: NoiseTexture2D = preload("res://scenes/world/procgen/erosion/erosion.tres")
@onready var peaks_valley: NoiseTexture2D = preload("res://scenes/world/procgen/peaks/peaks.tres")
@onready var temperature: NoiseTexture2D = preload("res://scenes/world/procgen/temperature/temperature.tres")
@onready var humidity: NoiseTexture2D = preload("res://scenes/world/procgen/humidity/humidity.tres")

var continentalness_data: PackedByteArray
var erosion_data: PackedByteArray
var peaks_valley_data: PackedByteArray
var temperature_data: PackedByteArray
var humidity_data: PackedByteArray

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
	print_debug(texture.noise.seed)


func setup_elevation():
	var cont_image = continentalness.get_image()
	var cont_data = cont_image.get_data()

func get_elevation_for_point():
	pass