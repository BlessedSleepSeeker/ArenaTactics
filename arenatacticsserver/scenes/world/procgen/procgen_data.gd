extends Node
class_name ProceduralGenerator


@onready var continentalness: NoiseTexture2D = preload("res://scenes/world/procgen/continentalness/continentalness.tres")
@onready var erosion: NoiseTexture2D = NoiseTexture2D.new()
@onready var peaks_valley: NoiseTexture2D = NoiseTexture2D.new()
@onready var temperature: NoiseTexture2D = NoiseTexture2D.new()
@onready var humidity: NoiseTexture2D = NoiseTexture2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func generate_noise() -> void:
	pass

func load_noise(texture: NoiseTexture2D) -> bool:
	texture.noise = FastNoiseLite.new()
	await texture.changed
	texture.noise.seed = int(RngHandler.MAIN_SEED)
	print_debug(texture.noise.seed)
	return true
