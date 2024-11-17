extends Control

@onready var gen_btn: Button = $"%RandomiseBtn"
@onready var seed_display: Label = $"%SeedDisplay"
@onready var procgen: ProceduralGenerator = $ProceduralGenerator
@onready var continentalnessTexture: TextureRect = $"%Continentalness"
@onready var erosionTexture: TextureRect = $"%Erosion"
@onready var peaksTexture: TextureRect = $"%Peaks"
@onready var temperatureTexture: TextureRect = $"%Temperature"
@onready var humidityTexture: TextureRect = $"%Humidity"


# Called when the node enters the scene tree for the first time.
func _ready():
	continentalnessTexture.texture = procgen.continentalness
	erosionTexture.texture = procgen.erosion
	peaksTexture.texture = procgen.peaks_valley
	temperatureTexture.texture = procgen.temperature
	humidityTexture.texture = procgen.humidity
	gen_btn.pressed.connect(_gen_button_pressed)


func _gen_button_pressed():
	procgen.generate_noise()
	seed_display.text = RngHandler.MAIN_SEED