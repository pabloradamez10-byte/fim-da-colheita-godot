extends "res://scripts/world/world_runtime_3d_v0526.gd"

const PlayerV0527Script = preload("res://scripts/player/player_3d_v0527.gd")
const ZombieV0527Script = preload("res://scripts/entities/zombie_3d_v0527.gd")
const BuiltHinge0527Script = preload("res://scripts/world/built_hinge_0527.gd")
const SAVE_VERSION_0527 := "0.5.27-alpha"
const BUILD_PIECES_0527 := ["floor", "wall", "fence", "crate", "door", "gate"]
const MAINTENANCE_RANGE_0527 := 2.75
const STRUCTURE_MAX_HEALTH_0527 := {
	"floor": 90.0,
	"wall": 180.0,
	"fence": 105.0,
	"crate": 95.0,
	"door": 135.0,
	"gate": 150.0
}

var repaired_world_structures_0527 := 0
var dismantled_world_structures_0527 := 0
var destroyed_world_structures_0527 := 0
var last_structure_event_0527 := ""

func _load_save() -> void:
	super._load_save()
	for i in range(structure_records_0526.size()):
		var record: Dictionary = structure_records_0526[i]
		var piece_id: String = str(record.get("type", "wall"))
		var max_health: float = get_structure_max_health_0527(piece_id)
		if not record.has("max_health_0527"):
			record["max_health_0527"] = max_health
		if not record.has("health_0527"):
			record["health_0527"] = max_health
		if piece_id in ["door", "gate"] and not record.has("open_0527"):
			record["open_0527"] = false
		structure_records_0526[i] = record
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	repaired_world_structures_0527 = int(world_state.get("repaired_world_structures_0527", 0))
	dismantled_world_structures_0527 = int(world_state.get("dismantled_world_structures_0527", 0))
	destroyed_world_structures_0527 = int(world_state.get("destroyed_world_structures_0527", 0))

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0527Script.new()
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
		var zombie: CharacterBody3D = ZombieV0527Script.new()
		zombie.name = zombie_name
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func get_structure_max_health_0527(piece_id: String) -> float:
	return float(STRUCTURE_MAX_HEALTH_0527.get(piece_id, 100.0))

func enter_build_mode_0526(piece_id: String = "floor") -> bool:
	if piece_id not in BUILD_PIECES_0527:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	preview_yaw_0526 = 0.0
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func select_build_piece_0526(piece_id: String) -> bool:
	if piece_id not in BUILD_PIECES_0527:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func _rebuild_preview_0526() -> void:
	if build_preview_0526 != null and is_instance_valid(build_preview_0526):
		build_preview_0526.queue_free()
	build_preview_0526 = Node3D.new()
	build_preview_0526.name = "BuildPreview0527"
	build_preview_0526.add_to_group("build_preview_0526")
	add_child(build_preview_0526)
	_draw_piece_0527(build_preview_0526, selected_piece_0526, preview_valid_material_0526, false, false)
	build_preview_0526.rotation_degrees.y = preview_yaw_0526

func _can_place_structure_0526(piece_id: String, pos: Vector3, yaw: float) -> bool:
	if player == null or piece_id not in BUILD_PIECES_0527:
		return false
	if not player.has_method("can_afford_build_0526") or not bool(player.call("can_afford_build_0526", piece_id)):
		return false
	var distance: float = Vector2(pos.x - player.global_position.x, pos.z - player.global_position.z).length()
	if distance < 1.45 or distance > BUILD_MAX_DISTANCE_0526:
		return false
	for record: Dictionary in structure_records_0526:
		var record_pos: Vector3 = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
		var record_type: String = str(record.get("type", ""))
		var gap: float = Vector2(pos.x - record_pos.x, pos.z - record_pos.z).length()
		if gap < 0.55 and piece_id == record_type:
			return false
		if gap < 1.05 and piece_id != "floor" and record_type != "floor":
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
		"door":
			return {"size": Vector3(2.62, 2.42, 0.18), "offset": Vector3(0.0, 1.21, 0.0)}
		"gate":
			return {"size": Vector3(2.62, 1.62, 0.18), "offset": Vector3(0.0, 0.81, 0.0)}
	return super._validation_shape_0526(piece_id)

