extends "res://scripts/player/player_3d_v0533.gd"

const SKILL_IDS_0535 := ["combat", "farming", "medicine", "mechanics", "scavenging"]
const SKILL_NAMES_0535 := {
	"combat": "Combate",
	"farming": "Agricultura",
	"medicine": "Medicina",
	"mechanics": "Mecânica",
	"scavenging": "Vasculhamento"
}
const MAX_SKILL_LEVEL_0535 := 10
const MAX_SURVIVOR_LEVEL_0535 := 30
const SKILL_XP_UNIT_0535 := 50
const SURVIVOR_XP_UNIT_0535 := 120

var skill_xp_0535: Dictionary = {
	"combat": 0,
	"farming": 0,
	"medicine": 0,
	"mechanics": 0,
	"scavenging": 0
}
var skill_levels_0535: Dictionary = {
	"combat": 0,
	"farming": 0,
	"medicine": 0,
	"mechanics": 0,
	"scavenging": 0
}
var total_xp_0535 := 0
var survivor_level_0535 := 1
var progression_actions_0535 := 0
var last_skill_0535 := ""
var last_xp_gain_0535 := 0
var last_level_up_0535 := ""

func _ready() -> void:
	super._ready()
	_ensure_progression_0535()

func _ensure_progression_0535() -> void:
	for skill_id in SKILL_IDS_0535:
		if not skill_xp_0535.has(skill_id):
			skill_xp_0535[skill_id] = 0
		if not skill_levels_0535.has(skill_id):
			skill_levels_0535[skill_id] = 0
	_recalculate_progression_0535()

func _skill_threshold_0535(level: int) -> int:
	if level <= 0:
		return 0
	return int(SKILL_XP_UNIT_0535 * level * (level + 1) / 2)

func _survivor_threshold_0535(level: int) -> int:
	# level 1 é a base. Para chegar ao 2, precisa do primeiro limiar.
	if level <= 1:
		return 0
	var earned_levels := level - 1
	return int(SURVIVOR_XP_UNIT_0535 * earned_levels * (earned_levels + 1) / 2)

func _level_from_skill_xp_0535(xp: int) -> int:
	var level := 0
	for candidate in range(1, MAX_SKILL_LEVEL_0535 + 1):
		if xp < _skill_threshold_0535(candidate):
			break
		level = candidate
	return level

func _level_from_total_xp_0535(xp: int) -> int:
	var level := 1
	for candidate in range(2, MAX_SURVIVOR_LEVEL_0535 + 1):
		if xp < _survivor_threshold_0535(candidate):
			break
		level = candidate
	return level

func _recalculate_progression_0535() -> void:
	var sum_xp := 0
	for skill_id in SKILL_IDS_0535:
		var xp := maxi(0, int(skill_xp_0535.get(skill_id, 0)))
		skill_xp_0535[skill_id] = xp
		skill_levels_0535[skill_id] = _level_from_skill_xp_0535(xp)
		sum_xp += xp
	total_xp_0535 = sum_xp
	survivor_level_0535 = _level_from_total_xp_0535(total_xp_0535)

func award_skill_xp_0535(skill_id: String, amount: int, reason: String = "") -> bool:
	if skill_id not in SKILL_IDS_0535 or amount <= 0:
		return false
	_ensure_progression_0535()
	var before_level := int(skill_levels_0535.get(skill_id, 0))
	skill_xp_0535[skill_id] = int(skill_xp_0535.get(skill_id, 0)) + amount
	progression_actions_0535 += 1
	last_skill_0535 = skill_id
	last_xp_gain_0535 = amount
	last_level_up_0535 = ""
	_recalculate_progression_0535()
	var after_level := int(skill_levels_0535.get(skill_id, 0))
	if after_level > before_level:
		last_level_up_0535 = "%s %d" % [str(SKILL_NAMES_0535.get(skill_id, skill_id)), after_level]
	_request_save_0524()
	return true

func get_skill_level_0535(skill_id: String) -> int:
	_ensure_progression_0535()
	return int(skill_levels_0535.get(skill_id, 0))

