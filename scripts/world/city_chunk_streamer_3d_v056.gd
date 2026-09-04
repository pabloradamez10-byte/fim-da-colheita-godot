extends "res://scripts/world/city_chunk_streamer_3d_v055.gd"

const CITY_RADIUS_056 := 2

func _city_info(coord: Vector2i) -> Dictionary:
	if abs(coord.x - STARTER_CITY_CENTER.x) <= CITY_RADIUS_056 and abs(coord.y - STARTER_CITY_CENTER.y) <= CITY_RADIUS_056:
		return {"city": true, "center": STARTER_CITY_CENTER, "local": coord - STARTER_CITY_CENTER, "starter": true}
	var sx: int = floori(float(coord.x) / float(CITY_SPACING))
	var sz: int = floori(float(coord.y) / float(CITY_SPACING))
	for dz in range(-1, 2):
		for dx in range(-1, 2):
			var center: Vector2i = _sector_city_center(sx + dx, sz + dz)
			if abs(center.x) <= 2 and abs(center.y) <= 2:
				continue
			if abs(coord.x - center.x) <= CITY_RADIUS_056 and abs(coord.y - center.y) <= CITY_RADIUS_056:
				return {"city": true, "center": center, "local": coord - center, "starter": false}
	return {"city": false}

func _generate_chunk(coord: Vector2i) -> void:
	super._generate_chunk(coord)
	var root := loaded_chunks.get(coord) as Node3D
	if root != null and is_instance_valid(root):
		_add_organic_ground_patches(root, coord)

func _build_city_chunk(root: Node3D, coord: Vector2i, info: Dictionary) -> void:
	root.add_to_group("city_chunk")
	var local: Vector2i = info.get("local", Vector2i.ZERO) as Vector2i
	var origin := Vector3(coord.x * CHUNK_CELLS * CELL_SIZE, 0.25, coord.y * CHUNK_CELLS * CELL_SIZE)
	_build_city_sidewalks(root, origin, local)
	var marker: int = int(abs(hash("building056:%d:%d:%d" % [world_seed, coord.x, coord.y])))

	# Regra urbana nova: os chunks do eixo X/Z são exclusivamente ruas.
	# Prédios só podem nascer nos lotes, nunca no asfalto ou cruzamento.
	if local.x == 0 or local.y == 0:
		_build_street_props(root, origin, marker)
		_build_roadside_debris(root, origin, local, marker)
		return

	var building_pos := origin + Vector3(16.0, 0.0, 16.0)
	if local == Vector2i(-1, -1):
		_build_market(root, building_pos, coord)
	elif local == Vector2i(1, 1):
		_build_armory(root, building_pos, coord)
	elif marker % 10 < 7:
		_build_house(root, building_pos, coord, marker % 3)
	else:
		_build_garage(root, building_pos, coord, marker % 2)

	_orient_building_toward_road(root, local)
	_decorate_city_lot(root, origin, local, marker)

func _orient_building_toward_road(chunk_root: Node3D, local: Vector2i) -> void:
	for child in chunk_root.get_children():
		if child is Node3D and child.is_in_group("city_building"):
			var building := child as Node3D
			if abs(local.x) <= abs(local.y):
				building.rotation.y = PI * 0.5 if local.x < 0 else -PI * 0.5
			else:
				building.rotation.y = 0.0 if local.y < 0 else PI

