extends "res://scripts/world/city_chunk_streamer_3d.gd"

func _terrain_id(gx: int, gz: int, h: float, m: float) -> String:
	var coord: Vector2i = _cell_to_chunk(gx, gz)
	var city: Dictionary = _city_info(coord)
	if bool(city.get("city", false)):
		var local: Vector2i = city.get("local", Vector2i.ZERO) as Vector2i
		var lx: int = posmod(gx, CHUNK_CELLS)
		var lz: int = posmod(gz, CHUNK_CELLS)
		if (local.x == 0 and lx in [3, 4]) or (local.y == 0 and lz in [3, 4]):
			return "asphalt"
		return "grass"
	return super._terrain_id(gx, gz, h, m)

func _build_city_sidewalks(parent: Node3D, origin: Vector3, local: Vector2i) -> void:
	var asphalt: Material = _material_for("asphalt")
	var concrete: Material = _material_for("concrete")
	var yellow: Material = _material_for("lane_yellow")
	var white: Material = _material_for("lane_white")
	if local.x == 0:
		var road_v: MeshInstance3D = _flat_box(parent, Vector3(8.7, 0.11, 32.0), origin + Vector3(16.0, 0.20, 16.0), asphalt)
		road_v.add_to_group("city_asphalt")
		_flat_box(parent, Vector3(2.8, 0.12, 31.0), origin + Vector3(10.1, 0.24, 16.0), concrete)
		_flat_box(parent, Vector3(2.8, 0.12, 31.0), origin + Vector3(21.9, 0.24, 16.0), concrete)
		_flat_box(parent, Vector3(0.18, 0.04, 29.0), origin + Vector3(16.0, 0.29, 16.0), yellow)
		_flat_box(parent, Vector3(0.10, 0.04, 29.0), origin + Vector3(12.05, 0.29, 16.0), white)
		_flat_box(parent, Vector3(0.10, 0.04, 29.0), origin + Vector3(19.95, 0.29, 16.0), white)
	if local.y == 0:
		var road_h: MeshInstance3D = _flat_box(parent, Vector3(32.0, 0.11, 8.7), origin + Vector3(16.0, 0.21, 16.0), asphalt)
		road_h.add_to_group("city_asphalt")
		_flat_box(parent, Vector3(31.0, 0.12, 2.8), origin + Vector3(16.0, 0.25, 10.1), concrete)
		_flat_box(parent, Vector3(31.0, 0.12, 2.8), origin + Vector3(16.0, 0.25, 21.9), concrete)
		_flat_box(parent, Vector3(29.0, 0.04, 0.18), origin + Vector3(16.0, 0.30, 16.0), yellow)
		_flat_box(parent, Vector3(29.0, 0.04, 0.10), origin + Vector3(16.0, 0.30, 12.05), white)
		_flat_box(parent, Vector3(29.0, 0.04, 0.10), origin + Vector3(16.0, 0.30, 19.95), white)

