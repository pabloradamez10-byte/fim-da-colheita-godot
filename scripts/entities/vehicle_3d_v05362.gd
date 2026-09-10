extends "res://scripts/entities/vehicle_3d_v0530.gd"

const VEHICLE_ATLAS_05362: Texture2D = preload("res://assets/vehicles/fdc_vehicle_atlas_05362.png")
const VEHICLE_TILE_05362 := Vector2i(64, 48)
const VEHICLE_DIRECTION_COUNT_05362 := 8
const VEHICLE_VARIANT_COUNT_05362 := 40
const VEHICLE_DIRECTION_OFFSET_05362 := 0
const DECORATIVE_VARIANTS_05362 := [8, 21]

const VEHICLE_NAMES_05362 := [
	"Compacto claro", "Sedã verde", "Perua utilitária", "Picape branca", "Furgão urbano", "Caminhão baú",
	"SUV vermelho", "Trator agrícola", "Carcaça queimada", "Utilitário branco", "Utilitário vermelho", "Micro-ônibus",
	"Viatura policial", "Ambulância", "Caminhão carroceria", "Caminhão rural", "Caminhão-tanque", "Colheitadeira",
	"Moto trail vermelha", "Moto trail verde", "Scooter", "Bicicleta", "Picape vermelha", "SUV expedição verde",
	"SUV expedição clara", "Caminhão pequeno azul", "Furgão de carga claro", "Hatch antigo bege", "Sedã compacto prata",
	"Hatch urbano azul", "Coupé clássico marrom", "Picape 4x4 azul", "Picape expedição preta",
	"Furgão clássico de passageiros", "Ônibus intermunicipal", "Carreta baú", "Caminhão leiteiro",
	"Trator vermelho clássico", "Colheitadeira verde", "Moto utilitária preta"
]

const VEHICLE_CATEGORIES_05362 := [
	"car", "car", "wagon", "pickup", "van", "box_truck", "suv", "tractor", "wreck", "suv", "suv", "minibus",
	"police", "ambulance", "stake_truck", "stake_truck", "tanker", "harvester", "motorcycle", "motorcycle", "scooter",
	"bicycle", "pickup", "suv", "suv", "stake_truck", "van", "car", "car", "car", "car", "pickup", "pickup", "van",
	"bus", "semi_truck", "tanker", "tractor", "harvester", "motorcycle"
]

func configure_parked_0530(world: Node, uid: String, atlas_index: int, yaw: float, seed: int) -> void:
	world_0530 = world
	vehicle_uid_0530 = uid
	atlas_index_0530 = clampi(atlas_index, 0, VEHICLE_VARIANT_COUNT_05362 - 1)
	world_seed_0530 = seed
	rotation.y = yaw
	ground_y_0530 = 0.28
	var marker := int(abs(hash("vehicle05362:%d:%s:%d" % [seed, uid, atlas_index_0530])))
	max_fuel_0530 = _fuel_capacity_for_variant_0530(atlas_index_0530)
	max_health_0530 = _health_capacity_for_variant_0530(atlas_index_0530)
	trunk_capacity_0530 = _trunk_capacity_for_variant_0530(atlas_index_0530)
	if atlas_index_0530 in DECORATIVE_VARIANTS_05362:
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
	atlas_index_0530 = clampi(int(record.get("variant", 0)), 0, VEHICLE_VARIANT_COUNT_05362 - 1)
	world_seed_0530 = int(record.get("seed", 0))
	max_fuel_0530 = float(record.get("max_fuel", _fuel_capacity_for_variant_0530(atlas_index_0530)))
	max_health_0530 = float(record.get("max_health", _health_capacity_for_variant_0530(atlas_index_0530)))
	trunk_capacity_0530 = int(record.get("trunk_capacity", _trunk_capacity_for_variant_0530(atlas_index_0530)))
	fuel_0530 = clampf(float(record.get("fuel", 0.0)), 0.0, max_fuel_0530)
	health_0530 = clampf(float(record.get("health", max_health_0530)), 0.0, max_health_0530)
	var raw_trunk: Variant = record.get("trunk", {})
	if raw_trunk is Dictionary:
		trunk_0530 = (raw_trunk as Dictionary).duplicate(true)
	else:
		trunk_0530 = {}
	rotation.y = float(record.get("yaw", 0.0))
	activated_0530 = true
	_build_vehicle_0530()

