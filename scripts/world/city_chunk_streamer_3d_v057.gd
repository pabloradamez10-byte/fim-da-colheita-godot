extends "res://scripts/world/city_chunk_streamer_3d_v056.gd"

const CHUNK_WORLD_057 := 32.0
const LOT_LIMIT_057 := 21.0
const ROAD_START_057 := 23.25
const ROAD_WIDTH_057 := 8.75
const ROAD_CENTER_057 := 27.625
const SIDEWALK_WIDTH_057 := 2.0
const SIDEWALK_CENTER_057 := 22.15
const CURB_WIDTH_057 := 0.26

func _terrain_id(gx: int, gz: int, h: float, m: float) -> String:
	var coord: Vector2i = _cell_to_chunk(gx, gz)
	var city: Dictionary = _city_info(coord)
	if bool(city.get("city", false)):
		# O asfalto urbano passa a ser uma malha contínua desenhada por meshes.
		# A base do lote continua gramada para eliminar buracos/células cinzas entre vias.
		return "grass"
	return super._terrain_id(gx, gz, h, m)

func _build_city_chunk(root: Node3D, coord: Vector2i, info: Dictionary) -> void:
	root.add_to_group("city_chunk")
	var local: Vector2i = info.get("local", Vector2i.ZERO) as Vector2i
	var origin := Vector3(coord.x * CHUNK_CELLS * CELL_SIZE, 0.25, coord.y * CHUNK_CELLS * CELL_SIZE)
	var marker: int = int(abs(hash("building057:%d:%d:%d" % [world_seed, coord.x, coord.y])))

	_build_city_sidewalks(root, origin, local)
	_build_street_props(root, origin, marker)
	_build_city_lot(root, origin, coord, local, marker)
	_add_city_surface_wear(root, origin, marker)

func _build_city_sidewalks(parent: Node3D, origin: Vector3, _local: Vector2i) -> void:
	var asphalt: Material = _material_for("asphalt")
	var sidewalk: Material = _material_for("sidewalk")
	var curb: Material = _material_for("curb")
	var yellow: Material = _material_for("road_marking_yellow")
	var white: Material = _material_for("road_marking_white")

	# Cada chunk urbano é uma quadra: rua contínua na borda leste e sul.
	# Como todos os chunks usam a mesma regra, as vias se conectam sem lacunas.
	var road_v := _flat_box(parent, Vector3(ROAD_WIDTH_057, 0.10, CHUNK_WORLD_057 + 0.18), origin + Vector3(ROAD_CENTER_057, 0.20, 16.0), asphalt)
	road_v.add_to_group("city_asphalt")
	road_v.add_to_group("street_grid")
	var road_h := _flat_box(parent, Vector3(CHUNK_WORLD_057 + 0.18, 0.10, ROAD_WIDTH_057), origin + Vector3(16.0, 0.205, ROAD_CENTER_057), asphalt)
	road_h.add_to_group("city_asphalt")
	road_h.add_to_group("street_grid")

	# Calçadas param antes da interseção e se unem num canto próprio; não atravessam o asfalto.
	var sidewalk_v := _flat_box(parent, Vector3(SIDEWALK_WIDTH_057, 0.11, ROAD_START_057), origin + Vector3(SIDEWALK_CENTER_057, 0.255, ROAD_START_057 * 0.5), sidewalk)
	sidewalk_v.add_to_group("city_sidewalk")
	var sidewalk_h := _flat_box(parent, Vector3(ROAD_START_057, 0.11, SIDEWALK_WIDTH_057), origin + Vector3(ROAD_START_057 * 0.5, 0.26, SIDEWALK_CENTER_057), sidewalk)
	sidewalk_h.add_to_group("city_sidewalk")
	var sidewalk_corner := _flat_box(parent, Vector3(SIDEWALK_WIDTH_057, 0.11, SIDEWALK_WIDTH_057), origin + Vector3(SIDEWALK_CENTER_057, 0.265, SIDEWALK_CENTER_057), sidewalk)
	sidewalk_corner.add_to_group("city_sidewalk")

	var curb_v := _flat_box(parent, Vector3(CURB_WIDTH_057, 0.20, ROAD_START_057), origin + Vector3(ROAD_START_057 - CURB_WIDTH_057 * 0.5, 0.31, ROAD_START_057 * 0.5), curb)
	curb_v.add_to_group("city_curb")
	var curb_h := _flat_box(parent, Vector3(ROAD_START_057, 0.20, CURB_WIDTH_057), origin + Vector3(ROAD_START_057 * 0.5, 0.315, ROAD_START_057 - CURB_WIDTH_057 * 0.5), curb)
	curb_h.add_to_group("city_curb")

	# Faixas descontínuas: terminam antes da interseção, sem formar o “X amarelo” da 0.5.6.
	for i in range(6):
		var along := 2.2 + float(i) * 3.25
		var dash_v := _flat_box(parent, Vector3(0.16, 0.035, 1.55), origin + Vector3(ROAD_CENTER_057, 0.285, along), yellow)
		dash_v.add_to_group("lane_marking")
		var dash_h := _flat_box(parent, Vector3(1.55, 0.035, 0.16), origin + Vector3(along, 0.29, ROAD_CENTER_057), yellow)
		dash_h.add_to_group("lane_marking")

	var edge_v := _flat_box(parent, Vector3(0.10, 0.035, 20.8), origin + Vector3(ROAD_START_057 + 0.55, 0.286, 10.4), white)
	edge_v.add_to_group("lane_marking")
	var edge_h := _flat_box(parent, Vector3(20.8, 0.035, 0.10), origin + Vector3(10.4, 0.291, ROAD_START_057 + 0.55), white)
	edge_h.add_to_group("lane_marking")

	# Faixas de pedestre simples antes do cruzamento.
	for i in range(4):
		var cross_offset := 24.2 + float(i) * 1.55
		var cross_v := _flat_box(parent, Vector3(0.85, 0.04, 0.34), origin + Vector3(cross_offset, 0.295, 21.25), white)
		cross_v.add_to_group("crosswalk")
		var cross_h := _flat_box(parent, Vector3(0.34, 0.04, 0.85), origin + Vector3(21.25, 0.30, cross_offset), white)
		cross_h.add_to_group("crosswalk")

