extends "res://scripts/entities/zombie_3d_v0537.gd"

const ZOMBIE_ATLAS_05402: Texture2D = preload("res://assets/visual_rework/fdc_zombie_atlas_05402.svg")
const ZOMBIE_CELL_05402 := Vector2i(96, 128)

func _ready() -> void:
	super._ready()
	add_to_group("zombie_high_detail_05402")
	set_meta("zombie_visual_version", "0.5.40.2")

func _build_sprite_0537() -> void:
	if sprite_0537 != null and is_instance_valid(sprite_0537):
		sprite_0537.queue_free()
	sprite_0537 = Sprite3D.new()
	# Keep the historical node contract so 0.5.37 ecology/debug and all later
	# systems still recognize one visual sprite per infected.
	sprite_0537.name = "ZombieSprite0537"
	sprite_0537.texture = ZOMBIE_ATLAS_05402
	sprite_0537.region_enabled = true
	sprite_0537.region_rect = Rect2(0.0, float(profile_0537 * ZOMBIE_CELL_05402.y), float(ZOMBIE_CELL_05402.x), float(ZOMBIE_CELL_05402.y))
	sprite_0537.pixel_size = 0.0180
	sprite_0537.position = Vector3(0.0, 1.14, 0.0)
	sprite_0537.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0537.shaded = false
	sprite_0537.transparent = true
	sprite_0537.double_sided = true
	sprite_0537.add_to_group("zombie_sprite_0537")
	sprite_0537.add_to_group("zombie_sprite_05402")
	add_child(sprite_0537)

func _refresh_sprite_frame_0537() -> void:
	if sprite_0537 == null or not is_instance_valid(sprite_0537):
		return
	sprite_0537.region_rect = Rect2(
		float(animation_frame_0537 * ZOMBIE_CELL_05402.x),
		float(profile_0537 * ZOMBIE_CELL_05402.y),
		float(ZOMBIE_CELL_05402.x),
		float(ZOMBIE_CELL_05402.y)
	)

func get_asset_rework_debug_05402() -> Dictionary:
	return {
		"version": "0.5.40.2",
		"atlas": "fdc_zombie_atlas_05402.svg",
		"tile_width": ZOMBIE_CELL_05402.x,
		"tile_height": ZOMBIE_CELL_05402.y,
		"profiles": ZOMBIE_PROFILE_COUNT_0537,
		"animation_frames": ZOMBIE_FRAME_COUNT_0537,
		"sprite": sprite_0537 != null and is_instance_valid(sprite_0537),
		"high_detail": true
	}
