extends "res://scripts/entities/zombie_3d_v0520.gd"

const NIGHT_VISION_RANGE_0521 := 11.5
const NIGHT_CLOSE_SENSE_0521 := 4.2
const NIGHT_HEARING_MULTIPLIER_0521 := 1.32
const NIGHT_MEMORY_MULTIPLIER_0521 := 1.35

func _is_night_0521() -> bool:
	if world_0519 != null and is_instance_valid(world_0519) and world_0519.has_method("is_night_0521"):
		return bool(world_0519.call("is_night_0521"))
	return false

func hear_noise_0519(noise_position: Vector3, radius: float, kind: String) -> bool:
	var effective_radius := radius * (NIGHT_HEARING_MULTIPLIER_0521 if _is_night_0521() else 1.0)
	var heard := super.hear_noise_0519(noise_position, effective_radius, kind)
	if heard and _is_night_0521():
		memory_timer_0519 = maxf(memory_timer_0519, INVESTIGATE_TIME_0519 * NIGHT_MEMORY_MULTIPLIER_0521)
	return heard

func _can_see_player_0519() -> bool:
	if player == null:
		return false
	var delta := player.global_position - global_position
	delta.y = 0.0
	var distance := delta.length()
	var night := _is_night_0521()
	var vision_range := NIGHT_VISION_RANGE_0521 if night else VISION_RANGE_0519
	var close_range := NIGHT_CLOSE_SENSE_0521 if night else CLOSE_SENSE_RANGE_0519
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

func get_ai_debug_0521() -> Dictionary:
	var result := get_ai_debug_0520()
	result["night_0521"] = _is_night_0521()
	result["hearing_multiplier_0521"] = NIGHT_HEARING_MULTIPLIER_0521 if _is_night_0521() else 1.0
	result["vision_range_0521"] = NIGHT_VISION_RANGE_0521 if _is_night_0521() else VISION_RANGE_0519
	return result
