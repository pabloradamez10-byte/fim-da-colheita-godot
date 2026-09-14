extends "res://scripts/world/world_runtime_3d_v0600.gd"

const FLUIDITY_VERSION_0601 := "0.6.1-alpha"

func get_fluidity_debug_0601() -> Dictionary:
	return {
		"version": FLUIDITY_VERSION_0601,
		"save_schema_compatible": SAVE_SCHEMA_0600,
		"save_version_compatible": SAVE_VERSION_0600,
		"physics_ticks": int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60)),
		"physics_interpolation": bool(ProjectSettings.get_setting("physics/common/physics_interpolation", false))
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["fluidity_0601"] = get_fluidity_debug_0601()
	return result
