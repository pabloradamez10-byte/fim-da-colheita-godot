extends "res://scripts/world/world_runtime_3d_v063.gd"

const PROTAGONIST_VERSION_064 := "0.6.4-alpha"
const PlayerV064Script = preload("res://scripts/player/player_3d_v064.gd")

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV064Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func get_protagonist_debug_064() -> Dictionary:
	if player != null and is_instance_valid(player) and player.has_method("get_player_visual_debug_064"):
		return player.call("get_player_visual_debug_064") as Dictionary
	return {
		"version": PROTAGONIST_VERSION_064,
		"sprite": false,
		"directions": 0,
		"movement_frames": 0,
		"run_supported": false
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["protagonist_064"] = get_protagonist_debug_064()
	return result
