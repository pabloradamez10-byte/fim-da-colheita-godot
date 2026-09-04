extends "res://scripts/world/city_chunk_streamer_3d_v057.gd"

func _build_city_sidewalks(parent: Node3D, origin: Vector3, local: Vector2i) -> void:
	super._build_city_sidewalks(parent, origin, local)
	var sidewalk: Material = _material_for("sidewalk")
	var curb: Material = _material_for("curb")

	# 0.5.8: fecha a quadra nos quatro lados. As vias continuam nas bordas leste/sul,
	# enquanto os lados oeste/norte recebem a calçada correspondente da quadra vizinha.
	var west_walk := _flat_box(parent, Vector3(SIDEWALK_WIDTH_057, 0.11, ROAD_START_057), origin + Vector3(SIDEWALK_WIDTH_057 * 0.5, 0.255, ROAD_START_057 * 0.5), sidewalk)
	west_walk.add_to_group("city_sidewalk")
	west_walk.add_to_group("four_side_sidewalk")
	var north_walk := _flat_box(parent, Vector3(ROAD_START_057, 0.11, SIDEWALK_WIDTH_057), origin + Vector3(ROAD_START_057 * 0.5, 0.26, SIDEWALK_WIDTH_057 * 0.5), sidewalk)
	north_walk.add_to_group("city_sidewalk")
	north_walk.add_to_group("four_side_sidewalk")
	var nw_corner := _flat_box(parent, Vector3(SIDEWALK_WIDTH_057, 0.11, SIDEWALK_WIDTH_057), origin + Vector3(SIDEWALK_WIDTH_057 * 0.5, 0.265, SIDEWALK_WIDTH_057 * 0.5), sidewalk)
	nw_corner.add_to_group("city_sidewalk")
	nw_corner.add_to_group("four_side_sidewalk")

	var west_curb := _flat_box(parent, Vector3(CURB_WIDTH_057, 0.20, ROAD_START_057), origin + Vector3(CURB_WIDTH_057 * 0.5, 0.31, ROAD_START_057 * 0.5), curb)
	west_curb.add_to_group("city_curb")
	west_curb.add_to_group("four_side_curb")
	var north_curb := _flat_box(parent, Vector3(ROAD_START_057, 0.20, CURB_WIDTH_057), origin + Vector3(ROAD_START_057 * 0.5, 0.315, CURB_WIDTH_057 * 0.5), curb)
	north_curb.add_to_group("city_curb")
	north_curb.add_to_group("four_side_curb")

func _build_city_lot(parent: Node3D, origin: Vector3, coord: Vector2i, local: Vector2i, marker: int) -> void:
	var lot_center := origin + Vector3(10.4, 0.0, 10.4)
	var face_east := marker % 2 == 0
	var jitter_x := float((marker % 5) - 2) * 0.22
	var jitter_z := float((int(marker / 7) % 5) - 2) * 0.22
	var building_pos := lot_center + Vector3(jitter_x, 0.0, jitter_z)
	var lot_kind := "building"

	if local == Vector2i(-1, -1):
		_build_market(parent, building_pos, coord)
	elif local == Vector2i(1, 1):
		_build_armory(parent, building_pos, coord)
	elif marker % 17 == 15:
		lot_kind = "parking"
		_build_parking_lot(parent, origin, coord, marker)
	elif marker % 17 == 16:
		lot_kind = "vacant"
		_build_vacant_lot(parent, origin, coord, marker)
	elif marker % 10 < 7:
		_build_house(parent, building_pos, coord, marker % 3)
	else:
		_build_garage(parent, building_pos, coord, marker % 2)

	if lot_kind == "building":
		var yaw := PI * 0.5 if face_east else 0.0
		for child in parent.get_children():
			if child is Node3D and child.is_in_group("city_building"):
				var building := child as Node3D
				if building.position.distance_to(building_pos) < 2.0:
					building.rotation.y = yaw
		_build_driveway(parent, origin, face_east, marker)
		_decorate_city_lot_057(parent, origin, face_east, marker)
	else:
		_decorate_open_lot_058(parent, origin, lot_kind, marker)

