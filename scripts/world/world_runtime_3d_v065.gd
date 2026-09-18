extends "res://scripts/world/world_runtime_3d_v064.gd"

const COMBAT_VERSION_065 := "0.6.5-alpha"
const PlayerV065Script = preload("res://scripts/player/player_3d_v065.gd")

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV065Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func get_spatial_combat_debug_065() -> Dictionary:
	if player != null and is_instance_valid(player) and player.has_method("get_spatial_combat_debug_065"):
		return player.call("get_spatial_combat_debug_065") as Dictionary
	return {"version":COMBAT_VERSION_065,"spatial_targeting":false,"weapon_profiles":0}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["spatial_combat_065"] = get_spatial_combat_debug_065()
	return result
