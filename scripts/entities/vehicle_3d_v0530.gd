extends CharacterBody3D

const VEHICLE_ATLAS_0530: Texture2D = preload("res://assets/vehicles/fdc_vehicle_atlas_0517.png")
const VEHICLE_TILE_0530 := Vector2i(64, 48)
const SYNC_INTERVAL_0530 := 0.40
const ENGINE_NOISE_INTERVAL_0530 := 1.10
const COLLISION_COOLDOWN_0530 := 0.55
const FUEL_PER_WORLD_UNIT_0530 := 0.00115

var world_0530: Node = null
var vehicle_uid_0530 := ""
var atlas_index_0530 := 0
var world_seed_0530 := 0
var activated_0530 := false
var driver_0530: Node = null
var speed_0530 := 0.0
var fuel_0530 := 0.0
var max_fuel_0530 := 45.0
var health_0530 := 100.0
var max_health_0530 := 100.0
var trunk_0530: Dictionary = {}
var trunk_capacity_0530 := 32
var sync_timer_0530 := 0.0
var noise_timer_0530 := 0.0
var collision_cooldown_0530 := 0.0
var ground_y_0530 := 0.28
var sprite_0530: Sprite3D = null
var drive_shape_0530: CollisionShape3D = null

func configure_parked_0530(world: Node, uid: String, atlas_index: int, yaw: float, seed: int) -> void:
	world_0530 = world
	vehicle_uid_0530 = uid
	atlas_index_0530 = clampi(atlas_index, 0, 8)
	world_seed_0530 = seed
	rotation.y = yaw
	ground_y_0530 = 0.28
	var marker := int(abs(hash("vehicle0530:%d:%s:%d" % [seed, uid, atlas_index_0530])))
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
	atlas_index_0530 = clampi(int(record.get("variant", 0)), 0, 8)
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
	name = "Vehicle0530_%s" % vehicle_uid_0530.replace(":", "_")
	add_to_group("vehicle")
	add_to_group("vehicle_0530")
	add_to_group("vehicle_sprite_root_0517")
	set_meta("vehicle_key_0530", vehicle_uid_0530)
	set_meta("vehicle_variant_0530", atlas_index_0530)

	sprite_0530 = Sprite3D.new()
	sprite_0530.name = "VehicleSprite0517"
	sprite_0530.texture = VEHICLE_ATLAS_0530
	sprite_0530.region_enabled = true
	var col := atlas_index_0530 % 3
	var row := int(atlas_index_0530 / 3)
	sprite_0530.region_rect = Rect2(float(col * VEHICLE_TILE_0530.x), float(row * VEHICLE_TILE_0530.y), float(VEHICLE_TILE_0530.x), float(VEHICLE_TILE_0530.y))
	sprite_0530.pixel_size = 0.07
	sprite_0530.position = Vector3(0.0, 1.42, 0.0)
	sprite_0530.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite_0530.shaded = false
	sprite_0530.transparent = true
	sprite_0530.double_sided = true
	sprite_0530.add_to_group("vehicle_sprite_0517")
	sprite_0530.add_to_group("vehicle_orientation_0518")
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

	# Marcador legado preservado para os smoke tests e integrações 0.5.17/0.5.18.
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

