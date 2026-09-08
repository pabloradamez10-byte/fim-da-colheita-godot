extends "res://scripts/world/world_runtime_3d_v0530_final.gd"

const PlayerV0531Script = preload("res://scripts/player/player_3d_v0531.gd")
const SAVE_VERSION_0531 := "0.5.31-alpha"
const FARM_PLOT_COUNT_0531 := 6
const FARM_INTERACT_RANGE_0531 := 2.35
const FARM_GROWTH_READY_MINUTES_0531 := 720.0
const FARM_GROWTH_SPROUT_MINUTES_0531 := 180.0
const FARM_GROWTH_MID_MINUTES_0531 := 420.0
const FARM_MOISTURE_DECAY_MINUTES_0531 := 420.0

var farm_plot_records_0531: Dictionary = {}
var farm_plot_nodes_0531: Dictionary = {}
var farm_root_0531: Node3D = null
var farm_tick_accumulator_0531 := 0.0
var farm_prepared_0531 := 0
var farm_planted_0531 := 0
var farm_watered_0531 := 0
var farm_harvested_0531 := 0

func _load_save() -> void:
	super._load_save()
	farm_plot_records_0531.clear()
	var world_state := save_cache.get("world", {}) as Dictionary
	var raw_records: Variant = world_state.get("farm_plot_records_0531", {})
	if raw_records is Dictionary:
		farm_plot_records_0531 = (raw_records as Dictionary).duplicate(true)
	farm_prepared_0531 = int(world_state.get("farm_prepared_0531", 0))
	farm_planted_0531 = int(world_state.get("farm_planted_0531", 0))
	farm_watered_0531 = int(world_state.get("farm_watered_0531", 0))
	farm_harvested_0531 = int(world_state.get("farm_harvested_0531", 0))

func _ready() -> void:
	super._ready()
	_build_farm_plots_0531()
	_refresh_farming_0531(true)

func _process(delta: float) -> void:
	super._process(delta)
	farm_tick_accumulator_0531 += delta
	if farm_tick_accumulator_0531 >= 0.5:
		farm_tick_accumulator_0531 = 0.0
		_refresh_farming_0531(false)

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0531Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _farm_total_minutes_0531() -> float:
	return float(maxi(0, world_day_0521 - 1)) * DAY_MINUTES_0521 + world_minutes_0521

func _default_plot_record_0531() -> Dictionary:
	return {
		"state": 0,
		"growth": 0.0,
		"moisture": 0.0,
		"last_update": _farm_total_minutes_0531()
	}

func _plot_position_0531(index: int) -> Vector3:
	var row := int(index / 3)
	var col := index % 3
	return _farm_to_world(Vector3(7.0 + float(col) * 2.55, 0.10, 3.3 + float(row) * 2.25))

func _build_farm_plots_0531() -> void:
	if farm_root_0531 == null or not is_instance_valid(farm_root_0531):
		farm_root_0531 = Node3D.new()
		farm_root_0531.name = "FarmPlots0531"
		add_child(farm_root_0531)
	farm_plot_nodes_0531.clear()
	for i in range(FARM_PLOT_COUNT_0531):
		var plot_id := "plot_%02d" % i
		if not farm_plot_records_0531.has(plot_id):
			farm_plot_records_0531[plot_id] = _default_plot_record_0531()
		var existing := farm_root_0531.get_node_or_null("Plot_%02d" % i) as Node3D
		var plot := existing
		if plot == null:
			plot = Node3D.new()
			plot.name = "Plot_%02d" % i
			plot.global_position = _plot_position_0531(i)
			plot.set_meta("farm_plot_id_0531", plot_id)
			plot.add_to_group("farm_plot_0531")
			farm_root_0531.add_child(plot)
			var soil := MeshInstance3D.new()
			soil.name = "Soil0531"
			var soil_mesh := BoxMesh.new()
			soil_mesh.size = Vector3(2.15, 0.10, 1.75)
			soil.mesh = soil_mesh
			soil.position = Vector3(0.0, 0.0, 0.0)
			plot.add_child(soil)
		farm_plot_nodes_0531[plot_id] = plot
		_update_plot_visual_0531(plot_id)

