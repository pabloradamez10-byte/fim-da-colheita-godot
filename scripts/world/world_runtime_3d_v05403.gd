extends "res://scripts/world/world_runtime_3d_v05402.gd"

const SAVE_VERSION_05403 := "0.5.40.3-alpha"

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_05403
	var world_state := payload.get("world", {}) as Dictionary
	world_state["world_rework_05403"] = true
	world_state["world_rework_scope_05403"] = "houses-roads-poi-rural-props"
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func get_world_rework_debug_05403() -> Dictionary:
	var previous := get_asset_rework_debug_05402()
	var streamer_debug: Dictionary = {}
	var streamer := get_node_or_null("ChunkStreamer")
	if streamer != null and streamer.has_method("get_environment_rework_debug_05403"):
		streamer_debug = streamer.call("get_environment_rework_debug_05403") as Dictionary
	return {
		"version": SAVE_VERSION_05403,
		"environment": streamer_debug,
		"asset_rework_05402": str(previous.get("version", "")) == "0.5.40.2-alpha",
		"player_high_detail": bool((previous.get("player", {}) as Dictionary).get("sprite", false)),
		"zombie_profiles": int(previous.get("zombie_profiles", 0)),
		"zombie_frames": int(previous.get("zombie_frames", 0)),
		"items": int((previous.get("items", {}) as Dictionary).get("registered_items", 0)),
		"vehicle_variants": int(previous.get("vehicle_variants", 0)),
		"vehicle_directions": int(previous.get("vehicle_directions", 0)),
		"animal_species": int(previous.get("animal_species", 0)),
		"animal_directions": int(previous.get("animal_directions", 0)),
		"decision_engine_0540": bool(previous.get("decision_engine_0540", false))
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["world_rework_05403"] = get_world_rework_debug_05403()
	return result
