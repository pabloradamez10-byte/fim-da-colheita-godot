extends "res://scripts/world/city_chunk_streamer_3d_v0514.gd"

func _build_large_house_0511(parent: Node3D, pos: Vector3, coord: Vector2i, slot: int, marker: int, yaw: float) -> void:
	super._build_large_house_0511(parent, pos, coord, slot, marker, yaw)
	var root := parent.get_node_or_null("CityHouse0511_%d_%d_%d" % [coord.x, coord.y, slot]) as Node3D
	if root == null:
		return
	_add_house_weathering_0515(root, marker)
	_add_house_roof_details_0515(root, marker)
	_add_house_side_details_0515(root, marker)

func _add_house_weathering_0515(root: Node3D, marker: int) -> void:
	var stain: Material = _material_for("wall_stain_0515")
	var moss: Material = _material_for("roof_moss_0515")
	# Manchas verticais quebram as fachadas grandes e limpas sem substituir as paredes funcionais.
	for i in range(4):
		var x := -5.6 + float(i) * 3.65 + float((marker + i) % 3) * 0.18
		var patch := _flat_box(root, Vector3(1.25 + float(i % 2) * 0.45, 0.035, 0.62), Vector3(x, 0.76 + float(i % 2) * 0.28, 6.195), stain)
		patch.rotation_degrees.x = 90.0
		patch.add_to_group("house_weathering_0515")
	for i in range(3):
		var z := -4.1 + float(i) * 3.7
		var side_patch := _flat_box(root, Vector3(1.05, 0.035, 0.72), Vector3(-7.31, 0.72 + float(i) * 0.13, z), stain)
		side_patch.rotation_degrees.z = 90.0
		side_patch.add_to_group("house_weathering_0515")
	# Musgo na base e próximo à varanda.
	for i in range(4):
		var ground_moss := _flat_box(root, Vector3(1.1 + float(i % 2) * 0.35, 0.025, 0.36), Vector3(-5.7 + float(i) * 3.6, 0.32, 6.30), moss)
		ground_moss.add_to_group("house_weathering_0515")

func _add_house_roof_details_0515(root: Node3D, marker: int) -> void:
	var roof := root.get_node_or_null("Roof") as Node3D
	if roof == null:
		return
	var metal: Material = _material_for("metal")
	var moss: Material = _material_for("roof_moss_0515")
	# Calhas, descida d'água e pequenos remendos acompanham o nó Roof e somem com o cutaway.
	for x in [-7.48, 7.48]:
		var gutter := _flat_box(roof, Vector3(0.12, 0.12, 13.05), Vector3(x, 3.18, 0), metal)
		gutter.add_to_group("roof_detail_0515")
	var downspout := _flat_box(roof, Vector3(0.10, 2.55, 0.10), Vector3(7.48, 1.92, 5.65), metal)
	downspout.add_to_group("roof_detail_0515")
	for i in range(3):
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * (2.25 + float(i) * 0.62)
		var y := 4.02 - absf(x) * 0.08
		var patch := _flat_box(roof, Vector3(1.15, 0.035, 1.10 + float(i) * 0.24), Vector3(x, y, -2.5 + float(i) * 2.15), moss)
		patch.rotation_degrees.z = 24.0 * side
		patch.add_to_group("roof_detail_0515")
	if marker % 3 == 0:
		var vent := Node3D.new()
		vent.position = Vector3(2.8, 4.18, -1.4)
		vent.add_to_group("roof_detail_0515")
		roof.add_child(vent)
		_cylinder(vent, 0.18, 0.52, Vector3.ZERO, metal, 10)

func _add_house_side_details_0515(root: Node3D, marker: int) -> void:
	var metal: Material = _material_for("metal")
	var wood: Material = _material_for("wood_bleached_0515")
	var box := _flat_box(root, Vector3(0.16, 0.85, 0.72), Vector3(7.33, 1.10, 2.55), metal)
	box.add_to_group("house_exterior_detail_0515")
	var pipe := _flat_box(root, Vector3(0.10, 1.65, 0.10), Vector3(7.36, 0.90, 1.75), metal)
	pipe.add_to_group("house_exterior_detail_0515")
	if marker % 2 == 0:
		for i in range(3):
			var board := _flat_box(root, Vector3(1.55, 0.08, 0.18), Vector3(-5.5 + float(i) * 0.22, 0.36 + float(i) * 0.10, -6.30), wood)
			board.rotation_degrees.y = -14.0 + float(i) * 8.0
			board.add_to_group("house_exterior_detail_0515")