func _make_material_0531(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material

func _clear_crop_visuals_0531(plot: Node3D) -> void:
	for child in plot.get_children():
		if str(child.name).begins_with("CropVisual0531"):
			child.queue_free()

func _add_crop_stem_0531(plot: Node3D, index: int, height: float, width: float, z_offset: float, color: Color) -> void:
	var stem := MeshInstance3D.new()
	stem.name = "CropVisual0531_%02d" % index
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, height, width)
	stem.mesh = mesh
	stem.material_override = _make_material_0531(color)
	stem.position = Vector3(-0.62 + float(index) * 0.62, 0.08 + height * 0.5, z_offset)
	plot.add_child(stem)
	if height >= 0.55:
		var leaf := MeshInstance3D.new()
		leaf.name = "CropVisual0531_leaf_%02d" % index
		var leaf_mesh := BoxMesh.new()
		leaf_mesh.size = Vector3(0.44, 0.08, 0.20)
		leaf.mesh = leaf_mesh
		leaf.material_override = _make_material_0531(Color("6f8e3a"))
		leaf.position = stem.position + Vector3(0.10, height * 0.25, 0.02)
		leaf.rotation_degrees.y = 28.0
		plot.add_child(leaf)

func _update_plot_visual_0531(plot_id: String) -> void:
	if not farm_plot_nodes_0531.has(plot_id) or not farm_plot_records_0531.has(plot_id):
		return
	var plot := farm_plot_nodes_0531[plot_id] as Node3D
	if plot == null or not is_instance_valid(plot):
		return
	var record := farm_plot_records_0531[plot_id] as Dictionary
	var state := int(record.get("state", 0))
	var moisture := clampf(float(record.get("moisture", 0.0)), 0.0, 1.0)
	var soil := plot.get_node_or_null("Soil0531") as MeshInstance3D
	if soil != null:
		var base_color := Color("68513d") if state == 0 else Color("4b3326")
		if moisture > 0.25:
			base_color = base_color.darkened(0.18 + moisture * 0.12)
		soil.material_override = _make_material_0531(base_color)
	_clear_crop_visuals_0531(plot)
	match state:
		2:
			for i in range(3):
				_add_crop_stem_0531(plot, i, 0.22, 0.12, 0.0, Color("739348"))
		3:
			for i in range(3):
				_add_crop_stem_0531(plot, i, 0.58, 0.16, 0.0, Color("62833a"))
		4:
			for i in range(3):
				_add_crop_stem_0531(plot, i, 0.86, 0.20, 0.0, Color("526f30"))

func _is_raining_0531() -> bool:
	return int(_resolved_weather_type_0522()) == WEATHER_RAIN_0522

func _refresh_farming_0531(force_visuals: bool = false) -> void:
	var now := _farm_total_minutes_0531()
	var raining := _is_raining_0531()
	for raw_id: Variant in farm_plot_records_0531.keys():
		var plot_id := str(raw_id)
		var record := farm_plot_records_0531[raw_id] as Dictionary
		var state_before := int(record.get("state", 0))
		var last_update := float(record.get("last_update", now))
		var elapsed := maxf(0.0, now - last_update)
		var moisture := clampf(float(record.get("moisture", 0.0)), 0.0, 1.0)
		if raining:
			moisture = minf(1.0, moisture + elapsed / 75.0)
		else:
			moisture = maxf(0.0, moisture - elapsed / FARM_MOISTURE_DECAY_MINUTES_0531)
		if state_before >= 2 and state_before <= 3 and elapsed > 0.0:
			var growth := float(record.get("growth", 0.0))
			var growth_rate := 0.25 + moisture * 0.75
			growth += elapsed * growth_rate
			record["growth"] = growth
			if growth >= FARM_GROWTH_READY_MINUTES_0531:
				record["state"] = 4
			elif growth >= FARM_GROWTH_MID_MINUTES_0531:
				record["state"] = 3
			else:
				record["state"] = 2
		record["moisture"] = moisture
		record["last_update"] = now
		farm_plot_records_0531[raw_id] = record
		if force_visuals or int(record.get("state", 0)) != state_before:
			_update_plot_visual_0531(plot_id)

func refresh_farming_0531() -> void:
	_refresh_farming_0531(true)

