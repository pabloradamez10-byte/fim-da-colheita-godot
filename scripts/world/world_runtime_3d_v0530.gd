extends "res://scripts/world/world_runtime_3d_v0529.gd"

const PlayerV0530Script = preload("res://scripts/player/player_3d_v0530.gd")
const VehicleV0530Script = preload("res://scripts/entities/vehicle_3d_v0530.gd")
const SAVE_VERSION_0530 := "0.5.30-alpha"
const VEHICLE_INTERACT_RANGE_0530 := 3.15
const VEHICLE_REPAIR_PERCENT_0530 := 0.30
const VEHICLE_TRUNK_ITEMS_0530 := [
	"wood", "stone", "fiber", "plank", "cordage", "stone_blade", "repair_kit",
	"food", "water", "dirty_water", "bandage", "antiseptic", "ammo_9mm", "shells", "gasoline"
]

var vehicle_records_0530: Dictionary = {}
var vehicle_runtime_root_0530: Node3D = null
var vehicle_entries_0530 := 0
var vehicle_exits_0530 := 0
var vehicle_refuels_0530 := 0
var vehicle_repairs_0530 := 0
var vehicle_trunk_transfers_0530 := 0
var driver_last_position_0530 := Vector3.ZERO

func _load_save() -> void:
	super._load_save()
	vehicle_records_0530.clear()
	var world_state := save_cache.get("world", {}) as Dictionary
	var raw_records: Variant = world_state.get("vehicle_records_0530", {})
	if raw_records is Dictionary:
		vehicle_records_0530 = (raw_records as Dictionary).duplicate(true)
	vehicle_entries_0530 = int(world_state.get("vehicle_entries_0530", 0))
	vehicle_exits_0530 = int(world_state.get("vehicle_exits_0530", 0))
	vehicle_refuels_0530 = int(world_state.get("vehicle_refuels_0530", 0))
	vehicle_repairs_0530 = int(world_state.get("vehicle_repairs_0530", 0))
	vehicle_trunk_transfers_0530 = int(world_state.get("vehicle_trunk_transfers_0530", 0))

func _ready() -> void:
	super._ready()
	_ensure_vehicle_root_0530()
	call_deferred("_restore_persistent_vehicles_0530")
	call_deferred("_restore_pending_driver_0530")

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0530Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _ensure_vehicle_root_0530() -> void:
	if vehicle_runtime_root_0530 != null and is_instance_valid(vehicle_runtime_root_0530):
		return
	vehicle_runtime_root_0530 = get_node_or_null("PersistentVehicles0530") as Node3D
	if vehicle_runtime_root_0530 == null:
		vehicle_runtime_root_0530 = Node3D.new()
		vehicle_runtime_root_0530.name = "PersistentVehicles0530"
		add_child(vehicle_runtime_root_0530)

func should_spawn_streamed_vehicle_0530(uid: String) -> bool:
	return uid != "" and not vehicle_records_0530.has(uid)

func _restore_persistent_vehicles_0530() -> void:
	_ensure_vehicle_root_0530()
	for raw_uid: Variant in vehicle_records_0530.keys():
		var uid := str(raw_uid)
		if _find_vehicle_0530(uid) != null:
			continue
		var record: Dictionary = vehicle_records_0530[raw_uid] as Dictionary
		var vehicle: CharacterBody3D = VehicleV0530Script.new()
		vehicle.call("configure_from_record_0530", self, uid, record)
		vehicle.add_to_group("vehicle_persistent_0530")
		vehicle_runtime_root_0530.add_child(vehicle)
		var pos: Dictionary = record.get("position", {}) as Dictionary
		vehicle.global_position = Vector3(float(pos.get("x", 0.0)), float(pos.get("y", 0.28)), float(pos.get("z", 0.0)))

func activate_vehicle_0530(vehicle: Node3D) -> String:
	if vehicle == null or not is_instance_valid(vehicle):
		return ""
	var uid := str(vehicle.get_meta("vehicle_key_0530", ""))
	if uid == "" or not vehicle.has_method("export_record_0530"):
		return ""
	_ensure_vehicle_root_0530()
	vehicle.set("activated_0530", true)
	if vehicle.get_parent() != vehicle_runtime_root_0530:
		vehicle.reparent(vehicle_runtime_root_0530, true)
	vehicle.remove_from_group("vehicle_streamed_0530")
	vehicle.add_to_group("vehicle_persistent_0530")
	if not harvested_keys.has(uid):
		harvested_keys.append(uid)
	update_vehicle_record_0530(vehicle)
	return uid

