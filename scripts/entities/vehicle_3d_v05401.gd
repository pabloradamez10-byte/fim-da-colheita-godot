extends "res://scripts/entities/vehicle_3d_v05362.gd"

const VEHICLE_ATLAS_05401: Texture2D = preload("res://assets/visual_rework/fdc_vehicle_atlas_05401.svg")
const VEHICLE_TILE_05401 := Vector2i(96, 72)
const VEHICLE_PIXEL_SCALE_05401 := 64.0 / 96.0

func _build_vehicle_0530() -> void:
	super._build_vehicle_0530()
	if sprite_0530 == null:
		return
	sprite_0530.texture = VEHICLE_ATLAS_05401
	sprite_0530.region_enabled = true
	sprite_0530.pixel_size = _vehicle_pixel_size_05362(atlas_index_0530) * VEHICLE_PIXEL_SCALE_05401
	sprite_0530.position = Vector3(0.0, _vehicle_sprite_height_05362(atlas_index_0530), 0.0)
	sprite_0530.add_to_group("vehicle_art_05401")
	sprite_0530.add_to_group("vehicle_high_detail_05401")
	set_meta("vehicle_visual_version", "0.5.40.1")
	_refresh_sprite_orientation_0530()

func _refresh_sprite_orientation_0530() -> void:
	if sprite_0530 == null:
		return
	var direction := _direction_index_05362(rotation.y)
	var row := clampi(atlas_index_0530, 0, VEHICLE_VARIANT_COUNT_05362 - 1)
	sprite_0530.region_rect = Rect2(float(direction * VEHICLE_TILE_05401.x), float(row * VEHICLE_TILE_05401.y), float(VEHICLE_TILE_05401.x), float(VEHICLE_TILE_05401.y))
	sprite_0530.flip_h = absf(sin(rotation.y)) <= 0.55
	set_meta("vehicle_direction_05362", direction)
	set_meta("vehicle_art_row_05362", row)
	set_meta("vehicle_art_tile_05401", VEHICLE_TILE_05401)

func get_visual_rework_debug_05401() -> Dictionary:
	return {"atlas":"fdc_vehicle_atlas_05401.svg","tile_width":VEHICLE_TILE_05401.x,"tile_height":VEHICLE_TILE_05401.y,"directions":VEHICLE_DIRECTION_COUNT_05362,"variants":VEHICLE_VARIANT_COUNT_05362,"high_detail":true}