func _build_house(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	var root := Node3D.new()
	root.name = "CityHouse_%d_%d" % [coord.x, coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	var wall_mat: Material = _material_for("interior_wall") if variant % 2 == 0 else _material_for("wood_old")
	_solid_box(root, Vector3(10.5, 0.22, 8.5), Vector3(0, 0.11, 0), _material_for("interior_floor"), "HouseFloor")
	_solid_box(root, Vector3(10.5, 2.9, 0.28), Vector3(0, 1.45, -4.15), wall_mat, "HouseBackWall")
	_solid_box(root, Vector3(0.28, 2.9, 8.5), Vector3(-5.1, 1.45, 0), wall_mat, "HouseLeftWall")
	_solid_box(root, Vector3(0.28, 2.9, 8.5), Vector3(5.1, 1.45, 0), wall_mat, "HouseRightWall")
	_solid_box(root, Vector3(3.7, 2.9, 0.28), Vector3(-3.25, 1.45, 4.15), wall_mat, "HouseFrontLeft")
	_solid_box(root, Vector3(3.7, 2.9, 0.28), Vector3(3.25, 1.45, 4.15), wall_mat, "HouseFrontRight")
	_solid_box(root, Vector3(0.18, 2.45, 4.4), Vector3(0.9, 1.22, -1.7), wall_mat, "HousePartition")
	_furniture_box(root, Vector3(2.2, 0.55, 1.0), Vector3(-3.2, 0.52, -2.5), _material_for("wood"), "BedFrame")
	_furniture_box(root, Vector3(2.0, 0.35, 0.9), Vector3(-3.2, 0.95, -2.5), _material_for("cloth"), "Bed")
	_furniture_box(root, Vector3(1.4, 2.0, 0.7), Vector3(-4.0, 1.0, 1.7), _material_for("wood_dark"), "Wardrobe")
	_furniture_box(root, Vector3(1.5, 0.8, 1.0), Vector3(-0.6, 0.55, 1.5), _material_for("wood"), "Table")
	_furniture_box(root, Vector3(0.9, 1.8, 0.9), Vector3(3.7, 0.95, -2.5), _material_for("metal"), "Fridge")
	_furniture_box(root, Vector3(2.5, 0.9, 0.7), Vector3(3.4, 0.50, 1.8), _material_for("wood_dark"), "KitchenCounter")
	_create_loot_container(root, Vector3(3.5, 0.72, -1.3), "city_home", "city:%d:%d:kitchen" % [coord.x, coord.y])
	_create_loot_container(root, Vector3(-3.8, 0.72, 1.0), "city_home", "city:%d:%d:wardrobe" % [coord.x, coord.y])
	_create_loot_container(root, Vector3(-1.4, 0.72, -2.6), "city_home", "city:%d:%d:bedroom" % [coord.x, coord.y])
	_add_house_roof(root, Vector3(10.9, 8.9), 3.15, _material_for("roof"))
	_add_roof_trigger(root, Vector3(9.6, 2.6, 7.4), 1.35)

func _build_garage(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	var root := Node3D.new()
	root.name = "CityGarage_%d_%d" % [coord.x, coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	var wall: Material = _material_for("rust") if variant == 0 else _material_for("wood_dark")
	_solid_box(root, Vector3(11.0, 0.22, 8.0), Vector3(0, 0.11, 0), _material_for("concrete"), "GarageFloor")
	_solid_box(root, Vector3(11.0, 3.1, 0.25), Vector3(0, 1.55, -3.9), wall, "GarageBack")
	_solid_box(root, Vector3(0.25, 3.1, 8.0), Vector3(-5.4, 1.55, 0), wall, "GarageLeft")
	_solid_box(root, Vector3(0.25, 3.1, 8.0), Vector3(5.4, 1.55, 0), wall, "GarageRight")
	_solid_box(root, Vector3(2.0, 3.1, 0.25), Vector3(-4.4, 1.55, 3.9), wall, "GarageFrontLeft")
	_solid_box(root, Vector3(2.0, 3.1, 0.25), Vector3(4.4, 1.55, 3.9), wall, "GarageFrontRight")
	_furniture_box(root, Vector3(4.0, 0.85, 0.9), Vector3(0, 0.52, -2.7), _material_for("wood_dark"), "Workbench")
	_furniture_box(root, Vector3(0.55, 2.2, 2.8), Vector3(4.4, 1.15, -1.4), _material_for("metal"), "GarageShelf")
	_furniture_box(root, Vector3(0.55, 2.2, 2.8), Vector3(-4.4, 1.15, -1.4), _material_for("metal"), "GarageShelf2")
	_create_loot_container(root, Vector3(-3.5, 0.72, 1.6), "city_garage", "city:%d:%d:garage_a" % [coord.x, coord.y])
	_create_loot_container(root, Vector3(3.4, 0.72, 1.6), "city_garage", "city:%d:%d:garage_b" % [coord.x, coord.y])
	_add_flat_roof(root, Vector3(11.6, 0.30, 8.6), 3.36, _material_for("roof_rust"))
	_add_roof_trigger(root, Vector3(10.0, 2.7, 7.0), 1.4)

func _build_market(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	var root := Node3D.new()
	root.name = "CityMarket_%d_%d" % [coord.x, coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	_solid_box(root, Vector3(12.0, 0.22, 9.5), Vector3(0, 0.11, 0), _material_for("concrete"), "MarketFloor")
	_solid_box(root, Vector3(12.0, 3.2, 0.25), Vector3(0, 1.6, -4.6), _material_for("interior_wall"), "MarketBack")
	_solid_box(root, Vector3(0.25, 3.2, 9.5), Vector3(-5.9, 1.6, 0), _material_for("interior_wall"), "MarketLeft")
	_solid_box(root, Vector3(0.25, 3.2, 9.5), Vector3(5.9, 1.6, 0), _material_for("interior_wall"), "MarketRight")
	_solid_box(root, Vector3(4.2, 3.2, 0.25), Vector3(-3.9, 1.6, 4.6), _material_for("interior_wall"), "MarketFrontLeft")
	_solid_box(root, Vector3(4.2, 3.2, 0.25), Vector3(3.9, 1.6, 4.6), _material_for("interior_wall"), "MarketFrontRight")
	for raw_z in [-2.4, -0.2, 2.0]:
		var shelf_z: float = float(raw_z)
		_furniture_box(root, Vector3(5.5, 1.5, 0.55), Vector3(0.5, 0.8, shelf_z), _material_for("wood"), "MarketShelf")
	_furniture_box(root, Vector3(3.0, 1.0, 0.7), Vector3(-3.7, 0.55, 3.3), _material_for("wood_dark"), "Counter")
	_furniture_box(root, Vector3(1.0, 1.9, 1.0), Vector3(4.7, 1.0, 3.0), _material_for("metal"), "MarketFridge")
	_create_loot_container(root, Vector3(4.4, 0.72, -3.2), "city_market", "city:%d:%d:market_a" % [coord.x, coord.y])
	_create_loot_container(root, Vector3(2.4, 0.72, -3.2), "city_market", "city:%d:%d:market_b" % [coord.x, coord.y])
	_create_loot_container(root, Vector3(-2.8, 0.72, 2.9), "city_market", "city:%d:%d:market_c" % [coord.x, coord.y])
	_add_flat_roof(root, Vector3(12.6, 0.30, 10.1), 3.46, _material_for("roof"))
	_add_roof_trigger(root, Vector3(11.0, 2.8, 8.5), 1.45)

func _build_armory(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	var root := Node3D.new()
	root.name = "CityDepot_%d_%d" % [coord.x, coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	_solid_box(root, Vector3(9.5, 0.22, 8.0), Vector3(0, 0.11, 0), _material_for("concrete"), "DepotFloor")
	_solid_box(root, Vector3(9.5, 3.0, 0.25), Vector3(0, 1.5, -3.9), _material_for("rust"), "DepotBack")
	_solid_box(root, Vector3(0.25, 3.0, 8.0), Vector3(-4.6, 1.5, 0), _material_for("rust"), "DepotLeft")
	_solid_box(root, Vector3(0.25, 3.0, 8.0), Vector3(4.6, 1.5, 0), _material_for("rust"), "DepotRight")
	_solid_box(root, Vector3(3.0, 3.0, 0.25), Vector3(-3.2, 1.5, 3.9), _material_for("rust"), "DepotFrontLeft")
	_solid_box(root, Vector3(3.0, 3.0, 0.25), Vector3(3.2, 1.5, 3.9), _material_for("rust"), "DepotFrontRight")
	_furniture_box(root, Vector3(0.6, 2.0, 4.5), Vector3(3.7, 1.05, -0.8), _material_for("metal"), "DepotRack")
	_furniture_box(root, Vector3(0.6, 2.0, 4.5), Vector3(-3.7, 1.05, -0.8), _material_for("metal"), "DepotRack2")
	_furniture_box(root, Vector3(3.2, 0.9, 0.8), Vector3(-1.5, 0.5, -2.5), _material_for("wood_dark"), "DepotBench")
	_create_loot_container(root, Vector3(-2.6, 0.72, 1.8), "city_armory", "city:%d:%d:armory_a" % [coord.x, coord.y])
	_create_loot_container(root, Vector3(0.0, 0.72, 1.8), "city_armory", "city:%d:%d:armory_b" % [coord.x, coord.y])
	_create_loot_container(root, Vector3(2.6, 0.72, 1.8), "city_armory", "city:%d:%d:armory_c" % [coord.x, coord.y])
	_add_flat_roof(root, Vector3(10.1, 0.30, 8.6), 3.26, _material_for("roof_rust"))
	_add_roof_trigger(root, Vector3(8.6, 2.6, 7.0), 1.35)

func _build_rural_house(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_house(parent, pos, coord)
	var root: Node3D = parent.get_node_or_null("RuralHouse_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	_add_house_roof(root, Vector3(8.9, 7.4), 2.95, _material_for("roof"))
	_add_roof_trigger(root, Vector3(7.5, 2.4, 6.0), 1.25)
	_create_loot_container(root, Vector3(2.6, 0.72, 1.6), "rural_home", "rural:%d:%d:home_extra" % [coord.x, coord.y])

func _build_rural_garage(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_garage(parent, pos, coord)
	var root: Node3D = parent.get_node_or_null("RuralGarage_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	_add_flat_roof(root, Vector3(8.5, 0.28, 7.0), 3.02, _material_for("roof_rust"))
	_add_roof_trigger(root, Vector3(7.0, 2.4, 5.5), 1.25)
	_create_loot_container(root, Vector3(2.4, 0.72, 1.4), "rural_garage", "rural:%d:%d:garage_extra" % [coord.x, coord.y])

func _build_street_props(parent: Node3D, origin: Vector3, marker: int) -> void:
	var chunk_world: float = float(CHUNK_CELLS) * CELL_SIZE
	var coord := Vector2i(floori(origin.x / chunk_world), floori(origin.z / chunk_world))
	var info: Dictionary = _city_info(coord)
	var local: Vector2i = info.get("local", Vector2i.ZERO) as Vector2i
	for i in range(2):
		var post_offset: float = 5.0 + float((marker + i * 11) % 20)
		_furniture_box(parent, Vector3(0.24, 3.8, 0.24), origin + Vector3(5.0, 1.9, post_offset), _material_for("metal"), "StreetLightPost")
		_flat_box(parent, Vector3(0.9, 0.12, 0.32), origin + Vector3(5.35, 3.75, post_offset), _material_for("lane_white"))
	if local.x == 0:
		var z1: float = 7.0 + float(marker % 8)
		_build_vehicle(parent, origin + Vector3(13.6, 0.28, z1), 0.0, marker % 3, "vehicle:%d:%d:a" % [coord.x, coord.y])
		if local == Vector2i.ZERO:
			_build_vehicle(parent, origin + Vector3(18.8, 0.28, 24.0), 0.0, (marker + 1) % 3, "vehicle:%d:%d:b" % [coord.x, coord.y])
	elif local.y == 0:
		var x1: float = 7.0 + float(marker % 8)
		_build_vehicle(parent, origin + Vector3(x1, 0.28, 13.6), PI * 0.5, marker % 3, "vehicle:%d:%d:a" % [coord.x, coord.y])

func _build_vehicle(parent: Node3D, pos: Vector3, yaw: float, variant: int, key: String) -> void:
	var root := Node3D.new()
	root.name = "AbandonedVehicle"
	root.position = pos
	root.rotation.y = yaw
	root.add_to_group("vehicle")
	parent.add_child(root)
	var body_mat: Material = _material_for("vehicle_red")
	if variant == 1:
		body_mat = _material_for("vehicle_blue")
	elif variant == 2:
		body_mat = _material_for("vehicle_white")
	_solid_box(root, Vector3(1.85, 0.58, 3.9), Vector3(0, 0.60, 0), body_mat, "VehicleChassis")
	_solid_box(root, Vector3(1.72, 0.78, 1.75), Vector3(0, 1.18, 0.25), body_mat, "VehicleCabin")
	_flat_box(root, Vector3(1.48, 0.48, 0.06), Vector3(0, 1.32, -0.68), _material_for("glass_dark"))
	_flat_box(root, Vector3(1.48, 0.42, 0.06), Vector3(0, 1.30, 1.02), _material_for("glass_dark"))
	for raw_x in [-1.02, 1.02]:
		var wheel_x: float = float(raw_x)
		for raw_z in [-1.22, 1.22]:
			var wheel_z: float = float(raw_z)
			var wheel: MeshInstance3D = _cylinder(root, 0.36, 0.28, Vector3(wheel_x, 0.42, wheel_z), _material_for("vehicle_dark"), 10)
			wheel.rotation_degrees.z = 90.0
	if world != null and world.has_method("register_streamed_loot"):
		world.call("register_streamed_loot", root.global_position, "city_garage", key, null)

func _create_loot_container(parent: Node3D, pos: Vector3, kind: String, key: String) -> void:
	if world != null:
		var harvested_raw: Variant = world.get("harvested_keys")
		if harvested_raw is Array and (harvested_raw as Array).has(key):
			return
	var root := Node3D.new()
	root.name = "LootContainer"
	root.position = pos
	root.add_to_group("loot_container")
	parent.add_child(root)
	_solid_box(root, Vector3(1.15, 0.82, 0.95), Vector3(0, 0.42, 0), _material_for("loot"), "LootBody")
	_flat_box(root, Vector3(1.25, 0.14, 1.02), Vector3(0, 0.88, 0), _material_for("wood_dark"))
	_flat_box(root, Vector3(0.08, 0.92, 1.02), Vector3(-0.45, 0.45, 0), _material_for("metal"))
	_flat_box(root, Vector3(0.08, 0.92, 1.02), Vector3(0.45, 0.45, 0), _material_for("metal"))
	if world != null and world.has_method("register_streamed_loot"):
		world.call("register_streamed_loot", root.global_position, kind, key, root)

func _add_house_roof(root: Node3D, footprint: Vector2, roof_y: float, mat: Material) -> void:
	var roof_root := Node3D.new()
	roof_root.name = "Roof"
	roof_root.add_to_group("building_roof")
	root.add_child(roof_root)
	var half_width: float = footprint.x * 0.53
	var depth: float = footprint.y * 1.04
	var left: MeshInstance3D = _flat_box(roof_root, Vector3(half_width, 0.24, depth), Vector3(-footprint.x * 0.24, roof_y, 0), mat)
	left.rotation_degrees.z = -16.0
	var right: MeshInstance3D = _flat_box(roof_root, Vector3(half_width, 0.24, depth), Vector3(footprint.x * 0.24, roof_y, 0), mat)
	right.rotation_degrees.z = 16.0

func _add_flat_roof(root: Node3D, size: Vector3, roof_y: float, mat: Material) -> void:
	var roof_root := Node3D.new()
	roof_root.name = "Roof"
	roof_root.add_to_group("building_roof")
	root.add_child(roof_root)
	_flat_box(roof_root, size, Vector3(0, roof_y, 0), mat)
	_flat_box(roof_root, Vector3(size.x + 0.18, 0.15, 0.18), Vector3(0, roof_y + 0.15, -size.z * 0.5), _material_for("metal"))
	_flat_box(roof_root, Vector3(size.x + 0.18, 0.15, 0.18), Vector3(0, roof_y + 0.15, size.z * 0.5), _material_for("metal"))

func _add_roof_trigger(root: Node3D, trigger_size: Vector3, trigger_y: float) -> void:
	var roof: Node3D = root.get_node_or_null("Roof") as Node3D
	if roof == null:
		return
	var area := Area3D.new()
	area.name = "InteriorTrigger"
	area.add_to_group("building_interior_trigger")
	area.monitoring = true
	area.monitorable = true
	var shape := BoxShape3D.new()
	shape.size = trigger_size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0, trigger_y, 0)
	area.add_child(collision)
	root.add_child(area)
	area.body_entered.connect(_on_building_body_entered.bind(roof))
	area.body_exited.connect(_on_building_body_exited.bind(roof))

func _on_building_body_entered(body: Node3D, roof: Node3D) -> void:
	if body != null and body.is_in_group("player") and is_instance_valid(roof):
		roof.visible = false

func _on_building_body_exited(body: Node3D, roof: Node3D) -> void:
	if body != null and body.is_in_group("player") and is_instance_valid(roof):
		roof.visible = true

func get_city_debug_metrics() -> Dictionary:
	var result: Dictionary = super.get_city_debug_metrics()
	result["roofs"] = get_tree().get_nodes_in_group("building_roof").size()
	result["roof_triggers"] = get_tree().get_nodes_in_group("building_interior_trigger").size()
	result["vehicles"] = get_tree().get_nodes_in_group("vehicle").size()
	result["asphalt"] = get_tree().get_nodes_in_group("city_asphalt").size()
	return result
