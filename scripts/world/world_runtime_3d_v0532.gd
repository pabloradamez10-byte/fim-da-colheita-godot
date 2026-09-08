extends "res://scripts/world/world_runtime_3d_v0531.gd"

const PlayerV0532Script = preload("res://scripts/player/player_3d_v0532.gd")
const SAVE_VERSION_0532 := "0.5.32-alpha"
const CROP_ORDER_0532 := ["potato", "corn", "carrot"]
const CROP_DEFS_0532 := {
	"potato": {
		"name": "Batata",
		"seed": "potato_seed",
		"grow_sprout": 180.0,
		"grow_mid": 420.0,
		"grow_ready": 720.0,
		"yield": 3,
		"seed_yield": 2,
		"color": Color("526f30")
	},
	"corn": {
		"name": "Milho",
		"seed": "corn_seed",
		"grow_sprout": 210.0,
		"grow_mid": 520.0,
		"grow_ready": 900.0,
		"yield": 3,
		"seed_yield": 2,
		"color": Color("73833a")
	},
	"carrot": {
		"name": "Cenoura",
		"seed": "carrot_seed",
		"grow_sprout": 140.0,
		"grow_mid": 330.0,
		"grow_ready": 600.0,
		"yield": 4,
		"seed_yield": 2,
		"color": Color("557b37")
	}
}

var selected_crop_0532 := "potato"
var crop_harvest_totals_0532 := {"potato": 0, "corn": 0, "carrot": 0}
var cooked_batches_0532 := 0

func _load_save() -> void:
	super._load_save()
	var world_state := save_cache.get("world", {}) as Dictionary
	selected_crop_0532 = str(world_state.get("selected_crop_0532", "potato"))
	if selected_crop_0532 not in CROP_ORDER_0532:
		selected_crop_0532 = "potato"
	var raw_totals: Variant = world_state.get("crop_harvest_totals_0532", {})
	if raw_totals is Dictionary:
		for crop_id in CROP_ORDER_0532:
			crop_harvest_totals_0532[crop_id] = int((raw_totals as Dictionary).get(crop_id, 0))
	cooked_batches_0532 = int(world_state.get("cooked_batches_0532", 0))
	_migrate_crop_records_0532()

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0532Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _default_plot_record_0531() -> Dictionary:
	return {
		"state": 0,
		"crop_id": "",
		"growth": 0.0,
		"moisture": 0.0,
		"last_update": _farm_total_minutes_0531()
	}

func _migrate_crop_records_0532() -> void:
	for raw_id: Variant in farm_plot_records_0531.keys():
		var record := farm_plot_records_0531[raw_id] as Dictionary
		var state := int(record.get("state", 0))
		if not record.has("crop_id"):
			record["crop_id"] = "potato" if state >= 2 else ""
		elif state >= 2 and str(record.get("crop_id", "")) == "":
			record["crop_id"] = "potato"
		farm_plot_records_0531[raw_id] = record

func select_crop_0532(crop_id: String) -> bool:
	if crop_id not in CROP_ORDER_0532:
		return false
	selected_crop_0532 = crop_id
	return true

func cycle_crop_0532() -> String:
	var index := CROP_ORDER_0532.find(selected_crop_0532)
	selected_crop_0532 = CROP_ORDER_0532[(index + 1) % CROP_ORDER_0532.size()]
	return selected_crop_0532

func get_selected_crop_0532() -> String:
	return selected_crop_0532

func get_crop_name_0532(crop_id: String) -> String:
	if not CROP_DEFS_0532.has(crop_id):
		return crop_id
	return str((CROP_DEFS_0532[crop_id] as Dictionary).get("name", crop_id))

func _first_available_crop_0532(target_player: Node) -> String:
	if target_player == null or not target_player.has_method("get_inventory_snapshot"):
		return ""
	var snapshot := target_player.call("get_inventory_snapshot") as Dictionary
	var candidates := [selected_crop_0532]
	for crop_id in CROP_ORDER_0532:
		if crop_id != selected_crop_0532:
			candidates.append(crop_id)
	for crop_id in candidates:
		var seed_id := str((CROP_DEFS_0532[crop_id] as Dictionary).get("seed", ""))
		if int(snapshot.get(seed_id, 0)) > 0:
			return crop_id
	return ""