func get_skill_xp_0535(skill_id: String) -> int:
	_ensure_progression_0535()
	return int(skill_xp_0535.get(skill_id, 0))

func get_skill_names_0535() -> Dictionary:
	return SKILL_NAMES_0535.duplicate(true)

func get_skill_progress_0535(skill_id: String) -> Dictionary:
	if skill_id not in SKILL_IDS_0535:
		return {}
	var level := get_skill_level_0535(skill_id)
	var xp := get_skill_xp_0535(skill_id)
	var current_threshold := _skill_threshold_0535(level)
	var next_threshold := _skill_threshold_0535(level + 1) if level < MAX_SKILL_LEVEL_0535 else current_threshold
	var ratio := 1.0
	if level < MAX_SKILL_LEVEL_0535 and next_threshold > current_threshold:
		ratio = clampf(float(xp - current_threshold) / float(next_threshold - current_threshold), 0.0, 1.0)
	return {
		"id": skill_id,
		"name": str(SKILL_NAMES_0535.get(skill_id, skill_id)),
		"level": level,
		"xp": xp,
		"current_threshold": current_threshold,
		"next_threshold": next_threshold,
		"ratio": ratio
	}

func get_attribute_snapshot_0535() -> Dictionary:
	_ensure_progression_0535()
	var combat := int(skill_levels_0535.get("combat", 0))
	var farming := int(skill_levels_0535.get("farming", 0))
	var mechanics := int(skill_levels_0535.get("mechanics", 0))
	var scavenging := int(skill_levels_0535.get("scavenging", 0))
	var strength := clampi(5 + int(floor(float(combat) / 2.0)) + int(floor(float(mechanics) / 4.0)), 5, 10)
	var conditioning := clampi(5 + int(floor(float(maxi(0, survivor_level_0535 - 1)) / 3.0)), 5, 10)
	var perception := clampi(5 + int(floor(float(scavenging) / 2.0)) + int(floor(float(farming) / 5.0)), 5, 10)
	return {"strength": strength, "conditioning": conditioning, "perception": perception}

func get_progression_snapshot_0535() -> Dictionary:
	_ensure_progression_0535()
	var skills: Dictionary = {}
	for skill_id in SKILL_IDS_0535:
		skills[skill_id] = get_skill_progress_0535(skill_id)
	var next_survivor := _survivor_threshold_0535(survivor_level_0535 + 1) if survivor_level_0535 < MAX_SURVIVOR_LEVEL_0535 else total_xp_0535
	return {
		"survivor_level": survivor_level_0535,
		"total_xp": total_xp_0535,
		"next_survivor_xp": next_survivor,
		"skills": skills,
		"attributes": get_attribute_snapshot_0535(),
		"actions": progression_actions_0535,
		"last_skill": last_skill_0535,
		"last_gain": last_xp_gain_0535,
		"last_level_up": last_level_up_0535
	}

func get_combat_damage_multiplier_0535() -> float:
	var level := get_skill_level_0535("combat")
	var attributes := get_attribute_snapshot_0535()
	var strength := int(attributes.get("strength", 5))
	return clampf(1.0 + float(level) * 0.035 + float(maxi(0, strength - 5)) * 0.02, 1.0, 1.58)

func get_farming_bonus_yield_0535() -> int:
	return int(floor(float(get_skill_level_0535("farming")) / 3.0))

func get_farming_seed_bonus_0535() -> int:
	var level := get_skill_level_0535("farming")
	if level >= 10:
		return 2
	if level >= 5:
		return 1
	return 0

func get_mechanics_repair_fraction_0535() -> float:
	return clampf(0.30 + float(get_skill_level_0535("mechanics")) * 0.025, 0.30, 0.55)

func get_scavenging_bonus_chance_0535() -> float:
	var level := get_skill_level_0535("scavenging")
	var perception := int(get_attribute_snapshot_0535().get("perception", 5))
	return clampf(0.06 + float(level) * 0.045 + float(maxi(0, perception - 5)) * 0.025, 0.06, 0.66)