func place_build_preview_0526() -> bool:
	if not build_mode_0526:
		return false
	_update_build_preview_0526(true)
	if not preview_valid_0526:
		return false
	if player == null or not player.has_method("consume_build_cost_0526"):
		return false
	if not bool(player.call("consume_build_cost_0526", selected_piece_0526)):
		return false
	structure_serial_0526 += 1
	var uid: String = "build0527:%d:%d" % [world_seed, structure_serial_0526]
	var max_health: float = get_structure_max_health_0527(selected_piece_0526)
	var record: Dictionary = {
		"uid": uid,
		"type": selected_piece_0526,
		"position": _vec_to_dict_0526(preview_position_0526),
		"yaw": preview_yaw_0526,
		"health_0527": max_health,
		"max_health_0527": max_health
	}
	if selected_piece_0526 in ["door", "gate"]:
		record["open_0527"] = false
	structure_records_0526.append(record)
	if selected_piece_0526 == "crate":
		storage_records_0526[uid] = {}
	_spawn_structure_record_0526(record)
	last_structure_event_0527 = "built:%s" % selected_piece_0526
	save_game()
	_update_build_preview_0526(true)
	return true

func _spawn_structure_record_0526(record: Dictionary) -> Node3D:
	var piece_id: String = str(record.get("type", ""))
	if piece_id not in BUILD_PIECES_0527:
		return null
	if piece_id in ["floor", "wall", "fence", "crate"]:
		var old_root: Node3D = super._spawn_structure_record_0526(record)
		if old_root != null:
			old_root.set_meta("health_0527", float(record.get("health_0527", get_structure_max_health_0527(piece_id))))
			old_root.set_meta("max_health_0527", float(record.get("max_health_0527", get_structure_max_health_0527(piece_id))))
		return old_root
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
	root.add_to_group("build_%s_0527" % piece_id)
	root.set_meta("build_uid_0526", uid)
	root.set_meta("build_type_0526", piece_id)
	root.set_meta("health_0527", float(record.get("health_0527", get_structure_max_health_0527(piece_id))))
	root.set_meta("max_health_0527", float(record.get("max_health_0527", get_structure_max_health_0527(piece_id))))
	build_root_0526.add_child(root)
	root.global_position = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
	root.rotation_degrees.y = float(record.get("yaw", 0.0))
	_draw_piece_0527(root, piece_id, null, true, bool(record.get("open_0527", false)))
	return root

func _draw_piece_0527(root: Node3D, piece_id: String, override_material: Material, solid: bool, open_state: bool) -> void:
	if piece_id in ["floor", "wall", "fence", "crate"]:
		_draw_piece_0526(root, piece_id, override_material, solid)
		return
	var wood_mat: Material = override_material if override_material != null else materials["wood"]
	var dark_mat: Material = override_material if override_material != null else materials["wood_dark"]
	var old_mat: Material = override_material if override_material != null else materials["wood_old"]
	if piece_id == "door":
		_box(root, Vector3(0.18, 2.55, 0.24), Vector3(-1.32, 1.275, 0.0), dark_mat)
		_box(root, Vector3(0.18, 2.55, 0.24), Vector3(1.32, 1.275, 0.0), dark_mat)
		_box(root, Vector3(2.82, 0.18, 0.24), Vector3(0.0, 2.47, 0.0), dark_mat)
		if solid:
			var hinge: Node3D = BuiltHinge0527Script.new()
			hinge.name = "DoorHinge0527"
			hinge.set("interaction_kind", "door")
			hinge.position = Vector3(-1.18, 0.0, 0.0)
			root.add_child(hinge)
			var body := StaticBody3D.new()
			body.name = "BuiltDoorPanel0527"
			body.position = Vector3(1.18, 1.22, 0.0)
			hinge.add_child(body)
			var mesh := BoxMesh.new()
			mesh.size = Vector3(2.32, 2.38, 0.16)
			mesh.material = old_mat
			var mesh_node := MeshInstance3D.new()
			mesh_node.mesh = mesh
			body.add_child(mesh_node)
			var shape := BoxShape3D.new()
			shape.size = Vector3(2.20, 2.32, 0.12)
			var collision := CollisionShape3D.new()
			collision.shape = shape
			body.add_child(collision)
			hinge.call("set_open_state_0527", open_state, false)
		else:
			_box(root, Vector3(2.32, 2.38, 0.16), Vector3(0.0, 1.22, 0.0), old_mat)
	elif piece_id == "gate":
		_box(root, Vector3(0.18, 1.72, 0.18), Vector3(-1.30, 0.86, 0.0), dark_mat)
		_box(root, Vector3(0.18, 1.72, 0.18), Vector3(1.30, 0.86, 0.0), dark_mat)
		if solid:
			var hinge_gate: Node3D = BuiltHinge0527Script.new()
			hinge_gate.name = "GateHinge0527"
			hinge_gate.set("interaction_kind", "gate")
			hinge_gate.set("open_angle_degrees", 100.0)
			hinge_gate.position = Vector3(-1.20, 0.0, 0.0)
			root.add_child(hinge_gate)
			var gate_body := StaticBody3D.new()
			gate_body.name = "BuiltGatePanel0527"
			gate_body.position = Vector3(1.18, 0.76, 0.0)
			hinge_gate.add_child(gate_body)
			var gate_mesh := BoxMesh.new()
			gate_mesh.size = Vector3(2.30, 1.44, 0.14)
			gate_mesh.material = wood_mat
			var gate_mesh_node := MeshInstance3D.new()
			gate_mesh_node.mesh = gate_mesh
			gate_body.add_child(gate_mesh_node)
			var gate_shape := BoxShape3D.new()
			gate_shape.size = Vector3(2.20, 1.38, 0.12)
			var gate_collision := CollisionShape3D.new()
			gate_collision.shape = gate_shape
			gate_body.add_child(gate_collision)
			hinge_gate.call("set_open_state_0527", open_state, false)
		else:
			_box(root, Vector3(2.30, 1.44, 0.14), Vector3(0.0, 0.76, 0.0), wood_mat)

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var hinge: Node3D = _nearest_built_hinge_0527(pos)
	if hinge != null:
		hinge.call("toggle_interaction")
		var structure: Node3D = _structure_root_from_node_0527(hinge)
		if structure != null:
			var uid: String = str(structure.get_meta("build_uid_0526", ""))
			var open_state: bool = bool(hinge.get("is_open"))
			_update_record_field_0527(uid, "open_0527", open_state)
			last_structure_event_0527 = "open:%s:%s" % [str(structure.get_meta("build_type_0526", "")), str(open_state)]
			save_game()
		return true
	return super.try_interact_near(pos, target_player)

