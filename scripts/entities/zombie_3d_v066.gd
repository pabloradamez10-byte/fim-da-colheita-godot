extends "res://scripts/entities/zombie_3d_v05402.gd"

const ZOMBIE_ATLAS_066: Texture2D = preload("res://assets/zombies/fdc_zombie_atlas_066.png")
const ZOMBIE_CELL_066 := Vector2i(128, 160)

func _ready() -> void:
	super._ready()
	add_to_group("zombie_visual_066")
	set_meta("zombie_visual_version", "0.6.6")
	set_meta("zombie_visual_source", "fdc_zombie_atlas_066.png")

func _build_sprite_0537() -> void:
	if sprite_0537 != null and is_instance_valid(sprite_0537):
		sprite_0537.queue_free()
	sprite_0537 = Sprite3D.new()
	sprite_0537.name = "ZombieSprite066"
	sprite_0537.texture = ZOMBIE_ATLAS_066
	sprite_0537.region_enabled = true
	sprite_0537.region_rect = Rect2(
		0.0,
		float(profile_0537 * ZOMBIE_CELL_066.y),
		float(ZOMBIE_CELL_066.x),
		float(ZOMBIE_CELL_066.y)
	)
	sprite_0537.pixel_size = 0.0120
	sprite_0537.position = Vector3(0.0, 0.96, 0.0)
	sprite_0537.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0537.shaded = false
	sprite_0537.transparent = true
	sprite_0537.double_sided = true
	sprite_0537.add_to_group("zombie_sprite_0537")
	sprite_0537.add_to_group("zombie_sprite_066")
	add_child(sprite_0537)

func _refresh_sprite_frame_0537() -> void:
	if sprite_0537 == null or not is_instance_valid(sprite_0537):
		return
	sprite_0537.region_rect = Rect2(
		float(animation_frame_0537 * ZOMBIE_CELL_066.x),
		float(profile_0537 * ZOMBIE_CELL_066.y),
		float(ZOMBIE_CELL_066.x),
		float(ZOMBIE_CELL_066.y)
	)

func get_zombie_visual_debug_066() -> Dictionary:
	return {
		"version": "0.6.6",
		"atlas": "fdc_zombie_atlas_066.png",
		"tile": ZOMBIE_CELL_066,
		"profiles": ZOMBIE_PROFILE_COUNT_0537,
		"frames": ZOMBIE_FRAME_COUNT_0537,
		"sprite": sprite_0537 != null and sprite_0537.texture == ZOMBIE_ATLAS_066
	}
