extends "res://scripts/entities/vehicle_3d_v0530.gd"

const VEHICLE_CITY_A_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_city_a.png")
const VEHICLE_CITY_B_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_city_b.png")
const VEHICLE_SERVICE_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_service.png")
const VEHICLE_RURAL_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_8dir_rural.png")
const VEHICLE_LEGACY_05361: Texture2D = preload("res://assets/vehicles/fdc_vehicle_atlas_0517.png")

const VEHICLE_DIRECTION_COUNT_05361 := 8
const VEHICLE_VARIANT_COUNT_05361 := 27
const VEHICLE_DIRECTION_OFFSET_05361 := 5
const DECORATIVE_VARIANTS_05361 := [8, 21]

const VEHICLE_NAMES_05361 := [
	"Compacto claro",
	"Sedã verde",
	"Perua utilitária",
	"Picape branca",
	"Furgão urbano",
	"Caminhão baú",
	"SUV vermelho",
	"Trator agrícola",
	"Carcaça queimada",
	"Utilitário branco",
	"Utilitário vermelho",
	"Micro-ônibus",
	"Viatura policial",
	"Ambulância",
	"Caminhão carroceria",
	"Caminhão rural",
	"Caminhão-tanque",
	"Colheitadeira",
	"Moto trail vermelha",
	"Moto trail verde",
	"Scooter",
	"Bicicleta",
	"Picape vermelha",
	"SUV expedição verde",
	"SUV expedição clara",
	"Caminhão pequeno azul",
	"Furgão de carga claro"
]

const VEHICLE_ART_05361 := [
	["city_a", 3],
	["city_a", 2],
	["city_a", 4],
	["service", 0],
	["city_b", 0],
	["city_b", 4],
	["city_a", 5],
	["rural", 2],
	["legacy", 8],
	["city_a", 0],
	["city_a", 1],
	["city_b", 1],
	["city_b", 2],
	["city_b", 3],
	["city_b", 5],
	["rural", 0],
	["rural", 1],
	["rural", 3],
	["rural", 4],
	["rural", 5],
	["rural", 6],
	["rural", 7],
	["service", 1],
	["service", 2],
	["service", 3],
	["service", 4],
	["service", 5]
]

const VEHICLE_CATEGORIES_05361 := [
	"car",
	"car",
	"wagon",
	"pickup",
	"van",
	"box_truck",
	"suv",
	"tractor",
	"wreck",
	"suv",
	"suv",
	"minibus",
	"police",
	"ambulance",
	"stake_truck",
	"stake_truck",
	"tanker",
	"harvester",
	"motorcycle",
	"motorcycle",
	"scooter",
	"bicycle",
	"pickup",
	"suv",
	"suv",
	"stake_truck",
	"van"
]