func update_vehicle_record_0530(vehicle: Node) -> void:
	if vehicle == null or not is_instance_valid(vehicle) or not vehicle.has_method("export_record_0530"):
		return
	var uid := str(vehicle.get_meta("vehicle_key_0530", ""))
	if uid == "":
		return
	vehicle_records_0530[uid] = (vehicle.call("export_record_0530") as Dictionary).duplicate(true)

func _sync_all_vehicle_records_0530() -> void:
	for raw: Node in get_tree().get_nodes_in_group("vehicle_persistent_0530"):
		if raw is Node3D:
			update_vehicle_record_0530(raw)

func _find_vehicle_0530(uid: String) -> Node3D:
	if uid == "":
		return null
	for raw: Node in get_tree().get_nodes_in_group("vehicle_0530"):
		if raw is Node3D and str((raw as Node3D).get_meta("vehicle_key_0530", "")) == uid:
			return raw as Node3D
	return null

func _nearest_vehicle_0530(pos: Vector3) -> Node3D:
	var nearest: Node3D = null
	var best := VEHICLE_INTERACT_RANGE_0530
	for raw: Node in get_tree().get_nodes_in_group("vehicle_0530"):
		if not (raw is Node3D):
			continue
		var vehicle := raw as Node3D
		var d := Vector2(pos.x - vehicle.global_position.x, pos.z - vehicle.global_position.z).length()
		if d <= best:
			best = d
			nearest = vehicle
	return nearest

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	if target_player != null and target_player.has_method("is_in_vehicle_0530") and bool(target_player.call("is_in_vehicle_0530")):
		return exit_vehicle_for_player_0530(target_player)
	var vehicle := _nearest_vehicle_0530(pos)
	if vehicle != null:
		var uid := activate_vehicle_0530(vehicle)
		if uid != "":
			for raw_ui: Node in get_tree().get_nodes_in_group("vehicle_ui_0530"):
				if raw_ui.has_method("open_vehicle_0530"):
					raw_ui.call("open_vehicle_0530", uid)
			save_game()
			return true
	return super.try_interact_near(pos, target_player)

func enter_vehicle_by_uid_0530(uid: String, target_player: Node) -> bool:
	if target_player == null or not target_player.has_method("enter_vehicle_0530"):
		return false
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null:
		return false
	activate_vehicle_0530(vehicle)
	if not vehicle.has_method("set_driver_0530") or not bool(vehicle.call("set_driver_0530", target_player)):
		return false
	if not bool(target_player.call("enter_vehicle_0530", uid, true)):
		vehicle.call("clear_driver_0530")
		return false
	vehicle_entries_0530 += 1
	driver_last_position_0530 = vehicle.global_position
	sync_driver_player_0530(target_player, uid)
	save_game()
	return true

func sync_driver_player_0530(target_player: Node, uid: String) -> void:
	if target_player == null or uid == "":
		return
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null:
		return
	var distance := Vector2(vehicle.global_position.x - driver_last_position_0530.x, vehicle.global_position.z - driver_last_position_0530.z).length()
	if distance > 0.0 and target_player.has_method("add_vehicle_distance_0530"):
		target_player.call("add_vehicle_distance_0530", distance)
	driver_last_position_0530 = vehicle.global_position
	target_player.global_position = vehicle.global_position + Vector3(0.0, 0.12, 0.0)
	target_player.set("velocity", Vector3.ZERO)

func exit_vehicle_for_player_0530(target_player: Node) -> bool:
	if target_player == null or not target_player.has_method("get_vehicle_uid_0530"):
		return false
	var uid := str(target_player.call("get_vehicle_uid_0530"))
	if uid == "":
		return false
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null:
		return false
	if vehicle.has_method("clear_driver_0530"):
		vehicle.call("clear_driver_0530")
	var side := vehicle.global_transform.basis.x.normalized()
	var exit_pos := vehicle.global_position + side * 1.75 + Vector3(0.0, -0.08, 0.0)
	target_player.call("exit_vehicle_0530", exit_pos)
	vehicle_exits_0530 += 1
	update_vehicle_record_0530(vehicle)
	save_game()
	return true

