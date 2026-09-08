extends "res://scripts/entities/zombie_3d_v059.gd"

const GROUND_Y_0519 := 0.20
const VISION_RANGE_0519 := 16.0
const CLOSE_SENSE_RANGE_0519 := 3.3
const MEMORY_TIME_0519 := 6.0
const INVESTIGATE_TIME_0519 := 4.2
const VISION_DOT_0519 := 0.32

var alert_state_0519 := "idle"
var last_known_position_0519 := Vector3.ZERO
var memory_timer_0519 := 0.0
var sense_timer_0519 := 0.0
var wander_timer_0519 := 0.0
var wander_direction_0519 := Vector3.ZERO
var last_heard_kind_0519 := ""
var can_see_player_0519 := false
var world_0519: Node = null

func _ready() -> void:
	super._ready()
	world_0519 = get_tree().current_scene
	wander_timer_0519 = 0.1

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
		world_0519 = get_tree().current_scene

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
		if attack_cooldown <= 0.0 and player.has_method("take_damage"):
			player.call("take_damage", 7.0 + float(variant) * 0.8)
			attack_cooldown = 1.18 + float(variant) * 0.04
			_emit_noise_0519(7.0, "zombie_attack")
	else:
		var target := _movement_target_0519()
		_move_toward_target_0519(target, delta)

	global_position.y = GROUND_Y_0519
	if visual_root != null:
		visual_root.position.y = 0.0

func _update_senses_0519() -> void:
	can_see_player_0519 = _can_see_player_0519()
	if can_see_player_0519:
		alert_state_0519 = "chase"
		last_known_position_0519 = player.global_position
		memory_timer_0519 = MEMORY_TIME_0519
		last_heard_kind_0519 = ""
		return

	if world_0519 != null and world_0519.has_method("get_loudest_noise_for_0519"):
		var heard: Variant = world_0519.call("get_loudest_noise_for_0519", global_position, 4800)
		if heard is Dictionary and not (heard as Dictionary).is_empty():
			var data := heard as Dictionary
			last_known_position_0519 = data.get("position", global_position) as Vector3
			last_heard_kind_0519 = str(data.get("kind", "noise"))
			alert_state_0519 = "investigate"
			memory_timer_0519 = INVESTIGATE_TIME_0519

func _can_see_player_0519() -> bool:
	if player == null:
		return false
	var delta := player.global_position - global_position
	delta.y = 0.0
	var distance := delta.length()
	if distance > VISION_RANGE_0519:
		return false
	if distance <= CLOSE_SENSE_RANGE_0519:
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

func _has_line_of_sight_0519(target_position: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	if space == null:
		return true
	var from := global_position + Vector3(0.0, 1.15, 0.0)
	var to := target_position + Vector3(0.0, 1.0, 0.0)
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	query.collide_with_areas = false
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return true
	var collider: Variant = hit.get("collider")
	return collider == player

func _movement_target_0519() -> Vector3:
	if alert_state_0519 in ["chase", "investigate"] and memory_timer_0519 > 0.0:
		return last_known_position_0519
	alert_state_0519 = "idle"
	last_heard_kind_0519 = ""
	if wander_timer_0519 <= 0.0 or wander_direction_0519.length() <= 0.01:
		var tick_bucket := int(Time.get_ticks_msec() / 800)
		var hash_value := int(abs(hash("wander0519:%s:%d" % [name, tick_bucket])))
		var marker := float(hash_value % 628) / 100.0
		wander_direction_0519 = Vector3(cos(marker), 0.0, sin(marker)).normalized()
		wander_timer_0519 = 1.4 + float(variant) * 0.35
	return global_position + wander_direction_0519 * 3.0

func _move_toward_target_0519(target: Vector3, delta: float) -> void:
	var dir := target - global_position
	dir.y = 0.0
	var distance := dir.length()
	if distance <= 0.55:
		velocity = Vector3.ZERO
		if alert_state_0519 != "idle" and memory_timer_0519 <= 0.4:
			alert_state_0519 = "idle"
		return
	var speed := 1.25 + float(variant) * 0.18
	if alert_state_0519 == "chase":
		speed = 2.15 + float(variant) * 0.22
	elif alert_state_0519 == "investigate":
		speed = 1.72 + float(variant) * 0.14
	velocity = dir.normalized() * speed
	_face_target_0519(target, delta)
	move_and_slide()
	gait_time += delta * (5.5 + speed)
	if get_slide_collision_count() > 0 and alert_state_0519 == "idle":
		wander_timer_0519 = 0.0

func _face_target_0519(target: Vector3, delta: float) -> void:
	var dir := target - global_position
	dir.y = 0.0
	if dir.length() <= 0.01:
		return
	rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z) + PI, clampf(delta * 7.5, 0.0, 1.0))

func take_damage(amount: float) -> void:
	super.take_damage(amount)
	if health <= 0.0:
		return
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if player != null:
		last_known_position_0519 = player.global_position
		alert_state_0519 = "chase"
		memory_timer_0519 = MEMORY_TIME_0519
	_emit_noise_0519(8.5, "zombie_hit")

func _emit_noise_0519(radius: float, kind: String) -> void:
	if world_0519 != null and world_0519.has_method("emit_noise_0519"):
		world_0519.call("emit_noise_0519", global_position, radius, kind, self)

func get_ai_debug_0519() -> Dictionary:
	return {
		"state": alert_state_0519,
		"can_see_player": can_see_player_0519,
		"memory": memory_timer_0519,
		"last_heard": last_heard_kind_0519,
		"target": last_known_position_0519
	}
