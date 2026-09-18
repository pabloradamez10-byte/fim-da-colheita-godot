extends "res://scripts/player/player_3d_v065.gd"

const HOTFIX_VERSION_066 := "0.6.6-alpha"
const SPRITE_CENTER_Y_066 := 0.76

var ground_shadow_066: MeshInstance3D = null

func _ready() -> void:
	super._ready()
	floor_snap_length = 0.62
	floor_stop_on_slope = true
	_build_ground_shadow_066()
	add_to_group("player_hotfix_066")
	set_meta("player_hotfix_version", HOTFIX_VERSION_066)

func _build_ground_shadow_066() -> void:
	if ground_shadow_066 != null:
		return
	ground_shadow_066 = MeshInstance3D.new()
	ground_shadow_066.name = "GroundShadow066"
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.82, 0.44)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.02, 0.02, 0.02, 0.24)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	ground_shadow_066.mesh = mesh
	ground_shadow_066.rotation_degrees.x = -90.0
	ground_shadow_066.position = Vector3(0.0, 0.025, 0.0)
	ground_shadow_066.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground_shadow_066)

func _refresh_character_art_05402(delta: float) -> void:
	super._refresh_character_art_05402(delta)
	if character_sprite_05402 == null or not is_instance_valid(character_sprite_05402):
		return
	character_sprite_05402.position.y = SPRITE_CENTER_Y_066
	character_sprite_05402.pixel_size = 0.052
	character_sprite_05402.scale = Vector3.ONE
	if movement_state_064 in ["walk", "run"] and action_clock_05405 <= 0.0:
		var fps := RUN_FPS_064 if movement_state_064 == "run" else WALK_FPS_064
		var sway := sin(movement_clock_064 * fps * 0.52)
		character_sprite_05402.position.x = sway * (0.018 if movement_state_064 == "run" else 0.012)
		character_sprite_05402.rotation.z = sway * (0.018 if movement_state_064 == "run" else 0.012)
	else:
		character_sprite_05402.position.x = lerpf(character_sprite_05402.position.x, 0.0, minf(1.0, delta * 12.0))
		character_sprite_05402.rotation.z = lerpf(character_sprite_05402.rotation.z, 0.0, minf(1.0, delta * 12.0))
	set_meta("player_grounded_visual_066", true)

func _apply_action_frame_05405() -> void:
	super._apply_action_frame_05405()
	if character_sprite_05402 != null and is_instance_valid(character_sprite_05402):
		character_sprite_05402.position.y = SPRITE_CENTER_Y_066
		character_sprite_05402.position.x = 0.0
		character_sprite_05402.rotation.z = 0.0

func get_player_hotfix_debug_066() -> Dictionary:
	return {
		"version": HOTFIX_VERSION_066,
		"floor_snap": floor_snap_length,
		"shadow": ground_shadow_066 != null and is_instance_valid(ground_shadow_066),
		"visual_y": character_sprite_05402.position.y if character_sprite_05402 != null else -1.0,
		"movement_state": movement_state_064,
		"spatial_combat": get_spatial_combat_debug_065()
	}