func _build_city_lot(parent: Node3D, origin: Vector3, coord: Vector2i, local: Vector2i, marker: int) -> void:
	var lot_center := origin + Vector3(10.4, 0.0, 10.4)
	var face_east := marker % 2 == 0
	var jitter_x := float((marker % 5) - 2) * 0.28
	var jitter_z := float((int(marker / 7) % 5) - 2) * 0.28
	var building_pos := lot_center + Vector3(jitter_x, 0.0, jitter_z)

	# Posições especiais garantem variedade de POIs sem quebrar a malha viária.
	if local == Vector2i(-1, -1):
		_build_market(parent, building_pos, coord)
	elif local == Vector2i(1, 1):
		_build_armory(parent, building_pos, coord)
	elif marker % 13 == 11:
		_build_parking_lot(parent, origin, coord, marker)
	elif marker % 13 == 12:
		_build_vacant_lot(parent, origin, coord, marker)
	elif marker % 10 < 7:
		_build_house(parent, building_pos, coord, marker % 3)
	else:
		_build_garage(parent, building_pos, coord, marker % 2)

	var yaw := PI * 0.5 if face_east else 0.0
	for child in parent.get_children():
		if child is Node3D and child.is_in_group("city_building"):
			var building := child as Node3D
			if building.position.distance_to(building_pos) < 2.0:
				building.rotation.y = yaw

	_build_driveway(parent, origin, face_east, marker)
	_decorate_city_lot_057(parent, origin, face_east, marker)

func _build_driveway(parent: Node3D, origin: Vector3, face_east: bool, marker: int) -> void:
	var mat: Material = _material_for("driveway") if marker % 3 != 0 else _material_for("dirt_dark")
	var driveway: MeshInstance3D
	if face_east:
		driveway = _flat_box(parent, Vector3(8.4, 0.07, 3.2), origin + Vector3(17.0, 0.285, 10.5), mat)
	else:
		driveway = _flat_box(parent, Vector3(3.2, 0.07, 8.4), origin + Vector3(10.5, 0.285, 17.0), mat)
	driveway.add_to_group("lot_driveway")

