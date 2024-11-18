extends Control
class_name ServerUI

@onready var gen_btn: Button = $"%RandomiseBtn"
@onready var noise_container: ScrollContainer = $"%NoiseTextureContainer"
@onready var showhide_btn: Button = $"%ShowHideUIButton"

@onready var seed_display: Label = $"%SeedDisplay"
@onready var continentalnessTexture: TextureRect = $"%Continentalness"
@onready var erosionTexture: TextureRect = $"%Erosion"
@onready var peaksTexture: TextureRect = $"%Peaks"
@onready var temperatureTexture: TextureRect = $"%Temperature"
@onready var humidityTexture: TextureRect = $"%Humidity"

signal generate_world

# Called when the node enters the scene tree for the first time.
func _ready():
	continentalnessTexture.texture = ProcGen.continentalness
	erosionTexture.texture = ProcGen.erosion
	peaksTexture.texture = ProcGen.peaks_valley
	temperatureTexture.texture = ProcGen.temperature
	humidityTexture.texture = ProcGen.humidity
	
	gen_btn.pressed.connect(_gen_button_pressed)
	showhide_btn.pressed.connect(_showhide_noise)
	
	RngHandler.main_seed_changed.connect(_update_seed_number)


func _gen_button_pressed():
	generate_world.emit()
	

func _showhide_noise():
	noise_container.visible = !noise_container.visible


func _update_seed_number(new_value: String):
	seed_display.text = new_value