const SHEET_RECTS_05361 := {
	"city_a": [
		[[11, 15, 71, 82], [81, 16, 89, 82], [174, 19, 104, 73], [279, 18, 89, 78], [372, 16, 63, 73], [445, 17, 92, 76], [534, 23, 101, 68], [631, 17, 90, 82]],
		[[7, 102, 72, 85], [77, 106, 94, 85], [174, 111, 103, 73], [277, 108, 89, 79], [371, 109, 63, 73], [444, 109, 91, 79], [535, 112, 101, 71], [632, 109, 89, 82]],
		[[7, 198, 72, 75], [77, 201, 98, 76], [176, 202, 102, 66], [276, 201, 91, 68], [372, 204, 63, 64], [440, 201, 95, 70], [534, 208, 102, 62], [633, 199, 85, 76]],
		[[7, 280, 77, 75], [80, 285, 93, 75], [174, 287, 103, 65], [275, 286, 94, 69], [371, 288, 64, 63], [440, 286, 95, 69], [533, 290, 104, 62], [633, 283, 85, 75]],
		[[4, 363, 79, 84], [78, 366, 94, 83], [175, 368, 103, 73], [276, 366, 91, 75], [373, 367, 62, 72], [445, 368, 92, 76], [533, 375, 101, 66], [631, 366, 91, 83]],
		[[5, 450, 74, 82], [77, 457, 94, 81], [174, 457, 103, 73], [276, 455, 86, 75], [372, 456, 62, 70], [445, 457, 90, 73], [533, 461, 100, 67], [630, 455, 89, 81]]
	],
	"city_b": [
		[[12, 24, 65, 83], [80, 22, 90, 87], [172, 28, 105, 71], [278, 24, 85, 79], [376, 24, 60, 73], [447, 23, 89, 80], [533, 30, 97, 69], [628, 25, 89, 84]],
		[[8, 112, 66, 83], [77, 114, 93, 84], [172, 117, 108, 72], [278, 115, 91, 80], [378, 117, 58, 73], [445, 113, 90, 81], [530, 119, 102, 68], [631, 112, 86, 86]],
		[[9, 202, 67, 74], [78, 203, 95, 75], [172, 203, 108, 65], [279, 203, 93, 71], [377, 206, 60, 65], [442, 204, 92, 69], [532, 203, 103, 62], [627, 203, 92, 75]],
		[[10, 278, 68, 86], [78, 279, 90, 86], [174, 274, 106, 79], [277, 278, 94, 83], [379, 282, 57, 71], [444, 279, 92, 82], [531, 282, 100, 70], [631, 276, 89, 89]],
		[[10, 365, 63, 92], [74, 365, 92, 96], [176, 365, 109, 87], [284, 361, 85, 89], [382, 364, 54, 85], [448, 364, 84, 87], [531, 368, 103, 82], [632, 364, 86, 96]],
		[[9, 456, 68, 77], [72, 457, 97, 78], [171, 457, 115, 75], [284, 456, 88, 72], [378, 449, 56, 74], [442, 453, 90, 75], [529, 460, 106, 69], [627, 456, 91, 77]]
	],
	"rural": [
		[[12, 7, 60, 79], [81, 4, 87, 86], [185, 13, 96, 65], [281, 9, 83, 73], [377, 10, 55, 67], [441, 9, 87, 75], [528, 14, 103, 62], [635, 4, 84, 84]],
		[[9, 86, 55, 79], [75, 86, 94, 80], [177, 92, 101, 70], [281, 84, 85, 78], [378, 84, 54, 77], [438, 85, 88, 78], [528, 91, 103, 69], [633, 87, 89, 79]],
		[[14, 165, 62, 71], [83, 164, 87, 75], [186, 165, 87, 70], [286, 163, 74, 69], [373, 166, 63, 65], [446, 165, 73, 71], [530, 165, 89, 70], [632, 165, 85, 75]],
		[[4, 236, 67, 78], [70, 240, 103, 76], [170, 239, 103, 71], [276, 236, 89, 75], [370, 237, 68, 67], [441, 235, 88, 76], [528, 240, 114, 70], [634, 237, 84, 77]],
		[[17, 315, 40, 59], [87, 317, 71, 58], [187, 316, 82, 52], [283, 315, 68, 55], [384, 314, 42, 58], [453, 315, 66, 56], [535, 315, 86, 52], [652, 313, 53, 60]],
		[[17, 374, 36, 58], [84, 375, 80, 57], [186, 375, 84, 51], [285, 376, 67, 52], [385, 375, 38, 55], [449, 375, 69, 54], [535, 373, 85, 52], [645, 374, 69, 57]],
		[[19, 430, 34, 59], [87, 431, 66, 58], [188, 428, 79, 54], [287, 429, 64, 57], [385, 431, 39, 56], [451, 429, 63, 57], [536, 430, 78, 53], [648, 431, 63, 58]],
		[[22, 490, 33, 48], [89, 490, 64, 48], [190, 488, 80, 48], [289, 488, 60, 50], [392, 490, 25, 47], [455, 488, 60, 51], [533, 488, 83, 49], [647, 489, 64, 49]]
	],
	"service": [
		[[6, 22, 86, 79], [83, 27, 95, 75], [179, 26, 100, 67], [277, 26, 89, 72], [375, 26, 59, 70], [445, 26, 92, 72], [535, 26, 99, 64], [630, 30, 91, 73]],
		[[5, 107, 83, 85], [81, 113, 99, 81], [179, 113, 95, 76], [270, 113, 96, 76], [373, 114, 60, 73], [442, 112, 93, 77], [531, 113, 102, 70], [628, 111, 92, 83]],
		[[5, 196, 81, 88], [80, 198, 96, 88], [178, 199, 95, 78], [269, 199, 96, 78], [373, 201, 62, 75], [447, 198, 90, 80], [534, 202, 98, 72], [628, 199, 93, 87]],
		[[5, 282, 86, 87], [82, 286, 96, 86], [178, 289, 95, 75], [269, 289, 96, 75], [373, 289, 61, 72], [445, 289, 93, 78], [535, 290, 100, 68], [628, 285, 93, 86]],
		[[5, 369, 85, 86], [81, 372, 98, 86], [178, 381, 95, 69], [269, 381, 95, 69], [375, 386, 58, 62], [445, 381, 92, 69], [533, 383, 101, 63], [630, 374, 89, 84]],
		[[9, 451, 80, 83], [82, 455, 92, 81], [177, 459, 101, 71], [278, 456, 85, 74], [375, 459, 59, 70], [451, 457, 85, 73], [538, 457, 98, 68], [630, 456, 88, 81]]
	]
}

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
	if atlas_index_0530 in DECORATIVE_VARIANTS_05361:
		fuel_0530 = 0.0
		health_0530 = 0.0 if atlas_index_0530 == 8 else max_health_0530
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
	sprite_0530.region_enabled = true
	sprite_0530.pixel_size = _vehicle_pixel_size_05361(atlas_index_0530)
	sprite_0530.position = Vector3(0.0, _vehicle_sprite_height_05361(atlas_index_0530), 0.0)
	sprite_0530.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0530.shaded = false
	sprite_0530.transparent = true
	sprite_0530.double_sided = true
	sprite_0530.flip_h = false
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

