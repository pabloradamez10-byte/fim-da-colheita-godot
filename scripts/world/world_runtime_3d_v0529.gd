extends "res://scripts/world/world_runtime_3d_v0528_final.gd"

const PlayerV0529Script = preload("res://scripts/player/player_3d_v0529.gd")
const SAVE_VERSION_0529 := "0.5.29-alpha"
const BUILD_PIECES_0529 := ["floor", "wall", "door", "fence", "gate", "crate", "barricade", "campfire", "rain_collector"]
const RAIN_COLLECTOR_RANGE_0529 := 2.75
const RAIN_COLLECTOR_CAPACITY_0529 := 18.0
const RAIN_COLLECTION_PER_MINUTE_0529 := 0.055
const WATER_BOIL_FUEL_COST_0529 := 10.0
const RAIN_COLLECTOR_HEALTH_0529 := 115.0

var rain_collected_total_0529 := 0.0
var water_purified_total_0529 := 0
var unsafe_direct_drinks_0529 := 0

func _load_save() -> void:
	super._load_save()
	for i in range(structure_records_0526.size()):
		var record: Dictionary = structure_records_0526[i]
		if str(record.get("type", "")) == "rain_collector":
			if not record.has("water_units_0529"):
				record["water_units_0529"] = 0.0
			if not record.has("water_capacity_0529"):
				record["water_capacity_0529"] = RAIN_COLLECTOR_CAPACITY_0529
			structure_records_0526[i] = record
	var world_state := save_cache.get("world", {}) as Dictionary
	rain_collected_total_0529 = float(world_state.get("rain_collected_total_0529", 0.0))
	water_purified_total_0529 = int(world_state.get("water_purified_total_0529", 0))
	unsafe_direct_drinks_0529 = int(world_state.get("unsafe_direct_drinks_0529", 0))

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0529Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func advance_time_0521(minutes: float, refresh_visuals: bool = true) -> void:
	super.advance_time_0521(minutes, refresh_visuals)
	if minutes > 0.0:
		_collect_rain_0529(minutes)

func get_structure_max_health_0527(piece_id: String) -> float:
	if piece_id == "rain_collector":
		return RAIN_COLLECTOR_HEALTH_0529
	return super.get_structure_max_health_0527(piece_id)

