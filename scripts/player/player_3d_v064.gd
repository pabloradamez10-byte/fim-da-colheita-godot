extends "res://scripts/player/player_3d_v0600.gd"

const PROTAGONIST_VERSION_064 := "0.6.4-alpha"
const PLAYER_IDLE_064: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/idle_8dir.png")
const PLAYER_MOVE_064: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/walk_8dir.png")

const DIRECTION_COUNT_064 := 8
const WALK_FRAMES_064 := 6
const WALK_FPS_064 := 9.0
const RUN_FPS_064 := 13.5
const RUN_THRESHOLD_064 := 6.0
const SPRITE_PIXEL_SIZE_064 := 0.05
const SPRITE_CENTER_Y_064 := 0.85

var movement_clock_064 := 0.0
var movement_state_064 := "idle"
var sprite_direction_064 := 0

func _install_character_art_05402() -> void:
	if visual_root != null and is_instance_valid(visual_root):
		visual_root.visible = false
	character_sprite_05402 = Sprite3D.new()
	character_sprite_05402.name = "PlayerSprite064"
	character_sprite_05402.texture = PLAYER_IDLE_064
	character_sprite_05402.hframes = DIRECTION_COUNT_064
	character_sprite_05402.vframes = 1
	character_sprite_05402.frame = 0
	character_sprite_05402.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	character_sprite_05402.shaded = false
	character_sprite_05402.transparent = true
	character_sprite_05402.double_sided = true
	character_sprite_05402.pixel_size = SPRITE_PIXEL_SIZE_064
	character_sprite_05402.position = Vector3(0.0, SPRITE_CENTER_Y_064, 0.0)
	character_sprite_05402.add_to_group("player_high_detail_05402")
	character_sprite_05402.add_to_group("player_sprite_pack_064")
	add_child(character_sprite_05402)
	set_meta("player_visual_version", PROTAGONIST_VERSION_064)
	set_meta("player_visual_source", "sprite_pack_05405_animated_064")
	_refresh_character_art_05402(0.0)

func _refresh_character_art_05402(delta: float) -> void:
	if character_sprite_05402 == null or not is_instance_valid(character_sprite_05402):
		return

	var yaw := fposmod(rotation.y, TAU)
	direction_05405 = posmod(int(round(yaw / (PI * 0.25))), DIRECTION_COUNT_05405)
	character_direction_05402 = direction_05405
	sprite_direction_064 = direction_05405

	if action_clock_05405 > 0.0 and action_texture_05405 != null:
		action_clock_05405 = maxf(0.0, action_clock_05405 - delta)
		_apply_action_frame_05405()
		if action_clock_05405 <= 0.0:
			action_texture_05405 = null
		return

	movement_clock_064 += maxf(0.0, delta)
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	var next_state := "idle"
	if planar_speed >= RUN_THRESHOLD_064:
		next_state = "run"
	elif planar_speed > 0.15:
		next_state = "walk"

	if next_state != movement_state_064:
		movement_state_064 = next_state
		movement_clock_064 = 0.0

	visual_state_05405 = movement_state_064
	character_sprite_05402.pixel_size = SPRITE_PIXEL_SIZE_064
	character_sprite_05402.scale = Vector3.ONE

	if movement_state_064 == "idle":
		character_sprite_05402.texture = PLAYER_IDLE_064
		character_sprite_05402.hframes = DIRECTION_COUNT_064
		character_sprite_05402.vframes = 1
		character_sprite_05402.frame = sprite_direction_064
		var idle_breath := sin(movement_clock_064 * 2.2)
		character_sprite_05402.position.y = SPRITE_CENTER_Y_064 + idle_breath * 0.006
		character_sprite_05402.scale.y = 1.0 + idle_breath * 0.004
	else:
		character_sprite_05402.texture = PLAYER_MOVE_064
		character_sprite_05402.hframes = WALK_FRAMES_064
		character_sprite_05402.vframes = DIRECTION_COUNT_064
		var fps := RUN_FPS_064 if movement_state_064 == "run" else WALK_FPS_064
		var move_frame := int(floor(movement_clock_064 * fps)) % WALK_FRAMES_064
		character_sprite_05402.frame = sprite_direction_064 * WALK_FRAMES_064 + move_frame
		if movement_state_064 == "run":
			var run_phase := absf(sin(movement_clock_064 * RUN_FPS_064))
			character_sprite_05402.position.y = SPRITE_CENTER_Y_064 + run_phase * 0.035
			character_sprite_05402.scale = Vector3(1.0 + run_phase * 0.018, 1.0 - run_phase * 0.014, 1.0)
		else:
			character_sprite_05402.position.y = SPRITE_CENTER_Y_064

	set_meta("player_direction_05402", sprite_direction_064)
	set_meta("player_visual_state_05405", visual_state_05405)
	set_meta("player_visual_state_064", movement_state_064)

func _apply_action_frame_05405() -> void:
	if character_sprite_05402 != null and is_instance_valid(character_sprite_05402):
		character_sprite_05402.pixel_size = SPRITE_PIXEL_SIZE_05405
		character_sprite_05402.position.y = SPRITE_CENTER_Y_05405
		character_sprite_05402.scale = Vector3.ONE
	super._apply_action_frame_05405()

func get_player_visual_debug_064() -> Dictionary:
	return {
		"version": PROTAGONIST_VERSION_064,
		"source": "assets/characters/player/sprite_pack_05405",
		"sprite": character_sprite_05402 != null and is_instance_valid(character_sprite_05402),
		"directions": DIRECTION_COUNT_064,
		"idle_supported": true,
		"walk_frames": WALK_FRAMES_064,
		"run_frames": WALK_FRAMES_064,
		"run_supported": true,
		"state": movement_state_064,
		"sprite_direction": sprite_direction_064,
		"legacy_actions_preserved": true,
		"pixel_size": SPRITE_PIXEL_SIZE_064
	}