func _update_plot_visual_0531(plot_id: String) -> void:
	if not farm_plot_nodes_0531.has(plot_id) or not farm_plot_records_0531.has(plot_id):
		return
	var plot := farm_plot_nodes_0531[plot_id] as Node3D
	if plot == null or not is_instance_valid(plot):
		return
	var record := farm_plot_records_0531[plot_id] as Dictionary
	var state := int(record.get("state", 0))
	var crop_id := str(record.get("crop_id", "potato"))
	if crop_id == "":
		crop_id = "potato"
	var moisture := clampf(float(record.get("moisture", 0.0)), 0.0, 1.0)
	var soil := plot.get_node_or_null("Soil0531") as MeshInstance3D
	if soil != null:
		var base_color := Color("68513d") if state == 0 else Color("4b3326")
		if moisture > 0.25:
			base_color = base_color.darkened(0.18 + moisture * 0.12)
		soil.material_override = _make_material_0531(base_color)
	_clear_crop_visuals_0531(plot)
	if state < 2:
		return
	var crop_color := Color("62833a")
	if CROP_DEFS_0532.has(crop_id):
		crop_color = (CROP_DEFS_0532[crop_id] as Dictionary).get("color", crop_color) as Color
	var height := 0.24
	var width := 0.12
	if state == 3:
		height = 0.62
		width = 0.15
	elif state == 4:
		height = 0.90
		width = 0.18
	if crop_id == "corn":
		height *= 1.45
		width *= 0.82
	elif crop_id == "carrot":
		height *= 0.70
		width *= 1.10
	for i in range(3):
		_add_crop_stem_0531(plot, i, height, width, 0.0, crop_color)
	if state == 4 and crop_id == "carrot":
		for i in range(3):
			var root_visual := MeshInstance3D.new()
			root_visual.name = "CropVisual0531_root_%02d" % i
			var root_mesh := BoxMesh.new()
			root_mesh.size = Vector3(0.18, 0.18, 0.18)
			root_visual.mesh = root_mesh
			root_visual.material_override = _make_material_0531(Color("d66f2c"))
			root_visual.position = Vector3(-0.62 + float(i) * 0.62, 0.15, 0.0)
			plot.add_child(root_visual)

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
			var crop_id := str(record.get("crop_id", "potato"))
			if crop_id not in CROP_ORDER_0532:
				crop_id = "potato"
				record["crop_id"] = crop_id
			var crop_def := CROP_DEFS_0532[crop_id] as Dictionary
			var growth := float(record.get("growth", 0.0))
			var growth_rate := 0.25 + moisture * 0.75
			growth += elapsed * growth_rate
			record["growth"] = growth
			if growth >= float(crop_def.get("grow_ready", 720.0)):
				record["state"] = 4
			elif growth >= float(crop_def.get("grow_mid", 420.0)):
				record["state"] = 3
			else:
				record["state"] = 2
		record["moisture"] = moisture
		record["last_update"] = now
		farm_plot_records_0531[raw_id] = record
		if force_visuals or int(record.get("state", 0)) != state_before:
			_update_plot_visual_0531(plot_id)

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var plot_id := _nearest_farm_plot_0531(pos)
	if plot_id != "" and target_player != null:
		_refresh_farming_0531(false)
		var record := farm_plot_records_0531[plot_id] as Dictionary
		var state := int(record.get("state", 0))
		if state == 0:
			record["state"] = 1
			record["crop_id"] = ""
			record["last_update"] = _farm_total_minutes_0531()
			farm_plot_records_0531[plot_id] = record
			farm_prepared_0531 += 1
			_update_plot_visual_0531(plot_id)
			save_game()
			return true
		if state == 1:
			var crop_id := _first_available_crop_0532(target_player)
			if crop_id == "":
				return true
			selected_crop_0532 = crop_id
			var crop_def := CROP_DEFS_0532[crop_id] as Dictionary
			var seed_id := str(crop_def.get("seed", ""))
			if target_player.has_method("consume_inventory_item_0530") and bool(target_player.call("consume_inventory_item_0530", seed_id, 1)):
				record["state"] = 2
				record["crop_id"] = crop_id
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
			var crop_id := str(record.get("crop_id", "potato"))
			if crop_id not in CROP_ORDER_0532:
				crop_id = "potato"
			var crop_def := CROP_DEFS_0532[crop_id] as Dictionary
			var amount := int(crop_def.get("yield", 3))
			var seed_amount := int(crop_def.get("seed_yield", 2))
			var seed_id := str(crop_def.get("seed", "potato_seed"))
			if target_player.has_method("receive_food_item_0532"):
				target_player.call("receive_food_item_0532", crop_id, amount, 100.0)
			elif target_player.has_method("receive_inventory_item_0530"):
				target_player.call("receive_inventory_item_0530", crop_id, amount)
			if target_player.has_method("receive_inventory_item_0530"):
				target_player.call("receive_inventory_item_0530", seed_id, seed_amount)
			crop_harvest_totals_0532[crop_id] = int(crop_harvest_totals_0532.get(crop_id, 0)) + amount
			record = _default_plot_record_0531()
			record["state"] = 1
			farm_plot_records_0531[plot_id] = record
			farm_harvested_0531 += 1
			_update_plot_visual_0531(plot_id)
			save_game()
			return true
	return super.try_interact_near(pos, target_player)