func _build_parking_lot(parent: Node3D, origin: Vector3, coord: Vector2i, marker: int) -> void:
	var lot := Node3D.new()
	lot.name = "ParkingLot_%d_%d" % [coord.x, coord.y]
	lot.add_to_group("city_lot")
	lot.add_to_group("open_lot")
	parent.add_child(lot)
	var slab := _flat_box(lot, Vector3(18.0, 0.08, 17.0), origin + Vector3(10.4, 0.19, 10.4), _material_for("asphalt_dark"))
	slab.add_to_group("parking_lot")
	for i in range(5):
		_flat_box(lot, Vector3(0.08, 0.03, 5.2), origin + Vector3(3.6 + float(i) * 3.15, 0.24, 10.2), _material_for("road_marking_white"))
	_build_vehicle(lot, origin + Vector3(5.8, 0.28, 8.8), 0.0, marker % 3, "parking058:%d:%d:a" % [coord.x, coord.y])
	if marker % 2 == 0:
		_build_vehicle(lot, origin + Vector3(12.8, 0.28, 12.0), 0.0, (marker + 1) % 3, "parking058:%d:%d:b" % [coord.x, coord.y])

func _build_vacant_lot(parent: Node3D, origin: Vector3, coord: Vector2i, marker: int) -> void:
	var lot := Node3D.new()
	lot.name = "VacantLot_%d_%d" % [coord.x, coord.y]
	lot.add_to_group("city_lot")
	lot.add_to_group("open_lot")
	parent.add_child(lot)
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 97 + marker
	for i in range(6):
		var p := origin + Vector3(rng_local.randf_range(2.2, 18.8), 0.16, rng_local.randf_range(2.2, 18.8))
		_ground_patch(lot, p, rng_local.randf_range(0.75, 1.8), rng_local.randf_range(0.40, 1.0), rng_local.randf_range(0.0, TAU), _material_for("dirt_dark"), "vacant_patch")
	for i in range(3):
		var bush := origin + Vector3(rng_local.randf_range(3.0, 18.0), 0.18, rng_local.randf_range(3.0, 18.0))
		_create_bush(lot, bush, rng_local.randf_range(0.50, 0.80))
	# Sem caixas, mesas ou bancadas soltas: lote vazio é vegetação/sucata, não "móvel sem casa".
	if marker % 2 == 0:
		var debris := Node3D.new()
		debris.position = origin + Vector3(9.0, 0.18, 8.0)
		debris.rotation.y = float(marker % 628) / 100.0
		debris.add_to_group("vacant_debris")
		lot.add_child(debris)
		_flat_box(debris, Vector3(1.5, 0.16, 0.28), Vector3.ZERO, _material_for("rust"))

func _decorate_open_lot_058(parent: Node3D, origin: Vector3, kind: String, marker: int) -> void:
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 3203 + marker
	# Cerca baixa contextualiza o espaço vazio/estacionamento e evita aparência de móveis abandonados sem prédio.
	for i in range(5):
		var x := 2.5 + float(i) * 3.7
		var post := Node3D.new()
		post.position = origin + Vector3(x, 0.0, 2.1)
		post.add_to_group("lot_fence")
		parent.add_child(post)
		_cylinder(post, 0.07, 1.0, Vector3(0, 0.5, 0), _material_for("fence_metal"), 7)
	if kind == "vacant" and marker % 3 == 0:
		var tree_pos := origin + Vector3(rng_local.randf_range(4.0, 17.0), 0.15, rng_local.randf_range(4.0, 17.0))
		_create_tree(parent, tree_pos, rng_local.randf_range(0.55, 0.75), false)

func get_city_debug_metrics() -> Dictionary:
	var result: Dictionary = super.get_city_debug_metrics()
	result["four_side_sidewalks"] = get_tree().get_nodes_in_group("four_side_sidewalk").size()
	result["four_side_curbs"] = get_tree().get_nodes_in_group("four_side_curb").size()
	result["open_lots"] = get_tree().get_nodes_in_group("open_lot").size()
	result["lot_fences"] = get_tree().get_nodes_in_group("lot_fence").size()
	return result
