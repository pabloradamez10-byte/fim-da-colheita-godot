extends "res://scripts/player/player_3d_v0526.gd"

const BUILD_COSTS_0527 := {
	"floor": {"plank": 2},
	"wall": {"plank": 3, "cordage": 1},
	"fence": {"wood": 3, "cordage": 1},
	"crate": {"plank": 3, "cordage": 1},
	"door": {"plank": 3, "cordage": 1},
	"gate": {"wood": 4, "cordage": 1}
}

var repaired_structures_0527 := 0
var dismantled_structures_0527 := 0
var destroyed_structures_0527 := 0

func get_build_cost_0526(piece_id: String) -> Dictionary:
	if not BUILD_COSTS_0527.has(piece_id):
		return {}
	return (BUILD_COSTS_0527[piece_id] as Dictionary).duplicate(true)

func can_afford_build_0526(piece_id: String) -> bool:
	var cost: Dictionary = get_build_cost_0526(piece_id)
	if cost.is_empty():
		return false
	for raw_id: Variant in cost.keys():
		var item_id: String = str(raw_id)
		if int(inventory.get(item_id, 0)) < int(cost[raw_id]):
			return false
	return true

func consume_build_cost_0526(piece_id: String) -> bool:
	if not can_afford_build_0526(piece_id):
		return false
	var cost: Dictionary = get_build_cost_0526(piece_id)
	for raw_id: Variant in cost.keys():
		var item_id: String = str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(cost[raw_id])
	placed_structures_0526 += 1
	last_build_piece_0526 = piece_id
	_request_save_0524()
	return true

func get_repair_cost_0527(piece_id: String, health: float, max_health: float) -> Dictionary:
	if max_health <= 0.0 or health >= max_health - 0.01:
		return {}
	var ratio_missing: float = clampf(1.0 - health / max_health, 0.0, 1.0)
	var base: Dictionary = get_build_cost_0526(piece_id)
	var result: Dictionary = {}
	for raw_id: Variant in base.keys():
		var amount: int = int(base[raw_id])
		var repair_amount: int = maxi(1, int(ceil(float(amount) * ratio_missing * 0.55)))
		result[str(raw_id)] = repair_amount
	return result

func can_repair_structure_0527(piece_id: String, health: float, max_health: float) -> bool:
	var cost: Dictionary = get_repair_cost_0527(piece_id, health, max_health)
	if cost.is_empty():
		return false
	for raw_id: Variant in cost.keys():
		var item_id: String = str(raw_id)
		if int(inventory.get(item_id, 0)) < int(cost[raw_id]):
			return false
	return true

func consume_repair_cost_0527(piece_id: String, health: float, max_health: float) -> bool:
	if not can_repair_structure_0527(piece_id, health, max_health):
		return false
	var cost: Dictionary = get_repair_cost_0527(piece_id, health, max_health)
	for raw_id: Variant in cost.keys():
		var item_id: String = str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(cost[raw_id])
	repaired_structures_0527 += 1
	_request_save_0524()
	return true

func receive_dismantle_refund_0527(piece_id: String) -> Dictionary:
	var cost: Dictionary = get_build_cost_0526(piece_id)
	var refund: Dictionary = {}
	for raw_id: Variant in cost.keys():
		var amount: int = int(cost[raw_id])
		var returned: int = int(floor(float(amount) * 0.50))
		if returned <= 0 and amount > 0:
			returned = 1
		add_item(str(raw_id), returned)
		refund[str(raw_id)] = returned
	dismantled_structures_0527 += 1
	placed_structures_0526 = maxi(0, placed_structures_0526 - 1)
	_request_save_0524()
	return refund

func register_destroyed_structure_0527() -> void:
	destroyed_structures_0527 += 1
	placed_structures_0526 = maxi(0, placed_structures_0526 - 1)
	_request_save_0524()

func export_save_state() -> Dictionary:
	var state: Dictionary = super.export_save_state()
	state["repaired_structures_0527"] = repaired_structures_0527
	state["dismantled_structures_0527"] = dismantled_structures_0527
	state["destroyed_structures_0527"] = destroyed_structures_0527
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	repaired_structures_0527 = int(state.get("repaired_structures_0527", 0))
	dismantled_structures_0527 = int(state.get("dismantled_structures_0527", 0))
	destroyed_structures_0527 = int(state.get("destroyed_structures_0527", 0))

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	repaired_structures_0527 = 0
	dismantled_structures_0527 = 0
	destroyed_structures_0527 = 0

func get_structure_maintenance_debug_0527() -> Dictionary:
	return {
		"repaired": repaired_structures_0527,
		"dismantled": dismantled_structures_0527,
		"destroyed": destroyed_structures_0527,
		"can_door": can_afford_build_0526("door"),
		"can_gate": can_afford_build_0526("gate")
	}
