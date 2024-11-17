extends Node

var MAIN_SEED: String = ''
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_seeds()

func generate_seeds():
	if (MAIN_SEED == ''):
		rng.randomize()
		rng.seed = hash(rng.randi())
		MAIN_SEED = str(rng.seed)
		print_debug(MAIN_SEED)
	else:
		rng.seed = int(MAIN_SEED)

func reset_seeds():
	MAIN_SEED = ''
	generate_seeds()
