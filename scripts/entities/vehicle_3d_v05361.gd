extends "res://scripts/entities/vehicle_3d_v0530.gd"

const VEHICLE_CITY_A_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_city_a.png")
const VEHICLE_CITY_B_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_city_b.png")
const VEHICLE_SERVICE_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_service.png")
const VEHICLE_RURAL_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_rural.png")
const VEHICLE_DIRECTION_COUNT_05361 := 8
const VEHICLE_VARIANT_COUNT_05361 := 24

const VEHICLE_NAMES_05361 := [
	"Hatch compacto", "Sedã popular", "Perua familiar", "Picape média", "Furgão de carga", "Caminhão baú",
	"SUV utilitário", "Trator agrícola", "Carcaça abandonada", "SUV compacto vermelho", "SUV grande vermelho",
	"Picape cabine simples", "SUV de expedição", "Perua de expedição", "Caminhão carroceria de madeira", "Furgão urbano",
	"Micro-ônibus", "Viatura policial", "Ambulância", "Caminhão de carga", "Caminhão rural", "Caminhão-tanque",
	"Colheitadeira", "Moto trail"
]

func configure_parked_0530(world: Node, uid: String, atlas_index: int, yaw: float, seed: int) -> void:
	world_0530 = world
	vehicle_uid_0530 = uid
	atlas_index_0530 = clampi(atlas_index, 0, VEHICLE_VARIANT_COUNT_05361 - 1)
	world_seed_0530 = seed
	rotation.y = yaw
	ground_y_0530 = 0.28
	var marker := int(abs(hash("vehicle05361:%d:%s:%d" % [seed, uid, atlas_index_0530])))
	max_fuel_0530 = _fuel_capacity_for_variant_0530(atlas_index_0530)
	max_health_0530 = _health_capacity_for_variant_0530(atlas_index_0530)
	trunk_capacity_0530 = _trunk_capacity_for_variant_0530(atlas_index_0530)
	if atlas_index_0530 == 8:
		fuel_0530 = 0.0
		health_0530 = 0.0
	else:
		fuel_0530 = minf(max_fuel_0530, 5.0 + float(marker % 17))
		health_0530 = clampf(58.0 + float(marker % 41), 58.0, max_health_0530)
	trunk_0530 = _initial_trunk_0530(marker)
	_build_vehicle_0530()

func configure_from_record_0530(world: Node, uid: String, record: Dictionary) -> void:
	world_0530 = world
	vehicle_uid_0530 = uid
	atlas_index_0530 = clampi(int(record.get("variant", 0)), 0, VEHICLE_VARIANT_COUNT_05361 - 1)
	world_seed_0530 = int(record.get("seed", 0))
	max_fuel_0530 = float(record.get("max_fuel", _fuel_capacity_for_variant_0530(atlas_index_0530)))
	max_health_0530 = float(record.get("max_health", _health_capacity_for_variant_0530(atlas_index_0530)))
	trunk_capacity_0530 = int(record.get("trunk_capacity", _trunk_capacity_for_variant_0530(atlas_index_0530)))
	fuel_0530 = clampf(float(record.get("fuel", 0.0)), 0.0, max_fuel_0530)
	health_0530 = clampf(float(record.get("health", max_health_0530)), 0.0, max_health_0530)
	var raw_trunk: Variant = record.get("trunk", {})
	trunk_0530 = (raw_trunk as Dictionary).duplicate(true) if raw_trunk is Dictionary else {}
	rotation.y = float(record.get("yaw", 0.0))
	activated_0530 = true
	_build_vehicle_0530()