func _vehicle_texture_by_sheet_05361(sheet: String) -> Texture2D:
	match sheet:
		"city_a": return VEHICLE_CITY_A_05361
		"city_b": return VEHICLE_CITY_B_05361
		"service": return VEHICLE_SERVICE_05361
		"rural": return VEHICLE_RURAL_05361
		_: return VEHICLE_LEGACY_05361

func _direction_index_05361(yaw: float) -> int:
	var step := int(round(fposmod(yaw, TAU) / (PI * 0.25)))
	return posmod(step + VEHICLE_DIRECTION_OFFSET_05361, VEHICLE_DIRECTION_COUNT_05361)

func _vehicle_region_rect_05361(index: int, direction: int) -> Rect2:
	if index == 8:
		var col := 8 % 3
		var row := int(8 / 3)
		return Rect2(float(col * 64), float(row * 48), 64.0, 48.0)
	var art: Array = VEHICLE_ART_05361[index] as Array
	var sheet := str(art[0])
	var row_index := int(art[1])
	var sheet_rows: Array = SHEET_RECTS_05361.get(sheet, []) as Array
	if row_index < 0 or row_index >= sheet_rows.size():
		return Rect2(0.0, 0.0, 64.0, 48.0)
	var row_rects: Array = sheet_rows[row_index] as Array
	var dir_index := posmod(direction, VEHICLE_DIRECTION_COUNT_05361)
	if dir_index >= row_rects.size():
		return Rect2(0.0, 0.0, 64.0, 48.0)
	var raw: Array = row_rects[dir_index] as Array
	return Rect2(float(raw[0]), float(raw[1]), float(raw[2]), float(raw[3]))

func _refresh_sprite_orientation_0530() -> void:
	if sprite_0530 == null:
		return
	if atlas_index_0530 == 8:
		sprite_0530.texture = VEHICLE_LEGACY_05361
		sprite_0530.region_rect = _vehicle_region_rect_05361(8, 0)
		sprite_0530.flip_h = absf(sin(rotation.y)) <= 0.55
		set_meta("vehicle_direction_05361", 0)
		return
	var art: Array = VEHICLE_ART_05361[atlas_index_0530] as Array
	var sheet := str(art[0])
	var direction := _direction_index_05361(rotation.y)
	sprite_0530.texture = _vehicle_texture_by_sheet_05361(sheet)
	sprite_0530.region_rect = _vehicle_region_rect_05361(atlas_index_0530, direction)
	sprite_0530.flip_h = false
	set_meta("vehicle_direction_05361", direction)
	set_meta("vehicle_art_sheet_05361", sheet)
	set_meta("vehicle_art_row_05361", int(art[1]))

func _vehicle_category_05361(index: int) -> String:
	if index >= 0 and index < VEHICLE_CATEGORIES_05361.size():
		return str(VEHICLE_CATEGORIES_05361[index])
	return "car"

func _vehicle_name_0530() -> String:
	if atlas_index_0530 >= 0 and atlas_index_0530 < VEHICLE_NAMES_05361.size():
		return str(VEHICLE_NAMES_05361[atlas_index_0530])
	return "Veículo"

func _max_speed_0530() -> float:
	match _vehicle_category_05361(atlas_index_0530):
		"box_truck": return 8.6
		"stake_truck": return 8.8
		"tanker": return 7.9
		"tractor": return 7.2
		"harvester": return 5.8
		"minibus": return 9.6
		"ambulance": return 11.2
		"police": return 13.4
		"pickup": return 12.4
		"van": return 10.8
		"suv": return 11.8
		"wagon": return 11.7
		"motorcycle": return 14.8
		"scooter": return 10.2
		"bicycle": return 0.0
		"wreck": return 0.0
		_: return 12.3