func _decorate_city_lot(parent: Node3D, origin: Vector3, local: Vector2i, marker: int) -> void:
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 911 + marker
	# Caminho/entrada irregular até a rua mais próxima.
	for i in range(4):
		var p := origin + Vector3(rng_local.randf_range(4.0, 28.0), 0.30, rng_local.randf_range(4.0, 28.0))
		_ground_patch(parent, p, rng_local.randf_range(0.9, 2.4), rng_local.randf_range(0.55, 1.25), rng_local.randf_range(0.0, TAU), _material_for("dirt_patch"), "lot_patch")
	# Pequenos elementos para quebrar a silhueta perfeitamente quadrada do lote.
	for i in range(2):
		var bush_pos := origin + Vector3(rng_local.randf_range(3.0, 29.0), 0.18, rng_local.randf_range(3.0, 29.0))
		_create_bush(parent, bush_pos, rng_local.randf_range(0.55, 0.82))
	var barrel := Node3D.new()
	barrel.position = origin + Vector3(4.2 if local.x > 0 else 27.8, 0.0, 5.0 if local.y > 0 else 27.0)
	barrel.add_to_group("city_prop")
	parent.add_child(barrel)
	_cylinder(barrel, 0.42, 0.90, Vector3(0, 0.45, 0), _material_for("rust"), 10)

func _build_roadside_debris(parent: Node3D, origin: Vector3, local: Vector2i, marker: int) -> void:
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 617 + marker
	for i in range(3):
		var p := origin + Vector3(rng_local.randf_range(4.0, 28.0), 0.32, rng_local.randf_range(4.0, 28.0))
		_ground_patch(parent, p, rng_local.randf_range(0.7, 1.7), rng_local.randf_range(0.35, 0.8), rng_local.randf_range(0.0, TAU), _material_for("asphalt_dark"), "road_wear")
	if marker % 3 == 0:
		var debris := Node3D.new()
		debris.position = origin + Vector3(6.0 + float(marker % 18), 0.3, 6.0 + float(int(marker / 7) % 18))
		debris.rotation.y = float(marker % 628) / 100.0
		debris.add_to_group("city_prop")
		parent.add_child(debris)
		_flat_box(debris, Vector3(1.2, 0.18, 0.35), Vector3.ZERO, _material_for("rust"))

func _add_organic_ground_patches(parent: Node3D, coord: Vector2i) -> void:
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 1777 + coord.x * 92821 + coord.y * 68917
	var info: Dictionary = _city_info(coord)
	var count := 4 if bool(info.get("city", false)) else 3
	for i in range(count):
		var px := coord.x * CHUNK_CELLS * CELL_SIZE + rng_local.randf_range(2.0, 30.0)
		var pz := coord.y * CHUNK_CELLS * CELL_SIZE + rng_local.randf_range(2.0, 30.0)
		var mat: Material = _material_for("dirt_patch")
		var y := 0.145
		if bool(info.get("city", false)):
			var local: Vector2i = info.get("local", Vector2i.ZERO) as Vector2i
			if local.x == 0 or local.y == 0:
				mat = _material_for("asphalt_dark")
				y = 0.275
			else:
				mat = _material_for("grass_dark") if i % 2 == 0 else _material_for("dirt_patch")
		else:
			mat = _material_for("grass_dark") if i % 2 == 0 else _material_for("dirt_patch")
		_ground_patch(parent, Vector3(px, y, pz), rng_local.randf_range(0.75, 2.25), rng_local.randf_range(0.45, 1.25), rng_local.randf_range(0.0, TAU), mat, "organic_ground_patch")

func _ground_patch(parent: Node3D, pos: Vector3, radius_x: float, radius_z: float, yaw: float, mat: Material, group_name: String) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = 0.035
	mesh.radial_segments = 12
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.rotation.y = yaw
	node.scale = Vector3(radius_x, 1.0, radius_z)
	node.add_to_group(group_name)
	parent.add_child(node)
	return node