func enter_build_mode_0526(piece_id: String = "floor") -> bool:
	if piece_id not in BUILD_PIECES_0529:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	preview_yaw_0526 = 0.0
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func select_build_piece_0526(piece_id: String) -> bool:
	if piece_id not in BUILD_PIECES_0529:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func _can_place_structure_0526(piece_id: String, pos: Vector3, yaw: float) -> bool:
	if piece_id != "rain_collector":
		return super._can_place_structure_0526(piece_id, pos, yaw)
	if player == null or not player.has_method("can_afford_build_0526"):
		return false
	if not bool(player.call("can_afford_build_0526", piece_id)):
		return false
	var distance := Vector2(pos.x - player.global_position.x, pos.z - player.global_position.z).length()
	if distance < 1.45 or distance > BUILD_MAX_DISTANCE_0526:
		return false
	for record: Dictionary in structure_records_0526:
		var record_pos := _dict_to_vec_0526(record.get("position", {}) as Dictionary)
		var gap := Vector2(pos.x - record_pos.x, pos.z - record_pos.z).length()
		if gap < 1.20 and str(record.get("type", "")) != "floor":
			return false
	var info := _validation_shape_0526(piece_id)
	var shape := BoxShape3D.new()
	shape.size = info.get("size", Vector3.ONE) as Vector3
	var basis := Basis(Vector3.UP, deg_to_rad(yaw))
	var offset := basis * (info.get("offset", Vector3.ZERO) as Vector3)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(basis, pos + offset)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	if player is CollisionObject3D:
		query.exclude = [(player as CollisionObject3D).get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(query, 12).is_empty()

func _validation_shape_0526(piece_id: String) -> Dictionary:
	if piece_id == "rain_collector":
		return {"size": Vector3(1.62, 1.46, 1.52), "offset": Vector3(0.0, 0.73, 0.0)}
	return super._validation_shape_0526(piece_id)

func _draw_piece_0527(root: Node3D, piece_id: String, override_material: Material, solid: bool, open_state: bool) -> void:
	if piece_id != "rain_collector":
		super._draw_piece_0527(root, piece_id, override_material, solid, open_state)
		return
	var old_wood: Material = override_material if override_material != null else materials["wood_old"]
	var dark_wood: Material = override_material if override_material != null else materials["wood_dark"]
	var cloth_mat: Material = override_material if override_material != null else materials["cloth"]
	var metal_mat: Material = override_material if override_material != null else materials["metal"]
	var water_mat: Material = override_material if override_material != null else materials["water"]
	if solid:
		_solid_box(root, Vector3(1.48, 0.78, 1.34), Vector3(0.0, 0.42, 0.0), old_wood, "RainCollectorCollider0529")
	else:
		_box(root, Vector3(1.48, 0.78, 1.34), Vector3(0.0, 0.42, 0.0), old_wood)
	_box(root, Vector3(1.64, 0.10, 1.48), Vector3(0.0, 0.84, 0.0), metal_mat)
	_box(root, Vector3(1.22, 0.05, 1.10), Vector3(0.0, 0.90, 0.0), water_mat)
	for x: float in [-0.68, 0.68]:
		var mast := Node3D.new()
		mast.position = Vector3(x, 0.0, -0.42)
		root.add_child(mast)
		_box(mast, Vector3(0.10, 1.34, 0.10), Vector3(0.0, 1.25, 0.0), dark_wood)
	var catchment := Node3D.new()
	catchment.position = Vector3(0.0, 1.68, -0.22)
	catchment.rotation_degrees.x = -16.0
	root.add_child(catchment)
	_box(catchment, Vector3(1.62, 0.07, 1.10), Vector3.ZERO, cloth_mat)

func _spawn_structure_record_0526(record: Dictionary) -> Node3D:
	var piece_id := str(record.get("type", ""))
	if piece_id != "rain_collector":
		return super._spawn_structure_record_0526(record)
	if build_root_0526 == null:
		return null
	var uid := str(record.get("uid", ""))
	for raw: Node in get_tree().get_nodes_in_group("build_structure_0526"):
		if raw is Node3D and str((raw as Node3D).get_meta("build_uid_0526", "")) == uid:
			return raw as Node3D
	var root := Node3D.new()
	root.name = "Built_RainCollector_%s" % uid.get_slice(":", 2)
	root.add_to_group("build_structure_0526")
	root.add_to_group("build_rain_collector_0529")
	root.add_to_group("rain_collector_0529")
	root.set_meta("build_uid_0526", uid)
	root.set_meta("build_type_0526", piece_id)
	root.set_meta("collector_uid_0529", uid)
	root.set_meta("health_0527", float(record.get("health_0527", RAIN_COLLECTOR_HEALTH_0529)))
	root.set_meta("max_health_0527", float(record.get("max_health_0527", RAIN_COLLECTOR_HEALTH_0529)))
	build_root_0526.add_child(root)
	root.global_position = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
	root.rotation_degrees.y = float(record.get("yaw", 0.0))
	_draw_piece_0527(root, piece_id, null, true, false)
	if not record.has("water_units_0529"):
		_update_record_field_0527(uid, "water_units_0529", 0.0)
	if not record.has("water_capacity_0529"):
		_update_record_field_0527(uid, "water_capacity_0529", RAIN_COLLECTOR_CAPACITY_0529)
	return root

func _collect_rain_0529(minutes: float) -> void:
	if _resolved_weather_type_0522() != WEATHER_RAIN_0522:
		return
	for i in range(structure_records_0526.size()):
		var record: Dictionary = structure_records_0526[i]
		if str(record.get("type", "")) != "rain_collector":
			continue
		var pos := _dict_to_vec_0526(record.get("position", {}) as Dictionary)
		if _is_position_sheltered_0521(pos):
			continue
		var capacity := float(record.get("water_capacity_0529", RAIN_COLLECTOR_CAPACITY_0529))
		var current := float(record.get("water_units_0529", 0.0))
		var added := minf(capacity - current, minutes * RAIN_COLLECTION_PER_MINUTE_0529)
		if added <= 0.0:
			continue
		record["water_units_0529"] = current + added
		structure_records_0526[i] = record
		rain_collected_total_0529 += added

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var collector := _nearest_rain_collector_0529(pos)
	if collector != null:
		var uid := str(collector.get_meta("collector_uid_0529", ""))
		for raw_ui: Node in get_tree().get_nodes_in_group("water_ui_0529"):
			if raw_ui.has_method("open_water_collector_0529"):
				raw_ui.call("open_water_collector_0529", uid)
		return true
	return super.try_interact_near(pos, target_player)

func _nearest_rain_collector_0529(pos: Vector3) -> Node3D:
	var nearest: Node3D = null
	var best := RAIN_COLLECTOR_RANGE_0529
	for raw: Node in get_tree().get_nodes_in_group("rain_collector_0529"):
		if not (raw is Node3D):
			continue
		var collector := raw as Node3D
		var distance := Vector2(pos.x - collector.global_position.x, pos.z - collector.global_position.z).length()
		if distance <= best:
			best = distance
			nearest = collector
	return nearest

func get_rain_collector_status_0529(uid: String) -> Dictionary:
	var index := _record_index_0527(uid)
	if index < 0:
		return {}
	var record: Dictionary = structure_records_0526[index]
	if str(record.get("type", "")) != "rain_collector":
		return {}
	var structure := _find_structure_node_0527(uid)
	var near := false
	if structure != null and player != null:
		near = Vector2(player.global_position.x - structure.global_position.x, player.global_position.z - structure.global_position.z).length() <= RAIN_COLLECTOR_RANGE_0529 + 0.35
	return {
		"uid": uid,
		"water": float(record.get("water_units_0529", 0.0)),
		"capacity": float(record.get("water_capacity_0529", RAIN_COLLECTOR_CAPACITY_0529)),
		"near": near,
		"raining": _resolved_weather_type_0522() == WEATHER_RAIN_0522,
		"sheltered": structure != null and _is_position_sheltered_0521(structure.global_position)
	}

func collector_take_water_0529(uid: String, target_player: Node) -> bool:
	var index := _record_index_0527(uid)
	if index < 0 or target_player == null or not target_player.has_method("receive_dirty_water_0529"):
		return false
	var status := get_rain_collector_status_0529(uid)
	if not bool(status.get("near", false)) or float(status.get("water", 0.0)) < 1.0:
		return false
	var record: Dictionary = structure_records_0526[index]
	record["water_units_0529"] = maxf(0.0, float(record.get("water_units_0529", 0.0)) - 1.0)
	structure_records_0526[index] = record
	target_player.call("receive_dirty_water_0529", 1)
	save_game()
	return true

func collector_drink_raw_0529(uid: String, target_player: Node) -> bool:
	var index := _record_index_0527(uid)
	if index < 0 or target_player == null or not target_player.has_method("drink_unsafe_direct_0529"):
		return false
	var status := get_rain_collector_status_0529(uid)
	if not bool(status.get("near", false)) or float(status.get("water", 0.0)) < 1.0:
		return false
	var record: Dictionary = structure_records_0526[index]
	record["water_units_0529"] = maxf(0.0, float(record.get("water_units_0529", 0.0)) - 1.0)
	structure_records_0526[index] = record
	target_player.call("drink_unsafe_direct_0529")
	unsafe_direct_drinks_0529 += 1
	save_game()
	return true

func campfire_purify_water_0529(uid: String, target_player: Node) -> bool:
	var index := _record_index_0527(uid)
	if index < 0 or target_player == null or not target_player.has_method("purify_dirty_water_0529"):
		return false
	if not _campfire_is_near_player_0528(uid):
		return false
	var record: Dictionary = structure_records_0526[index]
	if str(record.get("type", "")) != "campfire" or not bool(record.get("burning_0528", false)):
		return false
	var fuel := float(record.get("fuel_minutes_0528", 0.0))
	if fuel < WATER_BOIL_FUEL_COST_0529:
		return false
	if not bool(target_player.call("purify_dirty_water_0529", 1)):
		return false
	fuel = maxf(0.0, fuel - WATER_BOIL_FUEL_COST_0529)
	record["fuel_minutes_0528"] = fuel
	if fuel <= 0.01:
		record["burning_0528"] = false
	structure_records_0526[index] = record
	_update_campfire_visual_0528(uid)
	water_purified_total_0529 += 1
	save_game()
	return true

func get_nearest_structure_status_0527(pos: Vector3 = Vector3.INF) -> Dictionary:
	var result := super.get_nearest_structure_status_0527(pos)
	if str(result.get("type", "")) == "rain_collector":
		var index := _record_index_0527(str(result.get("uid", "")))
		if index >= 0:
			result["water_units_0529"] = float(structure_records_0526[index].get("water_units_0529", 0.0))
	return result

func dismantle_nearest_structure_0527() -> bool:
	if player != null:
		var status := get_nearest_structure_status_0527(player.global_position)
		if str(status.get("type", "")) == "rain_collector" and float(status.get("water_units_0529", 0.0)) > 0.01:
			return false
	return super.dismantle_nearest_structure_0527()

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0529,
		"world": {
			"seed": world_seed,
			"farm_layout": farm_layout,
			"harvested": harvested_keys.duplicate(),
			"dead_zombies_0520": dead_zombies_0520.duplicate(),
			"corpse_records_0520": corpse_records_0520.duplicate(true),
			"death_bags_0520": death_bags_0520.duplicate(true),
			"kills_0520": kills_0520,
			"deaths_0520": deaths_0520,
			"world_day_0521": world_day_0521,
			"world_minutes_0521": world_minutes_0521,
			"structure_records_0526": structure_records_0526.duplicate(true),
			"storage_records_0526": storage_records_0526.duplicate(true),
			"structure_serial_0526": structure_serial_0526,
			"repaired_world_structures_0527": repaired_world_structures_0527,
			"dismantled_world_structures_0527": dismantled_world_structures_0527,
			"destroyed_world_structures_0527": destroyed_world_structures_0527,
			"campfire_ignitions_0528": campfire_ignitions_0528,
			"campfire_refuels_0528": campfire_refuels_0528,
			"rain_collected_total_0529": rain_collected_total_0529,
			"water_purified_total_0529": water_purified_total_0529,
			"unsafe_direct_drinks_0529": unsafe_direct_drinks_0529
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	rain_collected_total_0529 = 0.0
	water_purified_total_0529 = 0
	unsafe_direct_drinks_0529 = 0
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var stored := 0.0
	for record: Dictionary in structure_records_0526:
		if str(record.get("type", "")) == "rain_collector":
			stored += float(record.get("water_units_0529", 0.0))
	result["rain_water_stored_0529"] = stored
	result["rain_collected_total_0529"] = rain_collected_total_0529
	result["water_purified_total_0529"] = water_purified_total_0529
	return result

func get_water_debug_0529() -> Dictionary:
	var stored := 0.0
	for record: Dictionary in structure_records_0526:
		if str(record.get("type", "")) == "rain_collector":
			stored += float(record.get("water_units_0529", 0.0))
	return {
		"player_0529": player != null and player.get_script() == PlayerV0529Script,
		"collectors": get_tree().get_nodes_in_group("rain_collector_0529").size(),
		"stored": stored,
		"collected_total": rain_collected_total_0529,
		"purified_total": water_purified_total_0529,
		"unsafe_direct": unsafe_direct_drinks_0529,
		"capacity": RAIN_COLLECTOR_CAPACITY_0529
	}
