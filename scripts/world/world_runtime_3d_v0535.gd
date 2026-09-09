extends "res://scripts/world/world_runtime_3d_v0534.gd"

const PlayerV0535Script = preload("res://scripts/player/player_3d_v0535.gd")
const SAVE_VERSION_0535 := "0.5.35-alpha"

var progression_harvest_bonus_0535 := 0
var progression_scavenge_bonus_0535 := 0
var progression_mechanic_repairs_0535 := 0

func _load_save() -> void:
	super._load_save()
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	progression_harvest_bonus_0535 = int(world_state.get("progression_harvest_bonus_0535", 0))
	progression_scavenge_bonus_0535 = int(world_state.get("progression_scavenge_bonus_0535", 0))
	progression_mechanic_repairs_0535 = int(world_state.get("progression_mechanic_repairs_0535", 0))

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0535Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var plot_id := ""
	var before_state := -1
	var before_crop := ""
	var before_water := -1
	if target_player != null and target_player.has_method("award_skill_xp_0535"):
		plot_id = _nearest_farm_plot_0531(pos)
		if plot_id != "" and farm_plot_records_0531.has(plot_id):
			var before_record: Dictionary = farm_plot_records_0531[plot_id] as Dictionary
			before_state = int(before_record.get("state", -1))
			before_crop = str(before_record.get("crop_id", ""))
			if target_player.has_method("get_inventory_snapshot"):
				var before_inventory: Dictionary = target_player.call("get_inventory_snapshot") as Dictionary
				before_water = int(before_inventory.get("water", 0))

	var handled := super.try_interact_near(pos, target_player)
	if not handled or plot_id == "" or target_player == null or not target_player.has_method("award_skill_xp_0535"):
		return handled
	if not farm_plot_records_0531.has(plot_id):
		return handled

	var after_record: Dictionary = farm_plot_records_0531[plot_id] as Dictionary
	var after_state := int(after_record.get("state", -1))
	match before_state:
		0:
			if after_state == 1:
				target_player.call("award_skill_xp_0535", "farming", 3, "prepare_soil")
		1:
			if after_state == 2:
				target_player.call("award_skill_xp_0535", "farming", 5, "plant")
		2, 3:
			if target_player.has_method("get_inventory_snapshot"):
				var after_inventory: Dictionary = target_player.call("get_inventory_snapshot") as Dictionary
				if before_water >= 0 and int(after_inventory.get("water", 0)) < before_water:
					target_player.call("award_skill_xp_0535", "farming", 2, "water")
		4:
			if after_state == 1 and before_crop in CROP_ORDER_0532:
				target_player.call("award_skill_xp_0535", "farming", 14, "harvest")
				_apply_farming_bonus_0535(before_crop, target_player)
		_:
			pass
	return handled

func _apply_farming_bonus_0535(crop_id: String, target_player: Node) -> void:
	if target_player == null or crop_id not in CROP_ORDER_0532:
		return
	var bonus_yield := 0
	var seed_bonus := 0
	if target_player.has_method("get_farming_bonus_yield_0535"):
		bonus_yield = int(target_player.call("get_farming_bonus_yield_0535"))
	if target_player.has_method("get_farming_seed_bonus_0535"):
		seed_bonus = int(target_player.call("get_farming_seed_bonus_0535"))
	if bonus_yield > 0:
		if target_player.has_method("receive_food_item_0532"):
			target_player.call("receive_food_item_0532", crop_id, bonus_yield, 100.0)
		elif target_player.has_method("add_item"):
			target_player.call("add_item", crop_id, bonus_yield)
		progression_harvest_bonus_0535 += bonus_yield
	if seed_bonus > 0:
		var crop_def: Dictionary = CROP_DEFS_0532[crop_id] as Dictionary
		var seed_id := str(crop_def.get("seed", ""))
		if seed_id != "":
			if target_player.has_method("receive_inventory_item_0530"):
				target_player.call("receive_inventory_item_0530", seed_id, seed_bonus)
			elif target_player.has_method("add_item"):
				target_player.call("add_item", seed_id, seed_bonus)
			progression_harvest_bonus_0535 += seed_bonus