func force_exit_vehicle_0530(uid: String) -> void:
	if player == null or not player.has_method("get_vehicle_uid_0530"):
		return
	if str(player.call("get_vehicle_uid_0530")) == uid:
		exit_vehicle_for_player_0530(player)

func _restore_pending_driver_0530() -> void:
	await get_tree().process_frame
	if player == null or not player.has_method("get_pending_vehicle_uid_0530"):
		return
	var uid := str(player.call("get_pending_vehicle_uid_0530"))
	if uid == "":
		return
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null or not vehicle.has_method("set_driver_0530"):
		return
	if not bool(vehicle.call("set_driver_0530", player)):
		return
	if player.has_method("enter_vehicle_0530") and bool(player.call("enter_vehicle_0530", uid, false)):
		driver_last_position_0530 = vehicle.global_position
		sync_driver_player_0530(player, uid)

func get_vehicle_status_0530(uid: String) -> Dictionary:
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null or not vehicle.has_method("get_status_0530"):
		return {}
	var status := vehicle.call("get_status_0530") as Dictionary
	status["near"] = player != null and Vector2(player.global_position.x - vehicle.global_position.x, player.global_position.z - vehicle.global_position.z).length() <= VEHICLE_INTERACT_RANGE_0530 + 0.45
	var backpack: Dictionary = {}
	if player != null and player.has_method("get_inventory_snapshot"):
		backpack = player.call("get_inventory_snapshot") as Dictionary
	status["backpack_gasoline"] = int(backpack.get("gasoline", 0))
	status["backpack_repair_kits"] = int(backpack.get("repair_kit", 0))
	return status

func vehicle_refuel_0530(uid: String, target_player: Node) -> bool:
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null or target_player == null or not target_player.has_method("consume_gasoline_0530"):
		return false
	var status := get_vehicle_status_0530(uid)
	if not bool(status.get("near", false)) or float(status.get("fuel", 0.0)) > float(status.get("max_fuel", 0.0)) - 0.99:
		return false
	if not bool(target_player.call("consume_gasoline_0530", 1)):
		return false
	var added := float(vehicle.call("add_fuel_0530", 1.0))
	if added <= 0.0:
		target_player.call("receive_inventory_item_0530", "gasoline", 1)
		return false
	vehicle_refuels_0530 += 1
	save_game()
	return true

func vehicle_repair_0530(uid: String, target_player: Node) -> bool:
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null or target_player == null or not target_player.has_method("consume_repair_kit_0530"):
		return false
	var status := get_vehicle_status_0530(uid)
	var health := float(status.get("health", 0.0))
	var max_health := float(status.get("max_health", 0.0))
	if not bool(status.get("near", false)) or health >= max_health - 0.01 or int(status.get("variant", 8)) == 8:
		return false
	if not bool(target_player.call("consume_repair_kit_0530", 1)):
		return false
	var repaired := float(vehicle.call("repair_0530", max_health * VEHICLE_REPAIR_PERCENT_0530))
	if repaired <= 0.0:
		target_player.call("receive_inventory_item_0530", "repair_kit", 1)
		return false
	vehicle_repairs_0530 += 1
	save_game()
	return true

func vehicle_trunk_deposit_0530(uid: String, item_id: String, amount: int, target_player: Node) -> bool:
	if item_id not in VEHICLE_TRUNK_ITEMS_0530 or amount <= 0 or target_player == null:
		return false
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null or not vehicle.has_method("trunk_deposit_0530") or not target_player.has_method("consume_inventory_item_0530"):
		return false
	var status := get_vehicle_status_0530(uid)
	if not bool(status.get("near", false)) or int(status.get("trunk_total", 0)) + amount > int(status.get("trunk_capacity", 0)):
		return false
	if not bool(target_player.call("consume_inventory_item_0530", item_id, amount)):
		return false
	if not bool(vehicle.call("trunk_deposit_0530", item_id, amount)):
		target_player.call("receive_inventory_item_0530", item_id, amount)
		return false
	vehicle_trunk_transfers_0530 += amount
	save_game()
	return true