func _build_house(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	super._build_house(parent, pos, coord, variant)
	var root := parent.get_node_or_null("CityHouse_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	# Varanda, janelas e chaminé deixam a casa menos parecida com um bloco.
	_solid_box(root, Vector3(4.6, 0.18, 1.55), Vector3(0, 0.18, 4.85), _material_for("wood_old"), "Porch")
	_solid_box(root, Vector3(2.7, 0.18, 0.8), Vector3(0, 0.36, 5.45), _material_for("wood_dark"), "PorchStep")
	_flat_box(root, Vector3(2.1, 1.15, 0.06), Vector3(-2.6, 1.65, 4.32), _material_for("glass_dark"))
	_flat_box(root, Vector3(2.1, 1.15, 0.06), Vector3(2.6, 1.65, 4.32), _material_for("glass_dark"))
	_solid_box(root, Vector3(0.65, 1.65, 0.65), Vector3(-3.0, 3.65, -1.5), _material_for("rust"), "Chimney")

func _add_house_roof(root: Node3D, footprint: Vector2, roof_y: float, mat: Material) -> void:
	var roof_root := Node3D.new()
	roof_root.name = "Roof"
	roof_root.add_to_group("building_roof")
	root.add_child(roof_root)
	var angle_deg := 24.0
	var angle := deg_to_rad(angle_deg)
	var run := footprint.x * 0.5 + 0.48
	var panel_length := run / cos(angle)
	var rise := run * tan(angle)
	var depth := footprint.y + 0.75
	var left := _flat_box(roof_root, Vector3(panel_length, 0.18, depth), Vector3(-run * 0.5, roof_y + rise * 0.5, 0), mat)
	left.rotation_degrees.z = angle_deg
	var right := _flat_box(roof_root, Vector3(panel_length, 0.18, depth), Vector3(run * 0.5, roof_y + rise * 0.5, 0), mat)
	right.rotation_degrees.z = -angle_deg
	_flat_box(roof_root, Vector3(0.22, 0.20, depth + 0.12), Vector3(0, roof_y + rise, 0), _material_for("metal"))

func _add_flat_roof(root: Node3D, size: Vector3, roof_y: float, mat: Material) -> void:
	var roof_root := Node3D.new()
	roof_root.name = "Roof"
	roof_root.add_to_group("building_roof")
	root.add_child(roof_root)
	_flat_box(roof_root, Vector3(size.x, 0.20, size.z), Vector3(0, roof_y, 0), mat)
	# Pequena platibanda/ventilação para tirar a aparência de uma simples tampa.
	_flat_box(roof_root, Vector3(size.x, 0.18, 0.18), Vector3(0, roof_y + 0.15, -size.z * 0.5), _material_for("metal"))
	_flat_box(roof_root, Vector3(size.x, 0.18, 0.18), Vector3(0, roof_y + 0.15, size.z * 0.5), _material_for("metal"))
	var vent := Node3D.new()
	vent.position = Vector3(size.x * 0.28, roof_y + 0.34, -size.z * 0.18)
	roof_root.add_child(vent)
	_cylinder(vent, 0.22, 0.55, Vector3.ZERO, _material_for("metal"), 10)

func get_city_debug_metrics() -> Dictionary:
	var result: Dictionary = super.get_city_debug_metrics()
	var road_buildings := 0
	for raw_node in get_tree().get_nodes_in_group("city_building"):
		if raw_node is Node3D:
			var building := raw_node as Node3D
			var coord := _world_to_chunk(building.global_position)
			var info := _city_info(coord)
			if bool(info.get("city", false)):
				var local := info.get("local", Vector2i.ZERO) as Vector2i
				if local.x == 0 or local.y == 0:
					road_buildings += 1
	result["road_buildings"] = road_buildings
	result["organic_patches"] = get_tree().get_nodes_in_group("organic_ground_patch").size()
	result["road_wear"] = get_tree().get_nodes_in_group("road_wear").size()
	result["city_props"] = get_tree().get_nodes_in_group("city_prop").size()
	return result

func debug_force_city_sample() -> Dictionary:
	for z in range(STARTER_CITY_CENTER.y - CITY_RADIUS_056, STARTER_CITY_CENTER.y + CITY_RADIUS_056 + 1):
		for x in range(STARTER_CITY_CENTER.x - CITY_RADIUS_056, STARTER_CITY_CENTER.x + CITY_RADIUS_056 + 1):
			var coord := Vector2i(x, z)
			if not loaded_chunks.has(coord):
				_generate_chunk(coord)
	return get_city_debug_metrics()
