extends "res://scripts/player/player_3d_v0527.gd"

const BUILD_COSTS_0528 := {
	"floor": {"plank": 2},
	"wall": {"plank": 3, "cordage": 1},
	"fence": {"wood": 3, "cordage": 1},
	"crate": {"plank": 3, "cordage": 1},
	"door": {"plank": 3, "cordage": 1},
	"gate": {"wood": 4, "cordage": 1},
	"barricade": {"wood": 5, "cordage": 1},
	"campfire": {"stone": 4, "wood": 2}
}

var campfire_fuel_added_0528 := 0
var barricades_built_0528 := 0
var campfires_built_0528 := 0

func get_build_cost_0526(piece_id: String) -> Dictionary:
	if not BUILD_COSTS_0528.has(piece_id):
		return {}
	return (BUILD_COSTS_0528[piece_id] as Dictionary).duplicate(true)

func consume_build_cost_0526(piece_id: String) -> bool:
	if not can_afford_build_0526(piece_id):
		return false
	var cost: Dictionary = get_build_cost_0526(piece_id)
	for raw_id: Variant in cost.keys():
		var item_id: String = str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(cost[raw_id])
	placed_structures_0526 += 1
	last_build_piece_0526 = piece_id
	if piece_id == "barricade":
		barricades_built_0528 += 1
	elif piece_id == "campfire":
		campfires_built_0528 += 1
	_request_save_0524()
	return true

func consume_campfire_wood_0528(amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current: int = int(inventory.get("wood", 0))
	if current < amount:
		return false
	inventory["wood"] = current - amount
	campfire_fuel_added_0528 += amount
	_request_save_0524()
	return true

func export_save_state() -> Dictionary:
	var state: Dictionary = super.export_save_state()
	state["campfire_fuel_added_0528"] = campfire_fuel_added_0528
	state["barricades_built_0528"] = barricades_built_0528
	state["campfires_built_0528"] = campfires_built_0528
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	campfire_fuel_added_0528 = int(state.get("campfire_fuel_added_0528", 0))
	barricades_built_0528 = int(state.get("barricades_built_0528", 0))
	campfires_built_0528 = int(state.get("campfires_built_0528", 0))

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	campfire_fuel_added_0528 = 0
	barricades_built_0528 = 0
	campfires_built_0528 = 0

func get_base_utility_debug_0528() -> Dictionary:
	return {
		"fuel_added": campfire_fuel_added_0528,
		"barricades_built": barricades_built_0528,
		"campfires_built": campfires_built_0528,
		"wood": int(inventory.get("wood", 0)),
		"can_barricade": can_afford_build_0526("barricade"),
		"can_campfire": can_afford_build_0526("campfire")
	}
