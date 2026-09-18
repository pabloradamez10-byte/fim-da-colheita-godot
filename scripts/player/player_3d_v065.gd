extends "res://scripts/player/player_3d_v064.gd"

const COMBAT_VERSION_065 := "0.6.5-alpha"
const ArrowProjectile065Script = preload("res://scripts/entities/arrow_projectile_065.gd")

const WEAPON_PROFILES_065 := {
	"machete": {
		"name": "FACÃO", "class": "melee_1h", "damage": 38.0, "range": 2.65,
		"cooldown": 0.48, "stamina": 7.0, "arc": 105.0, "targets": 2, "assist": 78.0, "noise": 3.5
	},
	"axe": {
		"name": "MACHADO", "class": "melee_2h", "damage": 56.0, "range": 2.45,
		"cooldown": 0.72, "stamina": 11.0, "arc": 88.0, "targets": 2, "assist": 72.0, "noise": 4.2
	},
	"spear": {
		"name": "LANÇA", "class": "melee_2h", "damage": 47.0, "range": 3.75,
		"cooldown": 0.62, "stamina": 8.0, "arc": 42.0, "targets": 1, "assist": 58.0, "noise": 3.0
	},
	"pistol": {
		"name": "PISTOLA 9MM", "class": "firearm_1h", "damage": 46.0, "range": 21.0,
		"cooldown": 0.32, "assist": 56.0, "spread": 2.4, "ammo": "ammo_9mm", "noise": 25.0
	},
	"shotgun": {
		"name": "ESPINGARDA 12", "class": "firearm_2h", "damage": 14.0, "range": 13.0,
		"cooldown": 0.88, "assist": 68.0, "pellets": 7, "spread": 13.0, "ammo": "shells", "noise": 34.0
	},
	"bow": {
		"name": "ARCO", "class": "bow", "damage": 62.0, "range": 18.0,
		"cooldown": 0.76, "assist": 52.0, "ammo": "arrows", "noise": 4.5
	}
}

const HOTBAR_PRIORITIES_065 := ["machete", "axe", "pistol", "shotgun", "bow", "bandage", "water", "food", "antiseptic"]

var combat_loadout_initialized_065 := false
var combat_attacks_065 := 0
var combat_hits_065 := 0
var combat_misses_065 := 0
var melee_hits_065 := 0
var firearm_shots_065 := 0
var arrows_fired_065 := 0
var last_attack_result_065 := ""
var last_target_id_065 := 0
var last_weapon_065 := ""

func _ready() -> void:
	super._ready()
	_ensure_combat_loadout_065()
	add_to_group("spatial_combat_065")
	set_meta("combat_version", COMBAT_VERSION_065)

func _ensure_combat_loadout_065() -> void:
	if not inventory.has("arrows"):
		inventory["arrows"] = 0
	if combat_loadout_initialized_065:
		_ensure_weapon_durability_0523()
		return
	var previous_weapon := get_equipped_weapon()
	for weapon_id in ["axe", "pistol", "shotgun", "bow"]:
		if not owned_weapons.has(weapon_id):
			unlock_weapon(weapon_id)
	inventory["ammo_9mm"] = int(inventory.get("ammo_9mm", 0)) + 30
	inventory["shells"] = int(inventory.get("shells", 0)) + 12
	inventory["arrows"] = int(inventory.get("arrows", 0)) + 20
	combat_loadout_initialized_065 = true
	if owned_weapons.has(previous_weapon):
		equip_weapon(previous_weapon)
	_ensure_weapon_durability_0523()

func get_weapon_max_durability_0523(id: String) -> float:
	if id == "bow":
		return 85.0
	return super.get_weapon_max_durability_0523(id)

func get_repair_cost_0523(id: String) -> Dictionary:
	if id == "bow":
		return {"wood": 2, "fiber": 2}
	return super.get_repair_cost_0523(id)