func _nearest_built_hinge_0527(pos: Vector3) -> Node3D:
	var nearest: Node3D = null
	var best: float = MAINTENANCE_RANGE_0527
	for raw: Node in get_tree().get_nodes_in_group("built_hinge_0527"):
		if not (raw is Node3D):
			continue
		var hinge := raw as Node3D
		var distance: float = Vector2(pos.x - hinge.global_position.x, pos.z - hinge.global_position.z).length()
		if distance <= best:
			best = distance
			nearest = hinge
	return nearest

func get_nearest_structure_status_0527(pos: Vector3 = Vector3.INF) -> Dictionary:
	if player == null:
		return {}
	var origin: Vector3 = player.global_position if not pos.is_finite() else pos
	var nearest: Node3D = _nearest_structure_0527(origin)
	if nearest == null:
		return {}
	var uid: String = str(nearest.get_meta("build_uid_0526", ""))
	var index: int = _record_index_0527(uid)
	if index < 0:
		return {}
	var record: Dictionary = structure_records_0526[index]
	var health: float = float(record.get("health_0527", get_structure_max_health_0527(str(record.get("type", "")))))
	var max_health: float = float(record.get("max_health_0527", get_structure_max_health_0527(str(record.get("type", "")))))
	return {
		"uid": uid,
		"type": str(record.get("type", "")),
		"health": health,
		"max_health": max_health,
		"ratio": health / maxf(1.0, max_health),
		"distance": Vector2(origin.x - nearest.global_position.x, origin.z - nearest.global_position.z).length(),
		"storage_total": get_storage_total_0526(uid) if str(record.get("type", "")) == "crate" else 0
	}

func repair_nearest_structure_0527() -> bool:
	if player == null:
		return false
	var status: Dictionary = get_nearest_structure_status_0527(player.global_position)
	if status.is_empty():
		return false
	var health: float = float(status.get("health", 0.0))
	var max_health: float = float(status.get("max_health", 1.0))
	var piece_id: String = str(status.get("type", ""))
	if health >= max_health - 0.01:
		return false
	if not player.has_method("consume_repair_cost_0527") or not bool(player.call("consume_repair_cost_0527", piece_id, health, max_health)):
		return false
	var uid: String = str(status.get("uid", ""))
	_update_record_field_0527(uid, "health_0527", max_health)
	var structure: Node3D = _find_structure_node_0527(uid)
	if structure != null:
		structure.set_meta("health_0527", max_health)
	repaired_world_structures_0527 += 1
	last_structure_event_0527 = "repair:%s" % piece_id
	save_game()
	return true

func dismantle_nearest_structure_0527() -> bool:
	if player == null:
		return false
	var status: Dictionary = get_nearest_structure_status_0527(player.global_position)
	if status.is_empty():
		return false
	var uid: String = str(status.get("uid", ""))
	var piece_id: String = str(status.get("type", ""))
	if piece_id == "crate" and get_storage_total_0526(uid) > 0:
		return false
	if player.has_method("receive_dismantle_refund_0527"):
		player.call("receive_dismantle_refund_0527", piece_id)
	_remove_structure_0527(uid, false)
	dismantled_world_structures_0527 += 1
	last_structure_event_0527 = "dismantle:%s" % piece_id
	save_game()
	return true

