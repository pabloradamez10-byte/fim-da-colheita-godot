extends "res://scripts/world/world_runtime_3d_v0532.gd"

const PlayerV0533Script = preload("res://scripts/player/player_3d_v0533.gd")
const SAVE_VERSION_0533 := "0.5.33-alpha"

var clothing_loot_found_0533 := 0

func _load_save() -> void:
	super._load_save()
	var world_state := save_cache.get("world", {}) as Dictionary
	clothing_loot_found_0533 = int(world_state.get("clothing_loot_found_0533", 0))

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0533Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _grant_contextual_loot_0514(kind: String, key: String, source: Node3D, target_player: Node) -> void:
	super._grant_contextual_loot_0514(kind, key, source, target_player)
	if target_player == null or not target_player.has_method("receive_clothing_0533"):
		return
	var marker := int(abs(hash("clothing0533:%s:%s:%d:%s" % [kind, key, world_seed, source.name if source != null else "none"])))
	var item_id := ""
	match kind:
		"loot_wardrobe":
			# Guarda-roupas são a principal fonte de vestuário. Nem todo móvel contém peça útil.
			if marker % 100 < 78:
				var wardrobe_pool := ["hoodie", "rain_jacket", "cargo_pants", "work_boots", "baseball_cap", "hiking_backpack"]
				item_id = str(wardrobe_pool[marker % wardrobe_pool.size()])
		"loot_bedroom":
			if marker % 100 < 42:
				var bedroom_pool := ["tshirt", "baseball_cap", "jeans", "school_backpack"]
				item_id = str(bedroom_pool[marker % bedroom_pool.size()])
		"loot_bathroom", "loot_medicine":
			if marker % 100 < 26:
				item_id = "work_gloves"
		"loot_living":
			if marker % 100 < 18:
				item_id = "school_backpack"
		_:
			pass
	if item_id != "" and bool(target_player.call("receive_clothing_0533", item_id, 1)):
		clothing_loot_found_0533 += 1

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_0533
	var world_state := payload.get("world", {}) as Dictionary
	world_state["clothing_loot_found_0533"] = clothing_loot_found_0533
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	clothing_loot_found_0533 = 0
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["clothing_loot_found_0533"] = clothing_loot_found_0533
	return result

func get_body_equipment_world_debug_0533() -> Dictionary:
	return {
		"player_0533": player != null and player.get_script() == PlayerV0533Script,
		"clothing_loot_found": clothing_loot_found_0533,
		"save_version": SAVE_VERSION_0533
	}
