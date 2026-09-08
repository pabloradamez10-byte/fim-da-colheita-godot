extends "res://scripts/entities/zombie_3d_v0521.gd"

func _weather_modifiers_0522() -> Dictionary:
	if world_0519 != null and is_instance_valid(world_0519) and world_0519.has_method("get_zombie_weather_modifiers_0522"):
		var raw: Variant = world_0519.call("get_zombie_weather_modifiers_0522")
		if raw is Dictionary:
			return raw as Dictionary
	return {"vision": 1.0, "hearing": 1.0}

func hear_noise_0519(noise_position: Vector3, radius: float, kind: String) -> bool:
	var mods := _weather_modifiers_0522()
	var hearing := clampf(float(mods.get("hearing", 1.0)), 0.35, 1.25)
	return super.hear_noise_0519(noise_position, radius * hearing, kind)

func _can_see_player_0519() -> bool:
	if player == null:
		return false
	var delta := player.global_position - global_position
	delta.y = 0.0
	var distance := delta.length()
	var night := _is_night_0521()
	var mods := _weather_modifiers_0522()
	var vision_modifier := clampf(float(mods.get("vision", 1.0)), 0.30, 1.0)
	var vision_range := (NIGHT_VISION_RANGE_0521 if night else VISION_RANGE_0519) * vision_modifier
	var close_range := (NIGHT_CLOSE_SENSE_0521 if night else CLOSE_SENSE_RANGE_0519) * maxf(0.72, vision_modifier)
	if distance > vision_range:
		return false
	if distance <= close_range:
		return _has_line_of_sight_0519(player.global_position)
	if delta.length() <= 0.01:
		return true
	var forward := -global_transform.basis.z
	forward.y = 0.0
	if forward.length() <= 0.01:
		forward = Vector3(0, 0, -1)
	if forward.normalized().dot(delta.normalized()) < VISION_DOT_0519:
		return false
	return _has_line_of_sight_0519(player.global_position)

func get_ai_debug_0522() -> Dictionary:
	var result := get_ai_debug_0521()
	var mods := _weather_modifiers_0522()
	result["weather_vision_0522"] = float(mods.get("vision", 1.0))
	result["weather_hearing_0522"] = float(mods.get("hearing", 1.0))
	return result
