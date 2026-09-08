extends "res://scripts/world/world_runtime_3d_v0530.gd"

func get_water_debug_0529() -> Dictionary:
	var result := super.get_water_debug_0529()
	result["player_0529"] = player != null and player.has_method("get_water_survival_debug_0529")
	return result
