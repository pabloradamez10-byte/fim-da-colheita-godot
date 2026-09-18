extends "res://scripts/ui/hud_3d_v05401.gd"

const PERFORMANCE_HUD_VERSION_067 := "0.6.7-alpha"

func _ready() -> void:
	super._ready()
	add_to_group("performance_hud_067")

func _update_world_05401() -> void:
	super._update_world_05401()
	if world == null or not world.has_method("get_performance_debug_067"):
		return
	var perf := world.call("get_performance_debug_067") as Dictionary
	var stream := perf.get("streaming", {}) as Dictionary
	var fps := int(perf.get("fps", 0))
	var active := int(perf.get("zombie_full", 0)) + int(perf.get("zombie_reduced", 0))
	var sleeping := int(perf.get("zombie_sleep", 0))
	var chunks := int(stream.get("loaded_chunks", 0))
	if location_label_05401 != null:
		location_label_05401.text += "  •  FPS %d  •  Z %d/%d  •  CH %d" % [fps, active, sleeping, chunks]

func get_performance_hud_debug_067() -> Dictionary:
	return {
		"version": PERFORMANCE_HUD_VERSION_067,
		"visible": location_label_05401 != null,
		"shows_fps": true
	}
