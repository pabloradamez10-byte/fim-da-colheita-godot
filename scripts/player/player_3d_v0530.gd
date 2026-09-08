extends "res://scripts/player/player_3d_v0529.gd"

var in_vehicle_0530 := false
var vehicle_uid_0530 := ""
var pending_vehicle_uid_0530 := ""
var original_collision_layer_0530 := 1
var original_collision_mask_0530 := 1
var vehicles_entered_0530 := 0
var kilometers_equivalent_0530 := 0.0

func _ready() -> void:
	super._ready()
	original_collision_layer_0530 = collision_layer
	original_collision_mask_0530 = collision_mask
	if not inventory.has("gasoline"):
		inventory["gasoline"] = 0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if in_vehicle_0530 and world != null and world.has_method("sync_driver_player_0530"):
		world.call("sync_driver_player_0530", self, vehicle_uid_0530)

func enter_vehicle_0530(uid: String) -> bool:
	if uid == "" or in_vehicle_0530:
		return false
	in_vehicle_0530 = true
	vehicle_uid_0530 = uid
	pending_vehicle_uid_0530 = uid
	vehicles_entered_0530 += 1
	visible = false
	collision_layer = 0
	collision_mask = 0
	_set_player_collision_disabled_0530(true)
	var controls := get_tree().get_first_node_in_group("mobile_controls")
	if controls != null and controls.has_method("set_vehicle_mode_0530"):
		controls.call("set_vehicle_mode_0530", true)
	return true

func exit_vehicle_0530(exit_position: Vector3) -> void:
	in_vehicle_0530 = false
	vehicle_uid_0530 = ""
	pending_vehicle_uid_0530 = ""
	visible = true
	collision_layer = original_collision_layer_0530
	collision_mask = original_collision_mask_0530
	_set_player_collision_disabled_0530(false)
	global_position = exit_position
	velocity = Vector3.ZERO
	var controls := get_tree().get_first_node_in_group("mobile_controls")
	if controls != null and controls.has_method("set_vehicle_mode_0530"):
		controls.call("set_vehicle_mode_0530", false)

func is_in_vehicle_0530() -> bool:
	return in_vehicle_0530

func get_vehicle_uid_0530() -> String:
	return vehicle_uid_0530

func get_pending_vehicle_uid_0530() -> String:
	return pending_vehicle_uid_0530

func consume_inventory_item_0530(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current := int(inventory.get(item_id, 0))
	if current < amount:
		return false
	inventory[item_id] = current - amount
	_request_save_0524()
	return true

func receive_inventory_item_0530(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	_request_save_0524()
	return true

func consume_gasoline_0530(amount: int = 1) -> bool:
	return consume_inventory_item_0530("gasoline", amount)

func consume_repair_kit_0530(amount: int = 1) -> bool:
	return consume_inventory_item_0530("repair_kit", amount)

func add_vehicle_distance_0530(world_units: float) -> void:
	if world_units > 0.0:
		kilometers_equivalent_0530 += world_units / 1000.0

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var gas := int(inventory.get("gasoline", 0))
	if gas > 0:
		result += " | Gasolina %dL" % gas
	return result

func _extract_death_drop_0520() -> Dictionary:
	var dropped := super._extract_death_drop_0520()
	var amount := int(inventory.get("gasoline", 0))
	if amount >= 2:
		var loss := maxi(1, int(floor(float(amount) * DEATH_DROP_RATIO_0520)))
		loss = mini(loss, amount)
		inventory["gasoline"] = amount - loss
		dropped["gasoline"] = loss
	return dropped

func get_vitals() -> Dictionary:
	var result := super.get_vitals()
	result["in_vehicle"] = in_vehicle_0530
	result["vehicle_uid"] = vehicle_uid_0530
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["in_vehicle_0530"] = in_vehicle_0530
	state["vehicle_uid_0530"] = vehicle_uid_0530
	state["vehicles_entered_0530"] = vehicles_entered_0530
	state["kilometers_equivalent_0530"] = kilometers_equivalent_0530
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	if not inventory.has("gasoline"):
		inventory["gasoline"] = 0
	vehicles_entered_0530 = int(state.get("vehicles_entered_0530", 0))
	kilometers_equivalent_0530 = float(state.get("kilometers_equivalent_0530", 0.0))
	pending_vehicle_uid_0530 = str(state.get("vehicle_uid_0530", "")) if bool(state.get("in_vehicle_0530", false)) else ""
	in_vehicle_0530 = false
	vehicle_uid_0530 = ""

func reset_for_new_world() -> void:
	if in_vehicle_0530:
		in_vehicle_0530 = false
		vehicle_uid_0530 = ""
		pending_vehicle_uid_0530 = ""
		visible = true
		collision_layer = original_collision_layer_0530
		collision_mask = original_collision_mask_0530
		_set_player_collision_disabled_0530(false)
	super.reset_for_new_world()
	inventory["gasoline"] = 0
	vehicles_entered_0530 = 0
	kilometers_equivalent_0530 = 0.0

func _respawn() -> void:
	if in_vehicle_0530 and world != null and world.has_method("exit_vehicle_for_player_0530"):
		world.call("exit_vehicle_for_player_0530", self)
	super._respawn()

func _set_player_collision_disabled_0530(disabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", disabled)

func get_vehicle_player_debug_0530() -> Dictionary:
	return {
		"in_vehicle": in_vehicle_0530,
		"uid": vehicle_uid_0530,
		"pending": pending_vehicle_uid_0530,
		"gasoline": int(inventory.get("gasoline", 0)),
		"entered": vehicles_entered_0530,
		"distance_km_equiv": kilometers_equivalent_0530
	}