func _physics_process(delta: float) -> void:
	collision_cooldown_0530 = maxf(0.0, collision_cooldown_0530 - delta)
	if driver_0530 == null or not is_instance_valid(driver_0530):
		driver_0530 = null
		speed_0530 = move_toward(speed_0530, 0.0, 5.5 * delta)
		return

	var input_vec := Vector2.ZERO
	var controls := get_tree().get_first_node_in_group("mobile_controls")
	if controls != null and controls.has_method("get_move_vector"):
		var raw: Variant = controls.call("get_move_vector")
		if raw is Vector2:
			input_vec = raw as Vector2
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vec.y = -1.0
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vec.y = 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vec.x = -1.0
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vec.x = 1.0

	var throttle := clampf(-input_vec.y, -1.0, 1.0)
	var steer := clampf(input_vec.x, -1.0, 1.0)
	var drive_allowed := health_0530 > 0.01 and fuel_0530 > 0.001 and atlas_index_0530 != 8
	var max_forward := _max_speed_0530()
	var max_reverse := max_forward * 0.38
	var target_speed := 0.0
	if drive_allowed:
		target_speed = throttle * (max_forward if throttle >= 0.0 else max_reverse)
	var acceleration := 8.2 if absf(target_speed) > absf(speed_0530) else 11.5
	speed_0530 = move_toward(speed_0530, target_speed, acceleration * delta)
	if absf(throttle) < 0.05:
		speed_0530 = move_toward(speed_0530, 0.0, 4.8 * delta)

	if absf(speed_0530) > 0.30 and absf(steer) > 0.05:
		var steer_factor := clampf(absf(speed_0530) / maxf(1.0, max_forward), 0.24, 1.0)
		var reverse_sign := 1.0 if speed_0530 >= 0.0 else -1.0
		rotation.y -= steer * 1.85 * steer_factor * reverse_sign * delta
		_refresh_sprite_orientation_0530()

	var distance_before := absf(speed_0530) * delta
	var forward := -global_transform.basis.z
	forward.y = 0.0
	if forward.length() <= 0.001:
		forward = Vector3(0.0, 0.0, -1.0)
	velocity = forward.normalized() * speed_0530
	velocity.y = 0.0
	var impact_speed := absf(speed_0530)
	move_and_slide()
	global_position.y = ground_y_0530

	if drive_allowed and distance_before > 0.0:
		fuel_0530 = maxf(0.0, fuel_0530 - distance_before * FUEL_PER_WORLD_UNIT_0530)
		if fuel_0530 <= 0.001:
			speed_0530 = move_toward(speed_0530, 0.0, 8.0 * delta)

	if get_slide_collision_count() > 0 and collision_cooldown_0530 <= 0.0 and impact_speed >= 3.4:
		_handle_collision_0530(impact_speed)
		collision_cooldown_0530 = COLLISION_COOLDOWN_0530

	noise_timer_0530 += delta
	if noise_timer_0530 >= ENGINE_NOISE_INTERVAL_0530:
		noise_timer_0530 = 0.0
		if world_0530 != null and world_0530.has_method("emit_noise_0519") and drive_allowed:
			world_0530.call("emit_noise_0519", global_position, 9.0 + absf(speed_0530) * 0.75, "vehicle_engine", self)

	sync_timer_0530 += delta
	if sync_timer_0530 >= SYNC_INTERVAL_0530:
		sync_timer_0530 = 0.0
		_sync_record_0530()

func _handle_collision_0530(impact_speed: float) -> void:
	var hit_zombie := false
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if collision == null:
			continue
		var collider: Object = collision.get_collider()
		if collider is Node and (collider as Node).is_in_group("zombies"):
			hit_zombie = true
			var zombie := collider as Node
			if zombie.has_method("take_damage"):
				zombie.call("take_damage", 34.0 + impact_speed * 5.2)
			if world_0530 != null and world_0530.has_method("emit_noise_0519"):
				world_0530.call("emit_noise_0519", global_position, 15.0, "vehicle_hit_zombie", self)
		else:
			if world_0530 != null and world_0530.has_method("emit_noise_0519"):
				world_0530.call("emit_noise_0519", global_position, 18.0, "vehicle_crash", self)
	var damage := (2.0 + impact_speed * 0.55) if hit_zombie else (4.0 + impact_speed * 0.95)
	take_vehicle_damage_0530(damage)
	speed_0530 *= 0.32

func take_vehicle_damage_0530(amount: float) -> void:
	if amount <= 0.0 or health_0530 <= 0.0:
		return
	health_0530 = maxf(0.0, health_0530 - amount)
	_sync_record_0530()
	if health_0530 <= 0.0:
		speed_0530 = 0.0
		if world_0530 != null and world_0530.has_method("force_exit_vehicle_0530"):
			world_0530.call_deferred("force_exit_vehicle_0530", vehicle_uid_0530)

func set_driver_0530(driver: Node) -> bool:
	if atlas_index_0530 == 8 or health_0530 <= 0.0 or fuel_0530 <= 0.0:
		return false
	driver_0530 = driver
	activated_0530 = true
	_sync_record_0530()
	return true

func clear_driver_0530() -> void:
	driver_0530 = null
	speed_0530 = move_toward(speed_0530, 0.0, 4.0)
	_sync_record_0530()

func is_drivable_0530() -> bool:
	return atlas_index_0530 != 8 and health_0530 > 0.01 and fuel_0530 > 0.001

func add_fuel_0530(liters: float) -> float:
	if liters <= 0.0 or atlas_index_0530 == 8:
		return 0.0
	var before := fuel_0530
	fuel_0530 = minf(max_fuel_0530, fuel_0530 + liters)
	_sync_record_0530()
	return fuel_0530 - before

func repair_0530(amount: float) -> float:
	if amount <= 0.0 or atlas_index_0530 == 8:
		return 0.0
	var before := health_0530
	health_0530 = minf(max_health_0530, health_0530 + amount)
	_sync_record_0530()
	return health_0530 - before

