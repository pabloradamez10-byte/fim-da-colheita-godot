extends "res://scripts/world/world_runtime_3d_v0525.gd"

const PlayerV0526Script = preload("res://scripts/player/player_3d_v0526.gd")
const SAVE_VERSION_0526 := "0.5.26-alpha"
const BUILD_GRID_0526 := 1.4
const BUILD_DISTANCE_0526 := 3.35
const BUILD_MAX_DISTANCE_0526 := 5.6
const STORAGE_RANGE_0526 := 2.35
const STORAGE_CAPACITY_0526 := 60
const BUILD_PIECES_0526 := ["floor", "wall", "fence", "crate"]

var structure_records_0526: Array[Dictionary] = []
var storage_records_0526: Dictionary = {}
var structure_serial_0526 := 0
var build_root_0526: Node3D = null
var build_preview_0526: Node3D = null
var build_mode_0526 := false
var selected_piece_0526 := "floor"
var preview_yaw_0526 := 0.0
var preview_valid_0526 := false
var preview_position_0526 := Vector3.ZERO
var preview_timer_0526 := 0.0
var preview_valid_material_0526: StandardMaterial3D
var preview_invalid_material_0526: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_construction_root_0526()
	_restore_structures_0526()
	_create_preview_materials_0526()

func _process(delta: float) -> void:
	super._process(delta)
	if not build_mode_0526:
		return
	preview_timer_0526 += delta
	if preview_timer_0526 >= 0.07:
		preview_timer_0526 = 0.0
		_update_build_preview_0526()

func _load_save() -> void:
	super._load_save()
	structure_records_0526.clear()
	storage_records_0526.clear()
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	var raw_structures: Variant = world_state.get("structure_records_0526", [])
	if raw_structures is Array:
		for raw_record: Variant in raw_structures as Array:
			if raw_record is Dictionary:
				structure_records_0526.append((raw_record as Dictionary).duplicate(true))
	var raw_storage: Variant = world_state.get("storage_records_0526", {})
	if raw_storage is Dictionary:
		storage_records_0526 = (raw_storage as Dictionary).duplicate(true)
	structure_serial_0526 = int(world_state.get("structure_serial_0526", structure_records_0526.size()))

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0526Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _build_construction_root_0526() -> void:
	if build_root_0526 != null and is_instance_valid(build_root_0526):
		return
	build_root_0526 = Node3D.new()
	build_root_0526.name = "PlayerConstruction0526"
	build_root_0526.add_to_group("construction_root_0526")
	add_child(build_root_0526)

func _create_preview_materials_0526() -> void:
	preview_valid_material_0526 = StandardMaterial3D.new()
	preview_valid_material_0526.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	preview_valid_material_0526.albedo_color = Color(0.30, 0.92, 0.42, 0.42)
	preview_invalid_material_0526 = StandardMaterial3D.new()
	preview_invalid_material_0526.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	preview_invalid_material_0526.albedo_color = Color(0.94, 0.24, 0.20, 0.46)

func enter_build_mode_0526(piece_id: String = "floor") -> bool:
	if piece_id not in BUILD_PIECES_0526:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	preview_yaw_0526 = 0.0
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func select_build_piece_0526(piece_id: String) -> bool:
	if piece_id not in BUILD_PIECES_0526:
		return false
	selected_piece_0526 = piece_id
	build_mode_0526 = true
	_rebuild_preview_0526()
	_update_build_preview_0526(true)
	return true

func rotate_build_preview_0526() -> bool:
	if not build_mode_0526:
		return false
	preview_yaw_0526 = fmod(preview_yaw_0526 + 90.0, 360.0)
	if build_preview_0526 != null:
		build_preview_0526.rotation_degrees.y = preview_yaw_0526
	_update_build_preview_0526(true)
	return true

func cancel_build_mode_0526() -> void:
	build_mode_0526 = false
	if build_preview_0526 != null and is_instance_valid(build_preview_0526):
		build_preview_0526.queue_free()
	build_preview_0526 = null