func advance_time_0521(minutes: float, refresh_visuals: bool = true) -> void:
	super.advance_time_0521(minutes, refresh_visuals)
	if minutes > 0.0 and player != null and player.has_method("advance_food_decay_0532"):
		player.call("advance_food_decay_0532", minutes)

func campfire_cook_food_0532(uid: String, target_player: Node, recipe_id: String) -> bool:
	var index := _record_index_0527(uid)
	if index < 0 or target_player == null or not target_player.has_method("cook_food_recipe_0532"):
		return false
	if not _campfire_is_near_player_0528(uid):
		return false
	var record := structure_records_0526[index] as Dictionary
	if str(record.get("type", "")) != "campfire" or not bool(record.get("burning_0528", false)):
		return false
	if not target_player.has_method("get_food_recipe_0532"):
		return false
	var recipe := target_player.call("get_food_recipe_0532", recipe_id) as Dictionary
	if recipe.is_empty():
		return false
	var fuel_cost := float(recipe.get("fuel_cost", 8.0))
	var fuel := float(record.get("fuel_minutes_0528", 0.0))
	if fuel < fuel_cost:
		return false
	if not bool(target_player.call("cook_food_recipe_0532", recipe_id)):
		return false
	fuel = maxf(0.0, fuel - fuel_cost)
	record["fuel_minutes_0528"] = fuel
	if fuel <= 0.01:
		record["burning_0528"] = false
	structure_records_0526[index] = record
	_update_campfire_visual_0528(uid)
	cooked_batches_0532 += 1
	save_game()
	return true

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_0532
	var world_state := payload.get("world", {}) as Dictionary
	world_state["selected_crop_0532"] = selected_crop_0532
	world_state["crop_harvest_totals_0532"] = crop_harvest_totals_0532.duplicate(true)
	world_state["cooked_batches_0532"] = cooked_batches_0532
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	selected_crop_0532 = "potato"
	crop_harvest_totals_0532 = {"potato": 0, "corn": 0, "carrot": 0}
	cooked_batches_0532 = 0
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["selected_crop_0532"] = selected_crop_0532
	result["crop_harvest_totals_0532"] = crop_harvest_totals_0532.duplicate(true)
	result["cooked_batches_0532"] = cooked_batches_0532
	return result

func get_food_farming_debug_0532() -> Dictionary:
	var crop_counts := {"potato": 0, "corn": 0, "carrot": 0}
	for raw: Variant in farm_plot_records_0531.values():
		var record := raw as Dictionary
		if int(record.get("state", 0)) >= 2:
			var crop_id := str(record.get("crop_id", "potato"))
			if crop_counts.has(crop_id):
				crop_counts[crop_id] = int(crop_counts[crop_id]) + 1
	return {
		"player_0532": player != null and player.get_script() == PlayerV0532Script,
		"selected_crop": selected_crop_0532,
		"crop_counts": crop_counts,
		"harvest_totals": crop_harvest_totals_0532.duplicate(true),
		"cooked_batches": cooked_batches_0532,
		"plots": farm_plot_records_0531.size()
	}
