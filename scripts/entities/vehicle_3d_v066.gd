extends "res://scripts/entities/vehicle_3d_v05401.gd"

const VEHICLE_ATLAS_066: Texture2D = preload("res://assets/vehicles/fdc_vehicle_atlas_066.png")
const VEHICLE_TILE_066 := Vector2i(128, 128)
const SAFE_VARIANTS_066 := [0,1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39]

func configure_parked_0530(world: Node, uid: String, atlas_index: int, yaw: float, seed: int) -> void:
	var migrated := _safe_variant_066(atlas_index, uid)
	super.configure_parked_0530(world, uid, migrated, yaw, seed)
	set_meta("vehicle_original_variant_066", atlas_index)
	set_meta("vehicle_ruin_removed_066", atlas_index == 8)

func configure_from_record_0530(world: Node, uid: String, record: Dictionary) -> void:
	var migrated := record.duplicate(true)
	var old_variant := int(migrated.get("variant", 0))
	var new_variant := _safe_variant_066(old_variant, uid)
	migrated["variant"] = new_variant
	if old_variant == 8:
		var max_health := _health_capacity_for_variant_0530(new_variant)
		var max_fuel := _fuel_capacity_for_variant_0530(new_variant)
		migrated["max_health"] = max_health
		migrated["health"] = maxf(float(migrated.get("health", 0.0)), max_health * 0.72)
		migrated["max_fuel"] = max_fuel
		migrated["fuel"] = maxf(float(migrated.get("fuel", 0.0)), minf(12.0, max_fuel))
	super.configure_from_record_0530(world, uid, migrated)
	set_meta("vehicle_original_variant_066", old_variant)
	set_meta("vehicle_ruin_removed_066", old_variant == 8)

func _safe_variant_066(index: int, key: String) -> int:
	if index != 8:
		return clampi(index, 0, VEHICLE_VARIANT_COUNT_05362 - 1)
	var marker := int(abs(hash("vehicle066:%s" % key)))
	return int(SAFE_VARIANTS_066[marker % SAFE_VARIANTS_066.size()])

func _build_vehicle_0530() -> void:
	super._build_vehicle_0530()
	if sprite_0530 == null:
		return
	sprite_0530.texture = VEHICLE_ATLAS_066
	sprite_0530.region_enabled = true
	sprite_0530.pixel_size = _pixel_size_066(atlas_index_0530)
	sprite_0530.position = Vector3(0.0, _sprite_height_066(atlas_index_0530), 0.0)
	sprite_0530.flip_h = false
	sprite_0530.add_to_group("vehicle_art_066")
	sprite_0530.add_to_group("vehicle_no_ruin_066")
	set_meta("vehicle_visual_version", "0.6.6")
	set_meta("vehicle_atlas_066", "fdc_vehicle_atlas_066.png")
	_refresh_sprite_orientation_0530()

func _refresh_sprite_orientation_0530() -> void:
	if sprite_0530 == null:
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

func _pixel_size_066(index: int) -> float:
	var category := _vehicle_category_05362(index)
	if category in ["motorcycle", "scooter", "bicycle"]:
		return 0.030
	if category in ["bus", "semi_truck", "harvester"]:
		return 0.052
	if category in ["box_truck", "stake_truck", "tanker", "minibus"]:
		return 0.047
	return 0.041

func _sprite_height_066(index: int) -> float:
	var category := _vehicle_category_05362(index)
	if category in ["bus", "semi_truck", "harvester"]:
		return 1.70
	if category in ["box_truck", "stake_truck", "tanker", "minibus"]:
		return 1.55
	if category in ["motorcycle", "scooter", "bicycle"]:
		return 0.82
	return 1.28

func get_vehicle_visual_debug_066() -> Dictionary:
	return {
		"version": "0.6.6",
		"atlas": "fdc_vehicle_atlas_066.png",
		"tile": VEHICLE_TILE_066,
		"variant": atlas_index_0530,
		"original_variant": int(get_meta("vehicle_original_variant_066", atlas_index_0530)),
		"ruin_removed": bool(get_meta("vehicle_ruin_removed_066", false)),
		"sprite": sprite_0530 != null and sprite_0530.texture == VEHICLE_ATLAS_066
	}