func _decorate_residential_yard_0511(parent: Node3D, origin: Vector3, sub: Vector2i, marker: int) -> void:
	super._decorate_residential_yard_0511(parent, origin, sub, marker)
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 7717 + marker * 31 + sub.x * 7 + sub.y * 13
	# Vegetação rasteira e solo morto próximo às construções quebram o gramado uniforme.
	for i in range(6):
		var p := origin + Vector3(rng_local.randf_range(3.0, 20.0), 0.17, rng_local.randf_range(3.0, 20.0))
		_ground_patch(parent, p, rng_local.randf_range(0.32, 0.78), rng_local.randf_range(0.18, 0.48), rng_local.randf_range(0.0, TAU), _material_for("grass_dead_0515"), "yard_breakup_0515")
	# Pequena micro-história por lote: lixo, tábuas ou pneus abandonados.
	var clutter := Node3D.new()
	clutter.position = origin + Vector3(rng_local.randf_range(4.0, 19.0), 0.18, rng_local.randf_range(4.0, 19.0))
	clutter.rotation.y = rng_local.randf_range(0.0, TAU)
	clutter.add_to_group("environment_story_0515")
	parent.add_child(clutter)
	match marker % 3:
		0:
			_sphere(clutter, 0.36, Vector3(-0.28, 0.28, 0), _material_for("trash_dark_0515"), Vector3(1.0, 0.80, 0.85))
			_sphere(clutter, 0.30, Vector3(0.32, 0.24, 0.12), _material_for("trash_dark_0515"), Vector3(0.9, 0.72, 1.0))
		1:
			for i in range(3):
				var board := _flat_box(clutter, Vector3(1.45, 0.09, 0.18), Vector3(float(i) * 0.12, 0.08 + float(i) * 0.06, float(i) * 0.24), _material_for("wood_bleached_0515"))
				board.rotation.y = -0.28 + float(i) * 0.22
		2:
			for i in range(2):
				var tire_root := Node3D.new()
				tire_root.position = Vector3(0, 0.18 + float(i) * 0.24, 0)
				clutter.add_child(tire_root)
				_cylinder(tire_root, 0.42, 0.18, Vector3.ZERO, _material_for("trash_dark_0515"), 12)

func _add_city_surface_wear(parent: Node3D, origin: Vector3, marker: int) -> void:
	super._add_city_surface_wear(parent, origin, marker)
	var coord := _chunk_coord_from_origin(origin)
	var sub := _block_sub(coord)
	var asphalt: Material = _material_for("asphalt_dark")
	# Trincas finas e manchas irregulares somente onde realmente há rua.
	if sub.x == BLOCK_SPAN_0511 - 1:
		for i in range(3):
			var crack := _flat_box(parent, Vector3(0.07, 0.025, 1.4 + float(i) * 0.35), origin + Vector3(25.3 + float(i) * 1.7, 0.286, 6.0 + float((marker + i * 5) % 13)), asphalt)
			crack.rotation.y = -0.35 + float(i) * 0.28
			crack.add_to_group("road_crack_0515")
	if sub.y == BLOCK_SPAN_0511 - 1:
		for i in range(3):
			var crack_h := _flat_box(parent, Vector3(1.4 + float(i) * 0.35, 0.025, 0.07), origin + Vector3(5.5 + float((marker + i * 7) % 13), 0.291, 25.4 + float(i) * 1.65), asphalt)
			crack_h.rotation.y = 0.25 - float(i) * 0.18
			crack_h.add_to_group("road_crack_0515")

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["house_weathering_0515"] = get_tree().get_nodes_in_group("house_weathering_0515").size()
	result["roof_details_0515"] = get_tree().get_nodes_in_group("roof_detail_0515").size()
	result["exterior_details_0515"] = get_tree().get_nodes_in_group("house_exterior_detail_0515").size()
	result["yard_breakup_0515"] = get_tree().get_nodes_in_group("yard_breakup_0515").size()
	result["environment_story_0515"] = get_tree().get_nodes_in_group("environment_story_0515").size()
	result["road_cracks_0515"] = get_tree().get_nodes_in_group("road_crack_0515").size()
	return result