func _build_vehicle_0530() -> void:
	name = "Vehicle05361_%s" % vehicle_uid_0530.replace(":", "_")
	add_to_group("vehicle")
	add_to_group("vehicle_0530")
	add_to_group("vehicle_sprite_root_0517")
	add_to_group("vehicle_art_05361")
	set_meta("vehicle_key_0530", vehicle_uid_0530)
	set_meta("vehicle_variant_0530", atlas_index_0530)
	set_meta("vehicle_name_05361", _vehicle_name_0530())

	sprite_0530 = Sprite3D.new()
	sprite_0530.name = "VehicleSprite0517"
	sprite_0530.texture = _vehicle_texture_05361(atlas_index_0530)
	sprite_0530.region_enabled = true
	sprite_0530.pixel_size = _vehicle_pixel_size_05361(atlas_index_0530)
	sprite_0530.position = Vector3(0.0, _vehicle_sprite_height_05361(atlas_index_0530), 0.0)
	sprite_0530.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0530.shaded = false
	sprite_0530.transparent = true
	sprite_0530.double_sided = true
	sprite_0530.add_to_group("vehicle_sprite_0517")
	sprite_0530.add_to_group("vehicle_orientation_0518")
	sprite_0530.add_to_group("vehicle_sprite_8dir_05361")
	add_child(sprite_0530)
	_refresh_sprite_orientation_0530()

	var collision_size := _collision_size_0530(atlas_index_0530)
	drive_shape_0530 = CollisionShape3D.new()
	drive_shape_0530.name = "VehicleDriveShape0530"
	var box := BoxShape3D.new()
	box.size = collision_size
	drive_shape_0530.shape = box
	drive_shape_0530.position = Vector3(0.0, collision_size.y * 0.5, 0.0)
	add_child(drive_shape_0530)

	var legacy := StaticBody3D.new()
	legacy.name = "VehicleCollider0517"
	legacy.collision_layer = 0
	legacy.collision_mask = 0
	legacy.add_to_group("vehicle_collider_0517")
	add_child(legacy)
	var legacy_shape := CollisionShape3D.new()
	legacy_shape.disabled = true
	var legacy_box := BoxShape3D.new()
	legacy_box.size = collision_size
	legacy_shape.shape = legacy_box
	legacy_shape.position = Vector3(0.0, collision_size.y * 0.5, 0.0)
	legacy.add_child(legacy_shape)

func _vehicle_texture_05361(index: int) -> Texture2D:
	if index <= 5 or index in [8, 9, 10]:
		return VEHICLE_CITY_A_05361
	if index in [6, 11, 12, 13, 14, 15]:
		return VEHICLE_CITY_B_05361
	if index in [16, 17, 18, 19, 5]:
		return VEHICLE_SERVICE_05361
	return VEHICLE_RURAL_05361

func _vehicle_sheet_rows_05361(index: int) -> int:
	return 7 if index in [7, 20, 21, 22, 23] else 6

func _vehicle_art_row_05361(index: int) -> int:
	match index:
		0: return 3
		1: return 2
		2: return 4
		3: return 0
		4: return 0
		5: return 4
		6: return 2
		7: return 2
		8: return 3
		9: return 1
		10: return 5
		11: return 1
		12: return 2
		13: return 3
		14: return 4
		15: return 5
		16: return 1
		17: return 2
		18: return 3
		19: return 5
		20: return 0
		21: return 1
		22: return 3
		23: return 4
	return 0

func _direction_index_05361(yaw: float) -> int:
	return posmod(int(round(fposmod(yaw, TAU) / (PI * 0.25))), VEHICLE_DIRECTION_COUNT_05361)

func _refresh_sprite_orientation_0530() -> void:
	if sprite_0530 == null:
		return
	var texture := _vehicle_texture_05361(atlas_index_0530)
	var rows := _vehicle_sheet_rows_05361(atlas_index_0530)
	var row := clampi(_vehicle_art_row_05361(atlas_index_0530), 0, rows - 1)
	var direction := _direction_index_05361(rotation.y)
	var cell_w := float(texture.get_width()) / float(VEHICLE_DIRECTION_COUNT_05361)
	var cell_h := float(texture.get_height()) / float(rows)
	sprite_0530.texture = texture
	sprite_0530.region_rect = Rect2(cell_w * float(direction), cell_h * float(row), cell_w, cell_h)
	# Mantém a correção 0.5.18 para compatibilidade; a arte nova ainda possui as 8 vistas reais.
	sprite_0530.flip_h = absf(sin(rotation.y)) <= 0.55
	set_meta("vehicle_direction_05361", direction)
	set_meta("vehicle_art_row_05361", row)

