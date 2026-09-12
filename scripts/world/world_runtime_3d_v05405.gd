extends "res://scripts/world/world_runtime_3d_v05404.gd"

const PlayerV05405Script = preload("res://scripts/player/player_3d_v05405.gd")
const SAVE_VERSION_05405 := "0.5.40.5-alpha"

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV05405Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_05405
	var world_state := payload.get("world", {}) as Dictionary
	world_state["character_sprite_pack_05405"] = true
	world_state["character_directions_05405"] = 8
	world_state["character_walk_frames_05405"] = 6
	world_state["character_action_frames_05405"] = 5
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func get_character_sprite_pack_debug_05405() -> Dictionary:
	var player_debug: Dictionary = {}
	if player != null and is_instance_valid(player) and player.has_method("get_player_visual_debug_05405"):
		player_debug = player.call("get_player_visual_debug_05405") as Dictionary
	var previous := get_feedback_audio_debug_05404()
	return {
		"version": SAVE_VERSION_05405,
		"player": player_debug,
		"feedback_audio_05404": str(previous.get("version", "")) == "0.5.40.4-alpha",
		"world_rework_05403": bool(previous.get("world_rework_05403", false)),
		"decision_engine_0540": bool(previous.get("decision_engine_0540", false))
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["character_sprite_pack_05405"] = get_character_sprite_pack_debug_05405()
	return result
