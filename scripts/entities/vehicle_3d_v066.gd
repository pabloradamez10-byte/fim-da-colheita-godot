extends "res://scripts/entities/vehicle_3d_v05362.gd"

const VEHICLE_ATLAS_066: Texture2D = preload("res://assets/visual_rework_066/fdc_vehicle_atlas_066.png")
const VEHICLE_TILE_066 := Vector2i(128, 96)
const VEHICLE_PIXEL_SCALE_066 := 64.0 / 128.0

func _build_vehicle_0530() -> void:
	super._build_vehicle_0530()
	if sprite_0530 == null:
		return
	sprite_0530.texture = VEHICLE_ATLAS_066
	sprite_0530.region_enabled = true
	sprite_0530.pixel_size = _vehicle_pixel_size_05362(atlas_index_0530) * VEHICLE_PIXEL_SCALE_066
	sprite_0530.position = Vector3(0.0, _vehicle_sprite_height_05362(atlas_index_0530) - 0.08, 0.0)
	sprite_0530.add_to_group("vehicle_art_066")
	sprite_0530.add_to_group("vehicle_high_detail_066")
	set_meta("vehicle_visual_version", "0.6.6")
	_refresh_sprite_orientation_0530()

func _refresh_sprite_orientation_0530() -> void:
	if sprite_0530 == null:
		return
	if sprite_0530.texture != VEHICLE_ATLAS_066:
		super._refresh_sprite_orientation_0530()
		return
	var direction := _direction_index_05362(rotation.y)
	var row := clampi(atlas_index_0530, 0, VEHICLE_VARIANT_COUNT_05362 - 1)
	sprite_0530.region_rect = Rect2(
		float(direction * VEHICLE_TILE_066.x),
		float(row * VEHICLE_TILE_066.y),
		float(VEHICLE_TILE_066.x),
		float(VEHICLE_TILE_066.y)
	)
	sprite_0530.flip_h = false
	set_meta("vehicle_direction_05362", direction)
	set_meta("vehicle_art_row_05362", row)
	set_meta("vehicle_art_tile_066", VEHICLE_TILE_066)

func get_visual_rework_debug_066() -> Dictionary:
	return {
		"version": "0.6.6",
		"tile": VEHICLE_TILE_066,
		"directions": VEHICLE_DIRECTION_COUNT_05362,
		"variants": VEHICLE_VARIANT_COUNT_05362,
		"sprite": sprite_0530 != null and is_instance_valid(sprite_0530)
	}