func _grant_contextual_loot_0514(kind: String, key: String, source: Node3D, target_player: Node) -> void:
	super._grant_contextual_loot_0514(kind, key, source, target_player)
	if target_player == null or not target_player.has_method("award_skill_xp_0535") or not kind.begins_with("loot_"):
		return
	var xp_gain := 8 if kind.begins_with("loot_poi_") else 3
	target_player.call("award_skill_xp_0535", "scavenging", xp_gain, kind)
	if not kind.begins_with("loot_poi_") or not target_player.has_method("get_scavenging_bonus_chance_0535"):
		return
	var chance := float(target_player.call("get_scavenging_bonus_chance_0535"))
	var marker := int(abs(hash("scavengebonus0535:%s:%s:%d" % [kind, key, world_seed])))
	if float(marker % 1000) >= chance * 1000.0:
		return
	var role := kind.trim_prefix("loot_poi_")
	if _grant_scavenging_bonus_0535(role, marker, target_player):
		progression_scavenge_bonus_0535 += 1

func _grant_scavenging_bonus_0535(role: String, marker: int, target_player: Node) -> bool:
	if target_player == null:
		return false
	match role:
		"hospital":
			if target_player.has_method("add_item"):
				target_player.call("add_item", "bandage" if marker % 2 == 0 else "antiseptic", 1)
				return true
		"market":
			var produce := ["potato", "corn", "carrot"]
			var food_id := str(produce[marker % produce.size()])
			if target_player.has_method("receive_food_item_0532"):
				target_player.call("receive_food_item_0532", food_id, 1, 100.0)
				return true
		"workshop":
			if target_player.has_method("add_item"):
				target_player.call("add_item", "repair_kit" if marker % 2 == 0 else "gasoline", 1)
				return true
		"police":
			if target_player.has_method("add_item"):
				target_player.call("add_item", "ammo_9mm", 3 + marker % 4)
				return true
		"farm":
			var seeds := ["potato_seed", "corn_seed", "carrot_seed"]
			if target_player.has_method("add_item"):
				target_player.call("add_item", str(seeds[marker % seeds.size()]), 1)
				return true
		_:
			pass
	return false

func vehicle_refuel_0530(uid: String, target_player: Node) -> bool:
	var refueled := super.vehicle_refuel_0530(uid, target_player)
	if refueled and target_player != null and target_player.has_method("award_skill_xp_0535"):
		target_player.call("award_skill_xp_0535", "mechanics", 3, "refuel")
	return refueled

func vehicle_repair_0530(uid: String, target_player: Node) -> bool:
	var vehicle := _find_vehicle_0530(uid)
	if vehicle == null or target_player == null or not target_player.has_method("consume_repair_kit_0530"):
		return false
	var status := get_vehicle_status_0530(uid)
	var health_value := float(status.get("health", 0.0))
	var max_health := float(status.get("max_health", 0.0))
	if not bool(status.get("near", false)) or health_value >= max_health - 0.01 or int(status.get("variant", 8)) == 8:
		return false
	if not bool(target_player.call("consume_repair_kit_0530", 1)):
		return false
	var repair_fraction := 0.30
	if target_player.has_method("get_mechanics_repair_fraction_0535"):
		repair_fraction = float(target_player.call("get_mechanics_repair_fraction_0535"))
	var repaired := float(vehicle.call("repair_0530", max_health * repair_fraction))
	if repaired <= 0.0:
		target_player.call("receive_inventory_item_0530", "repair_kit", 1)
		return false
	vehicle_repairs_0530 += 1
	progression_mechanic_repairs_0535 += 1
	if target_player.has_method("award_skill_xp_0535"):
		target_player.call("award_skill_xp_0535", "mechanics", 18, "repair_vehicle")
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
	payload["version"] = SAVE_VERSION_0535
	var world_state: Dictionary = payload.get("world", {}) as Dictionary
	world_state["progression_harvest_bonus_0535"] = progression_harvest_bonus_0535
	world_state["progression_scavenge_bonus_0535"] = progression_scavenge_bonus_0535
	world_state["progression_mechanic_repairs_0535"] = progression_mechanic_repairs_0535
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	progression_harvest_bonus_0535 = 0
	progression_scavenge_bonus_0535 = 0
	progression_mechanic_repairs_0535 = 0
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["progression_harvest_bonus_0535"] = progression_harvest_bonus_0535
	result["progression_scavenge_bonus_0535"] = progression_scavenge_bonus_0535
	result["progression_mechanic_repairs_0535"] = progression_mechanic_repairs_0535
	if player != null and player.has_method("get_progression_snapshot_0535"):
		result["progression_0535"] = player.call("get_progression_snapshot_0535")
	return result

func get_progression_world_debug_0535() -> Dictionary:
	return {
		"player_0535": player != null and player.get_script() == PlayerV0535Script,
		"harvest_bonus": progression_harvest_bonus_0535,
		"scavenge_bonus": progression_scavenge_bonus_0535,
		"mechanic_repairs": progression_mechanic_repairs_0535,
		"save_version": SAVE_VERSION_0535
	}