func _nearest_farm_plot_0531(pos: Vector3) -> String:
	var nearest := ""
	var best := FARM_INTERACT_RANGE_0531
	for raw_id: Variant in farm_plot_nodes_0531.keys():
		var plot_id := str(raw_id)
		var plot := farm_plot_nodes_0531[raw_id] as Node3D
		if plot == null or not is_instance_valid(plot):
			continue
		var distance := Vector2(pos.x - plot.global_position.x, pos.z - plot.global_position.z).length()
		if distance <= best:
			best = distance
			nearest = plot_id
	return nearest

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var plot_id := _nearest_farm_plot_0531(pos)
	if plot_id != "" and target_player != null:
		_refresh_farming_0531(false)
		var record := farm_plot_records_0531[plot_id] as Dictionary
		var state := int(record.get("state", 0))
		if state == 0:
			record["state"] = 1
			record["last_update"] = _farm_total_minutes_0531()
			farm_plot_records_0531[plot_id] = record
			farm_prepared_0531 += 1
			_update_plot_visual_0531(plot_id)
			save_game()
			return true
		if state == 1:
			if target_player.has_method("consume_inventory_item_0530") and bool(target_player.call("consume_inventory_item_0530", "potato_seed", 1)):
				record["state"] = 2
				record["growth"] = 0.0
				record["moisture"] = maxf(0.42, float(record.get("moisture", 0.0)))
				record["last_update"] = _farm_total_minutes_0531()
				farm_plot_records_0531[plot_id] = record
				farm_planted_0531 += 1
				_update_plot_visual_0531(plot_id)
				save_game()
			return true
		if state == 2 or state == 3:
			if target_player.has_method("consume_inventory_item_0530") and bool(target_player.call("consume_inventory_item_0530", "water", 1)):
				record["moisture"] = 1.0
				record["last_update"] = _farm_total_minutes_0531()
				farm_plot_records_0531[plot_id] = record
				farm_watered_0531 += 1
				_update_plot_visual_0531(plot_id)
				save_game()
			return true
		if state == 4:
			if target_player.has_method("receive_inventory_item_0530"):
				target_player.call("receive_inventory_item_0530", "potato", 3)
				target_player.call("receive_inventory_item_0530", "potato_seed", 2)
				record = _default_plot_record_0531()
				record["state"] = 1
				farm_plot_records_0531[plot_id] = record
				farm_harvested_0531 += 1
				_update_plot_visual_0531(plot_id)
				save_game()
			return true
	return super.try_interact_near(pos, target_player)

func get_farm_plot_state_0531(plot_id: String) -> Dictionary:
	if not farm_plot_records_0531.has(plot_id):
		return {}
	var record := (farm_plot_records_0531[plot_id] as Dictionary).duplicate(true)
	if farm_plot_nodes_0531.has(plot_id):
		var plot := farm_plot_nodes_0531[plot_id] as Node3D
		if plot != null and is_instance_valid(plot):
			record["position"] = plot.global_position
	return record

func save_game() -> void:
	_refresh_farming_0531(false)
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_0531
	var world_state := payload.get("world", {}) as Dictionary
	world_state["farm_plot_records_0531"] = farm_plot_records_0531.duplicate(true)
	world_state["farm_prepared_0531"] = farm_prepared_0531
	world_state["farm_planted_0531"] = farm_planted_0531
	world_state["farm_watered_0531"] = farm_watered_0531
	world_state["farm_harvested_0531"] = farm_harvested_0531
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	farm_plot_records_0531.clear()
	farm_prepared_0531 = 0
	farm_planted_0531 = 0
	farm_watered_0531 = 0
	farm_harvested_0531 = 0
	super.new_seed()
	call_deferred("_rebuild_farm_plots_0531")

func _rebuild_farm_plots_0531() -> void:
	if farm_root_0531 != null and is_instance_valid(farm_root_0531):
		for child in farm_root_0531.get_children():
			farm_root_0531.remove_child(child)
			child.queue_free()
	farm_plot_nodes_0531.clear()
	_build_farm_plots_0531()
	_refresh_farming_0531(true)

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var ready := 0
	var growing := 0
	for raw: Variant in farm_plot_records_0531.values():
		var record := raw as Dictionary
		var state := int(record.get("state", 0))
		if state == 4:
			ready += 1
		elif state == 2 or state == 3:
			growing += 1
	result["farm_ready_0531"] = ready
	result["farm_growing_0531"] = growing
	result["farm_harvested_0531"] = farm_harvested_0531
	return result

func get_agriculture_debug_0531() -> Dictionary:
	var ready := 0
	var growing := 0
	for raw: Variant in farm_plot_records_0531.values():
		var record := raw as Dictionary
		var state := int(record.get("state", 0))
		if state == 4:
			ready += 1
		elif state == 2 or state == 3:
			growing += 1
	return {
		"plots": farm_plot_records_0531.size(),
		"nodes": get_tree().get_nodes_in_group("farm_plot_0531").size(),
		"prepared": farm_prepared_0531,
		"planted": farm_planted_0531,
		"watered": farm_watered_0531,
		"harvested": farm_harvested_0531,
		"growing": growing,
		"ready": ready,
		"raining": _is_raining_0531(),
		"player_0531": player != null and player.get_script() == PlayerV0531Script
	}