func damage_structure_0527(uid: String, amount: float, source: String = "unknown") -> bool:
	if uid == "" or amount <= 0.0:
		return false
	var index: int = _record_index_0527(uid)
	if index < 0:
		return false
	var record: Dictionary = structure_records_0526[index]
	var piece_id: String = str(record.get("type", ""))
	var max_health: float = float(record.get("max_health_0527", get_structure_max_health_0527(piece_id)))
	var health: float = maxf(0.0, float(record.get("health_0527", max_health)) - amount)
	record["health_0527"] = health
	record["max_health_0527"] = max_health
	structure_records_0526[index] = record
	var structure: Node3D = _find_structure_node_0527(uid)
	if structure != null:
		structure.set_meta("health_0527", health)
	last_structure_event_0527 = "damage:%s:%s" % [piece_id, source]
	if health <= 0.0:
		_remove_structure_0527(uid, true)
		destroyed_world_structures_0527 += 1
		if player != null and player.has_method("register_destroyed_structure_0527"):
			player.call("register_destroyed_structure_0527")
	save_game()
	return true

func _remove_structure_0527(uid: String, destroyed: bool) -> void:
	var index: int = _record_index_0527(uid)
	if index < 0:
		return
	var record: Dictionary = structure_records_0526[index]
	var piece_id: String = str(record.get("type", ""))
	structure_records_0526.remove_at(index)
	if piece_id == "crate":
		storage_records_0526.erase(uid)
	var structure: Node3D = _find_structure_node_0527(uid)
	if structure != null:
		structure.queue_free()
	if destroyed:
		last_structure_event_0527 = "destroyed:%s" % piece_id

func _nearest_structure_0527(pos: Vector3) -> Node3D:
	var nearest: Node3D = null
	var best: float = MAINTENANCE_RANGE_0527
	for raw: Node in get_tree().get_nodes_in_group("build_structure_0526"):
		if not (raw is Node3D):
			continue
		var structure := raw as Node3D
		var distance: float = Vector2(pos.x - structure.global_position.x, pos.z - structure.global_position.z).length()
		if distance <= best:
			best = distance
			nearest = structure
	return nearest

func _structure_root_from_node_0527(node: Node) -> Node3D:
	var current: Node = node
	while current != null:
		if current is Node3D and current.is_in_group("build_structure_0526"):
			return current as Node3D
		current = current.get_parent()
	return null

func _find_structure_node_0527(uid: String) -> Node3D:
	for raw: Node in get_tree().get_nodes_in_group("build_structure_0526"):
		if raw is Node3D and str((raw as Node3D).get_meta("build_uid_0526", "")) == uid:
			return raw as Node3D
	return null

func _record_index_0527(uid: String) -> int:
	for i in range(structure_records_0526.size()):
		if str(structure_records_0526[i].get("uid", "")) == uid:
			return i
	return -1

func _update_record_field_0527(uid: String, key: String, value: Variant) -> void:
	var index: int = _record_index_0527(uid)
	if index < 0:
		return
	var record: Dictionary = structure_records_0526[index]
	record[key] = value
	structure_records_0526[index] = record

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0527,
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
			"destroyed_world_structures_0527": destroyed_world_structures_0527
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	repaired_world_structures_0527 = 0
	dismantled_world_structures_0527 = 0
	destroyed_world_structures_0527 = 0
	last_structure_event_0527 = ""
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result: Dictionary = super.get_world_summary()
	result["repaired_structures_0527"] = repaired_world_structures_0527
	result["dismantled_structures_0527"] = dismantled_world_structures_0527
	result["destroyed_structures_0527"] = destroyed_world_structures_0527
	return result

func get_structure_debug_0527() -> Dictionary:
	var damaged: int = 0
	for record: Dictionary in structure_records_0526:
		var max_health: float = float(record.get("max_health_0527", 1.0))
		if float(record.get("health_0527", max_health)) < max_health - 0.01:
			damaged += 1
	return {
		"player_0527": player != null and player.get_script() == PlayerV0527Script,
		"structures": structure_records_0526.size(),
		"doors": get_tree().get_nodes_in_group("build_door_0527").size(),
		"gates": get_tree().get_nodes_in_group("build_gate_0527").size(),
		"hinges": get_tree().get_nodes_in_group("built_hinge_0527").size(),
		"damaged": damaged,
		"repaired": repaired_world_structures_0527,
		"dismantled": dismantled_world_structures_0527,
		"destroyed": destroyed_world_structures_0527,
		"last_event": last_structure_event_0527
	}