func _attack() -> void:
	if attack_cooldown > 0.0:
		return
	_ensure_combat_loadout_065()
	var weapon := get_equipped_weapon()
	_ensure_weapon_durability_for_0523(weapon)
	if is_weapon_broken_0523(weapon):
		last_attack_result_065 = "broken"
		last_weapon_065 = weapon
		_emit_combat_feedback_065("denied", "ARMA QUEBRADA", 0.85)
		return
	if not WEAPON_PROFILES_065.has(weapon):
		super._attack()
		return

	var profile: Dictionary = WEAPON_PROFILES_065[weapon] as Dictionary
	var weapon_class := str(profile.get("class", "melee_1h"))
	var performed := false
	match weapon_class:
		"melee_1h", "melee_2h":
			performed = _perform_melee_065(weapon, profile)
		"firearm_1h", "firearm_2h":
			performed = _perform_firearm_065(weapon, profile)
		"bow":
			performed = _perform_bow_065(weapon, profile)
		_:
			pass
	if performed:
		combat_attacks_065 += 1
		last_weapon_065 = weapon
		_consume_weapon_durability_0523(weapon)
		if has_method("_request_save_0524"):
			call_deferred("_request_save_0524")

func _perform_melee_065(weapon: String, profile: Dictionary) -> bool:
	var stamina_cost := float(profile.get("stamina", 7.0))
	if stamina < stamina_cost:
		last_attack_result_065 = "tired"
		_emit_combat_feedback_065("denied", "SEM FÔLEGO", 0.72)
		return false
	stamina = maxf(0.0, stamina - stamina_cost)
	attack_cooldown = float(profile.get("cooldown", 0.5))
	var attack_range := float(profile.get("range", 2.5))
	var assisted := _select_target_065(attack_range, float(profile.get("assist", 70.0)), true)
	if assisted != null:
		_face_target_065(assisted)
		last_target_id_065 = assisted.get_instance_id()
	else:
		last_target_id_065 = 0
	_play_spatial_attack_animation_065(str(profile.get("class", "melee_1h")))

	var forward := _combat_forward_065()
	var half_arc := deg_to_rad(float(profile.get("arc", 90.0)) * 0.5)
	var possible: Array[Dictionary] = []
	for candidate in _combat_candidates_065():
		if candidate == null or not is_instance_valid(candidate):
			continue
		var offset := candidate.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance <= 0.05 or distance > attack_range:
			continue
		var dir := offset / distance
		var angle := acos(clampf(forward.dot(dir), -1.0, 1.0))
		if angle > half_arc:
			continue
		if not _line_of_sight_065(candidate):
			continue
		possible.append({"target": candidate, "distance": distance})
	possible.sort_custom(Callable(self, "_sort_combat_candidate_065"))

	var max_targets := maxi(1, int(profile.get("targets", 1)))
	var hit_count := 0
	for entry in possible:
		if hit_count >= max_targets:
			break
		var target := entry.get("target") as Node3D
		if target == null:
			continue
		_apply_combat_damage_065(target, float(profile.get("damage", 30.0)), "melee")
		hit_count += 1
		melee_hits_065 += 1
	_emit_combat_noise_065(float(profile.get("noise", 3.0)), "melee")
	if hit_count > 0:
		last_attack_result_065 = "hit"
		return true
	last_attack_result_065 = "miss"
	combat_misses_065 += 1
	return true

func _perform_firearm_065(weapon: String, profile: Dictionary) -> bool:
	var ammo_id := str(profile.get("ammo", ""))
	if ammo_id == "" or int(inventory.get(ammo_id, 0)) <= 0:
		last_attack_result_065 = "empty"
		_emit_combat_feedback_065("denied", "SEM MUNIÇÃO", 0.82)
		return false
	inventory[ammo_id] = int(inventory.get(ammo_id, 0)) - 1
	attack_cooldown = float(profile.get("cooldown", 0.4))
	var attack_range := float(profile.get("range", 18.0))
	var target := _select_target_065(attack_range, float(profile.get("assist", 55.0)), true)
	if target != null:
		_face_target_065(target)
		last_target_id_065 = target.get_instance_id()
	else:
		last_target_id_065 = 0
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

func _fire_single_round_065(target: Node3D, profile: Dictionary) -> void:
	var max_range := float(profile.get("range", 20.0))
	var direction := _aim_direction_065(target)
	var spread := float(profile.get("spread", 0.0))
	var pattern := [-0.45, 0.35, 0.0, 0.72, -0.68]
	var spread_step := float(pattern[firearm_shots_065 % pattern.size()]) * spread
	direction = direction.rotated(Vector3.UP, deg_to_rad(spread_step)).normalized()
	var hit := _raycast_damageable_065(direction, max_range)
	if hit == null and target != null and absf(spread_step) <= 1.25 and _line_of_sight_065(target):
		hit = target
	if hit == null:
		return
	var distance := global_position.distance_to(hit.global_position)
	var falloff := lerpf(1.0, 0.82, clampf(distance / max_range, 0.0, 1.0))
	_apply_combat_damage_065(hit, float(profile.get("damage", 42.0)) * falloff, "firearm")

