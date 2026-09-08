extends "res://scripts/player/player_3d_v0528.gd"

const BUILD_COSTS_0529 := {
	"floor": {"plank": 2},
	"wall": {"plank": 3, "cordage": 1},
	"fence": {"wood": 3, "cordage": 1},
	"crate": {"plank": 3, "cordage": 1},
	"door": {"plank": 3, "cordage": 1},
	"gate": {"wood": 4, "cordage": 1},
	"barricade": {"wood": 5, "cordage": 1},
	"campfire": {"stone": 4, "wood": 2},
	"rain_collector": {"plank": 3, "cordage": 2, "fiber": 4}
}

var water_sickness_0529 := 0.0
var rain_collectors_built_0529 := 0
var unsafe_water_drunk_0529 := 0
var water_purified_0529 := 0

func _ready() -> void:
	super._ready()
	if not inventory.has("dirty_water"):
		inventory["dirty_water"] = 0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_water_sickness_0529(delta)

func _update_water_sickness_0529(delta: float) -> void:
	if water_sickness_0529 <= 0.0:
		return
	# O organismo se recupera lentamente quando hidratado e fora do estágio crítico.
	if thirst >= 42.0 and water_sickness_0529 < 70.0:
		water_sickness_0529 = maxf(0.0, water_sickness_0529 - 0.018 * delta)
	if water_sickness_0529 >= 28.0:
		stamina = maxf(0.0, stamina - 0.24 * delta)
	if water_sickness_0529 >= 55.0:
		thirst = maxf(0.0, thirst - 0.32 * delta)
		pain_0519 = minf(100.0, pain_0519 + 0.035 * delta)
	if water_sickness_0529 >= 82.0:
		health = maxf(0.0, health - 0.26 * delta)
	if health <= 0.0:
		_respawn()

func get_build_cost_0526(piece_id: String) -> Dictionary:
	if BUILD_COSTS_0529.has(piece_id):
		return (BUILD_COSTS_0529[piece_id] as Dictionary).duplicate(true)
	return super.get_build_cost_0526(piece_id)

func consume_build_cost_0526(piece_id: String) -> bool:
	if piece_id != "rain_collector":
		return super.consume_build_cost_0526(piece_id)
	if not can_afford_build_0526(piece_id):
		return false
	var cost: Dictionary = get_build_cost_0526(piece_id)
	for raw_id: Variant in cost.keys():
		var item_id := str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(cost[raw_id])
	placed_structures_0526 += 1
	last_build_piece_0526 = piece_id
	rain_collectors_built_0529 += 1
	_request_save_0524()
	return true

func receive_dirty_water_0529(amount: int = 1) -> bool:
	if amount <= 0:
		return false
	inventory["dirty_water"] = int(inventory.get("dirty_water", 0)) + amount
	_request_save_0524()
	return true

func drink_unsafe_water_0529(amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current := int(inventory.get("dirty_water", 0))
	if current < amount:
		return false
	inventory["dirty_water"] = current - amount
	for _i in range(amount):
		thirst = minf(100.0, thirst + 28.0)
		water_sickness_0529 = minf(100.0, water_sickness_0529 + 18.0)
	unsafe_water_drunk_0529 += amount
	_request_save_0524()
	return true

func drink_unsafe_direct_0529() -> bool:
	thirst = minf(100.0, thirst + 28.0)
	water_sickness_0529 = minf(100.0, water_sickness_0529 + 18.0)
	unsafe_water_drunk_0529 += 1
	_request_save_0524()
	return true

func purify_dirty_water_0529(amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current := int(inventory.get("dirty_water", 0))
	if current < amount:
		return false
	inventory["dirty_water"] = current - amount
	inventory["water"] = int(inventory.get("water", 0)) + amount
	water_purified_0529 += amount
	_request_save_0524()
	return true

func _extract_death_drop_0520() -> Dictionary:
	var dropped: Dictionary = super._extract_death_drop_0520()
	var amount := int(inventory.get("dirty_water", 0))
	if amount >= 2:
		var loss := maxi(1, int(floor(float(amount) * DEATH_DROP_RATIO_0520)))
		loss = mini(loss, amount)
		inventory["dirty_water"] = amount - loss
		dropped["dirty_water"] = loss
	return dropped

func get_vitals() -> Dictionary:
	var result: Dictionary = super.get_vitals()
	result["water_sickness"] = water_sickness_0529
	return result

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var dirty := int(inventory.get("dirty_water", 0))
	if dirty > 0:
		result += " | Água bruta %d" % dirty
	return result

func export_save_state() -> Dictionary:
	var state: Dictionary = super.export_save_state()
	state["water_sickness_0529"] = water_sickness_0529
	state["rain_collectors_built_0529"] = rain_collectors_built_0529
	state["unsafe_water_drunk_0529"] = unsafe_water_drunk_0529
	state["water_purified_0529"] = water_purified_0529
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	water_sickness_0529 = float(state.get("water_sickness_0529", 0.0))
	rain_collectors_built_0529 = int(state.get("rain_collectors_built_0529", 0))
	unsafe_water_drunk_0529 = int(state.get("unsafe_water_drunk_0529", 0))
	water_purified_0529 = int(state.get("water_purified_0529", 0))
	if not inventory.has("dirty_water"):
		inventory["dirty_water"] = 0

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	inventory["dirty_water"] = 0
	water_sickness_0529 = 0.0
	rain_collectors_built_0529 = 0
	unsafe_water_drunk_0529 = 0
	water_purified_0529 = 0

func _respawn() -> void:
	super._respawn()
	water_sickness_0529 = minf(water_sickness_0529, 24.0)

func get_water_survival_debug_0529() -> Dictionary:
	return {
		"dirty_water": int(inventory.get("dirty_water", 0)),
		"safe_water": int(inventory.get("water", 0)),
		"sickness": water_sickness_0529,
		"collectors_built": rain_collectors_built_0529,
		"unsafe_drunk": unsafe_water_drunk_0529,
		"purified": water_purified_0529,
		"can_collector": can_afford_build_0526("rain_collector")
	}
