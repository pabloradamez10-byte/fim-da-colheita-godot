extends "res://scripts/entities/zombie_3d_v0528.gd"

const ZOMBIE_ATLAS_0537: Texture2D = preload("res://assets/zombies/fdc_zombie_atlas_0537.png")
const ZOMBIE_CELL_0537 := Vector2i(64, 96)
const ZOMBIE_PROFILE_COUNT_0537 := 5
const ZOMBIE_FRAME_COUNT_0537 := 8
const HINGE_ATTACK_COOLDOWN_0537 := 1.08

const PROFILE_NAMES_0537 := [
	"errante",
	"corredor",
	"robusto",
	"rural",
	"operario"
]
const PROFILE_SPEED_0537 := [1.00, 1.34, 0.78, 0.96, 0.90]
const PROFILE_HEARING_0537 := [1.00, 1.16, 0.92, 1.04, 1.08]
const PROFILE_HEALTH_0537 := [72.0, 61.0, 112.0, 84.0, 92.0]
const PROFILE_VARIANT_0537 := [0, 1, 2, 3, 2]
const PROFILE_HINGE_DAMAGE_0537 := [7.5, 6.0, 13.5, 8.5, 11.0]

var horde_id_0537 := -1
var horde_member_0537 := 0
var profile_0537 := -1
var sprite_0537: Sprite3D = null
var animation_clock_0537 := 0.0
var animation_frame_0537 := 0
var hinge_attack_timer_0537 := 0.0
var horde_offset_0537 := Vector3.ZERO

func configure_horde_0537(horde_id: int, member_index: int, profile_index: int) -> void:
	horde_id_0537 = maxi(-1, horde_id)
	horde_member_0537 = maxi(0, member_index)
	profile_0537 = posmod(profile_index, ZOMBIE_PROFILE_COUNT_0537)
	var angle := float(horde_member_0537 % 8) / 8.0 * TAU
	var ring := 0.65 + float(horde_member_0537 / 8) * 0.55
	horde_offset_0537 = Vector3(cos(angle) * ring, 0.0, sin(angle) * ring)

func _ready() -> void:
	super._ready()
	if profile_0537 < 0:
		profile_0537 = int(abs(hash("profile0537:%s" % name))) % ZOMBIE_PROFILE_COUNT_0537
	variant = int(PROFILE_VARIANT_0537[profile_0537])
	archetype_0520 = str(PROFILE_NAMES_0537[profile_0537])
	health = float(PROFILE_HEALTH_0537[profile_0537])
	if visual_root != null:
		visual_root.visible = false
	_build_sprite_0537()
	add_to_group("zombie_0537")
	add_to_group("zombie_horde_0537")
	add_to_group("zombie_profile_%s_0537" % archetype_0520)

func _build_sprite_0537() -> void:
	if sprite_0537 != null and is_instance_valid(sprite_0537):
		sprite_0537.queue_free()
	sprite_0537 = Sprite3D.new()
	sprite_0537.name = "ZombieSprite0537"
	sprite_0537.texture = ZOMBIE_ATLAS_0537
	sprite_0537.region_enabled = true
	sprite_0537.region_rect = Rect2(0.0, float(profile_0537 * ZOMBIE_CELL_0537.y), float(ZOMBIE_CELL_0537.x), float(ZOMBIE_CELL_0537.y))
	sprite_0537.pixel_size = 0.022
	sprite_0537.position = Vector3(0.0, 1.08, 0.0)
	sprite_0537.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0537.shaded = false
	sprite_0537.transparent = true
	sprite_0537.double_sided = true
	sprite_0537.add_to_group("zombie_sprite_0537")
	add_child(sprite_0537)

func _physics_process(delta: float) -> void:
	hinge_attack_timer_0537 = maxf(0.0, hinge_attack_timer_0537 - delta)
	super._physics_process(delta)
	if is_queued_for_deletion():
		return
	_update_sprite_animation_0537(delta)
	_try_attack_world_hinge_0537()

func _update_sprite_animation_0537(delta: float) -> void:
	if sprite_0537 == null or not is_instance_valid(sprite_0537):
		return
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	var interval := 0.34
	if planar_speed > 0.35:
		interval = 0.115 if alert_state_0519 == "chase" else 0.165
	animation_clock_0537 += delta
	if animation_clock_0537 < interval:
		return
	animation_clock_0537 = 0.0
	if planar_speed <= 0.35:
		animation_frame_0537 = (animation_frame_0537 + 1) % 2
	else:
		animation_frame_0537 = (animation_frame_0537 + 1) % ZOMBIE_FRAME_COUNT_0537
	_refresh_sprite_frame_0537()

