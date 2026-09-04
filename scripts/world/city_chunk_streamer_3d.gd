extends "res://scripts/world/chunk_streamer_3d.gd"

const CITY_SPACING := 9
const CITY_RADIUS := 1
const STARTER_CITY_CENTER := Vector2i(4, 0)

func _generate_chunk(coord: Vector2i) -> void:
	super._generate_chunk(coord)
	var root := loaded_chunks.get(coord) as Node3D
	if root == null:
		return
	var city := _city_info(coord)
	if bool(city.get("city", false)):
		_build_city_chunk(root, coord, city)
	else:
		_build_rural_poi_if_needed(root, coord)

func _terrain_id(gx: int, gz: int, h: float, m: float) -> String:
	var coord := _cell_to_chunk(gx, gz)
	var city := _city_info(coord)
	if bool(city.get("city", false)):
		var local := city.get("local", Vector2i.ZERO) as Vector2i
		var lx := posmod(gx, CHUNK_CELLS)
		var lz := posmod(gz, CHUNK_CELLS)
		if (local.x == 0 and lx in [3,4]) or (local.y == 0 and lz in [3,4]):
			return "road"
		return "grass"
	# Estrada de ligação entre a fazenda e a primeira cidade, a leste.
	if gx >= BASE_HALF_CELLS and gx <= (STARTER_CITY_CENTER.x + 1) * CHUNK_CELLS and abs(gz) <= 1:
		return "road"
	return super._terrain_id(gx, gz, h, m)

func _generate_nature_cell(parent: Node3D, gx: int, gz: int, terrain_id: String) -> void:
	var coord := _cell_to_chunk(gx, gz)
	if bool(_city_info(coord).get("city", false)):
		return
	super._generate_nature_cell(parent, gx, gz, terrain_id)

func _cell_to_chunk(gx: int, gz: int) -> Vector2i:
	return Vector2i(floori(float(gx) / float(CHUNK_CELLS)), floori(float(gz) / float(CHUNK_CELLS)))

func _city_info(coord: Vector2i) -> Dictionary:
	if abs(coord.x - STARTER_CITY_CENTER.x) <= CITY_RADIUS and abs(coord.y - STARTER_CITY_CENTER.y) <= CITY_RADIUS:
		return {"city": true, "center": STARTER_CITY_CENTER, "local": coord - STARTER_CITY_CENTER, "starter": true}
	var sx := floori(float(coord.x) / float(CITY_SPACING))
	var sz := floori(float(coord.y) / float(CITY_SPACING))
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			var center := _sector_city_center(sx + dx, sz + dz)
			if abs(center.x) <= 2 and abs(center.y) <= 2:
				continue
			if abs(coord.x - center.x) <= CITY_RADIUS and abs(coord.y - center.y) <= CITY_RADIUS:
				return {"city": true, "center": center, "local": coord - center, "starter": false}
	return {"city": false}

func _sector_city_center(sx: int, sz: int) -> Vector2i:
	var marker := abs(hash("city:%d:%d:%d" % [world_seed, sx, sz]))
	var ox := 3 + marker % max(1, CITY_SPACING - 5)
	var oz := 3 + (marker / 17) % max(1, CITY_SPACING - 5)
	return Vector2i(sx * CITY_SPACING + ox, sz * CITY_SPACING + oz)

func _build_city_chunk(root: Node3D, coord: Vector2i, info: Dictionary) -> void:
	root.add_to_group("city_chunk")
	var local := info.get("local", Vector2i.ZERO) as Vector2i
	var origin := Vector3(coord.x * CHUNK_CELLS * CELL_SIZE, 0.25, coord.y * CHUNK_CELLS * CELL_SIZE)
	_build_city_sidewalks(root, origin, local)
	var marker := abs(hash("building:%d:%d:%d" % [world_seed, coord.x, coord.y]))
	var building_pos := _building_position(origin, local, marker)
	if local == Vector2i.ZERO:
		_build_market(root, building_pos, coord)
	elif local == Vector2i(1, 1):
		_build_armory(root, building_pos, coord)
	elif marker % 10 < 7:
		_build_house(root, building_pos, coord, marker % 3)
	else:
		_build_garage(root, building_pos, coord, marker % 2)
	_build_street_props(root, origin, marker)

func _building_position(origin: Vector3, local: Vector2i, marker: int) -> Vector3:
	var p := origin + Vector3(16.0, 0.0, 16.0)
	if local.x == 0:
		p.x += -7.0 if marker % 2 == 0 else 7.0
	elif local.y == 0:
		p.z += -7.0 if marker % 2 == 0 else 7.0
	return p