func _damage_nearest(max_range: float, damage: float) -> void:
	if world == null or not world.has_method("get_zombies"):
		return
	var nearest: Node3D = null
	var best := max_range
	for candidate in world.call("get_zombies"):
		var zombie := candidate as Node3D
		if zombie == null:
			continue
		var distance := global_position.distance_to(zombie.global_position)
		if distance < best:
			best = distance
			nearest = zombie
	if nearest != null and nearest.has_method("take_damage"):
		nearest.call("take_damage", damage * get_combat_damage_multiplier_0535())
		award_skill_xp_0535("combat", 5, "hit")

func use_inventory_item(id: String) -> bool:
	var medicine_level := get_skill_level_0535("medicine")
	var used := super.use_inventory_item(id)
	if not used:
		return false
	if id == "bandage":
		health = minf(100.0, health + float(medicine_level) * 1.5)
		bleeding_0519 = maxf(0.0, bleeding_0519 - float(medicine_level) * 0.20)
		pain_0519 = maxf(0.0, pain_0519 - float(medicine_level) * 1.4)
		award_skill_xp_0535("medicine", 10, "bandage")
	elif id == "antiseptic":
		infection_0520 = maxf(0.0, infection_0520 - float(medicine_level) * 3.0)
		bleeding_0519 = maxf(0.0, bleeding_0519 - float(medicine_level) * 0.08)
		pain_0519 = maxf(0.0, pain_0519 - float(medicine_level) * 0.9)
		award_skill_xp_0535("medicine", 12, "antiseptic")
	return true

func _apply_equipment_encumbrance_0533(delta: float) -> void:
	var stats := get_equipment_stats_0533()
	var weight := float(stats.get("weight", 0.0))
	if weight <= 4.0:
		return
	var speed := Vector2(velocity.x, velocity.z).length()
	if speed <= 0.25:
		return
	var conditioning := int(get_attribute_snapshot_0535().get("conditioning", 5))
	var mitigation := clampf(1.0 - float(maxi(0, conditioning - 5)) * 0.065, 0.68, 1.0)
	var excess := weight - 4.0
	stamina = maxf(0.0, stamina - excess * 0.18 * delta * mitigation)
	fatigue_0521 = minf(100.0, fatigue_0521 + excess * 0.018 * delta * mitigation)

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["skill_xp_0535"] = skill_xp_0535.duplicate(true)
	state["progression_actions_0535"] = progression_actions_0535
	state["last_skill_0535"] = last_skill_0535
	state["last_xp_gain_0535"] = last_xp_gain_0535
	state["last_level_up_0535"] = last_level_up_0535
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	var raw_xp: Variant = state.get("skill_xp_0535", {})
	skill_xp_0535 = (raw_xp as Dictionary).duplicate(true) if raw_xp is Dictionary else {}
	progression_actions_0535 = int(state.get("progression_actions_0535", 0))
	last_skill_0535 = str(state.get("last_skill_0535", ""))
	last_xp_gain_0535 = int(state.get("last_xp_gain_0535", 0))
	last_level_up_0535 = str(state.get("last_level_up_0535", ""))
	_ensure_progression_0535()

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	skill_xp_0535 = {"combat": 0, "farming": 0, "medicine": 0, "mechanics": 0, "scavenging": 0}
	skill_levels_0535 = {"combat": 0, "farming": 0, "medicine": 0, "mechanics": 0, "scavenging": 0}
	total_xp_0535 = 0
	survivor_level_0535 = 1
	progression_actions_0535 = 0
	last_skill_0535 = ""
	last_xp_gain_0535 = 0
	last_level_up_0535 = ""

func get_progression_debug_0535() -> Dictionary:
	var snapshot := get_progression_snapshot_0535()
	snapshot["combat_multiplier"] = get_combat_damage_multiplier_0535()
	snapshot["farming_bonus"] = get_farming_bonus_yield_0535()
	snapshot["mechanics_repair"] = get_mechanics_repair_fraction_0535()
	snapshot["scavenging_chance"] = get_scavenging_bonus_chance_0535()
	return snapshot
