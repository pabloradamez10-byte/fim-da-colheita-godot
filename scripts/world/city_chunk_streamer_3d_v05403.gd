extends "res://scripts/world/city_chunk_streamer_3d_v05401.gd"

const WORLD_REWORK_VERSION_05403 := "0.5.40.3"

var material_cache_05403: Dictionary = {}

func _build_large_house_0511(parent: Node3D, pos: Vector3, coord: Vector2i, slot: int, marker: int, yaw: float) -> void:
	super._build_large_house_0511(parent, pos, coord, slot, marker, yaw)
	var root := parent.get_node_or_null("CityHouse0511_%d_%d_%d" % [coord.x, coord.y, slot]) as Node3D
	if root == null or root.has_meta("world_rework_05403"):
		return
	root.set_meta("world_rework_05403", true)
	root.add_to_group("world_rework_house_05403")
	_enhance_city_house_05403(root, marker)

func _build_rural_house(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_house(parent, pos, coord)
	var root := parent.get_node_or_null("RuralHouse_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null or root.has_meta("world_rework_05403"):
		return
	root.set_meta("world_rework_05403", true)
	root.add_to_group("world_rework_rural_05403")
	_enhance_rural_house_05403(root, coord)

func _build_city_sidewalks(parent: Node3D, origin: Vector3, local: Vector2i) -> void:
	super._build_city_sidewalks(parent, origin, local)
	var coord := _chunk_coord_from_origin(origin)
	var sub := _block_sub(coord)
	if sub.x == BLOCK_SPAN_0511 - 1:
		_add_storm_drain_05403(parent, origin + Vector3(23.7, 0.325, 7.2), false)
		_add_storm_drain_05403(parent, origin + Vector3(23.7, 0.325, 18.6), false)
		_add_road_wear_05403(parent, origin + Vector3(27.0, 0.306, 12.6), false, coord)
	if sub.y == BLOCK_SPAN_0511 - 1:
		_add_storm_drain_05403(parent, origin + Vector3(7.2, 0.330, 23.7), true)
		_add_storm_drain_05403(parent, origin + Vector3(18.6, 0.330, 23.7), true)
		_add_road_wear_05403(parent, origin + Vector3(12.6, 0.311, 27.0), true, coord)

func _decorate_residential_yard_0511(parent: Node3D, origin: Vector3, sub: Vector2i, marker: int) -> void:
	super._decorate_residential_yard_0511(parent, origin, sub, marker)
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed * 92821 + marker * 97 + sub.x * 17 + sub.y * 31
	var mailbox_pos := origin + Vector3(4.8 if sub.x == 0 else 20.0, 0.30, 5.0 if sub.y == 0 else 19.6)
	_add_mailbox_05403(parent, mailbox_pos, rng.randf_range(-0.28, 0.28))
	if marker % 2 == 0:
		var shrub_origin := origin + Vector3(rng.randf_range(6.5, 18.0), 0.28, rng.randf_range(6.0, 18.0))
		_add_shrub_cluster_05403(parent, shrub_origin, marker)

func _decorate_location_0534(root: Node3D, role: String, key_base: String) -> void:
	super._decorate_location_0534(root, role, key_base)
	if root == null or root.has_meta("poi_rework_05403"):
		return
	root.set_meta("poi_rework_05403", true)
	root.add_to_group("world_rework_poi_05403")
	_enhance_poi_05403(root, role)

func _enhance_city_house_05403(root: Node3D, marker: int) -> void:
	var trim := _mat_05403("trim", Color("c8c0ae"), 0.84)
	var glass := _mat_05403("glass", Color("263640"), 0.32)
	var dark := _mat_05403("dark", Color("282723"), 0.90)
	var metal := _mat_05403("metal", Color("6f7471"), 0.54, 0.20)
	var awning := _mat_05403("awning_%d" % (marker % 3), [Color("6c4938"), Color("556354"), Color("6b6045")][marker % 3], 0.72)

	# Fachada frontal: duas janelas grandes com moldura, peitoril e profundidade.
	for x in [-3.85, 3.85]:
		_box_05403(root, Vector3(2.18, 1.36, 0.05), Vector3(x, 1.72, 6.205), glass, "WindowGlass05403")
		_box_05403(root, Vector3(2.42, 0.10, 0.08), Vector3(x, 2.43, 6.225), trim, "WindowTrimTop05403")
		_box_05403(root, Vector3(2.54, 0.13, 0.16), Vector3(x, 1.01, 6.255), trim, "WindowSill05403")
		_box_05403(root, Vector3(0.10, 1.46, 0.08), Vector3(x - 1.16, 1.73, 6.225), trim, "WindowTrimL05403")
		_box_05403(root, Vector3(0.10, 1.46, 0.08), Vector3(x + 1.16, 1.73, 6.225), trim, "WindowTrimR05403")

	# Marquise da entrada e luminária simples; só visual, sem mexer na porta funcional.
	_box_05403(root, Vector3(2.36, 0.13, 1.05), Vector3(0.0, 2.67, 6.50), awning, "EntryAwning05403")
	_box_05403(root, Vector3(0.26, 0.42, 0.20), Vector3(1.16, 2.20, 6.28), dark, "PorchLamp05403")
	_box_05403(root, Vector3(0.10, 0.10, 0.08), Vector3(1.16, 2.20, 6.40), trim, "PorchLampFace05403")

	# Rodapé externo e caixa de medidor dão escala e quebram o aspecto de blocos limpos.
	_box_05403(root, Vector3(14.1, 0.24, 0.10), Vector3(0.0, 0.43, 6.19), dark, "FacadeBase05403")
	_box_05403(root, Vector3(0.38, 0.58, 0.20), Vector3(6.92, 1.28, 3.15), metal, "PowerMeter05403")

	var roof := root.get_node_or_null("Roof") as Node3D
	if roof != null:
		var chimney := Node3D.new()
		chimney.name = "Chimney05403"
		chimney.position = Vector3(4.45, 3.86, -2.55)
		chimney.add_to_group("world_rework_roof_05403")
		roof.add_child(chimney)
		_box_05403(chimney, Vector3(0.78, 1.36, 0.78), Vector3.ZERO, _mat_05403("brick", Color("705247"), 0.92), "ChimneyBody05403")
		_box_05403(chimney, Vector3(0.96, 0.14, 0.96), Vector3(0.0, 0.73, 0.0), dark, "ChimneyCap05403")

func _enhance_rural_house_05403(root: Node3D, coord: Vector2i) -> void:
	var wood := _mat_05403("rural_wood", Color("725b3f"), 0.94)
	var metal := _mat_05403("rural_metal", Color("6b716d"), 0.58, 0.18)
	var tank := _mat_05403("water_tank", Color("5d6f70"), 0.55, 0.15)
	var cloth := _mat_05403("cloth", Color("b6aa8b"), 0.86)

	# Caixa d'água elevada e estrutura de madeira ao lado da casa.
	var tank_root := Node3D.new()
	tank_root.name = "RuralWaterTank05403"
	tank_root.position = Vector3(4.25, 0.0, -2.65)
	tank_root.add_to_group("world_rework_rural_detail_05403")
	root.add_child(tank_root)
	for x in [-0.62, 0.62]:
		for z in [-0.62, 0.62]:
			_box_05403(tank_root, Vector3(0.16, 2.20, 0.16), Vector3(x, 1.10, z), wood, "TankPost05403")
	_cylinder_05403(tank_root, 0.88, 1.18, Vector3(0.0, 2.50, 0.0), tank, "Tank05403")

	# Varal: reforça a leitura de propriedade habitada/abandonada sem criar colisão.
	var line_z := 2.55
	_box_05403(root, Vector3(0.12, 1.65, 0.12), Vector3(-3.7, 0.83, line_z), wood, "ClothesPostA05403")
	_box_05403(root, Vector3(0.12, 1.65, 0.12), Vector3(-0.6, 0.83, line_z), wood, "ClothesPostB05403")
	_box_05403(root, Vector3(3.10, 0.035, 0.035), Vector3(-2.15, 1.48, line_z), metal, "ClothesLine05403")
	var cloth_offset := 0.0 if posmod(coord.x + coord.y, 2) == 0 else 0.32
	_box_05403(root, Vector3(0.72, 0.72, 0.035), Vector3(-2.55 + cloth_offset, 1.12, line_z), cloth, "Cloth05403")

func _enhance_poi_05403(root: Node3D, role: String) -> void:
	var white := _mat_05403("poi_white", Color("d8d8d0"), 0.78)
	var dark := _mat_05403("poi_dark", Color("252725"), 0.90)
	match role:
		"hospital":
			var red := _mat_05403("poi_red", Color("a8463d"), 0.72)
			_box_05403(root, Vector3(0.34, 1.62, 0.12), Vector3(-5.75, 2.08, 6.29), red, "HospitalCrossV05403")
			_box_05403(root, Vector3(1.62, 0.34, 0.12), Vector3(-5.75, 2.08, 6.30), red, "HospitalCrossH05403")
		"market":
			var green := _mat_05403("poi_green", Color("687647"), 0.78)
			for i in range(5):
				var mat := green if i % 2 == 0 else white
				_box_05403(root, Vector3(1.20, 0.10, 1.26), Vector3(-2.4 + float(i) * 1.20, 2.40, 6.62), mat, "MarketAwning05403")
		"workshop":
			var rust := _mat_05403("poi_rust", Color("9a623d"), 0.84)
			_box_05403(root, Vector3(6.3, 0.42, 0.18), Vector3(0.0, 2.38, 6.30), rust, "WorkshopHeader05403")
			for i in range(4):
				_box_05403(root, Vector3(0.08, 1.65, 0.12), Vector3(-2.2 + float(i) * 1.45, 1.34, 6.31), dark, "WorkshopSlat05403")
		"police":
			var blue := _mat_05403("poi_blue", Color("445f7c"), 0.66)
			_box_05403(root, Vector3(4.4, 0.30, 0.18), Vector3(0.0, 2.42, 6.31), blue, "PoliceHeader05403")
			_box_05403(root, Vector3(0.42, 0.22, 0.26), Vector3(5.55, 3.02, 0.0), blue, "PoliceBeacon05403")
		"farm":
			var farm_metal := _mat_05403("farm_metal", Color("77765f"), 0.62, 0.12)
			_cylinder_05403(root, 0.72, 1.65, Vector3(5.15, 1.05, -3.4), farm_metal, "FarmTank05403")

func _add_storm_drain_05403(parent: Node3D, pos: Vector3, rotate_90: bool) -> void:
	var root := Node3D.new()
	root.name = "StormDrain05403"
	root.position = pos
	root.rotation.y = PI * 0.5 if rotate_90 else 0.0
	root.add_to_group("world_rework_street_05403")
	parent.add_child(root)
	var metal := _mat_05403("drain_metal", Color("3f4543"), 0.52, 0.25)
	_box_05403(root, Vector3(1.08, 0.035, 0.62), Vector3.ZERO, metal, "DrainPlate05403")
	var slot_mat := _mat_05403("drain_slot", Color("171a19"), 0.96)
	for i in range(5):
		_box_05403(root, Vector3(0.08, 0.018, 0.48), Vector3(-0.36 + float(i) * 0.18, 0.025, 0.0), slot_mat, "DrainSlot05403")

func _add_road_wear_05403(parent: Node3D, pos: Vector3, horizontal: bool, coord: Vector2i) -> void:
	var marker := int(abs(hash("road05403:%d:%d:%d" % [world_seed, coord.x, coord.y])))
	var patch := _box_05403(parent, Vector3(2.8 if horizontal else 1.5, 0.028, 1.5 if horizontal else 2.8), pos, _mat_05403("road_patch", Color("242825"), 0.98), "RoadPatch05403")
	patch.rotation.y = float(marker % 7 - 3) * 0.045
	patch.add_to_group("world_rework_roadwear_05403")
	for i in range(3):
		var weed := _box_05403(parent, Vector3(0.07, 0.25 + float(i) * 0.07, 0.07), pos + Vector3(-0.58 + float(i) * 0.48, 0.14, 0.62), _mat_05403("weed", Color("596643"), 0.94), "CurbWeed05403")
		weed.rotation_degrees.z = -12.0 + float(i) * 11.0
		weed.add_to_group("world_rework_vegetation_05403")

func _add_mailbox_05403(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.name = "Mailbox05403"
	root.position = pos
	root.rotation.y = yaw
	root.add_to_group("world_rework_prop_05403")
	parent.add_child(root)
	var metal := _mat_05403("mailbox", Color("59635d"), 0.68, 0.10)
	var wood := _mat_05403("mailpost", Color("66523a"), 0.94)
	_box_05403(root, Vector3(0.12, 1.12, 0.12), Vector3(0.0, 0.56, 0.0), wood, "Post05403")
	_box_05403(root, Vector3(0.72, 0.42, 0.48), Vector3(0.0, 1.12, 0.0), metal, "Box05403")
	_box_05403(root, Vector3(0.08, 0.52, 0.08), Vector3(0.39, 1.22, 0.0), _mat_05403("flag", Color("8c4b3f"), 0.80), "Flag05403")

func _add_shrub_cluster_05403(parent: Node3D, pos: Vector3, marker: int) -> void:
	var root := Node3D.new()
	root.name = "ShrubCluster05403"
	root.position = pos
	root.add_to_group("world_rework_vegetation_05403")
	parent.add_child(root)
	var green := _mat_05403("shrub_%d" % (marker % 2), Color("4d5d3e") if marker % 2 == 0 else Color("5d6041"), 0.96)
	for i in range(5):
		var angle := float(i) / 5.0 * TAU
		_cylinder_05403(root, 0.18 + float(i % 2) * 0.05, 0.72 + float(i % 3) * 0.14, Vector3(cos(angle) * 0.46, 0.40, sin(angle) * 0.46), green, "Shrub05403")

func _box_05403(parent: Node3D, size_value: Vector3, pos: Vector3, material: Material, node_name: String) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh.material = material
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.add_to_group("world_rework_mesh_05403")
	parent.add_child(node)
	return node

func _cylinder_05403(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, node_name: String) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.material = material
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	node.add_to_group("world_rework_mesh_05403")
	parent.add_child(node)
	return node

func _mat_05403(key: String, color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	if material_cache_05403.has(key):
		return material_cache_05403[key] as StandardMaterial3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	material_cache_05403[key] = mat
	return mat

func get_environment_rework_debug_05403() -> Dictionary:
	return {
		"version": WORLD_REWORK_VERSION_05403,
		"houses": get_tree().get_nodes_in_group("world_rework_house_05403").size(),
		"rural": get_tree().get_nodes_in_group("world_rework_rural_05403").size(),
		"poi": get_tree().get_nodes_in_group("world_rework_poi_05403").size(),
		"street": get_tree().get_nodes_in_group("world_rework_street_05403").size(),
		"roadwear": get_tree().get_nodes_in_group("world_rework_roadwear_05403").size(),
		"vegetation": get_tree().get_nodes_in_group("world_rework_vegetation_05403").size(),
		"props": get_tree().get_nodes_in_group("world_rework_prop_05403").size(),
		"meshes": get_tree().get_nodes_in_group("world_rework_mesh_05403").size()
	}

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	var rework := get_environment_rework_debug_05403()
	for key in rework.keys():
		result["world05403_%s" % str(key)] = rework[key]
	return result
