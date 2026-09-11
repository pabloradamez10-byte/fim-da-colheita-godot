extends "res://scripts/player/player_3d_v0538.gd"

const PLAYER_N_05402: Texture2D = preload("res://web/assets/characters/CHR_M_SURVIVOR_0001_N.png")
const PLAYER_E_05402: Texture2D = preload("res://web/assets/characters/CHR_M_SURVIVOR_0001_E.png")
const PLAYER_S_05402: Texture2D = preload("res://web/assets/characters/CHR_M_SURVIVOR_0001_S.png")
const PLAYER_W_05402: Texture2D = preload("res://web/assets/characters/CHR_M_SURVIVOR_0001_W.png")
const PLAYER_TEXTURES_05402 := [PLAYER_N_05402, PLAYER_E_05402, PLAYER_S_05402, PLAYER_W_05402]

var character_sprite_05402: Sprite3D = null
var character_bob_05402 := 0.0
var character_direction_05402 := 2

func _ready() -> void:
	super._ready()
	_install_character_art_05402()

func _install_character_art_05402() -> void:
	if visual_root != null and is_instance_valid(visual_root):
		visual_root.visible = false
	character_sprite_05402 = Sprite3D.new()
	character_sprite_05402.name = "PlayerSprite05402"
	character_sprite_05402.texture = PLAYER_S_05402
	character_sprite_05402.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	character_sprite_05402.shaded = false
	character_sprite_05402.transparent = true
	character_sprite_05402.double_sided = true
	character_sprite_05402.pixel_size = 0.0062
	character_sprite_05402.position = Vector3(0.0, 1.22, 0.0)
	character_sprite_05402.add_to_group("player_high_detail_05402")
	add_child(character_sprite_05402)
	set_meta("player_visual_version", "0.5.40.2")
	set_meta("player_visual_source", "CHR_M_SURVIVOR_0001")
	_refresh_character_art_05402(0.0)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_refresh_character_art_05402(delta)

func _refresh_character_art_05402(delta: float) -> void:
	if character_sprite_05402 == null or not is_instance_valid(character_sprite_05402):
		return
	var yaw := fposmod(rotation.y, TAU)
	var quadrant := posmod(int(round(yaw / (PI * 0.5))), 4)
	# Base player yaw: 0=N, PI/2=E, PI=S, 3PI/2=W.
	var texture_index := quadrant
	if texture_index != character_direction_05402:
		character_direction_05402 = texture_index
		character_sprite_05402.texture = PLAYER_TEXTURES_05402[character_direction_05402]
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	if planar_speed > 0.15:
		character_bob_05402 += delta * (8.8 if planar_speed < 6.0 else 12.0)
		character_sprite_05402.position.y = 1.22 + sin(character_bob_05402) * 0.035
		character_sprite_05402.scale = Vector3(1.0 + abs(sin(character_bob_05402)) * 0.012, 1.0 - abs(sin(character_bob_05402)) * 0.010, 1.0)
	else:
		character_sprite_05402.position.y = lerpf(character_sprite_05402.position.y, 1.22, minf(1.0, delta * 8.0))
		character_sprite_05402.scale = character_sprite_05402.scale.lerp(Vector3.ONE, minf(1.0, delta * 8.0))
	set_meta("player_direction_05402", character_direction_05402)

func get_player_visual_debug_05402() -> Dictionary:
	return {
		"version": "0.5.40.2",
		"sprite": character_sprite_05402 != null and is_instance_valid(character_sprite_05402),
		"directions": 4,
		"direction": character_direction_05402,
		"source": "web/assets/characters/CHR_M_SURVIVOR_0001_*",
		"procedural_body_hidden": visual_root != null and not visual_root.visible,
		"high_detail": true
	}