func _fuel_capacity_for_variant_0530(index: int) -> float:
	match _vehicle_category_05361(index):
		"box_truck": return 88.0
		"stake_truck": return 80.0
		"tanker": return 105.0
		"tractor": return 70.0
		"harvester": return 118.0
		"minibus": return 72.0
		"ambulance": return 68.0
		"police": return 58.0
		"pickup": return 55.0
		"van": return 64.0
		"suv": return 60.0
		"wagon": return 52.0
		"motorcycle": return 18.0
		"scooter": return 8.0
		"bicycle", "wreck": return 0.0
		_: return 46.0

func _health_capacity_for_variant_0530(index: int) -> float:
	match _vehicle_category_05361(index):
		"box_truck": return 148.0
		"stake_truck": return 140.0
		"tanker": return 158.0
		"tractor": return 132.0
		"harvester": return 185.0
		"minibus": return 132.0
		"ambulance": return 126.0
		"police": return 116.0
		"pickup": return 114.0
		"van": return 120.0
		"suv": return 124.0
		"wagon": return 106.0
		"motorcycle": return 68.0
		"scooter": return 52.0
		"bicycle": return 46.0
		"wreck": return 1.0
		_: return 100.0

func _trunk_capacity_for_variant_0530(index: int) -> int:
	match _vehicle_category_05361(index):
		"box_truck": return 92
		"stake_truck": return 84
		"tanker": return 58
		"tractor": return 28
		"harvester": return 64
		"minibus": return 72
		"ambulance": return 66
		"police": return 38
		"pickup": return 54
		"van": return 66
		"suv": return 48
		"wagon": return 44
		"motorcycle": return 12
		"scooter": return 6
		"bicycle": return 4
		"wreck": return 18
		_: return 34

func _collision_size_0530(index: int) -> Vector3:
	match _vehicle_category_05361(index):
		"box_truck": return Vector3(2.35, 2.25, 5.15)
		"stake_truck": return Vector3(2.25, 2.05, 4.90)
		"tanker": return Vector3(2.35, 2.30, 5.30)
		"tractor": return Vector3(2.15, 1.85, 3.60)
		"harvester": return Vector3(3.10, 2.75, 5.25)
		"minibus": return Vector3(2.18, 2.05, 4.75)
		"ambulance": return Vector3(2.08, 1.92, 4.55)
		"police": return Vector3(1.95, 1.50, 4.10)
		"pickup": return Vector3(2.0, 1.45, 4.35)
		"van": return Vector3(2.05, 1.72, 4.35)
		"suv": return Vector3(2.0, 1.62, 4.15)
		"wagon": return Vector3(1.95, 1.50, 4.10)
		"motorcycle": return Vector3(0.95, 1.30, 2.25)
		"scooter": return Vector3(0.82, 1.20, 1.85)
		"bicycle": return Vector3(0.72, 1.18, 1.85)
		"wreck": return Vector3(2.0, 1.30, 4.05)
		_: return Vector3(1.90, 1.48, 3.95)

func _vehicle_pixel_size_05361(index: int) -> float:
	match _vehicle_category_05361(index):
		"box_truck", "stake_truck", "tanker", "harvester": return 0.060
		"tractor", "minibus", "ambulance", "van": return 0.058
		"motorcycle": return 0.050
		"scooter", "bicycle": return 0.047
		_: return 0.055

func _vehicle_sprite_height_05361(index: int) -> float:
	match _vehicle_category_05361(index):
		"box_truck", "stake_truck", "tanker": return 1.72
		"harvester": return 1.88
		"tractor", "minibus", "ambulance": return 1.60
		"motorcycle", "scooter", "bicycle": return 1.10
		_: return 1.42

func set_driver_0530(driver: Node) -> bool:
	if atlas_index_0530 in DECORATIVE_VARIANTS_05361:
		return false
	return super.set_driver_0530(driver)

func is_drivable_0530() -> bool:
	if atlas_index_0530 in DECORATIVE_VARIANTS_05361:
		return false
	return super.is_drivable_0530()

func get_vehicle_art_debug_05361() -> Dictionary:
	var region := sprite_0530.region_rect if sprite_0530 != null else Rect2()
	return {
		"variant": atlas_index_0530,
		"name": _vehicle_name_0530(),
		"category": _vehicle_category_05361(atlas_index_0530),
		"direction": int(get_meta("vehicle_direction_05361", -1)),
		"sheet": str(get_meta("vehicle_art_sheet_05361", "legacy")),
		"row": int(get_meta("vehicle_art_row_05361", -1)),
		"variant_count": VEHICLE_VARIANT_COUNT_05361,
		"direction_count": VEHICLE_DIRECTION_COUNT_05361,
		"region": region,
		"drivable": is_drivable_0530()
	}
