extends "res://scripts/world/world_runtime_3d_v0527.gd"

const PlayerV0528Script = preload("res://scripts/player/player_3d_v0528.gd")
const ZombieV0528Script = preload("res://scripts/entities/zombie_3d_v0528.gd")
const SAVE_VERSION_0528 := "0.5.28-alpha"
const BUILD_PIECES_0528 := ["floor", "wall", "door", "fence", "gate", "crate", "barricade", "campfire"]
const CAMPFIRE_RANGE_0528 := 2.65
const CAMPFIRE_WARMTH_RANGE_0528 := 7.5
const CAMPFIRE_FUEL_PER_WOOD_0528 := 60.0
const CAMPFIRE_MAX_FUEL_0528 := 360.0
const CAMPFIRE_NOISE_INTERVAL_0528 := 7.0
const STRUCTURE_MAX_HEALTH_0528 := {
	"barricade": 220.0,
	"campfire": 80.0
}

var campfire_noise_timer_0528 := 0.0
var campfire_ignitions_0528 := 0
var campfire_refuels_0528 := 0

func _load_save() -> void:
	super._load_save()
	for i in range(structure_records_0526.size()):
		var record: Dictionary = structure_records_0526[i]
		var piece_id: String = str(record.get("type", ""))
		if piece_id == "campfire":
			if not record.has("fuel_minutes_0528"):
				record["fuel_minutes_0528"] = 0.0
			if not record.has("burning_0528"):
				record["burning_0528"] = false
			structure_records_0526[i] = record
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	campfire_ignitions_0528 = int(world_state.get("campfire_ignitions_0528", 0))
	campfire_refuels_0528 = int(world_state.get("campfire_refuels_0528", 0))

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0528Script.new()
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
	for i in range(count):
		var zombie_name: String = "Zombie_%02d" % i
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(18.0, 52.0)
		var spawn_pos := Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
		if dead_zombies_0520.has(zombie_name):
			continue
		var zombie: CharacterBody3D = ZombieV0528Script.new()
		zombie.name = zombie_name
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func _process(delta: float) -> void:
	super._process(delta)
	campfire_noise_timer_0528 += delta
	if campfire_noise_timer_0528 >= CAMPFIRE_NOISE_INTERVAL_0528:
		campfire_noise_timer_0528 = 0.0
		_emit_campfire_noise_0528()

func advance_time_0521(minutes: float, refresh_visuals: bool = true) -> void:
	super.advance_time_0521(minutes, refresh_visuals)
	if minutes > 0.0:
		_burn_campfires_0528(minutes)

func get_structure_max_health_0527(piece_id: String) -> float:
	if STRUCTURE_MAX_HEALTH_0528.has(piece_id):
		return float(STRUCTURE_MAX_HEALTH_0528[piece_id])
	return super.get_structure_max_health_0527(piece_id)

func enter_build_mode_0526(piece_id: String = "floor") -> bool:
	if piece_id not in BUILD_PIECES_0528:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	preview_yaw_0526 = 0.0
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func select_build_piece_0526(piece_id: String) -> bool:
	if piece_id not in BUILD_PIECES_0528:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func _can_place_structure_0526(piece_id: String, pos: Vector3, yaw: float) -> bool:
	if piece_id not in ["barricade", "campfire"]:
		return super._can_place_structure_0526(piece_id, pos, yaw)
	if player == null or not player.has_method("can_afford_build_0526"):
		return false
	if not bool(player.call("can_afford_build_0526", piece_id)):
		return false
	var distance: float = Vector2(pos.x - player.global_position.x, pos.z - player.global_position.z).length()
	if distance < 1.45 or distance > BUILD_MAX_DISTANCE_0526:
		return false
	for record: Dictionary in structure_records_0526:
		var record_pos: Vector3 = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
		var record_type: String = str(record.get("type", ""))
		var gap: float = Vector2(pos.x - record_pos.x, pos.z - record_pos.z).length()
		if gap < 0.70 and piece_id == record_type:
			return false
		if gap < 1.15 and piece_id != "campfire" and record_type != "floor":
			return false
		if gap < 0.95 and piece_id == "campfire" and record_type != "floor":
			return false
	var info: Dictionary = _validation_shape_0526(piece_id)
	var shape := BoxShape3D.new()
	shape.size = info.get("size", Vector3.ONE) as Vector3
	var basis := Basis(Vector3.UP, deg_to_rad(yaw))
	var offset: Vector3 = basis * (info.get("offset", Vector3.ZERO) as Vector3)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(basis, pos + offset)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	if player is CollisionObject3D:
		query.exclude = [(player as CollisionObject3D).get_rid()]
	var hits: Array[Dictionary] = get_world_3d().direct_space_state.intersect_shape(query, 12)
	return hits.is_empty()