func trunk_total_0530() -> int:
	var total := 0
	for raw_id: Variant in trunk_0530.keys():
		total += maxi(0, int(trunk_0530[raw_id]))
	return total

func trunk_deposit_0530(item_id: String, amount: int) -> bool:
	if amount <= 0 or trunk_total_0530() + amount > trunk_capacity_0530:
		return false
	trunk_0530[item_id] = int(trunk_0530.get(item_id, 0)) + amount
	_sync_record_0530()
	return true

func trunk_withdraw_0530(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return false
	var current := int(trunk_0530.get(item_id, 0))
	if current < amount:
		return false
	trunk_0530[item_id] = current - amount
	if int(trunk_0530[item_id]) <= 0:
		trunk_0530.erase(item_id)
	_sync_record_0530()
	return true

func get_status_0530() -> Dictionary:
	return {
		"uid": vehicle_uid_0530,
		"variant": atlas_index_0530,
		"name": _vehicle_name_0530(),
		"fuel": fuel_0530,
		"max_fuel": max_fuel_0530,
		"health": health_0530,
		"max_health": max_health_0530,
		"speed": absf(speed_0530),
		"trunk": trunk_0530.duplicate(true),
		"trunk_total": trunk_total_0530(),
		"trunk_capacity": trunk_capacity_0530,
		"drivable": is_drivable_0530(),
		"occupied": driver_0530 != null and is_instance_valid(driver_0530),
		"activated": activated_0530
	}

func export_record_0530() -> Dictionary:
	return {
		"seed": world_seed_0530,
		"variant": atlas_index_0530,
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z},
		"yaw": rotation.y,
		"fuel": fuel_0530,
		"max_fuel": max_fuel_0530,
		"health": health_0530,
		"max_health": max_health_0530,
		"trunk": trunk_0530.duplicate(true),
		"trunk_capacity": trunk_capacity_0530,
		"activated": true
	}

func _sync_record_0530() -> void:
	if world_0530 != null and activated_0530 and world_0530.has_method("update_vehicle_record_0530"):
		world_0530.call("update_vehicle_record_0530", self)

func _refresh_sprite_orientation_0530() -> void:
	if sprite_0530 != null:
		sprite_0530.flip_h = absf(sin(rotation.y)) <= 0.55

func _vehicle_name_0530() -> String:
	match atlas_index_0530:
		0: return "Hatch abandonado"
		1: return "Sedã abandonado"
		2: return "Perua utilitária"
		3: return "Picape"
		4: return "Furgão"
		5: return "Caminhão baú"
		6: return "SUV"
		7: return "Trator"
		8: return "Carcaça queimada"
	return "Veículo"

func _max_speed_0530() -> float:
	match atlas_index_0530:
		3: return 12.4
		4: return 10.8
		5: return 8.6
		6: return 11.7
		7: return 7.2
		_: return 12.0

func _fuel_capacity_for_variant_0530(index: int) -> float:
	match index:
		3: return 55.0
		4: return 62.0
		5: return 82.0
		6: return 58.0
		7: return 70.0
		8: return 0.0
		_: return 46.0

func _health_capacity_for_variant_0530(index: int) -> float:
	match index:
		3: return 112.0
		4: return 118.0
		5: return 145.0
		6: return 122.0
		7: return 130.0
		8: return 1.0
		_: return 100.0

func _trunk_capacity_for_variant_0530(index: int) -> int:
	match index:
		2: return 42
		3: return 52
		4: return 64
		5: return 88
		6: return 48
		7: return 26
		8: return 18
		_: return 34

func _collision_size_0530(index: int) -> Vector3:
	match index:
		3: return Vector3(2.0, 1.45, 4.35)
		4: return Vector3(2.05, 1.72, 4.35)
		5: return Vector3(2.35, 2.25, 5.15)
		6: return Vector3(2.0, 1.62, 4.15)
		7: return Vector3(2.15, 1.85, 3.60)
		8: return Vector3(2.0, 1.30, 4.05)
		_: return Vector3(1.90, 1.48, 3.95)

func _initial_trunk_0530(marker: int) -> Dictionary:
	var result: Dictionary = {}
	if marker % 2 == 0:
		result["gasoline"] = 1 + marker % 4
	if marker % 3 == 0:
		result["water"] = 1
	if marker % 4 == 0:
		result["food"] = 1 + int(marker / 5) % 2
	if marker % 5 == 0:
		result["bandage"] = 1
	if marker % 3 == 1:
		result["ammo_9mm"] = 2 + marker % 6
	if marker % 7 == 0:
		result["repair_kit"] = 1
	if atlas_index_0530 in [3, 4, 5, 6] and marker % 4 != 3:
		result["wood"] = 1 + marker % 3
	return result