func _decorate_city_lot_057(parent: Node3D, origin: Vector3, face_east: bool, marker: int) -> void:
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 2221 + marker
	for i in range(3):
		var p := origin + Vector3(rng_local.randf_range(2.0, 19.0), 0.16, rng_local.randf_range(2.0, 19.0))
		_ground_patch(parent, p, rng_local.randf_range(0.65, 1.7), rng_local.randf_range(0.40, 1.0), rng_local.randf_range(0.0, TAU), _material_for("dirt_patch"), "lot_patch")
	if marker % 3 != 1:
		var bush_pos := origin + Vector3(rng_local.randf_range(2.0, 6.0), 0.18, rng_local.randf_range(14.0, 19.0))
		_create_bush(parent, bush_pos, rng_local.randf_range(0.52, 0.78))
	if marker % 5 == 0:
		var tree_pos := origin + Vector3(rng_local.randf_range(2.4, 5.6), 0.15, rng_local.randf_range(2.4, 6.0))
		_create_tree(parent, tree_pos, rng_local.randf_range(0.62, 0.82), false)

	# Caixa de correio e lixeira dão escala ao lote e quebram o aspecto de cubos soltos.
	var mailbox := Node3D.new()
	mailbox.position = origin + (Vector3(20.0, 0.0, 17.5) if face_east else Vector3(17.5, 0.0, 20.0))
	mailbox.add_to_group("city_prop")
	parent.add_child(mailbox)
	_cylinder(mailbox, 0.09, 1.05, Vector3(0, 0.52, 0), _material_for("fence_metal"), 8)
	_solid_box(mailbox, Vector3(0.50, 0.35, 0.32), Vector3(0, 1.05, 0), _material_for("metal"), "Mailbox")

	if marker % 2 == 0:
		var trash := Node3D.new()
		trash.position = origin + Vector3(18.5, 0.0, 18.7)
		trash.add_to_group("city_prop")
		parent.add_child(trash)
		_cylinder(trash, 0.34, 0.85, Vector3(0, 0.43, 0), _material_for("trash"), 10)

func _build_street_props(parent: Node3D, origin: Vector3, marker: int) -> void:
	# Poste sempre nasce na calçada, nunca no asfalto nem no lote.
	var post := Node3D.new()
	post.position = origin + Vector3(21.8, 0.0, 3.4 + float(marker % 13))
	post.add_to_group("city_prop")
	parent.add_child(post)
	_cylinder(post, 0.11, 3.9, Vector3(0, 1.95, 0), _material_for("fence_metal"), 8)
	_flat_box(post, Vector3(0.75, 0.10, 0.28), Vector3(0.32, 3.82, 0), _material_for("road_marking_white"))

	# Veículos estacionados junto ao meio-fio; não ocupam o centro dos cruzamentos.
	if marker % 3 == 0:
		var z := 6.0 + float(marker % 10)
		_build_vehicle(parent, origin + Vector3(26.0, 0.28, z), 0.0, marker % 3, "vehicle057:%d:%d:v" % [int(origin.x), int(origin.z)])
	elif marker % 3 == 1:
		var x := 6.0 + float(marker % 10)
		_build_vehicle(parent, origin + Vector3(x, 0.28, 26.0), PI * 0.5, marker % 3, "vehicle057:%d:%d:h" % [int(origin.x), int(origin.z)])

func _add_city_surface_wear(parent: Node3D, origin: Vector3, marker: int) -> void:
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 401 + marker
	for i in range(2):
		var wear_v := origin + Vector3(rng_local.randf_range(24.2, 30.8), 0.272, rng_local.randf_range(3.0, 20.0))
		_ground_patch(parent, wear_v, rng_local.randf_range(0.35, 0.85), rng_local.randf_range(0.20, 0.55), rng_local.randf_range(0.0, TAU), _material_for("asphalt_dark"), "road_wear")
		var wear_h := origin + Vector3(rng_local.randf_range(3.0, 20.0), 0.276, rng_local.randf_range(24.2, 30.8))
		_ground_patch(parent, wear_h, rng_local.randf_range(0.35, 0.85), rng_local.randf_range(0.20, 0.55), rng_local.randf_range(0.0, TAU), _material_for("asphalt_dark"), "road_wear")

func _add_organic_ground_patches(parent: Node3D, coord: Vector2i) -> void:
	var info: Dictionary = _city_info(coord)
	if not bool(info.get("city", false)):
		super._add_organic_ground_patches(parent, coord)
		return
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 1777 + coord.x * 92821 + coord.y * 68917
	var origin := Vector3(coord.x * CHUNK_CELLS * CELL_SIZE, 0.0, coord.y * CHUNK_CELLS * CELL_SIZE)
	for i in range(4):
		var p := origin + Vector3(rng_local.randf_range(1.5, 19.5), 0.145, rng_local.randf_range(1.5, 19.5))
		var mat := _material_for("grass_dark") if i % 2 == 0 else _material_for("dirt_patch")
		_ground_patch(parent, p, rng_local.randf_range(0.65, 1.55), rng_local.randf_range(0.35, 0.95), rng_local.randf_range(0.0, TAU), mat, "organic_ground_patch")