func _fire_shotgun_065(target: Node3D, profile: Dictionary) -> void:
	var max_range := float(profile.get("range", 13.0))
	var center := _aim_direction_065(target)
	var pellet_count := maxi(3, int(profile.get("pellets", 7)))
	var spread := float(profile.get("spread", 13.0))
	var damage_by_id: Dictionary = {}
	var target_by_id: Dictionary = {}
	for i in range(pellet_count):
		var ratio := 0.0 if pellet_count <= 1 else float(i) / float(pellet_count - 1)
		var offset_deg := lerpf(-spread, spread, ratio)
		var direction := center.rotated(Vector3.UP, deg_to_rad(offset_deg)).normalized()
		var hit := _raycast_damageable_065(direction, max_range)
		if hit == null and target != null and absf(offset_deg) < 0.01 and _line_of_sight_065(target):
			hit = target
		if hit == null:
			continue
		var id := hit.get_instance_id()
		var distance := global_position.distance_to(hit.global_position)
		var falloff := lerpf(1.0, 0.38, clampf(distance / max_range, 0.0, 1.0))
		damage_by_id[id] = float(damage_by_id.get(id, 0.0)) + float(profile.get("damage", 14.0)) * falloff
		target_by_id[id] = hit
	for raw_id in damage_by_id.keys():
		var id := int(raw_id)
		var hit := target_by_id.get(id) as Node3D
		if hit != null and is_instance_valid(hit):
			_apply_combat_damage_065(hit, float(damage_by_id[id]), "shotgun")

func _perform_bow_065(_weapon: String, profile: Dictionary) -> bool:
	var ammo_id := str(profile.get("ammo", "arrows"))
	if int(inventory.get(ammo_id, 0)) <= 0:
		last_attack_result_065 = "empty"
		_emit_combat_feedback_065("denied", "SEM FLECHAS", 0.82)
		return false
	inventory[ammo_id] = int(inventory.get(ammo_id, 0)) - 1
	attack_cooldown = float(profile.get("cooldown", 0.76))
	var max_range := float(profile.get("range", 18.0))
	var target := _select_target_065(max_range, float(profile.get("assist", 52.0)), true)
	if target != null:
		_face_target_065(target)
		last_target_id_065 = target.get_instance_id()
	else:
		last_target_id_065 = 0
	_play_spatial_attack_animation_065("bow")
	var direction := _aim_direction_065(target)
	var arrow := ArrowProjectile065Script.new()
	var projectile_parent: Node = get_tree().current_scene
	if projectile_parent == null and world != null and is_instance_valid(world):
		projectile_parent = world
	if projectile_parent == null:
		projectile_parent = get_parent()
	if projectile_parent == null:
		last_attack_result_065 = "projectile_parent_missing"
		arrow.queue_free()
		return false
	projectile_parent.add_child(arrow)
	arrow.global_position = global_position + Vector3(0.0, 0.88, 0.0) + direction * 0.65
	arrow.call("setup_065", self, direction, float(profile.get("damage", 62.0)), max_range)
	arrows_fired_065 += 1
	last_attack_result_065 = "projectile"
	_emit_combat_noise_065(float(profile.get("noise", 4.5)), "bow")
	return true

func register_arrow_hit_065(collider: Object, base_damage: float) -> bool:
	var target := _resolve_damageable_065(collider)
	if target == null:
		return false
	_apply_combat_damage_065(target, base_damage, "bow")
	last_attack_result_065 = "hit"
	last_target_id_065 = target.get_instance_id()
	return true

func _select_target_065(max_range: float, assist_half_angle_deg: float, require_los: bool) -> Node3D:
	var forward := _combat_forward_065()
	var best: Node3D = null
	var best_score := INF
	var max_angle := deg_to_rad(maxf(1.0, assist_half_angle_deg))
	for candidate in _combat_candidates_065():
		if candidate == null or not is_instance_valid(candidate):
			continue
		var offset := candidate.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance <= 0.05 or distance > max_range:
			continue
		var direction := offset / distance
		var angle := acos(clampf(forward.dot(direction), -1.0, 1.0))
		if angle > max_angle:
			continue
		if require_los and not _line_of_sight_065(candidate):
			continue
		var animal_penalty := 5.0 if candidate.is_in_group("huntable_0538") else 0.0
		var score := distance + angle * 2.25 + animal_penalty
		if score < best_score:
			best_score = score
			best = candidate
	return best