func _vehicle_pixel_size_05361(index: int) -> float:
	if index in [5, 14, 19, 20, 21, 22]:
		return 0.065
	if index in [7, 23]:
		return 0.060
	return 0.055

func _vehicle_sprite_height_05361(index: int) -> float:
	if index in [5, 14, 19, 20, 21, 22]:
		return 1.70
	if index == 7:
		return 1.58
	return 1.42

func _vehicle_name_0530() -> String:
	if atlas_index_0530 >= 0 and atlas_index_0530 < VEHICLE_NAMES_05361.size():
		return str(VEHICLE_NAMES_05361[atlas_index_0530])
	return "Veículo"

func _max_speed_0530() -> float:
	match atlas_index_0530:
		5: return 8.6
		7: return 7.2
		14, 19, 20, 21: return 8.2
		16: return 9.4
		17: return 13.0
		18: return 10.4
		22: return 6.2
		23: return 12.8
		3, 11: return 12.4
		6, 9, 10, 12, 13: return 11.7
		_: return 12.0

func _fuel_capacity_for_variant_0530(index: int) -> float:
	match index:
		5, 19: return 82.0
		7, 22: return 70.0
		14, 20: return 78.0
		21: return 110.0
		16, 18: return 68.0
		17: return 60.0
		23: return 18.0
		3, 11: return 55.0
		4, 15: return 62.0
		6, 9, 10, 12, 13: return 58.0
		8: return 0.0
		_: return 46.0

func _health_capacity_for_variant_0530(index: int) -> float:
	match index:
		5, 19: return 145.0
		7: return 130.0
		14, 20: return 138.0
		21: return 150.0
		22: return 155.0
		16, 18: return 124.0
		17: return 120.0
		23: return 72.0
		3, 11: return 112.0
		4, 15: return 118.0
		6, 9, 10, 12, 13: return 122.0
		8: return 1.0
		_: return 100.0

func _trunk_capacity_for_variant_0530(index: int) -> int:
	match index:
		2, 13: return 42
		3, 11: return 52
		4, 15: return 64
		5, 19: return 88
		6, 9, 10, 12: return 48
		7: return 26
		14, 20: return 84
		16: return 70
		17: return 46
		18: return 76
		21: return 72
		22: return 40
		23: return 8
		8: return 18
		_: return 34

func _collision_size_0530(index: int) -> Vector3:
	match index:
		3, 11: return Vector3(2.0, 1.45, 4.35)
		4, 15, 18: return Vector3(2.05, 1.72, 4.35)
		5, 19: return Vector3(2.35, 2.25, 5.15)
		6, 9, 10, 12, 13: return Vector3(2.0, 1.62, 4.15)
		7: return Vector3(2.15, 1.85, 3.60)
		14, 20: return Vector3(2.25, 2.05, 4.90)
		16: return Vector3(2.20, 2.15, 5.10)
		17: return Vector3(1.95, 1.50, 4.20)
		21: return Vector3(2.40, 2.35, 5.40)
		22: return Vector3(3.10, 2.75, 5.25)
		23: return Vector3(1.05, 1.35, 2.30)
		8: return Vector3(2.0, 1.30, 4.05)
		_: return Vector3(1.90, 1.48, 3.95)

func get_vehicle_art_debug_05361() -> Dictionary:
	return {
		"variant": atlas_index_0530,
		"name": _vehicle_name_0530(),
		"direction": int(get_meta("vehicle_direction_05361", -1)),
		"row": int(get_meta("vehicle_art_row_05361", -1)),
		"variant_count": VEHICLE_VARIANT_COUNT_05361,
		"direction_count": VEHICLE_DIRECTION_COUNT_05361,
		"texture_width": sprite_0530.texture.get_width() if sprite_0530 != null and sprite_0530.texture != null else 0,
		"texture_height": sprite_0530.texture.get_height() if sprite_0530 != null and sprite_0530.texture != null else 0
	}
