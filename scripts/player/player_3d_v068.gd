extends "res://scripts/player/player_3d_v066.gd"

# Original controller guided by the documented input facts, not transplanted code.
const MOTION_VERSION_068 := "0.6.8-alpha"
const STRIDE_WALK_068 := 3.4
const STRIDE_RUN_068 := 3.9
var travel_phase_068 := 0.0
var actual_speed_068 := 0.0
var motion_camera_068: Camera3D
var previous_position_068 := Vector3.ZERO
var movement_input_enabled_068 := true

func _ready() -> void:
	set_meta("survival_motion_068", true)
	super._ready()
	floor_snap_length = 0.35
	floor_constant_speed = true
	safe_margin = 0.025
	previous_position_068 = global_position
	add_to_group("survival_motion_068")

func _motion_direction_058(input_vec: Vector2) -> Vector3:
	if not movement_input_enabled_068:
		return Vector3.ZERO
	if motion_camera_068 == null or not is_instance_valid(motion_camera_068):
		motion_camera_068 = get_viewport().get_camera_3d()
	if motion_camera_068 == null:
		return super._motion_direction_058(input_vec)
	var right := motion_camera_068.global_basis.x
	var down := motion_camera_068.global_basis.z
	right.y = 0.0
	down.y = 0.0
	return right.normalized() * input_vec.x + down.normalized() * input_vec.y

func _apply_motion_058(desired: Vector3, delta: float) -> void:
	if is_in_vehicle_0530():
		actual_speed_068 = 0.0
		velocity = Vector3.ZERO
		return
	# Direct bounded planar input: a released stick has no smoothing tail.
	velocity.x = desired.x
	velocity.z = desired.z
	if is_on_floor():
		velocity.y = -FLOOR_STICK_SPEED_066
	else:
		velocity.y = maxf(velocity.y - GRAVITY_066 * delta, -TERMINAL_FALL_SPEED_066)
	var start := global_position
	move_and_slide()
	if is_on_floor():
		apply_floor_snap()
	var displacement := global_position - start
	displacement.y = 0.0
	actual_speed_068 = displacement.length() / maxf(delta, 0.00001)
	# Use resolved displacement, so pushing into a wall does not animate running.
	var stride := STRIDE_RUN_068 if actual_speed_068 >= RUN_THRESHOLD_064 else STRIDE_WALK_068
	travel_phase_068 = fposmod(travel_phase_068 + displacement.length() / stride, 1.0)
	previous_position_068 = global_position

func _refresh_character_art_05402(delta: float) -> void:
	if character_sprite_05402 == null or not is_instance_valid(character_sprite_05402):
		return
	# Keep action frames, textures and combat hooks from the existing controller.
	if action_clock_05405 > 0.0 and action_texture_05405 != null:
		super._refresh_character_art_05402(delta)
		return
	var yaw := fposmod(rotation.y, TAU)
	sprite_direction_064 = posmod(roundi(yaw / (PI * 0.25)), DIRECTION_COUNT_064)
	direction_05405 = sprite_direction_064
	character_direction_05402 = sprite_direction_064
	movement_state_064 = "idle" if actual_speed_068 <= 0.08 else ("run" if actual_speed_068 >= RUN_THRESHOLD_064 else "walk")
	visual_state_05405 = movement_state_064
	character_sprite_05402.pixel_size = SPRITE_PIXEL_SIZE_064
	character_sprite_05402.position.y = SPRITE_CENTER_Y_064
	character_sprite_05402.scale = Vector3.ONE
	if movement_state_064 == "idle":
		character_sprite_05402.texture = PLAYER_IDLE_064
		character_sprite_05402.hframes = DIRECTION_COUNT_064
		character_sprite_05402.vframes = 1
		character_sprite_05402.frame = sprite_direction_064
	else:
		character_sprite_05402.texture = PLAYER_MOVE_064
		character_sprite_05402.hframes = WALK_FRAMES_064
		character_sprite_05402.vframes = DIRECTION_COUNT_064
		character_sprite_05402.frame = sprite_direction_064 * WALK_FRAMES_064 + mini(WALK_FRAMES_064 - 1, int(travel_phase_068 * WALK_FRAMES_064))
	set_meta("player_direction_05402", sprite_direction_064)
	set_meta("player_visual_state_05405", movement_state_064)
	set_meta("player_visual_state_064", movement_state_064)

func get_survival_motion_debug_068() -> Dictionary:
	return {"version": MOTION_VERSION_068, "actual_speed": actual_speed_068,
		"phase": travel_phase_068, "state": movement_state_064,
		"camera_relative": motion_camera_068 != null, "grounded": is_on_floor()}
