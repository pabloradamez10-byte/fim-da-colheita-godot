extends "res://scripts/entities/zombie_3d_v0537.gd"

const ZOMBIE_ATLAS_066: Texture2D = preload("res://assets/visual_rework_066/fdc_zombie_atlas_066.png")
const ZOMBIE_CELL_066 := Vector2i(128, 160)
const ZOMBIE_DIRECTIONS_066 := 8
const ZOMBIE_FRAMES_066 := 4

var zombie_direction_066 := 0

func _ready() -> void:
	super._ready()
	add_to_group("zombie_visual_066")
	set_meta("zombie_visual_version", "0.6.6")
	_refresh_sprite_frame_0537()

func _build_sprite_0537() -> void:
	if sprite_0537 != null and is_instance_valid(sprite_0537):
		sprite_0537.queue_free()
	sprite_0537 = Sprite3D.new()
	sprite_0537.name = "ZombieSprite066"
	sprite_0537.texture = ZOMBIE_ATLAS_066
	sprite_0537.region_enabled = true
	sprite_0537.pixel_size = 0.0142
	sprite_0537.position = Vector3(0.0, 1.12, 0.0)
	sprite_0537.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0537.shaded = false
	sprite_0537.transparent = true
	sprite_0537.double_sided = true
	sprite_0537.add_to_group("zombie_sprite_0537")
	sprite_0537.add_to_group("zombie_sprite_066")
	add_child(sprite_0537)

func _update_sprite_animation_0537(delta: float) -> void:
	if sprite_0537 == null or not is_instance_valid(sprite_0537):
		return
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	var interval := 0.36
	if planar_speed > 0.35:
		interval = 0.105 if alert_state_0519 == "chase" else 0.155
	var yaw := fposmod(rotation.y, TAU)
	zombie_direction_066 = posmod(int(round(yaw / (PI * 0.25))), ZOMBIE_DIRECTIONS_066)
	animation_clock_0537 += delta
	if animation_clock_0537 >= interval:
		animation_clock_0537 = 0.0
		if planar_speed <= 0.35:
			animation_frame_0537 = 0
		else:
			animation_frame_0537 = (animation_frame_0537 + 1) % ZOMBIE_FRAMES_066
	_refresh_sprite_frame_0537()

func _refresh_sprite_frame_0537() -> void:
	if sprite_0537 == null or not is_instance_valid(sprite_0537):
		return
	var row := profile_0537 * ZOMBIE_DIRECTIONS_066 + zombie_direction_066
	sprite_0537.region_rect = Rect2(
		float(animation_frame_0537 * ZOMBIE_CELL_066.x),
		float(row * ZOMBIE_CELL_066.y),
		float(ZOMBIE_CELL_066.x),
		float(ZOMBIE_CELL_066.y)
	)
	set_meta("zombie_direction_066", zombie_direction_066)

func get_visual_rework_debug_066() -> Dictionary:
	return {
		"version": "0.6.6",
		"directions": ZOMBIE_DIRECTIONS_066,
		"frames": ZOMBIE_FRAMES_066,
		"profiles": ZOMBIE_PROFILE_COUNT_0537,
		"direction": zombie_direction_066,
		"sprite": sprite_0537 != null and is_instance_valid(sprite_0537)
	}