func _validation_shape_0526(piece_id: String) -> Dictionary:
	match piece_id:
		"barricade":
			return {"size": Vector3(2.70, 1.22, 0.74), "offset": Vector3(0.0, 0.62, 0.0)}
		"campfire":
			return {"size": Vector3(1.30, 0.16, 1.30), "offset": Vector3(0.0, 0.08, 0.0)}
	return super._validation_shape_0526(piece_id)

func _draw_piece_0527(root: Node3D, piece_id: String, override_material: Material, solid: bool, open_state: bool) -> void:
	if piece_id not in ["barricade", "campfire"]:
		super._draw_piece_0527(root, piece_id, override_material, solid, open_state)
		return
	var wood_mat: Material = override_material if override_material != null else materials["wood"]
	var dark_mat: Material = override_material if override_material != null else materials["wood_dark"]
	var stone_mat: Material = override_material if override_material != null else materials["stone"]
	if piece_id == "barricade":
		if solid:
			_solid_box(root, Vector3(2.74, 0.42, 0.62), Vector3(0.0, 0.32, 0.0), dark_mat, "BarricadeCollider0528")
		else:
			_box(root, Vector3(2.74, 0.42, 0.62), Vector3(0.0, 0.32, 0.0), dark_mat)
		for x: float in [-1.05, -0.52, 0.0, 0.52, 1.05]:
			var spike_root := Node3D.new()
			spike_root.position = Vector3(x, 0.54, -0.10)
			spike_root.rotation_degrees.x = -32.0
			root.add_child(spike_root)
			_box(spike_root, Vector3(0.14, 1.42, 0.14), Vector3(0.0, 0.55, 0.0), wood_mat)
		_box(root, Vector3(2.78, 0.14, 0.14), Vector3(0.0, 0.72, 0.13), wood_mat)
	elif piece_id == "campfire":
		for angle_index in range(8):
			var angle: float = float(angle_index) / 8.0 * TAU
			var stone_pos := Vector3(cos(angle) * 0.56, 0.12, sin(angle) * 0.56)
			_box(root, Vector3(0.34, 0.22, 0.28), stone_pos, stone_mat)
		var log_a := Node3D.new()
		log_a.rotation_degrees.y = 42.0
		root.add_child(log_a)
		_box(log_a, Vector3(1.05, 0.16, 0.18), Vector3(0.0, 0.18, 0.0), dark_mat)
		var log_b := Node3D.new()
		log_b.rotation_degrees.y = -42.0
		root.add_child(log_b)
		_box(log_b, Vector3(1.05, 0.16, 0.18), Vector3(0.0, 0.22, 0.0), wood_mat)
		if solid:
			_create_campfire_flame_0528(root)

func _spawn_structure_record_0526(record: Dictionary) -> Node3D:
	var piece_id: String = str(record.get("type", ""))
	if piece_id not in ["barricade", "campfire"]:
		return super._spawn_structure_record_0526(record)
	if build_root_0526 == null:
		return null
	var uid: String = str(record.get("uid", ""))
	for raw: Node in get_tree().get_nodes_in_group("build_structure_0526"):
		if raw is Node3D and str((raw as Node3D).get_meta("build_uid_0526", "")) == uid:
			return raw as Node3D
	var root := Node3D.new()
	root.name = "Built_%s_%s" % [piece_id.capitalize(), uid.get_slice(":", 2)]
	root.add_to_group("build_structure_0526")
	root.add_to_group("build_%s_0526" % piece_id)
	root.add_to_group("build_%s_0528" % piece_id)
	root.set_meta("build_uid_0526", uid)
	root.set_meta("build_type_0526", piece_id)
	root.set_meta("health_0527", float(record.get("health_0527", get_structure_max_health_0527(piece_id))))
	root.set_meta("max_health_0527", float(record.get("max_health_0527", get_structure_max_health_0527(piece_id))))
	build_root_0526.add_child(root)
	root.global_position = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
	root.rotation_degrees.y = float(record.get("yaw", 0.0))
	_draw_piece_0527(root, piece_id, null, true, false)
	if piece_id == "campfire":
		root.add_to_group("campfire_0528")
		root.set_meta("campfire_uid_0528", uid)
		if not record.has("fuel_minutes_0528"):
			_update_record_field_0527(uid, "fuel_minutes_0528", 0.0)
		if not record.has("burning_0528"):
			_update_record_field_0527(uid, "burning_0528", false)
		_update_campfire_visual_0528(uid)
	elif piece_id == "barricade":
		root.add_to_group("spike_barricade_0528")
	return root

