extends "res://scripts/world/world_runtime_3d_v05401.gd"

const PlayerV05402Script = preload("res://scripts/player/player_3d_v05402.gd")
const ZombieV05402Script = preload("res://scripts/entities/zombie_3d_v05402.gd")
const SAVE_VERSION_05402 := "0.5.40.2-alpha"

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV05402Script.new()
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
		var zombie: CharacterBody3D = ZombieV05402Script.new()
		zombie.name = zombie_name
		zombie.call("configure_horde_0537", horde_id, member_index, (i + horde_id * 2) % 5)
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_05402
	var world_state := payload.get("world", {}) as Dictionary
	world_state["asset_rework_05402"] = true
	world_state["player_art_05402"] = "survivor-4dir-hd"
	world_state["zombie_art_05402"] = "96x128x5x8-vector"
	world_state["item_art_05402"] = "64x64x16-vector"
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func get_asset_rework_debug_05402() -> Dictionary:
	var player_debug: Dictionary = {}
	if player != null and is_instance_valid(player) and player.has_method("get_player_visual_debug_05402"):
		player_debug = player.call("get_player_visual_debug_05402") as Dictionary
	var zombie_nodes := get_tree().get_nodes_in_group("zombie_high_detail_05402")
	var hotbar_nodes := get_tree().get_nodes_in_group("hotbar_asset_rework_05402")
	var item_debug: Dictionary = {}
	if not hotbar_nodes.is_empty() and hotbar_nodes[0].has_method("get_item_asset_debug_05402"):
		item_debug = hotbar_nodes[0].call("get_item_asset_debug_05402") as Dictionary
	var previous := get_visual_rework_debug_05401()
	return {
		"version": SAVE_VERSION_05402,
		"player": player_debug,
		"zombie_sprites": zombie_nodes.size(),
		"zombie_profiles": ZOMBIE_PROFILE_COUNT_0537,
		"zombie_frames": ZOMBIE_FRAME_COUNT_0537,
		"zombie_tile": "96x128",
		"items": item_debug,
		"vehicle_variants": int(previous.get("vehicle_variants", 0)),
		"vehicle_directions": int(previous.get("vehicle_directions", 0)),
		"animal_species": int(previous.get("animal_species", 0)),
		"animal_directions": int(previous.get("animal_directions", 0)),
		"decision_engine_0540": has_method("get_decision_engine_debug_0540"),
		"high_detail": true
	}
