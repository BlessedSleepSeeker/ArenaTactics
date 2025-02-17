extends PanelContainer
class_name ActionTooltip

@export var action: GameplayAction = null
	# set(value):
	# 	action = value
	# 	build()

@export var img_tags_template: String = "[img]%s[/img]"

@onready var icon: TextureRect = %"IconRect"
@onready var title: IconRichTextLabel = %"TitleLabel"
@onready var description: IconRichTextLabel = %"DescriptionLabel"

@onready var cost: IconRichTextLabel = %"CostLabel"

@export var targeting_template: String = "[img]range_eye[/img] %d"
@onready var targeting: IconRichTextLabel = %"TargetingLabel"

@onready var pathfinding: IconRichTextLabel = %"PathFindingLabel"
@onready var pathfinding_sep: HSeparator = %"PathFindingSeparator"

@onready var effects: IconRichTextLabel = %"EffectLabel"



func _ready():
	build()

func build():
	if action:
		icon.texture = action.icon
		title.text = action.name
		cost.parse_and_set_text(build_cost())
		if action.targeting_restrictions:
			targeting.parse_and_set_text(build_targeting())
			if action.targeting_restrictions.pathfinder_settings:
				pathfinding.parse_and_set_text(build_pathfinding())
				pathfinding.show()
				pathfinding_sep.show()
			else:
				pathfinding.hide()
				pathfinding_sep.hide()
		if action is BasicOffensiveAction:
			effects.parse_and_set_text(build_effects())
			effects.show()
		else:
			effects.hide()
		#description.text = action.description

func build_cost() -> String:
	var ap_cost: String = "%s %d %s" % [encase_in_color("Cost", Color.SLATE_GRAY), action.ap_cost, build_img("ap_star")]
	var noise: String = "%s %d %s" % [encase_in_color("Self Noise", Color.SLATE_GRAY), action.noise_level_actor, build_img("actor_sound")]
	if action.noise_level_target != 0:
		noise += "\n%s %d %s" % [encase_in_color("Target Noise", Color.SLATE_GRAY), action.noise_level_target, build_img("target_sound")]
	var cooldown: String = ""
	if action.cooldown != 0:
		cooldown = "%s %d %s\n" % [encase_in_color("Cooldown", Color.SLATE_GRAY), action.cooldown, build_img("cooldown_time")]
	var max_use_per_turn: String = ""
	if action.max_use_per_turn != 0:
		max_use_per_turn = "%s %d %s\n" % [encase_in_color("Max use per turn", Color.SLATE_GRAY), action.max_use_per_turn, build_img("cooldown_time")]
	return "%s\n%s\n%s%s" % [ap_cost, noise, cooldown, max_use_per_turn]

func build_targeting() -> String:
	var _range: String = "%s %d" % [encase_in_color("Range", Color.SLATE_GRAY), action.targeting_restrictions.min_range]
	if action.targeting_restrictions.max_range != action.targeting_restrictions.min_range:
		_range += " - %d" % [action.targeting_restrictions.max_range]
	_range += "%s\n" % build_img("range_eye")
	
	var line_of_sight: String = ""
	if action.targeting_restrictions.line_of_sight:
		line_of_sight = "%s\n" % [encase_in_color("No Line of Sight", Color.SLATE_GRAY)]
	
	var aligned: String = ""
	if action.targeting_restrictions.aligned:
		aligned = "%s\n" % [encase_in_color("Must Be In Line", Color.SLATE_GRAY)]
	
	var must_be_empty: String = ""
	if action.targeting_restrictions.must_be_empty:
		must_be_empty = "%s\n" % [encase_in_color("Tile Must Be Empty", Color.SLATE_GRAY)]
	return _range + line_of_sight + aligned + must_be_empty

func build_pathfinding() -> String:
	var max_distance: String = "%s %d %s\n" % [encase_in_color("Maximum PathFinding Distance", Color.SLATE_GRAY), action.targeting_restrictions.pathfinder_settings.max_distance, build_img("path_distance")]
	if action.targeting_restrictions.pathfinder_settings.max_distance == -1:
		max_distance = "%s %s %s\n" % [encase_in_color("Maximum PathFinding Distance", Color.SLATE_GRAY), "Infinite", build_img("path_distance")]

	var elevation_difference_tolerated_between_neighbors: String = "%s %d %s\n" % [encase_in_color("Tiles Elevation Difference Tolerated", Color.SLATE_GRAY), action.targeting_restrictions.pathfinder_settings.elevation_difference_tolerated_between_neighbors, build_img("elevation_difference")]
	if action.targeting_restrictions.pathfinder_settings.elevation_difference_tolerated_between_neighbors == -1:
		elevation_difference_tolerated_between_neighbors = "%s %s %s\n" % [encase_in_color("Tiles Elevation Difference Tolerated", Color.SLATE_GRAY), "Infinite", build_img("elevation_difference")]

	var allow_non_empty_tile_as_path: String = ""
	if action.targeting_restrictions.pathfinder_settings.allow_non_empty_tile_as_path:
		allow_non_empty_tile_as_path = "%s" % [encase_in_color("Non-Empty Tile Allowed", Color.SLATE_GRAY)]
	return max_distance + elevation_difference_tolerated_between_neighbors + allow_non_empty_tile_as_path

func build_effects() -> String:
	var target_eff: String = ""
	if action.target_effect:
		var start_target_zone: String =  "%s\n" % [encase_in_color("On Target", Color.SLATE_GRAY)]
		var target_effects: String = build_effect(action.target_effect)
		target_eff = start_target_zone + target_effects
	var self_eff: String = ""
	if action.actor_effect:
		var start_self_zone: String =  "%s\n" % [encase_in_color("On Self", Color.SLATE_GRAY)]
		var self_effects: String = build_effect(action.actor_effect)
		self_eff = start_self_zone + self_effects
	return target_eff + self_eff

func build_effect(effect: OffensiveActionEffect) -> String:
	var dmg_nbr: String = "%d to %d" % [abs(effect.min_damage), abs(effect.max_damage)] if effect.max_damage != effect.min_damage else "%d" % abs(effect.min_damage)

	var damages = "%s %s %s\n" % [build_img("heart"), dmg_nbr, "Damage(s)" if effect.min_damage >= 0 else "Heal"]

	var crits: String = "%s\n" % encase_in_color("Can't Crit", Color.SLATE_GRAY)
	if effect.crit_chance >= 0:
		crits = "%s %d%% x%d Multiplier\n" % [build_img("crit"), effect.crit_multiplier, effect.crit_chance]

	var backstabs: String = ""
	if effect.backstab_multiplier != 1:
		backstabs = "%s x%d Multiplier\n" % [build_img("backstab"), effect.backstab_multiplier]

	return damages + crits + backstabs

func build_img(img_name: String) -> String:
	return img_tags_template % img_name


func encase_in_color(text: String, color: Color) -> String:
	return "[color=%s]%s[/color]" % [color.to_html(), text]