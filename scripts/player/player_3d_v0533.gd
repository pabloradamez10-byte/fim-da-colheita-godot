extends "res://scripts/player/player_3d_v0532.gd"

const EQUIPMENT_SLOTS_0533 := ["head", "torso", "hands", "legs", "feet", "back"]
const SLOT_NAMES_0533 := {
	"head":"CABEÇA", "torso":"TRONCO", "hands":"MÃOS", "legs":"PERNAS", "feet":"PÉS", "back":"COSTAS"
}
const CLOTHING_DEFS_0533 := {
	"baseball_cap": {"name":"Boné", "slot":"head", "bite":2.0, "cut":5.0, "cold":3.0, "rain":2.0, "weight":0.20},
	"motorcycle_helmet": {"name":"Capacete de moto", "slot":"head", "bite":18.0, "cut":32.0, "cold":7.0, "rain":18.0, "weight":1.40},
	"tshirt": {"name":"Camiseta", "slot":"torso", "bite":2.0, "cut":5.0, "cold":4.0, "rain":1.0, "weight":0.25},
	"hoodie": {"name":"Moletom", "slot":"torso", "bite":8.0, "cut":18.0, "cold":24.0, "rain":10.0, "weight":1.15},
	"rain_jacket": {"name":"Jaqueta impermeável", "slot":"torso", "bite":6.0, "cut":14.0, "cold":16.0, "rain":56.0, "weight":0.95},
	"work_gloves": {"name":"Luvas de trabalho", "slot":"hands", "bite":10.0, "cut":22.0, "cold":8.0, "rain":8.0, "weight":0.30},
	"jeans": {"name":"Calça jeans", "slot":"legs", "bite":7.0, "cut":16.0, "cold":11.0, "rain":5.0, "weight":0.85},
	"cargo_pants": {"name":"Calça cargo", "slot":"legs", "bite":9.0, "cut":18.0, "cold":14.0, "rain":8.0, "weight":0.95},
	"sneakers": {"name":"Tênis", "slot":"feet", "bite":4.0, "cut":10.0, "cold":5.0, "rain":3.0, "weight":0.65},
	"work_boots": {"name":"Botas de trabalho", "slot":"feet", "bite":14.0, "cut":28.0, "cold":14.0, "rain":22.0, "weight":1.45},
	"school_backpack": {"name":"Mochila escolar", "slot":"back", "bite":1.0, "cut":4.0, "cold":2.0, "rain":5.0, "weight":0.80, "carry_bonus":6.0},
	"hiking_backpack": {"name":"Mochila cargueira", "slot":"back", "bite":3.0, "cut":8.0, "cold":5.0, "rain":18.0, "weight":1.70, "carry_bonus":14.0}
}

var equipment_0533: Dictionary = {}
var equipment_hits_0533 := 0
var blocked_damage_0533 := 0.0
var clothing_swaps_0533 := 0

func _ready() -> void:
	super._ready()
	_ensure_equipment_inventory_0533()
	_ensure_equipment_slots_0533(true)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_apply_equipment_encumbrance_0533(delta)

func _default_equipment_0533() -> Dictionary:
	return {
		"head":"",
		"torso":"tshirt",
		"hands":"",
		"legs":"jeans",
		"feet":"sneakers",
		"back":"school_backpack"
	}

func _ensure_equipment_inventory_0533() -> void:
	for raw_id: Variant in CLOTHING_DEFS_0533.keys():
		var item_id := str(raw_id)
		if not inventory.has(item_id):
			inventory[item_id] = 0

func _ensure_equipment_slots_0533(use_defaults_when_empty: bool) -> void:
	if equipment_0533.is_empty() and use_defaults_when_empty:
		equipment_0533 = _default_equipment_0533()
	for slot in EQUIPMENT_SLOTS_0533:
		if not equipment_0533.has(slot):
			equipment_0533[slot] = ""
		var item_id := str(equipment_0533.get(slot, ""))
		if item_id != "":
			if not CLOTHING_DEFS_0533.has(item_id) or str((CLOTHING_DEFS_0533[item_id] as Dictionary).get("slot", "")) != slot:
				equipment_0533[slot] = ""

func get_clothing_defs_0533() -> Dictionary:
	return CLOTHING_DEFS_0533.duplicate(true)

func get_equipment_snapshot_0533() -> Dictionary:
	return equipment_0533.duplicate(true)

func get_slot_names_0533() -> Dictionary:
	return SLOT_NAMES_0533.duplicate(true)

func get_equipment_stats_0533() -> Dictionary:
	var bite := 0.0
	var cut := 0.0
	var cold := 0.0
	var rain := 0.0
	var weight := 0.0
	var carry_bonus := 0.0
	for slot in EQUIPMENT_SLOTS_0533:
		var item_id := str(equipment_0533.get(slot, ""))
		if item_id == "" or not CLOTHING_DEFS_0533.has(item_id):
			continue
		var data := CLOTHING_DEFS_0533[item_id] as Dictionary
		bite += float(data.get("bite", 0.0))
		cut += float(data.get("cut", 0.0))
		cold += float(data.get("cold", 0.0))
		rain += float(data.get("rain", 0.0))
		weight += float(data.get("weight", 0.0))
		carry_bonus += float(data.get("carry_bonus", 0.0))
	return {
		"bite": clampf(bite, 0.0, 70.0),
		"cut": clampf(cut, 0.0, 78.0),
		"cold": clampf(cold, 0.0, 82.0),
		"rain": clampf(rain, 0.0, 88.0),
		"weight": weight,
		"carry_bonus": carry_bonus,
		"mobility": clampf(1.0 - maxf(0.0, weight - 4.0) * 0.035, 0.78, 1.0)
	}