func _combat_candidates_065() -> Array[Node3D]:
	var result: Array[Node3D] = []
	if world != null and world.has_method("get_zombies"):
		for raw in world.call("get_zombies"):
			if raw is Node3D and is_instance_valid(raw as Node3D):
				result.append(raw as Node3D)
	if world != null and world.has_method("get_huntable_animals_0538"):
		for raw in world.call("get_huntable_animals_0538"):
			if not (raw is Node3D):
				continue
			var animal := raw as Node3D
			if not is_instance_valid(animal):
				continue
			if animal.has_method("is_alive_0538") and not bool(animal.call("is_alive_0538")):
				continue
			result.append(animal)
	return result

func _combat_forward_065() -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return Vector3(0.0, 0.0, -1.0)
	return forward.normalized()

func _face_target_065(target: Node3D) -> void:
	var direction := target.global_position - global_position
	direction.y = 0.0
	if direction.length() <= 0.01:
		return
	rotation.y = atan2(direction.x, direction.z) + PI

func _aim_direction_065(target: Node3D) -> Vector3:
	if target == null or not is_instance_valid(target):
		return _combat_forward_065()
	var origin := global_position + Vector3(0.0, 0.88, 0.0)
	var target_point := target.global_position + Vector3(0.0, 0.78, 0.0)
	var direction := target_point - origin
	if direction.length() <= 0.01:
		return _combat_forward_065()
	return direction.normalized()