func _build_vehicle_0530() -> void:
	name = "Vehicle05362_%s" % vehicle_uid_0530.replace(":", "_")
	add_to_group("vehicle")
	add_to_group("vehicle_0530")
	add_to_group("vehicle_sprite_root_0517")
	add_to_group("vehicle_art_05362")
	set_meta("vehicle_key_0530", vehicle_uid_0530)
	set_meta("vehicle_variant_0530", atlas_index_0530)
	set_meta("vehicle_name_05362", _vehicle_name_0530())
	set_meta("vehicle_category_05362", _vehicle_category_05362(atlas_index_0530))

	sprite_0530 = Sprite3D.new()
	sprite_0530.name = "VehicleSprite0517"
	sprite_0530.texture = VEHICLE_ATLAS_05362
	sprite_0530.region_enabled = true
	sprite_0530.pixel_size = _vehicle_pixel_size_05362(atlas_index_0530)
	sprite_0530.position = Vector3(0.0, _vehicle_sprite_height_05362(atlas_index_0530), 0.0)
	sprite_0530.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0530.shaded = false
	sprite_0530.transparent = true
	sprite_0530.double_sided = true
	sprite_0530.add_to_group("vehicle_sprite_0517")
	sprite_0530.add_to_group("vehicle_orientation_0518")
	sprite_0530.add_to_group("vehicle_sprite_8dir_05362")
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

	# Compatibilidade com integrações e regressões da 0.5.17/0.5.18.
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

func _direction_index_05362(yaw: float) -> int:
	return posmod(int(round(fposmod(yaw, TAU) / (PI * 0.25))) + VEHICLE_DIRECTION_OFFSET_05362, VEHICLE_DIRECTION_COUNT_05362)

func _refresh_sprite_orientation_0530() -> void:
	if sprite_0530 == null:
		return
	var direction := _direction_index_05362(rotation.y)
	var row := clampi(atlas_index_0530, 0, VEHICLE_VARIANT_COUNT_05362 - 1)
	sprite_0530.region_rect = Rect2(
		float(direction * VEHICLE_TILE_05362.x),
		float(row * VEHICLE_TILE_05362.y),
		float(VEHICLE_TILE_05362.x),
		float(VEHICLE_TILE_05362.y)
	)
	# Mantém a leitura visual legada exigida pela correção 0.5.18.
	sprite_0530.flip_h = absf(sin(rotation.y)) <= 0.55
	set_meta("vehicle_direction_05362", direction)
	set_meta("vehicle_art_row_05362", row)

func _vehicle_category_05362(index: int) -> String:
	if index >= 0 and index < VEHICLE_CATEGORIES_05362.size():
		return str(VEHICLE_CATEGORIES_05362[index])
	return "car"

func _vehicle_name_0530() -> String:
	if atlas_index_0530 >= 0 and atlas_index_0530 < VEHICLE_NAMES_05362.size():
		return str(VEHICLE_NAMES_05362[atlas_index_0530])
	return "Veículo"

func _vehicle_pixel_size_05362(index: int) -> float:
	var category := _vehicle_category_05362(index)
	if category in ["motorcycle", "scooter", "bicycle"]:
		return 0.074
	if category in ["bus", "semi_truck", "harvester"]:
		return 0.094
	if category in ["box_truck", "stake_truck", "tanker"]:
		return 0.090
	return 0.086

func _vehicle_sprite_height_05362(index: int) -> float:
	var category := _vehicle_category_05362(index)
	if category in ["bus", "semi_truck", "harvester", "box_truck", "tanker"]:
		return 1.72
	if category in ["motorcycle", "scooter", "bicycle"]:
		return 0.95
	if category == "tractor":
		return 1.50
	return 1.42

func is_drivable_0530() -> bool:
	return atlas_index_0530 not in DECORATIVE_VARIANTS_05362 and health_0530 > 0.01 and fuel_0530 > 0.001

func set_driver_0530(driver: Node) -> bool:
	if atlas_index_0530 in DECORATIVE_VARIANTS_05362 or health_0530 <= 0.0 or fuel_0530 <= 0.0:
		return false
	driver_0530 = driver
	activated_0530 = true
	_sync_record_0530()
	return true

func add_fuel_0530(liters: float) -> float:
	if liters <= 0.0 or atlas_index_0530 in DECORATIVE_VARIANTS_05362:
		return 0.0
	var before := fuel_0530
	fuel_0530 = minf(max_fuel_0530, fuel_0530 + liters)
	_sync_record_0530()
	return fuel_0530 - before

