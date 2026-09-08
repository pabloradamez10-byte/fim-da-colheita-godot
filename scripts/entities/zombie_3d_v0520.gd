extends "res://scripts/entities/zombie_3d_v0519.gd"

var archetype_0520 := "errante"

func _ready() -> void:
	super._ready()
	match variant:
		0:
			archetype_0520 = "errante"
			health = 64.0
		1:
			archetype_0520 = "agitado"
			health = 70.0
		2:
			archetype_0520 = "robusto"
			health = 96.0
		_:
			archetype_0520 = "infectado"
			health = 78.0

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	memory_timer_0519 = maxf(0.0, memory_timer_0519 - delta)
	sense_timer_0519 = maxf(0.0, sense_timer_0519 - delta)
	wander_timer_0519 = maxf(0.0, wander_timer_0519 - delta)

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		velocity = Vector3.ZERO
		global_position.y = GROUND_Y_0519
		return

	if world_0519 == null or not is_instance_valid(world_0519):
		world_0519 = _resolve_world_0519()

	if sense_timer_0519 <= 0.0:
		_update_senses_0519()
		sense_timer_0519 = 0.16 + float(variant) * 0.015

	var distance_to_player := global_position.distance_to(player.global_position)
	if distance_to_player <= ATTACK_RANGE and _has_line_of_sight_0519(player.global_position):
		velocity = Vector3.ZERO
		alert_state_0519 = "chase"
		last_known_position_0519 = player.global_position
		memory_timer_0519 = MEMORY_TIME_0519
		_face_target_0519(player.global_position, delta)
		if attack_cooldown <= 0.0:
			var damage := 7.0 + float(variant) * 0.8
			if player.has_method("take_zombie_damage_0520"):
				player.call("take_zombie_damage_0520", damage, variant)
			elif player.has_method("take_damage"):
				player.call("take_damage", damage)
			attack_cooldown = 1.18 + float(variant) * 0.04
			_emit_noise_0519(7.0, "zombie_attack")
	else:
		var target := _movement_target_0519()
		_move_toward_target_0519(target, delta)

	global_position.y = GROUND_Y_0519
	if visual_root != null:
		visual_root.position.y = 0.0

func take_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	health -= amount
	if health <= 0.0:
		if world_0519 == null or not is_instance_valid(world_0519):
			world_0519 = _resolve_world_0519()
		if world_0519 != null and world_0519.has_method("register_zombie_death_0520"):
			world_0519.call("register_zombie_death_0520", name, global_position, variant)
		queue_free()
		return

	if visual_root != null:
		var tween := create_tween()
		tween.tween_property(visual_root, "scale", Vector3(1.08, 0.92, 1.08), 0.06)
		tween.tween_property(visual_root, "scale", Vector3.ONE, 0.10)
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		last_known_position_0519 = player.global_position
		alert_state_0519 = "chase"
		memory_timer_0519 = MEMORY_TIME_0519
	_emit_noise_0519(8.5, "zombie_hit")

func get_ai_debug_0520() -> Dictionary:
	var result := get_ai_debug_0519()
	result["archetype_0520"] = archetype_0520
	result["health_0520"] = health
	result["variant_0520"] = variant
	return result
