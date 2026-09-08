extends "res://scripts/player/player_3d_v0525.gd"

const BUILD_COSTS_0526 := {
	"floor": {"plank": 2},
	"wall": {"plank": 3, "cordage": 1},
	"fence": {"wood": 3, "cordage": 1},
	"crate": {"plank": 3, "cordage": 1}
}

var placed_structures_0526 := 0
var last_build_piece_0526 := ""
var storage_transfers_0526 := 0

func get_build_cost_0526(piece_id: String) -> Dictionary:
	if not BUILD_COSTS_0526.has(piece_id):
		return {}
	return (BUILD_COSTS_0526[piece_id] as Dictionary).duplicate(true)

func can_afford_build_0526(piece_id: String) -> bool:
	var cost := get_build_cost_0526(piece_id)
	if cost.is_empty():
		return false
	for raw_id in cost.keys():
		var item_id := str(raw_id)
		if int(inventory.get(item_id, 0)) < int(cost[raw_id]):
			return false
	return true

func consume_build_cost_0526(piece_id: String) -> bool:
	if not can_afford_build_0526(piece_id):
		return false
	var cost := get_build_cost_0526(piece_id)
	for raw_id in cost.keys():
		var item_id := str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(cost[raw_id])
	placed_structures_0526 += 1
	last_build_piece_0526 = piece_id
	_request_save_0524()
	return true

func refund_build_cost_0526(piece_id: String) -> void:
	var cost := get_build_cost_0526(piece_id)
	for raw_id in cost.keys():
		add_item(str(raw_id), int(cost[raw_id]))
	placed_structures_0526 = maxi(0, placed_structures_0526 - 1)
	_request_save_0524()

func remove_item_0526(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current := int(inventory.get(item_id, 0))
	if current < amount:
		return false
	inventory[item_id] = current - amount
	storage_transfers_0526 += 1
	_request_save_0524()
	return true

func receive_storage_item_0526(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	add_item(item_id, amount)
	storage_transfers_0526 += 1
	_request_save_0524()
	return true

func get_build_inventory_debug_0526() -> Dictionary:
	return {
		"placed": placed_structures_0526,
		"last_piece": last_build_piece_0526,
		"transfers": storage_transfers_0526,
		"can_floor": can_afford_build_0526("floor"),
		"can_wall": can_afford_build_0526("wall"),
		"can_fence": can_afford_build_0526("fence"),
		"can_crate": can_afford_build_0526("crate")
	}

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["placed_structures_0526"] = placed_structures_0526
	state["last_build_piece_0526"] = last_build_piece_0526
	state["storage_transfers_0526"] = storage_transfers_0526
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	placed_structures_0526 = int(state.get("placed_structures_0526", 0))
	last_build_piece_0526 = str(state.get("last_build_piece_0526", ""))
	storage_transfers_0526 = int(state.get("storage_transfers_0526", 0))

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	placed_structures_0526 = 0
	last_build_piece_0526 = ""
	storage_transfers_0526 = 0
