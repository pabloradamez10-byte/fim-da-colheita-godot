extends "res://scripts/player/player_3d_v065.gd"

const QUALITY_VERSION_066 := "0.6.6-alpha"

var last_firearm_target_066 := 0
var firearm_target_switches_066 := 0

func _ready() -> void:
	super._ready()
	add_to_group("quality_fix_066")
	set_meta("quality_version", QUALITY_VERSION_066)
	set_meta("firearm_autoaim_360_066", true)

func _perform_firearm_065(weapon: String, profile: Dictionary) -> bool:
	var ammo_id := str(profile.get("ammo", ""))
	if ammo_id == "" or int(inventory.get(ammo_id, 0)) <= 0:
		last_attack_result_065 = "empty"
		_emit_combat_feedback_065("denied", "SEM MUNIÇÃO", 0.82)
		return false

	var attack_range := float(profile.get("range", 18.0))
	var target := _select_firearm_target_066(attack_range)
	if target != null:
		var new_id := target.get_instance_id()
		if last_firearm_target_066 != 0 and last_firearm_target_066 != new_id:
			firearm_target_switches_066 += 1
		last_firearm_target_066 = new_id
		last_target_id_065 = new_id
		_face_target_065(target)
		_sync_attack_facing_066()
	else:
		last_firearm_target_066 = 0
		last_target_id_065 = 0

	inventory[ammo_id] = int(inventory.get(ammo_id, 0)) - 1
	attack_cooldown = float(profile.get("cooldown", 0.4))
	_play_spatial_attack_animation_065(str(profile.get("class", "firearm_1h")))
	firearm_shots_065 += 1

	var hits_before := combat_hits_065
	if weapon == "shotgun":
		_fire_shotgun_065(target, profile)
	else:
		_fire_single_round_065(target, profile)
	_emit_combat_noise_065(float(profile.get("noise", 24.0)), weapon)
	if combat_hits_065 > hits_before:
		last_attack_result_065 = "hit"
	else:
		last_attack_result_065 = "miss"
		combat_misses_065 += 1
	return true

func _select_firearm_target_066(max_range: float) -> Node3D:
	var best: Node3D = null
	var best_score := INF
	for candidate in _combat_candidates_065():
		if candidate == null or not is_instance_valid(candidate):
			continue
		var offset := candidate.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance <= 0.05 or distance > max_range:
			continue
		if not _line_of_sight_065(candidate):
			continue
		# Estilo survival mobile: zumbis têm prioridade sobre caça;
		# dentro da mesma classe, o mais próximo é escolhido.
		var class_penalty := 100.0 if candidate.is_in_group("huntable_0538") else 0.0
		var score := distance + class_penalty
		if score < best_score:
			best_score = score
			best = candidate
	return best

func _sync_attack_facing_066() -> void:
	var yaw := fposmod(rotation.y, TAU)
	direction_05405 = posmod(int(round(yaw / (PI * 0.25))), DIRECTION_COUNT_05405)
	character_direction_05402 = direction_05405
	sprite_direction_064 = direction_05405
	set_meta("player_direction_05402", direction_05405)

func get_quality_debug_066() -> Dictionary:
	var combat := super.get_spatial_combat_debug_065()
	combat["quality_version"] = QUALITY_VERSION_066
	combat["firearm_autoaim_360"] = true
	combat["firearm_last_target"] = last_firearm_target_066
	combat["firearm_target_switches"] = firearm_target_switches_066
	combat["grounding"] = bool(get_meta("grounding_066", false))
	combat["floor_snap_length"] = floor_snap_length
	return combat