func vehicle_trunk_withdraw_0530(uid: String, item_id: String, amount: int, target_player: Node) -> bool:
	if item_id not in VEHICLE_TRUNK_ITEMS_0530 or amount <= 0 or target_player == null:
		return false
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null or not vehicle.has_method("trunk_withdraw_0530") or not target_player.has_method("receive_inventory_item_0530"):
		return false
	var status := get_vehicle_status_0530(uid)
	if not bool(status.get("near", false)):
		return false
	if not bool(vehicle.call("trunk_withdraw_0530", item_id, amount)):
		return false
	target_player.call("receive_inventory_item_0530", item_id, amount)
	vehicle_trunk_transfers_0530 += amount
	save_game()
	return true

func get_environment_state_0521(pos: Vector3) -> Dictionary:
	var result := super.get_environment_state_0521(pos)
	if player != null and player.has_method("is_in_vehicle_0530") and bool(player.call("is_in_vehicle_0530")):
		var uid := str(player.call("get_vehicle_uid_0530"))
		var vehicle := _find_vehicle_0530(uid)
		if vehicle != null and Vector2(pos.x - vehicle.global_position.x, pos.z - vehicle.global_position.z).length() < 1.2:
			result["sheltered"] = true
			result["vehicle_shelter_0530"] = true
			result["effective_temperature"] = lerpf(float(result.get("effective_temperature", 18.0)), 19.0, 0.52)
	return result

func save_game() -> void:
	_sync_all_vehicle_records_0530()
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_0530
	var world_state := payload.get("world", {}) as Dictionary
	world_state["vehicle_records_0530"] = vehicle_records_0530.duplicate(true)
	world_state["vehicle_entries_0530"] = vehicle_entries_0530
	world_state["vehicle_exits_0530"] = vehicle_exits_0530
	world_state["vehicle_refuels_0530"] = vehicle_refuels_0530
	world_state["vehicle_repairs_0530"] = vehicle_repairs_0530
	world_state["vehicle_trunk_transfers_0530"] = vehicle_trunk_transfers_0530
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	vehicle_records_0530.clear()
	vehicle_entries_0530 = 0
	vehicle_exits_0530 = 0
	vehicle_refuels_0530 = 0
	vehicle_repairs_0530 = 0
	vehicle_trunk_transfers_0530 = 0
	if vehicle_runtime_root_0530 != null and is_instance_valid(vehicle_runtime_root_0530):
		for child in vehicle_runtime_root_0530.get_children():
			child.queue_free()
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["vehicles_persistent_0530"] = vehicle_records_0530.size()
	result["vehicle_entries_0530"] = vehicle_entries_0530
	if player != null and player.has_method("is_in_vehicle_0530") and bool(player.call("is_in_vehicle_0530")):
		var uid := str(player.call("get_vehicle_uid_0530"))
		var status := get_vehicle_status_0530(uid)
		result["driving_vehicle_0530"] = str(status.get("name", "Veículo"))
		result["driving_fuel_0530"] = float(status.get("fuel", 0.0))
		result["driving_health_0530"] = float(status.get("health", 0.0))
	else:
		result["driving_vehicle_0530"] = ""
	return result

func get_vehicle_debug_0530() -> Dictionary:
	var occupied := 0
	for raw: Node in get_tree().get_nodes_in_group("vehicle_0530"):
		if raw.has_method("get_status_0530"):
			var status := raw.call("get_status_0530") as Dictionary
			if bool(status.get("occupied", false)):
				occupied += 1
	return {
		"player_0530": player != null and player.get_script() == PlayerV0530Script,
		"streamed": get_tree().get_nodes_in_group("vehicle_streamed_0530").size(),
		"persistent": get_tree().get_nodes_in_group("vehicle_persistent_0530").size(),
		"records": vehicle_records_0530.size(),
		"occupied": occupied,
		"entries": vehicle_entries_0530,
		"exits": vehicle_exits_0530,
		"refuels": vehicle_refuels_0530,
		"repairs": vehicle_repairs_0530,
		"transfers": vehicle_trunk_transfers_0530
	}