func _max_speed_0530() -> float:
	match _vehicle_category_05362(atlas_index_0530):
		"motorcycle": return 13.2
		"scooter": return 9.4
		"pickup": return 12.4
		"suv", "police": return 11.8
		"van", "ambulance": return 10.7
		"minibus": return 9.5
		"bus": return 8.8
		"box_truck", "stake_truck", "tanker": return 8.3
		"semi_truck": return 7.8
		"tractor": return 7.1
		"harvester": return 6.1
		"bicycle": return 0.0
		"wreck": return 0.0
		_: return 12.0

func _fuel_capacity_for_variant_0530(index: int) -> float:
	match _vehicle_category_05362(index):
		"motorcycle": return 18.0
		"scooter": return 10.0
		"pickup": return 55.0
		"suv", "police": return 58.0
		"van": return 62.0
		"ambulance", "minibus": return 68.0
		"bus": return 110.0
		"box_truck", "stake_truck": return 82.0
		"semi_truck": return 140.0
		"tanker": return 110.0
		"tractor": return 70.0
		"harvester": return 90.0
		"bicycle", "wreck": return 0.0
		_: return 46.0

func _health_capacity_for_variant_0530(index: int) -> float:
	match _vehicle_category_05362(index):
		"motorcycle": return 72.0
		"scooter": return 55.0
		"bicycle": return 35.0
		"pickup": return 112.0
		"suv", "police": return 122.0
		"van": return 118.0
		"ambulance", "minibus": return 124.0
		"bus": return 155.0
		"box_truck", "stake_truck": return 145.0
		"semi_truck": return 170.0
		"tanker": return 150.0
		"tractor": return 130.0
		"harvester": return 155.0
		"wreck": return 1.0
		_: return 100.0

func _trunk_capacity_for_variant_0530(index: int) -> int:
	match _vehicle_category_05362(index):
		"motorcycle": return 8
		"scooter": return 5
		"bicycle": return 2
		"pickup": return 52
		"wagon": return 42
		"suv", "police": return 48
		"van": return 64
		"ambulance": return 76
		"minibus": return 70
		"bus": return 100
		"box_truck", "stake_truck": return 88
		"semi_truck": return 120
		"tanker": return 72
		"tractor": return 26
		"harvester": return 40
		"wreck": return 18
		_: return 34

func _collision_size_0530(index: int) -> Vector3:
	match _vehicle_category_05362(index):
		"motorcycle", "scooter": return Vector3(1.05, 1.35, 2.30)
		"bicycle": return Vector3(0.85, 1.20, 2.05)
		"pickup": return Vector3(2.0, 1.45, 4.35)
		"suv", "police": return Vector3(2.0, 1.62, 4.15)
		"van", "ambulance": return Vector3(2.05, 1.72, 4.35)
		"minibus": return Vector3(2.20, 2.15, 5.10)
		"bus": return Vector3(2.40, 2.45, 6.20)
		"box_truck", "stake_truck": return Vector3(2.35, 2.25, 5.15)
		"semi_truck": return Vector3(2.50, 2.45, 6.50)
		"tanker": return Vector3(2.40, 2.35, 5.40)
		"tractor": return Vector3(2.15, 1.85, 3.60)
		"harvester": return Vector3(3.10, 2.75, 5.25)
		"wreck": return Vector3(2.0, 1.30, 4.05)
		_: return Vector3(1.90, 1.48, 3.95)

func get_vehicle_art_debug_05362() -> Dictionary:
	return {
		"variant": atlas_index_0530,
		"name": _vehicle_name_0530(),
		"category": _vehicle_category_05362(atlas_index_0530),
		"direction": int(get_meta("vehicle_direction_05362", -1)),
		"row": int(get_meta("vehicle_art_row_05362", -1)),
		"variant_count": VEHICLE_VARIANT_COUNT_05362,
		"direction_count": VEHICLE_DIRECTION_COUNT_05362,
		"tile_width": VEHICLE_TILE_05362.x,
		"tile_height": VEHICLE_TILE_05362.y,
		"texture_width": sprite_0530.texture.get_width() if sprite_0530 != null and sprite_0530.texture != null else 0,
		"texture_height": sprite_0530.texture.get_height() if sprite_0530 != null and sprite_0530.texture != null else 0,
		"drivable": is_drivable_0530()
	}
