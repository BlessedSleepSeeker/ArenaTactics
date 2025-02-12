extends Resource
class_name OffensiveActionEffect

var name = "OffensiveActionEffect"

## The maximum amount of HP removed from the target. If max_damage is negative, it will heal.
@export var max_damage: int = 0
## The minimum amount of HP removed from the target. If max_damage is negative, it will heal.
@export var min_damage: int = 0
## The Critical Strike Chance in %. 0 == can't crit, 100 == always crit.
@export var crit_chance: int = 0
## The Critical Damage Multiplier.
@export var crit_multiplier: float = 1.0
## The Backstab Damage Multiplier.
@export var backstab_multiplier: float = 1.0

func _init(_data: Dictionary):
	parse_data(_data)


func parse_data(data: Dictionary) -> void:
	for key in data:
		add_data_to_var(key, data[key])

func apply_effect(target: CharacterInstance, is_backstab: bool):
	deal_damage(target, is_backstab)
	apply_status(target, is_backstab)

func deal_damage(target: CharacterInstance, is_backstab: bool):
	var stats: StatisticsModule = target.get_module_by_name("Statistics")
	if stats:
		stats.current_health = stats.current_health - calculate_damage(target, stats, is_backstab)

func calculate_damage(_target: CharacterInstance, _stats: StatisticsModule, is_backstab: bool) -> int:
	## TODO : Add replay-compatible RNG here between min/max_damage.
	var damage: float = max_damage
	## TODO : add replay-compatible crit RNG here.
	if is_backstab:
		damage =  max_damage * backstab_multiplier
	## TODO : calculate resistances from stats here
	## TODO : calculate resistances from status effects here
	return roundi(damage)
	#var attack_damage = roundi()

func apply_status(target: CharacterInstance, is_backstab: bool):
	pass

#region Helpers
func is_match(match: String, key) -> bool:
	return key is String && key.contains(match)

func is_match_and_path_exist(match: String, key, value) -> bool:
	return key is String && key.contains(match) && value is String && FileAccess.file_exists(value)

func add_data_to_var(var_name: String, var_value: Variant):
	if var_name in self:
		self.set(var_name, var_value)
	else:
		push_error(DebugHelper.format_debug_string(self, "ERROR", "Can't set {%s.%s} : Member variable not found" % [self.name, var_name]))
#endregion