func get_equipment_summary_0533() -> String:
	var stats := get_equipment_stats_0533()
	return "MORD %d%%  CORTE %d%%  FRIO %d%%  CHUVA %d%%  PESO %.1fkg" % [int(round(float(stats.get("bite", 0.0)))), int(round(float(stats.get("cut", 0.0)))), int(round(float(stats.get("cold", 0.0)))), int(round(float(stats.get("rain", 0.0)))), float(stats.get("weight", 0.0))]

func equip_clothing_0533(item_id: String) -> bool:
	if not CLOTHING_DEFS_0533.has(item_id) or int(inventory.get(item_id, 0)) <= 0:
		return false
	var data := CLOTHING_DEFS_0533[item_id] as Dictionary
	var slot := str(data.get("slot", ""))
	if slot not in EQUIPMENT_SLOTS_0533:
		return false
	var previous := str(equipment_0533.get(slot, ""))
	inventory[item_id] = int(inventory.get(item_id, 0)) - 1
	if previous != "":
		inventory[previous] = int(inventory.get(previous, 0)) + 1
	equipment_0533[slot] = item_id
	clothing_swaps_0533 += 1
	_request_save_0524()
	return true

func unequip_slot_0533(slot: String) -> bool:
	if slot not in EQUIPMENT_SLOTS_0533:
		return false
	var item_id := str(equipment_0533.get(slot, ""))
	if item_id == "":
		return false
	inventory[item_id] = int(inventory.get(item_id, 0)) + 1
	equipment_0533[slot] = ""
	clothing_swaps_0533 += 1
	_request_save_0524()
	return true

func receive_clothing_0533(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or not CLOTHING_DEFS_0533.has(item_id):
		return false
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	_request_save_0524()
	return true

func take_zombie_damage_0520(amount: float, zombie_variant: int = 0) -> void:
	if amount <= 0.0:
		return
	var stats := get_equipment_stats_0533()
	var attack_kind := "bite" if zombie_variant in [1, 3] else "cut"
	var protection := float(stats.get(attack_kind, 0.0))
	var effective := maxf(0.75, amount * (1.0 - protection / 100.0))
	blocked_damage_0533 += maxf(0.0, amount - effective)
	equipment_hits_0533 += 1
	super.take_zombie_damage_0520(effective, zombie_variant)

func get_rain_exposure_multiplier_0533() -> float:
	var rain := float(get_equipment_stats_0533().get("rain", 0.0))
	return clampf(1.0 - rain * 0.0082, 0.28, 1.0)

func get_cold_insulation_0533() -> float:
	var cold := float(get_equipment_stats_0533().get("cold", 0.0))
	return clampf(cold / 100.0, 0.0, 0.78)

func _apply_equipment_encumbrance_0533(delta: float) -> void:
	var stats := get_equipment_stats_0533()
	var weight := float(stats.get("weight", 0.0))
	if weight <= 4.0:
		return
	var speed := Vector2(velocity.x, velocity.z).length()
	if speed <= 0.25:
		return
	var excess := weight - 4.0
	stamina = maxf(0.0, stamina - excess * 0.18 * delta)
	fatigue_0521 = minf(100.0, fatigue_0521 + excess * 0.018 * delta)

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var clothing_count := 0
	for raw_id: Variant in CLOTHING_DEFS_0533.keys():
		clothing_count += int(inventory.get(str(raw_id), 0))
	if clothing_count > 0:
		result += " | Roupas %d" % clothing_count
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["equipment_0533"] = equipment_0533.duplicate(true)
	state["equipment_hits_0533"] = equipment_hits_0533
	state["blocked_damage_0533"] = blocked_damage_0533
	state["clothing_swaps_0533"] = clothing_swaps_0533
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	_ensure_equipment_inventory_0533()
	var raw_equipment: Variant = state.get("equipment_0533", {})
	equipment_0533 = (raw_equipment as Dictionary).duplicate(true) if raw_equipment is Dictionary else {}
	_ensure_equipment_slots_0533(true)
	equipment_hits_0533 = int(state.get("equipment_hits_0533", 0))
	blocked_damage_0533 = float(state.get("blocked_damage_0533", 0.0))
	clothing_swaps_0533 = int(state.get("clothing_swaps_0533", 0))

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	_ensure_equipment_inventory_0533()
	for raw_id: Variant in CLOTHING_DEFS_0533.keys():
		inventory[str(raw_id)] = 0
	equipment_0533 = _default_equipment_0533()
	equipment_hits_0533 = 0
	blocked_damage_0533 = 0.0
	clothing_swaps_0533 = 0

func get_equipment_debug_0533() -> Dictionary:
	return {
		"equipment": equipment_0533.duplicate(true),
		"stats": get_equipment_stats_0533(),
		"hits": equipment_hits_0533,
		"blocked_damage": blocked_damage_0533,
		"swaps": clothing_swaps_0533
	}
