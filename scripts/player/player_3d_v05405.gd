extends "res://scripts/player/player_3d_v05402.gd"

const PLAYER_IDLE_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/idle_8dir.png")
const PLAYER_WALK_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/walk_8dir.png")
const PLAYER_MELEE_1H_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/melee_1h_8dir.png")
const PLAYER_MELEE_2H_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/melee_2h_8dir.png")
const PLAYER_FIREARM_1H_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/firearm_1h_8dir.png")
const PLAYER_FIREARM_2H_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/firearm_2h_8dir.png")
const PLAYER_BOW_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/bow_8dir.png")
const PLAYER_HARVEST_05405: Texture2D = preload("res://assets/characters/player/sprite_pack_05405/harvest_animal_8dir.png")

const WALK_FRAMES_05405 := 6
const ACTION_FRAMES_05405 := 5
const DIRECTION_COUNT_05405 := 8
const WALK_FPS_05405 := 9.0

var animation_clock_05405 := 0.0
var action_clock_05405 := 0.0
var action_duration_05405 := 0.0
var action_texture_05405: Texture2D = null
var action_fps_05405 := 12.0
var action_frames_05405 := ACTION_FRAMES_05405
var visual_state_05405 := "idle"
var direction_05405 := 0

func _install_character_art_05402() -> void:
	if visual_root != null and is_instance_valid(visual_root):
		visual_root.visible = false
	character_sprite_05402 = Sprite3D.new()
	character_sprite_05402.name = "PlayerSprite05405"
	character_sprite_05402.texture = PLAYER_IDLE_05405
	character_sprite_05402.hframes = DIRECTION_COUNT_05405
	character_sprite_05402.vframes = 1
	character_sprite_05402.frame = 0
	character_sprite_05402.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	character_sprite_05402.shaded = false
	character_sprite_05402.transparent = true
	character_sprite_05402.double_sided = true
	character_sprite_05402.pixel_size = 0.0145
	character_sprite_05402.position = Vector3(0.0, 1.02, 0.0)
	character_sprite_05402.add_to_group("player_high_detail_05402")
	character_sprite_05402.add_to_group("player_sprite_pack_05405")
	add_child(character_sprite_05402)
	set_meta("player_visual_version", "0.5.40.5")
	set_meta("player_visual_source", "sprite_pack_05405")
	_refresh_character_art_05402(0.0)

func _refresh_character_art_05402(delta: float) -> void:
	if character_sprite_05402 == null or not is_instance_valid(character_sprite_05402):
		return
	var yaw := fposmod(rotation.y, TAU)
	direction_05405 = posmod(int(round(yaw / (PI * 0.25))), DIRECTION_COUNT_05405)
	character_direction_05402 = direction_05405
	animation_clock_05405 += maxf(0.0, delta)

	if action_clock_05405 > 0.0 and action_texture_05405 != null:
		action_clock_05405 = maxf(0.0, action_clock_05405 - delta)
		_apply_action_frame_05405()
		if action_clock_05405 <= 0.0:
			action_texture_05405 = null
		return

	var planar_speed := Vector2(velocity.x, velocity.z).length()
	if planar_speed > 0.15:
		visual_state_05405 = "walk"
		character_sprite_05402.texture = PLAYER_WALK_05405
		character_sprite_05402.hframes = WALK_FRAMES_05405
		character_sprite_05402.vframes = DIRECTION_COUNT_05405
		var walk_frame := int(floor(animation_clock_05405 * WALK_FPS_05405)) % WALK_FRAMES_05405
		character_sprite_05402.frame = direction_05405 * WALK_FRAMES_05405 + walk_frame
	else:
		visual_state_05405 = "idle"
		character_sprite_05402.texture = PLAYER_IDLE_05405
		character_sprite_05402.hframes = DIRECTION_COUNT_05405
		character_sprite_05402.vframes = 1
		character_sprite_05402.frame = direction_05405

	character_sprite_05402.position.y = 1.02
	character_sprite_05402.scale = Vector3.ONE
	set_meta("player_direction_05402", direction_05405)
	set_meta("player_visual_state_05405", visual_state_05405)

func _apply_action_frame_05405() -> void:
	if action_texture_05405 == null:
		return
	visual_state_05405 = "action"
	character_sprite_05402.texture = action_texture_05405
	character_sprite_05402.hframes = action_frames_05405
	character_sprite_05402.vframes = DIRECTION_COUNT_05405
	var elapsed := maxf(0.0, action_duration_05405 - action_clock_05405)
	var action_frame := mini(action_frames_05405 - 1, int(floor(elapsed * action_fps_05405)))
	character_sprite_05402.frame = direction_05405 * action_frames_05405 + action_frame
	set_meta("player_visual_state_05405", visual_state_05405)

func play_action_sprite_05405(texture: Texture2D, frames: int = ACTION_FRAMES_05405, fps: float = 12.0, duration: float = 0.42) -> void:
	action_texture_05405 = texture
	action_frames_05405 = maxi(1, frames)
	action_fps_05405 = maxf(1.0, fps)
	action_duration_05405 = maxf(0.08, duration)
	action_clock_05405 = action_duration_05405
	_apply_action_frame_05405()

func play_melee_1h_05405() -> void:
	play_action_sprite_05405(PLAYER_MELEE_1H_05405, ACTION_FRAMES_05405, 12.0, 0.42)

func play_melee_2h_05405() -> void:
	play_action_sprite_05405(PLAYER_MELEE_2H_05405, ACTION_FRAMES_05405, 11.0, 0.46)

func play_firearm_1h_05405() -> void:
	play_action_sprite_05405(PLAYER_FIREARM_1H_05405, ACTION_FRAMES_05405, 10.0, 0.50)

func play_firearm_2h_05405() -> void:
	play_action_sprite_05405(PLAYER_FIREARM_2H_05405, ACTION_FRAMES_05405, 10.0, 0.50)

func play_bow_05405() -> void:
	play_action_sprite_05405(PLAYER_BOW_05405, ACTION_FRAMES_05405, 9.0, 0.56)

func play_harvest_05405() -> void:
	play_action_sprite_05405(PLAYER_HARVEST_05405, ACTION_FRAMES_05405, 8.0, 0.62)

func _damage_nearest(max_range: float, damage: float) -> void:
	play_melee_1h_05405()
	super._damage_nearest(max_range, damage)

func get_player_visual_debug_05402() -> Dictionary:
	return get_player_visual_debug_05405()

func get_player_visual_debug_05405() -> Dictionary:
	return {
		"version": "0.5.40.5",
		"sprite": character_sprite_05402 != null and is_instance_valid(character_sprite_05402),
		"directions": DIRECTION_COUNT_05405,
		"direction": direction_05405,
		"state": visual_state_05405,
		"source": "assets/characters/player/sprite_pack_05405",
		"walk_frames": WALK_FRAMES_05405,
		"action_frames": ACTION_FRAMES_05405,
		"procedural_body_hidden": visual_root != null and not visual_root.visible,
		"high_detail": true
	}
