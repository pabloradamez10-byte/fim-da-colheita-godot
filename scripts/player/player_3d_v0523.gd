extends "res://scripts/player/player_3d_v0522.gd"

const WEAPON_MAX_DURABILITY_0523 := {
	"machete": 100.0,
	"axe": 85.0,
	"spear": 72.0,
	"pistol": 120.0,
	"shotgun": 100.0
}

const WEAPON_WEAR_0523 := {
	"machete": 1.25,
	"axe": 1.55,
	"spear": 1.05,
	"pistol": 0.60,
	"shotgun": 0.95
}

const REPAIR_COSTS_0523 := {
	"machete": {"stone": 1, "fiber": 1},
	"axe": {"stone": 2, "wood": 1},
	"spear": {"wood": 2, "fiber": 1},
	"pistol": {"stone": 1, "fiber": 2},
	"shotgun": {"wood": 2, "fiber": 2}
}

const REPAIR_FRACTION_0523 := 0.45
const HOTBAR_PRIORITIES_0523 := ["machete", "axe", "spear", "pistol", "shotgun", "bandage", "water", "food", "antiseptic"]
const CONSUMABLE_IDS_0523 := ["bandage", "water", "food", "antiseptic"]

var weapon_durability_0523: Dictionary = {}
var last_hotbar_action_0523 := ""
var last_broken_weapon_0523 := ""

func _ready() -> void:
	super._ready()
	_ensure_weapon_durability_0523()

func _attack() -> void:
	var weapon := get_equipped_weapon()
	_ensure_weapon_durability_for_0523(weapon)
	if is_weapon_broken_0523(weapon):
		last_broken_weapon_0523 = weapon
		last_hotbar_action_0523 = "broken:%s" % weapon
		return
	var cooldown_before := attack_cooldown
	super._attack()
	if attack_cooldown > cooldown_before:
		_consume_weapon_durability_0523(weapon)

func _consume_weapon_durability_0523(weapon: String) -> void:
	var max_value := get_weapon_max_durability_0523(weapon)
	if max_value <= 0.0:
		return
	var current := get_weapon_durability_0523(weapon)
	var wear := float(WEAPON_WEAR_0523.get(weapon, 1.0))
	weapon_durability_0523[weapon] = maxf(0.0, current - wear)
	if float(weapon_durability_0523[weapon]) <= 0.0:
		last_broken_weapon_0523 = weapon

func unlock_weapon(id: String) -> void:
	var already_owned := owned_weapons.has(id)
	super.unlock_weapon(id)
	if not already_owned:
		weapon_durability_0523[id] = get_weapon_max_durability_0523(id)
	else:
		_ensure_weapon_durability_for_0523(id)

func _ensure_weapon_durability_0523() -> void:
	for raw_id in owned_weapons:
		_ensure_weapon_durability_for_0523(str(raw_id))

func _ensure_weapon_durability_for_0523(id: String) -> void:
	if not weapon_durability_0523.has(id):
		weapon_durability_0523[id] = get_weapon_max_durability_0523(id)

func get_weapon_max_durability_0523(id: String) -> float:
	return float(WEAPON_MAX_DURABILITY_0523.get(id, 100.0))

func get_weapon_durability_0523(id: String) -> float:
	_ensure_weapon_durability_for_0523(id)
	return clampf(float(weapon_durability_0523.get(id, get_weapon_max_durability_0523(id))), 0.0, get_weapon_max_durability_0523(id))

func get_weapon_durability_percent_0523(id: String) -> int:
	var max_value := maxf(1.0, get_weapon_max_durability_0523(id))
	return int(round(get_weapon_durability_0523(id) / max_value * 100.0))

func is_weapon_broken_0523(id: String) -> bool:
	return get_weapon_durability_0523(id) <= 0.01

func get_repair_cost_0523(id: String) -> Dictionary:
	if not REPAIR_COSTS_0523.has(id):
		return {}
	return (REPAIR_COSTS_0523[id] as Dictionary).duplicate(true)