func _line_of_sight_065(target: Node3D) -> bool:
	if target == null or not is_instance_valid(target):
		return false
	var origin := global_position + Vector3(0.0, 0.92, 0.0)
	var endpoint := target.global_position + Vector3(0.0, 0.76, 0.0)
	var query := PhysicsRayQueryParameters3D.create(origin, endpoint)
	query.exclude = [get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true
	var resolved := _resolve_damageable_065(result.get("collider") as Object)
	return resolved == target

func _raycast_damageable_065(direction: Vector3, max_range: float) -> Node3D:
	var origin := global_position + Vector3(0.0, 0.92, 0.0)
	var endpoint := origin + direction.normalized() * max_range
	var query := PhysicsRayQueryParameters3D.create(origin, endpoint)
	query.exclude = [get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	return _resolve_damageable_065(result.get("collider") as Object)

func _resolve_damageable_065(value: Object) -> Node3D:
	if value == null or not (value is Node):
		return null
	var current := value as Node
	while current != null:
		if current == self:
			return null
		if current is Node3D and current.has_method("take_damage"):
			return current as Node3D
		current = current.get_parent()
	return null

func _apply_combat_damage_065(target: Node3D, base_damage: float, source_kind: String) -> void:
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage"):
		return
	var multiplier := get_combat_damage_multiplier_0535() if has_method("get_combat_damage_multiplier_0535") else 1.0
	var damage := maxf(1.0, base_damage * multiplier)
	target.call("take_damage", damage)
	combat_hits_065 += 1
	if target.is_in_group("huntable_0538"):
		animals_hit_0538 += 1
		award_skill_xp_0535("combat", 4, "animal_hit")
	else:
		award_skill_xp_0535("combat", 5, "hit")
	_emit_combat_feedback_065("attack", "ACERTO", 1.0 if source_kind == "melee" else 1.12)

func _play_spatial_attack_animation_065(weapon_class: String) -> void:
	match weapon_class:
		"melee_2h":
			play_melee_2h_05405()
		"firearm_1h":
			play_firearm_1h_05405()
		"firearm_2h":
			play_firearm_2h_05405()
		"bow":
			play_bow_05405()
		_:
			play_melee_1h_05405()

func _emit_combat_noise_065(radius: float, kind: String) -> void:
	if world != null and world.has_method("emit_noise_0519"):
		world.call("emit_noise_0519", global_position, radius, kind, self)

func _emit_combat_feedback_065(kind: String, text: String, strength: float) -> void:
	if world != null and world.has_method("emit_feedback_05404"):
		world.call("emit_feedback_05404", kind, text, strength)

func _sort_combat_candidate_065(a: Dictionary, b: Dictionary) -> bool:
	return float(a.get("distance", INF)) < float(b.get("distance", INF))

func get_hotbar_slots_0523() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_id in HOTBAR_PRIORITIES_065:
		var id := str(raw_id)
		if owned_weapons.has(id):
			var detail_count := -1
			if id == "pistol":
				detail_count = int(inventory.get("ammo_9mm", 0))
			elif id == "shotgun":
				detail_count = int(inventory.get("shells", 0))
			elif id == "bow":
				detail_count = int(inventory.get("arrows", 0))
			result.append({
				"id": id,
				"kind": "weapon",
				"count": detail_count,
				"equipped": get_equipped_weapon() == id,
				"broken": is_weapon_broken_0523(id),
				"durability": get_weapon_durability_percent_0523(id)
			})
		elif id in CONSUMABLE_IDS_0523:
			var amount := int(inventory.get(id, 0))
			if amount > 0:
				result.append({"id":id,"kind":"item","count":amount,"equipped":false,"broken":false,"durability":-1})
		if result.size() >= 6:
			break
	return result

func get_weapon_summary() -> String:
	var weapon := get_equipped_weapon()
	var profile: Dictionary = WEAPON_PROFILES_065.get(weapon, {}) as Dictionary
	var label := str(profile.get("name", weapon.to_upper()))
	var ammo_text := ""
	if weapon == "pistol":
		ammo_text = " • %d munições" % int(inventory.get("ammo_9mm", 0))
	elif weapon == "shotgun":
		ammo_text = " • %d cartuchos" % int(inventory.get("shells", 0))
	elif weapon == "bow":
		ammo_text = " • %d flechas" % int(inventory.get("arrows", 0))
	var durability := get_weapon_durability_percent_0523(weapon)
	if is_weapon_broken_0523(weapon):
		return "%s%s — QUEBRADA" % [label, ammo_text]
	return "%s%s — DUR %d%%" % [label, ammo_text, durability]

func get_weapon_profile_065(id: String) -> Dictionary:
	if not WEAPON_PROFILES_065.has(id):
		return {}
	return (WEAPON_PROFILES_065[id] as Dictionary).duplicate(true)

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["combat_loadout_initialized_065"] = combat_loadout_initialized_065
	state["combat_attacks_065"] = combat_attacks_065
	state["combat_hits_065"] = combat_hits_065
	state["combat_misses_065"] = combat_misses_065
	state["melee_hits_065"] = melee_hits_065
	state["firearm_shots_065"] = firearm_shots_065
	state["arrows_fired_065"] = arrows_fired_065
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	combat_loadout_initialized_065 = bool(state.get("combat_loadout_initialized_065", false))
	combat_attacks_065 = int(state.get("combat_attacks_065", 0))
	combat_hits_065 = int(state.get("combat_hits_065", 0))
	combat_misses_065 = int(state.get("combat_misses_065", 0))
	melee_hits_065 = int(state.get("melee_hits_065", 0))
	firearm_shots_065 = int(state.get("firearm_shots_065", 0))
	arrows_fired_065 = int(state.get("arrows_fired_065", 0))
	_ensure_combat_loadout_065()

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	combat_loadout_initialized_065 = false
	combat_attacks_065 = 0
	combat_hits_065 = 0
	combat_misses_065 = 0
	melee_hits_065 = 0
	firearm_shots_065 = 0
	arrows_fired_065 = 0
	last_attack_result_065 = ""
	last_target_id_065 = 0
	last_weapon_065 = ""
	_ensure_combat_loadout_065()

func get_spatial_combat_debug_065() -> Dictionary:
	return {
		"version": COMBAT_VERSION_065,
		"spatial_targeting": true,
		"line_of_sight": true,
		"melee_arc": true,
		"firearm_raycast": true,
		"shotgun_pellets": int((WEAPON_PROFILES_065["shotgun"] as Dictionary).get("pellets", 0)),
		"bow_projectile": true,
		"weapon_profiles": WEAPON_PROFILES_065.size(),
		"owned_weapons": owned_weapons.duplicate(),
		"equipped": get_equipped_weapon(),
		"arrows": int(inventory.get("arrows", 0)),
		"ammo_9mm": int(inventory.get("ammo_9mm", 0)),
		"shells": int(inventory.get("shells", 0)),
		"attacks": combat_attacks_065,
		"hits": combat_hits_065,
		"misses": combat_misses_065,
		"melee_hits": melee_hits_065,
		"firearm_shots": firearm_shots_065,
		"arrows_fired": arrows_fired_065,
		"last_result": last_attack_result_065,
		"last_target": last_target_id_065,
		"last_weapon": last_weapon_065
	}