func _rebuild_preview_0526() -> void:
	if build_preview_0526 != null and is_instance_valid(build_preview_0526):
		build_preview_0526.queue_free()
	build_preview_0526 = Node3D.new()
	build_preview_0526.name = "BuildPreview0526"
	build_preview_0526.add_to_group("build_preview_0526")
	add_child(build_preview_0526)
	_draw_piece_0526(build_preview_0526, selected_piece_0526, preview_valid_material_0526, false)
	build_preview_0526.rotation_degrees.y = preview_yaw_0526

func _update_build_preview_0526(force_material: bool = false) -> void:
	if not build_mode_0526 or player == null:
		return
	if build_preview_0526 == null or not is_instance_valid(build_preview_0526):
		_rebuild_preview_0526()
	var facing := Vector3(0.0, 0.0, 1.0)
	var raw_facing: Variant = player.get("last_move_dir")
	if raw_facing is Vector3:
		facing = raw_facing as Vector3
	facing.y = 0.0
	if facing.length() < 0.05:
		facing = Vector3(0.0, 0.0, 1.0)
	facing = facing.normalized()
	var target: Vector3 = player.global_position + facing * BUILD_DISTANCE_0526
	preview_position_0526 = Vector3(
		round(target.x / BUILD_GRID_0526) * BUILD_GRID_0526,
		0.20,
		round(target.z / BUILD_GRID_0526) * BUILD_GRID_0526
	)
	build_preview_0526.global_position = preview_position_0526
	build_preview_0526.rotation_degrees.y = preview_yaw_0526
	var old_valid: bool = preview_valid_0526
	preview_valid_0526 = _can_place_structure_0526(selected_piece_0526, preview_position_0526, preview_yaw_0526)
	if force_material or old_valid != preview_valid_0526:
		var material: Material = preview_valid_material_0526 if preview_valid_0526 else preview_invalid_material_0526
		_set_preview_material_0526(build_preview_0526, material)