func _refresh_sprite_frame_0537() -> void:
	if sprite_0537 == null:
		return
	sprite_0537.region_rect = Rect2(
		float(animation_frame_0537 * ZOMBIE_CELL_0537.x),
		float(profile_0537 * ZOMBIE_CELL_0537.y),
		float(ZOMBIE_CELL_0537.x),
		float(ZOMBIE_CELL_0537.y)
	)

func hear_noise_0519(noise_position: Vector3, radius: float, kind: String) -> bool:
	var profile_hearing := float(PROFILE_HEARING_0537[profile_0537]) if profile_0537 >= 0 else 1.0
	var kind_multiplier := 1.0
	match kind:
		"shotgun":
			kind_multiplier = 1.28
		"pistol":
			kind_multiplier = 1.18
		"vehicle_crash":
			kind_multiplier = 1.25
		"vehicle_engine":
			kind_multiplier = 1.12
		"zombie_structure", "zombie_hinge_0537":
			kind_multiplier = 1.08
	var heard := super.hear_noise_0519(noise_position, radius * profile_hearing * kind_multiplier, kind)
	if heard and world_0519 != null and world_0519.has_method("register_horde_noise_0537") and horde_id_0537 >= 0:
		world_0519.call("register_horde_noise_0537", horde_id_0537, noise_position, radius, kind)
	return heard

func _movement_target_0519() -> Vector3:
	if alert_state_0519 in ["chase", "investigate"] and memory_timer_0519 > 0.0:
		return super._movement_target_0519()
	if horde_id_0537 >= 0 and world_0519 != null and world_0519.has_method("get_horde_target_0537"):
		var raw: Variant = world_0519.call("get_horde_target_0537", horde_id_0537)
		if raw is Vector3:
			var target := raw as Vector3
			if Vector2(target.x - global_position.x, target.z - global_position.z).length() > 1.0:
				alert_state_0519 = "migrate"
				return target + horde_offset_0537
	return super._movement_target_0519()

func _move_toward_target_0519(target: Vector3, delta: float) -> void:
	var dir := target - global_position
	dir.y = 0.0
	var distance := dir.length()
	if distance <= 0.55:
		velocity = Vector3.ZERO
		if alert_state_0519 in ["chase", "investigate"] and memory_timer_0519 <= 0.4:
			alert_state_0519 = "idle"
		return
	var speed := 1.25 + float(variant) * 0.18
	if alert_state_0519 == "chase":
		speed = 2.15 + float(variant) * 0.22
	elif alert_state_0519 == "investigate":
		speed = 1.72 + float(variant) * 0.14
	elif alert_state_0519 == "migrate":
		speed = 1.38 + float(variant) * 0.10
	if profile_0537 >= 0:
		speed *= float(PROFILE_SPEED_0537[profile_0537])
	velocity = dir.normalized() * speed
	_face_target_0519(target, delta)
	move_and_slide()
	gait_time += delta * (5.5 + speed)
	if get_slide_collision_count() > 0 and alert_state_0519 == "idle":
		wander_timer_0519 = 0.0

func _try_attack_world_hinge_0537() -> void:
	if hinge_attack_timer_0537 > 0.0:
		return
	if alert_state_0519 not in ["chase", "investigate", "migrate"]:
		return
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		if collision == null:
			continue
		var collider: Object = collision.get_collider()
		if not (collider is Node):
			continue
		var hinge := _find_world_hinge_0537(collider as Node)
		if hinge == null:
			continue
		if bool(hinge.get("is_open")):
			continue
		if world_0519 == null or not is_instance_valid(world_0519):
			world_0519 = _resolve_world_0519()
		if world_0519 != null and world_0519.has_method("damage_world_hinge_0537"):
			var amount := float(PROFILE_HINGE_DAMAGE_0537[profile_0537]) if profile_0537 >= 0 else 8.0
			world_0519.call("damage_world_hinge_0537", hinge, amount, name)
			hinge_attack_timer_0537 = HINGE_ATTACK_COOLDOWN_0537
			_emit_noise_0519(9.5, "zombie_hinge_0537")
			return

func _find_world_hinge_0537(node: Node) -> Node3D:
	var current: Node = node
	while current != null:
		if current is Node3D and current.is_in_group("interactive_hinge_0512"):
			return current as Node3D
		if current is Node3D and current.is_in_group("build_structure_0526"):
			return null
		current = current.get_parent()
	return null

func get_ai_debug_0537() -> Dictionary:
	var result := get_ai_debug_0528()
	result["horde_id_0537"] = horde_id_0537
	result["horde_member_0537"] = horde_member_0537
	result["profile_0537"] = profile_0537
	result["profile_name_0537"] = archetype_0520
	result["sprite_0537"] = sprite_0537 != null and is_instance_valid(sprite_0537)
	result["animation_frame_0537"] = animation_frame_0537
	result["migrating_0537"] = alert_state_0519 == "migrate"
	return result