func _build_city_sidewalks(parent: Node3D, origin: Vector3, local: Vector2i) -> void:
	var stone := _material_for("stone_light")
	if local.x == 0:
		_flat_box(parent, Vector3(3.0, 0.08, 31.0), origin + Vector3(7.2, 0.14, 16.0), stone)
		_flat_box(parent, Vector3(3.0, 0.08, 31.0), origin + Vector3(24.8, 0.14, 16.0), stone)
	if local.y == 0:
		_flat_box(parent, Vector3(31.0, 0.08, 3.0), origin + Vector3(16.0, 0.14, 7.2), stone)
		_flat_box(parent, Vector3(31.0, 0.08, 3.0), origin + Vector3(16.0, 0.14, 24.8), stone)

func _build_house(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	var root := Node3D.new()
	root.name = "CityHouse_%d_%d" % [coord.x, coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	var wall_mat := _material_for("interior_wall") if variant % 2 == 0 else _material_for("wood_old")
	_solid_box(root, Vector3(10.5,0.22,8.5), Vector3(0,0.11,0), _material_for("interior_floor"), "HouseFloor")
	_solid_box(root, Vector3(10.5,2.9,0.28), Vector3(0,1.45,-4.15), wall_mat, "HouseBackWall")
	_solid_box(root, Vector3(0.28,2.9,8.5), Vector3(-5.1,1.45,0), wall_mat, "HouseLeftWall")
	_solid_box(root, Vector3(0.28,2.9,8.5), Vector3(5.1,1.45,0), wall_mat, "HouseRightWall")
	_solid_box(root, Vector3(3.7,2.9,0.28), Vector3(-3.25,1.45,4.15), wall_mat, "HouseFrontLeft")
	_solid_box(root, Vector3(3.7,2.9,0.28), Vector3(3.25,1.45,4.15), wall_mat, "HouseFrontRight")
	# Telhado parcial: mantém leitura externa sem esconder todo o interior na câmera isométrica.
	_flat_box(root, Vector3(4.4,0.22,9.0), Vector3(-3.0,3.15,0), _material_for("roof"))
	_flat_box(root, Vector3(4.4,0.22,9.0), Vector3(3.0,3.15,0), _material_for("roof"))
	_furniture_box(root, Vector3(2.2,0.55,1.0), Vector3(-3.1,0.52,-2.5), _material_for("wood"), "BedFrame")
	_furniture_box(root, Vector3(2.0,0.35,0.9), Vector3(-3.1,0.95,-2.5), _material_for("cloth"), "Bed")
	_furniture_box(root, Vector3(1.5,0.8,1.0), Vector3(0.5,0.55,-1.1), _material_for("wood"), "Table")
	_furniture_box(root, Vector3(0.9,1.8,0.9), Vector3(3.6,0.95,-2.5), _material_for("metal"), "Fridge")
	_create_loot_container(root, Vector3(3.5,0.75,2.7), "city_home", "city:%d:%d:home" % [coord.x,coord.y])

func _build_garage(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	var root := Node3D.new()
	root.name = "CityGarage_%d_%d" % [coord.x, coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	var wall := _material_for("rust") if variant == 0 else _material_for("wood_dark")
	_solid_box(root, Vector3(11.0,0.22,8.0), Vector3(0,0.11,0), _material_for("stone_light"), "GarageFloor")
	_solid_box(root, Vector3(11.0,3.1,0.25), Vector3(0,1.55,-3.9), wall, "GarageBack")
	_solid_box(root, Vector3(0.25,3.1,8.0), Vector3(-5.4,1.55,0), wall, "GarageLeft")
	_solid_box(root, Vector3(0.25,3.1,8.0), Vector3(5.4,1.55,0), wall, "GarageRight")
	_solid_box(root, Vector3(2.0,3.1,0.25), Vector3(-4.4,1.55,3.9), wall, "GarageFrontLeft")
	_solid_box(root, Vector3(2.0,3.1,0.25), Vector3(4.4,1.55,3.9), wall, "GarageFrontRight")
	_flat_box(root, Vector3(11.5,0.28,8.5), Vector3(0,3.35,0), _material_for("roof_rust"))
	_furniture_box(root, Vector3(4.0,0.85,0.9), Vector3(0,0.52,-2.7), _material_for("wood_dark"), "Workbench")
	_furniture_box(root, Vector3(0.55,2.2,2.8), Vector3(4.4,1.15,-1.4), _material_for("metal"), "GarageShelf")
	_create_loot_container(root, Vector3(-3.6,0.7,-1.8), "city_garage", "city:%d:%d:garage" % [coord.x,coord.y])

func _build_market(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	var root := Node3D.new()
	root.name = "CityMarket_%d_%d" % [coord.x,coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	_solid_box(root, Vector3(12.0,0.22,9.5), Vector3(0,0.11,0), _material_for("stone_light"), "MarketFloor")
	_solid_box(root, Vector3(12.0,3.2,0.25), Vector3(0,1.6,-4.6), _material_for("interior_wall"), "MarketBack")
	_solid_box(root, Vector3(0.25,3.2,9.5), Vector3(-5.9,1.6,0), _material_for("interior_wall"), "MarketLeft")
	_solid_box(root, Vector3(0.25,3.2,9.5), Vector3(5.9,1.6,0), _material_for("interior_wall"), "MarketRight")
	_solid_box(root, Vector3(4.2,3.2,0.25), Vector3(-3.9,1.6,4.6), _material_for("interior_wall"), "MarketFrontLeft")
	_solid_box(root, Vector3(4.2,3.2,0.25), Vector3(3.9,1.6,4.6), _material_for("interior_wall"), "MarketFrontRight")
	for z in [-2.3,0.0,2.0]:
		_furniture_box(root, Vector3(6.0,1.5,0.55), Vector3(0,0.8,z), _material_for("wood"), "MarketShelf")
	_furniture_box(root, Vector3(3.0,1.0,0.7), Vector3(-3.5,0.55,3.3), _material_for("wood_dark"), "Counter")
	_create_loot_container(root, Vector3(3.8,0.75,-3.0), "city_market", "city:%d:%d:market" % [coord.x,coord.y])

func _build_armory(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	var root := Node3D.new()
	root.name = "CityDepot_%d_%d" % [coord.x,coord.y]
	root.position = pos
	root.add_to_group("city_building")
	parent.add_child(root)
	_solid_box(root, Vector3(9.5,0.22,8.0), Vector3(0,0.11,0), _material_for("stone_light"), "DepotFloor")
	_solid_box(root, Vector3(9.5,3.0,0.25), Vector3(0,1.5,-3.9), _material_for("rust"), "DepotBack")
	_solid_box(root, Vector3(0.25,3.0,8.0), Vector3(-4.6,1.5,0), _material_for("rust"), "DepotLeft")
	_solid_box(root, Vector3(0.25,3.0,8.0), Vector3(4.6,1.5,0), _material_for("rust"), "DepotRight")
	_solid_box(root, Vector3(3.0,3.0,0.25), Vector3(-3.2,1.5,3.9), _material_for("rust"), "DepotFrontLeft")
	_solid_box(root, Vector3(3.0,3.0,0.25), Vector3(3.2,1.5,3.9), _material_for("rust"), "DepotFrontRight")
	_furniture_box(root, Vector3(0.6,2.0,4.5), Vector3(3.7,1.05,-0.8), _material_for("metal"), "DepotRack")
	_furniture_box(root, Vector3(3.2,0.9,0.8), Vector3(-1.8,0.5,-2.5), _material_for("wood_dark"), "DepotBench")
	_create_loot_container(root, Vector3(-3.4,0.72,1.8), "city_armory", "city:%d:%d:armory" % [coord.x,coord.y])

func _build_street_props(parent: Node3D, origin: Vector3, marker: int) -> void:
	for i in range(3):
		var x := 4.0 + float((marker / (i + 1)) % 24)
		var z := 4.0 + float((marker / (i + 3)) % 24)
		_furniture_box(parent, Vector3(0.45,1.0,0.45), origin + Vector3(x,0.55,z), _material_for("metal"), "StreetPost")

func _build_rural_poi_if_needed(parent: Node3D, coord: Vector2i) -> void:
	if abs(coord.x) <= 2 and abs(coord.y) <= 2:
		return
	var marker := abs(hash("rural:%d:%d:%d" % [world_seed, coord.x, coord.y])) % 100
	if marker >= 10:
		return
	var origin := Vector3(coord.x * CHUNK_CELLS * CELL_SIZE + 16.0, 0.25, coord.y * CHUNK_CELLS * CELL_SIZE + 16.0)
	if marker < 7:
		_build_rural_house(parent, origin, coord)
	else:
		_build_rural_garage(parent, origin, coord)

func _build_rural_house(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	var root := Node3D.new()
	root.name = "RuralHouse_%d_%d" % [coord.x,coord.y]
	root.position = pos
	root.add_to_group("rural_building")
	parent.add_child(root)
	_solid_box(root, Vector3(8.5,0.22,7.0), Vector3(0,0.11,0), _material_for("interior_floor"), "RuralFloor")
	_solid_box(root, Vector3(8.5,2.7,0.24), Vector3(0,1.35,-3.4), _material_for("wood_old"), "RuralBack")
	_solid_box(root, Vector3(0.24,2.7,7.0), Vector3(-4.1,1.35,0), _material_for("wood_old"), "RuralLeft")
	_solid_box(root, Vector3(0.24,2.7,7.0), Vector3(4.1,1.35,0), _material_for("wood_old"), "RuralRight")
	_solid_box(root, Vector3(2.8,2.7,0.24), Vector3(-2.8,1.35,3.4), _material_for("wood_old"), "RuralFrontL")
	_solid_box(root, Vector3(2.8,2.7,0.24), Vector3(2.8,1.35,3.4), _material_for("wood_old"), "RuralFrontR")
	_furniture_box(root, Vector3(1.7,0.8,0.8), Vector3(2.6,0.45,-2.2), _material_for("wood"), "RuralTable")
	_create_loot_container(root, Vector3(-2.7,0.7,-2.0), "rural_home", "rural:%d:%d:home" % [coord.x,coord.y])

func _build_rural_garage(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	var root := Node3D.new()
	root.name = "RuralGarage_%d_%d" % [coord.x,coord.y]
	root.position = pos
	root.add_to_group("rural_building")
	parent.add_child(root)
	_solid_box(root, Vector3(8.0,0.22,6.5), Vector3(0,0.11,0), _material_for("stone_light"), "RuralGarageFloor")
	_solid_box(root, Vector3(8.0,2.8,0.24), Vector3(0,1.4,-3.1), _material_for("rust"), "RuralGarageBack")
	_solid_box(root, Vector3(0.24,2.8,6.5), Vector3(-3.9,1.4,0), _material_for("rust"), "RuralGarageLeft")
	_solid_box(root, Vector3(0.24,2.8,6.5), Vector3(3.9,1.4,0), _material_for("rust"), "RuralGarageRight")
	_furniture_box(root, Vector3(3.0,0.8,0.8), Vector3(0,0.45,-2.2), _material_for("wood_dark"), "RuralWorkbench")
	_create_loot_container(root, Vector3(-2.5,0.7,1.6), "rural_garage", "rural:%d:%d:garage" % [coord.x,coord.y])

func _create_loot_container(parent: Node3D, pos: Vector3, kind: String, key: String) -> void:
	if world != null:
		var harvested_raw: Variant = world.get("harvested_keys")
		if harvested_raw is Array and (harvested_raw as Array).has(key):
			return
	var node := _solid_box(parent, Vector3(1.05,1.05,0.85), pos, _material_for("wood"), "LootContainer")
	node.add_to_group("loot_container")
	if world != null and world.has_method("register_streamed_loot"):
		world.call("register_streamed_loot", node.global_position, kind, key, node)

func _furniture_box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material, label: String) -> StaticBody3D:
	var node := _solid_box(parent, size, pos, mat, label)
	node.add_to_group("furniture")
	return node

func _solid_box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material, label: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	body.add_child(visual)
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	return body

func _flat_box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

func get_city_debug_metrics() -> Dictionary:
	var distance := -1
	if player != null and is_instance_valid(player):
		var city_pos := Vector3((STARTER_CITY_CENTER.x * CHUNK_CELLS + CHUNK_CELLS / 2.0) * CELL_SIZE, 0.0, (STARTER_CITY_CENTER.y * CHUNK_CELLS + CHUNK_CELLS / 2.0) * CELL_SIZE)
		distance = int(player.global_position.distance_to(city_pos))
	return {
		"chunks": loaded_chunks.size(),
		"city_buildings": get_tree().get_nodes_in_group("city_building").size(),
		"rural_buildings": get_tree().get_nodes_in_group("rural_building").size(),
		"furniture": get_tree().get_nodes_in_group("furniture").size(),
		"loot": get_tree().get_nodes_in_group("loot_container").size(),
		"city_distance": distance
	}

func debug_force_city_sample() -> Dictionary:
	for z in range(STARTER_CITY_CENTER.y - 1, STARTER_CITY_CENTER.y + 2):
		for x in range(STARTER_CITY_CENTER.x - 1, STARTER_CITY_CENTER.x + 2):
			var coord := Vector2i(x,z)
			if not loaded_chunks.has(coord):
				_generate_chunk(coord)
	return get_city_debug_metrics()