func _build_house(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	super._build_house(parent, pos, coord, variant)
	var root := parent.get_node_or_null("CityHouse_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	# Rodapé e beiral dão mais leitura ao volume e aproximam de uma casa isométrica acabada.
	_flat_box(root, Vector3(10.2, 0.35, 0.12), Vector3(0, 0.42, 4.31), _material_for("brick_dark"))
	_flat_box(root, Vector3(10.2, 0.22, 0.25), Vector3(0, 2.84, 4.35), _material_for("wood_dark"))

func _build_market(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_market(parent, pos, coord)
	var root := parent.get_node_or_null("CityMarket_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	_flat_box(root, Vector3(8.0, 0.22, 1.25), Vector3(0, 2.55, 5.15), _material_for("brick"))
	_flat_box(root, Vector3(4.6, 0.18, 0.90), Vector3(0, 2.25, 5.35), _material_for("roof_shingle"))

func _build_garage(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	super._build_garage(parent, pos, coord, variant)
	var root := parent.get_node_or_null("CityGarage_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	_flat_box(root, Vector3(5.9, 2.45, 0.10), Vector3(0, 1.45, 4.04), _material_for("metal"))
	for i in range(4):
		_flat_box(root, Vector3(5.4, 0.06, 0.05), Vector3(0, 0.58 + float(i) * 0.52, 4.10), _material_for("fence_metal"))

func _build_armory(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_armory(parent, pos, coord)
	var root := parent.get_node_or_null("CityDepot_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	_flat_box(root, Vector3(6.2, 0.28, 0.18), Vector3(0, 2.62, 4.08), _material_for("brick_dark"))

func _build_parking_lot(parent: Node3D, origin: Vector3, coord: Vector2i, marker: int) -> void:
	var lot := Node3D.new()
	lot.name = "ParkingLot_%d_%d" % [coord.x, coord.y]
	lot.add_to_group("city_lot")
	parent.add_child(lot)
	var slab := _flat_box(lot, Vector3(18.0, 0.08, 17.0), origin + Vector3(10.4, 0.19, 10.4), _material_for("asphalt_dark"))
	slab.add_to_group("parking_lot")
	for i in range(4):
		_flat_box(lot, Vector3(0.08, 0.03, 5.2), origin + Vector3(4.4 + float(i) * 3.4, 0.24, 10.2), _material_for("road_marking_white"))
	_build_vehicle(lot, origin + Vector3(6.1, 0.28, 9.0), 0.0, marker % 3, "parking:%d:%d:a" % [coord.x, coord.y])
	if marker % 2 == 0:
		_build_vehicle(lot, origin + Vector3(13.3, 0.28, 12.0), 0.0, (marker + 1) % 3, "parking:%d:%d:b" % [coord.x, coord.y])
	_create_loot_container(lot, origin + Vector3(3.0, 0.72, 3.0), "city_garage", "parking:%d:%d:loot" % [coord.x, coord.y])

func _build_vacant_lot(parent: Node3D, origin: Vector3, coord: Vector2i, marker: int) -> void:
	var lot := Node3D.new()
	lot.name = "VacantLot_%d_%d" % [coord.x, coord.y]
	lot.add_to_group("city_lot")
	parent.add_child(lot)
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 97 + marker
	for i in range(5):
		var p := origin + Vector3(rng_local.randf_range(2.0, 19.0), 0.16, rng_local.randf_range(2.0, 19.0))
		_ground_patch(lot, p, rng_local.randf_range(0.8, 2.0), rng_local.randf_range(0.45, 1.1), rng_local.randf_range(0.0, TAU), _material_for("dirt_dark"), "vacant_patch")
	for i in range(2):
		var bush := origin + Vector3(rng_local.randf_range(3.0, 18.0), 0.18, rng_local.randf_range(3.0, 18.0))
		_create_bush(lot, bush, rng_local.randf_range(0.55, 0.85))
	_create_loot_container(lot, origin + Vector3(9.5, 0.72, 8.5), "city_garage", "vacant:%d:%d:loot" % [coord.x, coord.y])

func get_city_debug_metrics() -> Dictionary:
	var result: Dictionary = super.get_city_debug_metrics()
	var road_conflicts := 0
	for raw_node in get_tree().get_nodes_in_group("city_building"):
		if raw_node is Node3D:
			var building := raw_node as Node3D
			var lx := fposmod(building.global_position.x, CHUNK_WORLD_057)
			var lz := fposmod(building.global_position.z, CHUNK_WORLD_057)
			if lx > LOT_LIMIT_057 or lz > LOT_LIMIT_057:
				road_conflicts += 1
	result["road_buildings"] = road_conflicts
	result["street_grid"] = get_tree().get_nodes_in_group("street_grid").size()
	result["sidewalks"] = get_tree().get_nodes_in_group("city_sidewalk").size()
	result["curbs"] = get_tree().get_nodes_in_group("city_curb").size()
	result["crosswalks"] = get_tree().get_nodes_in_group("crosswalk").size()
	result["driveways"] = get_tree().get_nodes_in_group("lot_driveway").size()
	result["parking_lots"] = get_tree().get_nodes_in_group("parking_lot").size()
	return result
