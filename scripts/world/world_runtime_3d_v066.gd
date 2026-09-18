extends "res://scripts/world/world_runtime_3d_v065.gd"

const QUALITY_VERSION_066 := "0.6.6-alpha"
const PlayerV066Script = preload("res://scripts/player/player_3d_v066.gd")
const ZombieV066Script = preload("res://scripts/entities/zombie_3d_v066.gd")
const VehicleV066Script = preload("res://scripts/entities/vehicle_3d_v066.gd")

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV066Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _spawn_zombies(count: int) -> void:
	_ensure_horde_records_0537()
	var spawn_count := maxi(14, count)
	for i in range(spawn_count):
		var zombie_name := "Zombie_%02d" % i
		if dead_zombies_0520.has(zombie_name):
			continue
		var horde_id := i % HORDE_COUNT_0537
		var member_index := int(i / HORDE_COUNT_0537)
		var record: Dictionary = horde_records_0537.get(str(horde_id), {}) as Dictionary
		var center := _dict_to_vec_0537(record.get("spawn", {}) as Dictionary)
		var member_angle := float(member_index * 2 + horde_id) * 1.31
		var member_radius := 1.8 + float(member_index % 3) * 1.25
		var spawn_pos := center + Vector3(cos(member_angle) * member_radius, 0.20, sin(member_angle) * member_radius)
		spawn_pos.y = 0.20
		var zombie: CharacterBody3D = ZombieV066Script.new()
		zombie.name = zombie_name
		zombie.call("configure_horde_0537", horde_id, member_index, (i + horde_id * 2) % ZOMBIE_PROFILE_COUNT_05402)
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func _restore_persistent_vehicles_0530() -> void:
	_ensure_vehicle_root_0530()
	for raw_uid: Variant in vehicle_records_0530.keys():
		var uid := str(raw_uid)
		if _find_vehicle_0530(uid) != null:
			continue
		var record: Dictionary = vehicle_records_0530[raw_uid] as Dictionary
		var vehicle: CharacterBody3D = VehicleV066Script.new()
		vehicle.call("configure_from_record_0530", self, uid, record)
		vehicle.add_to_group("vehicle_persistent_0530")
		vehicle.add_to_group("vehicle_persistent_066")
		vehicle_runtime_root_0530.add_child(vehicle)
		var pos: Dictionary = record.get("position", {}) as Dictionary
		vehicle.global_position = Vector3(
			float(pos.get("x", 0.0)),
			float(pos.get("y", 0.28)),
			float(pos.get("z", 0.0))
		)

func get_quality_debug_066() -> Dictionary:
	var player_debug: Dictionary = {}
	if player != null and is_instance_valid(player) and player.has_method("get_quality_debug_066"):
		player_debug = player.call("get_quality_debug_066") as Dictionary
	return {
		"version": QUALITY_VERSION_066,
		"player": player_debug,
		"zombies_066": get_tree().get_nodes_in_group("zombie_visual_066").size(),
		"vehicles_066": get_tree().get_nodes_in_group("vehicle_art_066").size(),
		"persistent_vehicles_066": get_tree().get_nodes_in_group("vehicle_persistent_066").size(),
		"ruin_vehicle_nodes": get_tree().get_nodes_in_group("vehicle_ruin_066").size()
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["quality_066"] = get_quality_debug_066()
	return result