func _create_campfire_flame_0528(root: Node3D) -> void:
	var flame_material := StandardMaterial3D.new()
	flame_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flame_material.albedo_color = Color(1.0, 0.42, 0.08, 0.88)
	flame_material.emission_enabled = true
	flame_material.emission = Color(1.0, 0.26, 0.03)
	flame_material.emission_energy_multiplier = 2.8
	var flame_mesh := SphereMesh.new()
	flame_mesh.radius = 0.25
	flame_mesh.height = 0.62
	flame_mesh.material = flame_material
	var flame := MeshInstance3D.new()
	flame.name = "CampfireFlame0528"
	flame.mesh = flame_mesh
	flame.position = Vector3(0.0, 0.52, 0.0)
	root.add_child(flame)
	var light := OmniLight3D.new()
	light.name = "CampfireLight0528"
	light.position = Vector3(0.0, 0.78, 0.0)
	light.light_color = Color(1.0, 0.48, 0.18)
	light.light_energy = 2.2
	light.omni_range = 7.0
	light.shadow_enabled = false
	root.add_child(light)

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var campfire: Node3D = _nearest_campfire_0528(pos)
	if campfire != null:
		var uid: String = str(campfire.get_meta("campfire_uid_0528", ""))
		for raw_ui: Node in get_tree().get_nodes_in_group("campfire_ui_0528"):
			if raw_ui.has_method("open_campfire_0528"):
				raw_ui.call("open_campfire_0528", uid)
		return true
	return super.try_interact_near(pos, target_player)

func _nearest_campfire_0528(pos: Vector3) -> Node3D:
	var nearest: Node3D = null
	var best: float = CAMPFIRE_RANGE_0528
	for raw: Node in get_tree().get_nodes_in_group("campfire_0528"):
		if not (raw is Node3D):
			continue
		var campfire := raw as Node3D
		var distance: float = Vector2(pos.x - campfire.global_position.x, pos.z - campfire.global_position.z).length()
		if distance <= best:
			best = distance
			nearest = campfire
	return nearest

func get_campfire_status_0528(uid: String) -> Dictionary:
	var index: int = _record_index_0527(uid)
	if index < 0:
		return {}
	var record: Dictionary = structure_records_0526[index]
	if str(record.get("type", "")) != "campfire":
		return {}
	return {
		"uid": uid,
		"fuel_minutes": float(record.get("fuel_minutes_0528", 0.0)),
		"burning": bool(record.get("burning_0528", false)),
		"max_fuel": CAMPFIRE_MAX_FUEL_0528,
		"fuel_per_wood": CAMPFIRE_FUEL_PER_WOOD_0528,
		"near": player != null and _campfire_is_near_player_0528(uid)
	}

func campfire_add_fuel_0528(uid: String, target_player: Node) -> bool:
	var index: int = _record_index_0527(uid)
	if index < 0 or not _campfire_is_near_player_0528(uid):
		return false
	var record: Dictionary = structure_records_0526[index]
	if str(record.get("type", "")) != "campfire":
		return false
	var fuel: float = float(record.get("fuel_minutes_0528", 0.0))
	if fuel > CAMPFIRE_MAX_FUEL_0528 - CAMPFIRE_FUEL_PER_WOOD_0528 + 0.01:
		return false
	if target_player == null or not target_player.has_method("consume_campfire_wood_0528"):
		return false
	if not bool(target_player.call("consume_campfire_wood_0528", 1)):
		return false
	fuel = minf(CAMPFIRE_MAX_FUEL_0528, fuel + CAMPFIRE_FUEL_PER_WOOD_0528)
	record["fuel_minutes_0528"] = fuel
	structure_records_0526[index] = record
	campfire_refuels_0528 += 1
	save_game()
	return true

func campfire_toggle_0528(uid: String) -> bool:
	var index: int = _record_index_0527(uid)
	if index < 0 or not _campfire_is_near_player_0528(uid):
		return false
	var record: Dictionary = structure_records_0526[index]
	if str(record.get("type", "")) != "campfire":
		return false
	var burning: bool = bool(record.get("burning_0528", false))
	var fuel: float = float(record.get("fuel_minutes_0528", 0.0))
	if not burning and fuel <= 0.01:
		return false
	burning = not burning
	record["burning_0528"] = burning
	structure_records_0526[index] = record
	if burning:
		campfire_ignitions_0528 += 1
	_update_campfire_visual_0528(uid)
	save_game()
	return true

