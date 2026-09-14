extends "res://scripts/player/player_3d_v05405.gd"

const STABILIZATION_VERSION_0600 := "0.6.0-alpha"

var last_combat_animation_0600 := ""
var combat_animation_events_0600 := 0

func _damage_nearest(max_range: float, damage: float) -> void:
	_play_equipped_combat_animation_0600()
	_apply_damage_nearest_0600(max_range, damage)

func _play_equipped_combat_animation_0600() -> void:
	var weapon := get_equipped_weapon()
	match weapon:
		"pistol":
			last_combat_animation_0600 = "firearm_1h"
			play_firearm_1h_05405()
		"shotgun":
			last_combat_animation_0600 = "firearm_2h"
			play_firearm_2h_05405()
		"bow":
			last_combat_animation_0600 = "bow"
			play_bow_05405()
		_:
			last_combat_animation_0600 = "melee_1h"
			play_melee_1h_05405()
	combat_animation_events_0600 += 1
	set_meta("last_combat_animation_0600", last_combat_animation_0600)

func _apply_damage_nearest_0600(max_range: float, damage: float) -> void:
	if world == null or not world.has_method("get_zombies"):
		return
	var nearest: Node3D = null
	var best := max_range
	for candidate in world.call("get_zombies"):
		var zombie := candidate as Node3D
		if zombie == null or not is_instance_valid(zombie):
			continue
		var distance := global_position.distance_to(zombie.global_position)
		if distance < best:
			best = distance
			nearest = zombie
	if nearest != null and nearest.has_method("take_damage"):
		nearest.call("take_damage", damage)

func get_player_stabilization_debug_0600() -> Dictionary:
	return {
		"version": STABILIZATION_VERSION_0600,
		"last_combat_animation": last_combat_animation_0600,
		"combat_animation_events": combat_animation_events_0600,
		"equipped_weapon": get_equipped_weapon(),
		"visual": get_player_visual_debug_05405()
	}