func can_repair_weapon_0523(id: String) -> bool:
	if not owned_weapons.has(id):
		return false
	if get_weapon_durability_0523(id) >= get_weapon_max_durability_0523(id) - 0.01:
		return false
	var cost := get_repair_cost_0523(id)
	if cost.is_empty():
		return false
	for raw_id in cost.keys():
		var item_id := str(raw_id)
		if int(inventory.get(item_id, 0)) < int(cost[raw_id]):
			return false
	return true

func repair_weapon_0523(id: String) -> bool:
	if not can_repair_weapon_0523(id):
		return false
	var cost := get_repair_cost_0523(id)
	for raw_id in cost.keys():
		var item_id := str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(cost[raw_id])
	var max_value := get_weapon_max_durability_0523(id)
	var repaired := max_value * REPAIR_FRACTION_0523
	weapon_durability_0523[id] = minf(max_value, get_weapon_durability_0523(id) + repaired)
	if get_weapon_durability_0523(id) > 0.0 and last_broken_weapon_0523 == id:
		last_broken_weapon_0523 = ""
	last_hotbar_action_0523 = "repair:%s" % id
	if world != null and world.has_method("save_game"):
		world.call_deferred("save_game")
	return true

func get_hotbar_slots_0523() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_id in HOTBAR_PRIORITIES_0523:
		var id := str(raw_id)
		if id in CONSUMABLE_IDS_0523:
			var amount := int(inventory.get(id, 0))
			if amount <= 0:
				continue
			result.append({
				"id": id,
				"kind": "item",
				"count": amount,
				"equipped": false,
				"broken": false,
				"durability": -1
			})
		elif owned_weapons.has(id):
			var detail_count := -1
			if id == "pistol":
				detail_count = int(inventory.get("ammo_9mm", 0))
			elif id == "shotgun":
				detail_count = int(inventory.get("shells", 0))
			result.append({
				"id": id,
				"kind": "weapon",
				"count": detail_count,
				"equipped": get_equipped_weapon() == id,
				"broken": is_weapon_broken_0523(id),
				"durability": get_weapon_durability_percent_0523(id)
			})
		if result.size() >= 6:
			break
	return result

func hotbar_activate_0523(id: String) -> bool:
	if owned_weapons.has(id):
		last_hotbar_action_0523 = "equip:%s" % id
		return equip_weapon(id)
	if id in CONSUMABLE_IDS_0523:
		var used := use_inventory_item(id)
		if used:
			last_hotbar_action_0523 = "use:%s" % id
			if world != null and world.has_method("save_game"):
				world.call_deferred("save_game")
		return used
	return false

func get_weapon_summary() -> String:
	var weapon := get_equipped_weapon()
	var base := super.get_weapon_summary()
	var durability := get_weapon_durability_percent_0523(weapon)
	if is_weapon_broken_0523(weapon):
		return "%s — QUEBRADA (0%%)" % base
	return "%s — DUR %d%%" % [base, durability]

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["weapon_durability_0523"] = weapon_durability_0523.duplicate(true)
	state["last_broken_weapon_0523"] = last_broken_weapon_0523
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	weapon_durability_0523.clear()
	var raw: Variant = state.get("weapon_durability_0523", {})
	if raw is Dictionary:
		weapon_durability_0523 = (raw as Dictionary).duplicate(true)
	last_broken_weapon_0523 = str(state.get("last_broken_weapon_0523", ""))
	_ensure_weapon_durability_0523()

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	weapon_durability_0523.clear()
	_ensure_weapon_durability_0523()
	last_hotbar_action_0523 = ""
	last_broken_weapon_0523 = ""

func get_equipment_debug_0523() -> Dictionary:
	return {
		"durability": weapon_durability_0523.duplicate(true),
		"equipped": get_equipped_weapon(),
		"slots": get_hotbar_slots_0523(),
		"last_action": last_hotbar_action_0523,
		"last_broken": last_broken_weapon_0523
	}