func _campfire_is_near_player_0528(uid: String) -> bool:
	if player == null:
		return false
	var structure: Node3D = _find_structure_node_0527(uid)
	if structure == null:
		return false
	return Vector2(player.global_position.x - structure.global_position.x, player.global_position.z - structure.global_position.z).length() <= CAMPFIRE_RANGE_0528 + 0.35

func _burn_campfires_0528(minutes: float) -> void:
	for i in range(structure_records_0526.size()):
		var record: Dictionary = structure_records_0526[i]
		if str(record.get("type", "")) != "campfire" or not bool(record.get("burning_0528", false)):
			continue
		var fuel: float = float(record.get("fuel_minutes_0528", 0.0))
		var burn_rate: float = 1.0
		var fire_pos: Vector3 = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
		if _resolved_weather_type_0522() == WEATHER_RAIN_0522 and not _is_position_sheltered_0521(fire_pos):
			burn_rate = 1.35
		fuel = maxf(0.0, fuel - minutes * burn_rate)
		record["fuel_minutes_0528"] = fuel
		if fuel <= 0.01:
			record["burning_0528"] = false
		structure_records_0526[i] = record
		if fuel <= 0.01:
			_update_campfire_visual_0528(str(record.get("uid", "")))

func _update_campfire_visual_0528(uid: String) -> void:
	var structure: Node3D = _find_structure_node_0527(uid)
	if structure == null:
		return
	var index: int = _record_index_0527(uid)
	if index < 0:
		return
	var record: Dictionary = structure_records_0526[index]
	var burning: bool = bool(record.get("burning_0528", false)) and float(record.get("fuel_minutes_0528", 0.0)) > 0.01
	var flame: MeshInstance3D = structure.get_node_or_null("CampfireFlame0528") as MeshInstance3D
	if flame != null:
		flame.visible = burning
	var light: OmniLight3D = structure.get_node_or_null("CampfireLight0528") as OmniLight3D
	if light != null:
		light.visible = burning

func _emit_campfire_noise_0528() -> void:
	for record: Dictionary in structure_records_0526:
		if str(record.get("type", "")) != "campfire" or not bool(record.get("burning_0528", false)):
			continue
		var fire_pos: Vector3 = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
		emit_noise_0519(fire_pos, 7.5, "campfire", null)

func get_environment_state_0521(pos: Vector3) -> Dictionary:
	var result: Dictionary = super.get_environment_state_0521(pos)
	var warmth: float = 0.0
	for record: Dictionary in structure_records_0526:
		if str(record.get("type", "")) != "campfire" or not bool(record.get("burning_0528", false)):
			continue
		var fire_pos: Vector3 = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
		var distance: float = Vector2(pos.x - fire_pos.x, pos.z - fire_pos.z).length()
		if distance > CAMPFIRE_WARMTH_RANGE_0528:
			continue
		var local_warmth: float = lerpf(0.0, 8.5, 1.0 - distance / CAMPFIRE_WARMTH_RANGE_0528)
		warmth = maxf(warmth, local_warmth)
	if warmth > 0.0:
		result["effective_temperature"] = float(result.get("effective_temperature", 18.0)) + warmth
	result["campfire_warmth_0528"] = warmth
	return result

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0528,
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
			"campfire_refuels_0528": campfire_refuels_0528
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	campfire_noise_timer_0528 = 0.0
	campfire_ignitions_0528 = 0
	campfire_refuels_0528 = 0
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result: Dictionary = super.get_world_summary()
	var active: int = 0
	for record: Dictionary in structure_records_0526:
		if str(record.get("type", "")) == "campfire" and bool(record.get("burning_0528", false)):
			active += 1
	result["campfires_active_0528"] = active
	result["campfire_ignitions_0528"] = campfire_ignitions_0528
	return result

func get_base_utility_debug_0528() -> Dictionary:
	var burning: int = 0
	var fuel_total: float = 0.0
	for record: Dictionary in structure_records_0526:
		if str(record.get("type", "")) == "campfire":
			fuel_total += float(record.get("fuel_minutes_0528", 0.0))
			if bool(record.get("burning_0528", false)):
				burning += 1
	return {
		"player_0528": player != null and player.get_script() == PlayerV0528Script,
		"barricades": get_tree().get_nodes_in_group("spike_barricade_0528").size(),
		"campfires": get_tree().get_nodes_in_group("campfire_0528").size(),
		"burning": burning,
		"fuel_total": fuel_total,
		"refuels": campfire_refuels_0528,
		"ignitions": campfire_ignitions_0528,
		"zombies_0528": get_tree().get_nodes_in_group("zombies").size()
	}