func _set_preview_material_0526(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = material
	for child: Node in node.get_children():
		_set_preview_material_0526(child, material)

func _can_place_structure_0526(piece_id: String, pos: Vector3, yaw: float) -> bool:
	if player == null or piece_id not in BUILD_PIECES_0526:
		return false
	if not player.has_method("can_afford_build_0526"):
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
		"floor":
			return {"size": Vector3(2.55, 0.08, 2.55), "offset": Vector3(0.0, 0.05, 0.0)}
		"wall":
			return {"size": Vector3(2.62, 2.35, 0.16), "offset": Vector3(0.0, 1.20, 0.0)}
		"fence":
			return {"size": Vector3(2.62, 1.28, 0.14), "offset": Vector3(0.0, 0.66, 0.0)}
		"crate":
			return {"size": Vector3(1.18, 0.74, 0.88), "offset": Vector3(0.0, 0.39, 0.0)}
	return {"size": Vector3.ONE, "offset": Vector3.ZERO}

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
	var uid: String = "build0526:%d:%d" % [world_seed, structure_serial_0526]
	var record: Dictionary = {
		"uid": uid,
		"type": selected_piece_0526,
		"position": _vec_to_dict_0526(preview_position_0526),
		"yaw": preview_yaw_0526
	}
	structure_records_0526.append(record)
	if selected_piece_0526 == "crate":
		storage_records_0526[uid] = {}
	_spawn_structure_record_0526(record)
	save_game()
	_update_build_preview_0526(true)
	return true

func _restore_structures_0526() -> void:
	for record: Dictionary in structure_records_0526:
		_spawn_structure_record_0526(record)

func _spawn_structure_record_0526(record: Dictionary) -> Node3D:
	if build_root_0526 == null:
		return null
	var uid: String = str(record.get("uid", ""))
	for raw: Node in get_tree().get_nodes_in_group("build_structure_0526"):
		if raw is Node3D and str((raw as Node3D).get_meta("build_uid_0526", "")) == uid:
			return raw as Node3D
	var piece_id: String = str(record.get("type", ""))
	if piece_id not in BUILD_PIECES_0526:
		return null
	var root := Node3D.new()
	root.name = "Built_%s_%d" % [piece_id.capitalize(), structure_serial_0526]
	root.add_to_group("build_structure_0526")
	root.add_to_group("build_%s_0526" % piece_id)
	root.set_meta("build_uid_0526", uid)
	root.set_meta("build_type_0526", piece_id)
	build_root_0526.add_child(root)
	root.global_position = _dict_to_vec_0526(record.get("position", {}) as Dictionary)
	root.rotation_degrees.y = float(record.get("yaw", 0.0))
	_draw_piece_0526(root, piece_id, null, true)
	if piece_id == "crate":
		root.add_to_group("storage_crate_0526")
		root.set_meta("storage_uid_0526", uid)
		if not storage_records_0526.has(uid):
			storage_records_0526[uid] = {}
	return root

func _draw_piece_0526(root: Node3D, piece_id: String, override_material: Material, solid: bool) -> void:
	var wood_mat: Material = override_material if override_material != null else materials["wood"]
	var dark_mat: Material = override_material if override_material != null else materials["wood_dark"]
	var old_mat: Material = override_material if override_material != null else materials["wood_old"]
	match piece_id:
		"floor":
			_box(root, Vector3(2.76, 0.12, 2.76), Vector3(0.0, 0.07, 0.0), old_mat)
			for x: float in [-0.92, -0.46, 0.0, 0.46, 0.92]:
				_box(root, Vector3(0.025, 0.025, 2.66), Vector3(x, 0.14, 0.0), dark_mat)
		"wall":
			if solid:
				_solid_box(root, Vector3(2.76, 2.45, 0.18), Vector3(0.0, 1.225, 0.0), old_mat, "BuiltWallCollider0526")
			else:
				_box(root, Vector3(2.76, 2.45, 0.18), Vector3(0.0, 1.225, 0.0), old_mat)
			_box(root, Vector3(0.14, 2.50, 0.22), Vector3(-1.31, 1.25, 0.0), dark_mat)
			_box(root, Vector3(0.14, 2.50, 0.22), Vector3(1.31, 1.25, 0.0), dark_mat)
		"fence":
			if solid:
				_solid_box(root, Vector3(0.16, 1.48, 0.16), Vector3(-1.28, 0.74, 0.0), dark_mat, "FencePostL0526")
				_solid_box(root, Vector3(0.16, 1.48, 0.16), Vector3(1.28, 0.74, 0.0), dark_mat, "FencePostR0526")
				_solid_box(root, Vector3(2.52, 0.13, 0.13), Vector3(0.0, 0.48, 0.0), wood_mat, "FenceRailLow0526")
				_solid_box(root, Vector3(2.52, 0.13, 0.13), Vector3(0.0, 1.02, 0.0), wood_mat, "FenceRailHigh0526")
			else:
				_box(root, Vector3(0.16, 1.48, 0.16), Vector3(-1.28, 0.74, 0.0), dark_mat)
				_box(root, Vector3(0.16, 1.48, 0.16), Vector3(1.28, 0.74, 0.0), dark_mat)
				_box(root, Vector3(2.52, 0.13, 0.13), Vector3(0.0, 0.48, 0.0), wood_mat)
				_box(root, Vector3(2.52, 0.13, 0.13), Vector3(0.0, 1.02, 0.0), wood_mat)
		"crate":
			if solid:
				_solid_box(root, Vector3(1.18, 0.72, 0.88), Vector3(0.0, 0.38, 0.0), old_mat, "StorageCrate0526")
			else:
				_box(root, Vector3(1.18, 0.72, 0.88), Vector3(0.0, 0.38, 0.0), old_mat)
			_box(root, Vector3(1.24, 0.10, 0.94), Vector3(0.0, 0.79, 0.0), dark_mat)

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var crate: Node3D = _nearest_storage_crate_0526(pos)
	if crate != null:
		var uid: String = str(crate.get_meta("storage_uid_0526", ""))
		for raw_ui: Node in get_tree().get_nodes_in_group("storage_ui_0526"):
			if raw_ui.has_method("open_storage_0526"):
				raw_ui.call("open_storage_0526", uid)
		return true
	return super.try_interact_near(pos, target_player)

func _nearest_storage_crate_0526(pos: Vector3) -> Node3D:
	var nearest: Node3D = null
	var best := STORAGE_RANGE_0526
	for raw: Node in get_tree().get_nodes_in_group("storage_crate_0526"):
		if not (raw is Node3D):
			continue
		var crate := raw as Node3D
		var distance: float = Vector2(pos.x - crate.global_position.x, pos.z - crate.global_position.z).length()
		if distance <= best:
			best = distance
			nearest = crate
	return nearest

func get_storage_snapshot_0526(uid: String) -> Dictionary:
	if not storage_records_0526.has(uid):
		return {}
	return (storage_records_0526[uid] as Dictionary).duplicate(true)

func get_storage_total_0526(uid: String) -> int:
	var total := 0
	var storage: Dictionary = storage_records_0526.get(uid, {}) as Dictionary
	for raw_id: Variant in storage.keys():
		total += int(storage[raw_id])
	return total

func get_storage_capacity_0526(_uid: String = "") -> int:
	return STORAGE_CAPACITY_0526

func storage_deposit_0526(uid: String, item_id: String, amount: int, target_player: Node) -> bool:
	if uid == "" or amount <= 0 or not storage_records_0526.has(uid):
		return false
	if get_storage_total_0526(uid) + amount > STORAGE_CAPACITY_0526:
		return false
	if target_player == null or not target_player.has_method("remove_item_0526"):
		return false
	if not bool(target_player.call("remove_item_0526", item_id, amount)):
		return false
	var storage: Dictionary = storage_records_0526[uid] as Dictionary
	storage[item_id] = int(storage.get(item_id, 0)) + amount
	storage_records_0526[uid] = storage
	save_game()
	return true

func storage_withdraw_0526(uid: String, item_id: String, amount: int, target_player: Node) -> bool:
	if uid == "" or amount <= 0 or not storage_records_0526.has(uid):
		return false
	var storage: Dictionary = storage_records_0526[uid] as Dictionary
	var current := int(storage.get(item_id, 0))
	if current < amount:
		return false
	if target_player == null or not target_player.has_method("receive_storage_item_0526"):
		return false
	if not bool(target_player.call("receive_storage_item_0526", item_id, amount)):
		return false
	storage[item_id] = current - amount
	if int(storage[item_id]) <= 0:
		storage.erase(item_id)
	storage_records_0526[uid] = storage
	save_game()
	return true

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0526,
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
			"structure_serial_0526": structure_serial_0526
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	cancel_build_mode_0526()
	structure_records_0526.clear()
	storage_records_0526.clear()
	structure_serial_0526 = 0
	if build_root_0526 != null and is_instance_valid(build_root_0526):
		build_root_0526.queue_free()
	build_root_0526 = null
	super.new_seed()
	call_deferred("_build_construction_root_0526")

func get_world_summary() -> Dictionary:
	var result: Dictionary = super.get_world_summary()
	result["built_structures_0526"] = structure_records_0526.size()
	result["build_mode_0526"] = build_mode_0526
	result["build_piece_0526"] = selected_piece_0526
	return result

func get_build_debug_0526() -> Dictionary:
	return {
		"player_0526": player != null and player.get_script() == PlayerV0526Script,
		"mode": build_mode_0526,
		"piece": selected_piece_0526,
		"yaw": preview_yaw_0526,
		"valid": preview_valid_0526,
		"preview_position": preview_position_0526,
		"structures": structure_records_0526.size(),
		"floors": get_tree().get_nodes_in_group("build_floor_0526").size(),
		"walls": get_tree().get_nodes_in_group("build_wall_0526").size(),
		"fences": get_tree().get_nodes_in_group("build_fence_0526").size(),
		"crates": get_tree().get_nodes_in_group("storage_crate_0526").size(),
		"storage_records": storage_records_0526.size()
	}

func _vec_to_dict_0526(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0526(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.20)), float(value.get("z", 0.0)))
