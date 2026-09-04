extends "res://scripts/world/city_chunk_streamer_3d_v059.gd"

const RoofCutaway0511 = preload("res://scripts/world/house_roof_cutaway_0511.gd")
const BLOCK_SPAN_0511 := 2
const LARGE_HOUSE_W_0511 := 14.6
const LARGE_HOUSE_D_0511 := 12.4

func _chunk_coord_from_origin(origin: Vector3) -> Vector2i:
	return Vector2i(floori(origin.x / CHUNK_WORLD_057), floori(origin.z / CHUNK_WORLD_057))

func _block_sub(coord: Vector2i) -> Vector2i:
	return Vector2i(posmod(coord.x, BLOCK_SPAN_0511), posmod(coord.y, BLOCK_SPAN_0511))

func _block_key(coord: Vector2i) -> Vector2i:
	return Vector2i(floori(float(coord.x) / float(BLOCK_SPAN_0511)), floori(float(coord.y) / float(BLOCK_SPAN_0511)))

func _build_city_sidewalks(parent: Node3D, origin: Vector3, _local: Vector2i) -> void:
	# 0.5.11: duas células de chunk formam uma quadra residencial maior.
	# A rua só existe no perímetro externo do superbloco; a emenda interna vira lote contínuo.
	var coord := _chunk_coord_from_origin(origin)
	var sub := _block_sub(coord)
	var east_road := sub.x == BLOCK_SPAN_0511 - 1
	var south_road := sub.y == BLOCK_SPAN_0511 - 1
	var west_walk := sub.x == 0
	var north_walk := sub.y == 0
	var asphalt: Material = _material_for("asphalt")
	var sidewalk: Material = _material_for("sidewalk")
	var curb: Material = _material_for("curb")
	var yellow: Material = _material_for("road_marking_yellow")
	var white: Material = _material_for("road_marking_white")

	if east_road:
		var road_v := _flat_box(parent, Vector3(ROAD_WIDTH_057, 0.10, CHUNK_WORLD_057 + 0.18), origin + Vector3(ROAD_CENTER_057, 0.20, 16.0), asphalt)
		road_v.add_to_group("city_asphalt")
		road_v.add_to_group("street_grid")
		var walk_v := _flat_box(parent, Vector3(SIDEWALK_WIDTH_057, 0.11, CHUNK_WORLD_057), origin + Vector3(SIDEWALK_CENTER_057, 0.255, 16.0), sidewalk)
		walk_v.add_to_group("city_sidewalk")
		walk_v.add_to_group("block_sidewalk_0511")
		var curb_v := _flat_box(parent, Vector3(CURB_WIDTH_057, 0.20, CHUNK_WORLD_057), origin + Vector3(ROAD_START_057 - CURB_WIDTH_057 * 0.5, 0.31, 16.0), curb)
		curb_v.add_to_group("city_curb")
		for i in range(7):
			var along := 2.4 + float(i) * 3.25
			if along < 22.0:
				_flat_box(parent, Vector3(0.16, 0.035, 1.45), origin + Vector3(ROAD_CENTER_057, 0.285, along), yellow).add_to_group("lane_marking")
		_flat_box(parent, Vector3(0.10, 0.035, 21.0), origin + Vector3(ROAD_START_057 + 0.55, 0.286, 10.5), white).add_to_group("lane_marking")

	if south_road:
		var road_h := _flat_box(parent, Vector3(CHUNK_WORLD_057 + 0.18, 0.10, ROAD_WIDTH_057), origin + Vector3(16.0, 0.205, ROAD_CENTER_057), asphalt)
		road_h.add_to_group("city_asphalt")
		road_h.add_to_group("street_grid")
		var walk_h := _flat_box(parent, Vector3(CHUNK_WORLD_057, 0.11, SIDEWALK_WIDTH_057), origin + Vector3(16.0, 0.26, SIDEWALK_CENTER_057), sidewalk)
		walk_h.add_to_group("city_sidewalk")
		walk_h.add_to_group("block_sidewalk_0511")
		var curb_h := _flat_box(parent, Vector3(CHUNK_WORLD_057, 0.20, CURB_WIDTH_057), origin + Vector3(16.0, 0.315, ROAD_START_057 - CURB_WIDTH_057 * 0.5), curb)
		curb_h.add_to_group("city_curb")
		for i in range(7):
			var along_h := 2.4 + float(i) * 3.25
			if along_h < 22.0:
				_flat_box(parent, Vector3(1.45, 0.035, 0.16), origin + Vector3(along_h, 0.29, ROAD_CENTER_057), yellow).add_to_group("lane_marking")
		_flat_box(parent, Vector3(21.0, 0.035, 0.10), origin + Vector3(10.5, 0.291, ROAD_START_057 + 0.55), white).add_to_group("lane_marking")

	# Calçadas do lado oeste/norte pertencem a esta quadra; a rua correspondente vem do superbloco vizinho.
	if west_walk:
		var ww := _flat_box(parent, Vector3(SIDEWALK_WIDTH_057, 0.11, CHUNK_WORLD_057), origin + Vector3(SIDEWALK_WIDTH_057 * 0.5, 0.255, 16.0), sidewalk)
		ww.add_to_group("city_sidewalk")
		ww.add_to_group("block_sidewalk_0511")
	if north_walk:
		var nw := _flat_box(parent, Vector3(CHUNK_WORLD_057, 0.11, SIDEWALK_WIDTH_057), origin + Vector3(16.0, 0.26, SIDEWALK_WIDTH_057 * 0.5), sidewalk)
		nw.add_to_group("city_sidewalk")
		nw.add_to_group("block_sidewalk_0511")

	if east_road and south_road:
		for i in range(4):
			var off := 24.1 + float(i) * 1.55
			_flat_box(parent, Vector3(0.82, 0.04, 0.34), origin + Vector3(off, 0.295, 21.35), white).add_to_group("crosswalk")
			_flat_box(parent, Vector3(0.34, 0.04, 0.82), origin + Vector3(21.35, 0.30, off), white).add_to_group("crosswalk")

func _build_street_props(parent: Node3D, origin: Vector3, marker: int) -> void:
	var coord := _chunk_coord_from_origin(origin)
	var sub := _block_sub(coord)
	if sub.x == BLOCK_SPAN_0511 - 1 or sub.y == BLOCK_SPAN_0511 - 1:
		super._build_street_props(parent, origin, marker)

func _add_city_surface_wear(parent: Node3D, origin: Vector3, marker: int) -> void:
	var coord := _chunk_coord_from_origin(origin)
	var sub := _block_sub(coord)
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 401 + marker
	if sub.x == BLOCK_SPAN_0511 - 1:
		for i in range(2):
			var wear_v := origin + Vector3(rng_local.randf_range(24.2, 30.8), 0.272, rng_local.randf_range(3.0, 20.0))
			_ground_patch(parent, wear_v, rng_local.randf_range(0.35, 0.85), rng_local.randf_range(0.20, 0.55), rng_local.randf_range(0.0, TAU), _material_for("asphalt_dark"), "road_wear")
	if sub.y == BLOCK_SPAN_0511 - 1:
		for i in range(2):
			var wear_h := origin + Vector3(rng_local.randf_range(3.0, 20.0), 0.276, rng_local.randf_range(24.2, 30.8))
			_ground_patch(parent, wear_h, rng_local.randf_range(0.35, 0.85), rng_local.randf_range(0.20, 0.55), rng_local.randf_range(0.0, TAU), _material_for("asphalt_dark"), "road_wear")

func _build_city_lot(parent: Node3D, origin: Vector3, coord: Vector2i, _local: Vector2i, marker: int) -> void:
	var sub := _block_sub(coord)
	var block := _block_key(coord)
	var block_marker: int = int(abs(hash("residential0511:%d:%d:%d" % [world_seed, block.x, block.y])))
	var house_x := 15.2 if sub.x == 0 else 13.9
	var house_z := 15.0 if sub.y == 0 else 13.8
	var house_pos := origin + Vector3(house_x, 0.0, house_z)
	var slot := sub.y * 2 + sub.x
	var yaw := 0.0
	if sub.x == 1 and (slot % 2 == 0 or block_marker % 3 == 0):
		yaw = PI * 0.5
	elif sub.x == 0 and slot % 2 == 1:
		yaw = -PI * 0.5
	elif sub.y == 0:
		yaw = PI

	# A maior parte das quadras é residencial com quatro casas grandes; POIs aparecem como exceção contextual.
	if block_marker % 11 == 0 and slot == 0:
		_build_market(parent, house_pos, coord)
		for child in parent.get_children():
			if child is Node3D and child.is_in_group("city_building"):
				(child as Node3D).rotation.y = yaw
	else:
		_build_large_house_0511(parent, house_pos, coord, slot, marker, yaw)

	_build_house_access_0511(parent, origin, house_pos, sub, marker)
	_decorate_residential_yard_0511(parent, origin, sub, marker)
	if sub == Vector2i.ZERO:
		var marker_node := Node3D.new()
		marker_node.name = "ResidentialBlock0511_%d_%d" % [block.x, block.y]
		marker_node.add_to_group("residential_block_0511")
		parent.add_child(marker_node)

func _build_house_access_0511(parent: Node3D, origin: Vector3, house_pos: Vector3, sub: Vector2i, marker: int) -> void:
	var mat: Material = _material_for("driveway") if marker % 3 != 0 else _material_for("dirt_dark")
	var local_house := house_pos - origin
	var driveway: MeshInstance3D
	if sub.x == 1:
		driveway = _flat_box(parent, Vector3(8.2, 0.07, 2.7), origin + Vector3(19.1, 0.285, local_house.z + 3.7), mat)
	elif sub.x == 0:
		driveway = _flat_box(parent, Vector3(7.6, 0.07, 2.7), origin + Vector3(4.0, 0.285, local_house.z + 3.4), mat)
	elif sub.y == 1:
		driveway = _flat_box(parent, Vector3(2.7, 0.07, 8.2), origin + Vector3(local_house.x, 0.285, 19.1), mat)
	else:
		driveway = _flat_box(parent, Vector3(2.7, 0.07, 7.6), origin + Vector3(local_house.x, 0.285, 4.0), mat)
	driveway.add_to_group("lot_driveway")

func _build_large_house_0511(parent: Node3D, pos: Vector3, coord: Vector2i, slot: int, marker: int, yaw: float) -> void:
	var root := Node3D.new()
	root.name = "CityHouse0511_%d_%d_%d" % [coord.x, coord.y, slot]
	root.position = pos
	root.rotation.y = yaw
	root.set_script(RoofCutaway0511)
	root.set("half_size", Vector2(LARGE_HOUSE_W_0511 * 0.52, LARGE_HOUSE_D_0511 * 0.54))
	root.add_to_group("city_building")
	root.add_to_group("residential_house_0511")
	root.add_to_group("large_house_0511")
	parent.add_child(root)

	var wall_choices := ["house_plaster", "house_plaster_worn", "brick_weathered", "wood_siding"]
	var wall_mat: Material = _material_for(wall_choices[marker % wall_choices.size()])
	var inside: Material = _material_for("interior_wall_worn")
	var floor_old: Material = _material_for("wood_floor_old")
	var tile_old: Material = _material_for("tile_floor_old")
	var roof_mat: Material = _material_for("roof_ceramic_old") if marker % 4 != 0 else _material_for("roof_zinc_old")

	_solid_box(root, Vector3(LARGE_HOUSE_W_0511, 0.24, LARGE_HOUSE_D_0511), Vector3(0, 0.12, 0), _material_for("brick_dark"), "Foundation")
	_flat_box(root, Vector3(7.0, 0.08, 5.7), Vector3(-3.55, 0.27, -3.1), floor_old)
	_flat_box(root, Vector3(7.0, 0.08, 5.7), Vector3(3.55, 0.27, -3.1), floor_old)
	_flat_box(root, Vector3(7.0, 0.08, 6.0), Vector3(-3.55, 0.27, 3.0), floor_old)
	_flat_box(root, Vector3(7.0, 0.08, 6.0), Vector3(3.55, 0.27, 3.0), tile_old)

	# Paredes externas modulares com porta frontal central e vãos de janela.
	_solid_box(root, Vector3(LARGE_HOUSE_W_0511, 3.05, 0.26), Vector3(0, 1.53, -6.05), wall_mat, "BackWall")
	_solid_box(root, Vector3(0.26, 3.05, LARGE_HOUSE_D_0511), Vector3(-7.17, 1.53, 0), wall_mat, "LeftWall")
	_solid_box(root, Vector3(0.26, 3.05, LARGE_HOUSE_D_0511), Vector3(7.17, 1.53, 0), wall_mat, "RightWall")
	_solid_box(root, Vector3(5.7, 3.05, 0.26), Vector3(-4.45, 1.53, 6.05), wall_mat, "FrontLeft")
	_solid_box(root, Vector3(5.7, 3.05, 0.26), Vector3(4.45, 1.53, 6.05), wall_mat, "FrontRight")
	_solid_box(root, Vector3(1.15, 2.28, 0.18), Vector3(0, 1.18, 6.11), _material_for("door_old"), "FrontDoor")

	# Cômodos: dois quartos ao fundo, sala à frente esquerda, cozinha à frente direita e banheiro compacto.
	_add_partition_z_0511(root, 0.0, -3.25, 4.25, inside, "HallDividerA")
	_add_partition_z_0511(root, 0.0, 3.15, 3.85, inside, "HallDividerB")
	_add_partition_x_0511(root, 0.65, -4.75, 3.1, inside, "RoomDividerL")
	_add_partition_x_0511(root, 0.65, 4.65, 3.35, inside, "RoomDividerR")
	_solid_box(root, Vector3(3.4, 2.55, 0.18), Vector3(4.75, 1.34, -1.1), inside, "BathroomWallA").add_to_group("room_partition_0511")
	_solid_box(root, Vector3(0.18, 2.55, 2.6), Vector3(3.1, 1.34, -2.35), inside, "BathroomWallB").add_to_group("room_partition_0511")

	# Mobília com contexto por cômodo.
	_furniture_box(root, Vector3(2.35, 0.55, 1.15), Vector3(-4.65, 0.55, -4.05), _material_for("wood"), "BedFrameA").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(2.15, 0.30, 1.05), Vector3(-4.65, 0.95, -4.05), _material_for("cloth"), "BedA").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(1.15, 2.05, 0.72), Vector3(-6.1, 1.08, -2.6), _material_for("wood_dark"), "WardrobeA").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(2.35, 0.55, 1.15), Vector3(2.1, 0.55, -4.35), _material_for("wood"), "BedFrameB").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(2.15, 0.30, 1.05), Vector3(2.1, 0.95, -4.35), _material_for("cloth"), "BedB").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(3.2, 0.75, 1.0), Vector3(-4.2, 0.56, 2.35), _material_for("cloth"), "Sofa").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(1.55, 0.55, 0.95), Vector3(-1.7, 0.46, 3.9), _material_for("wood_dark"), "CoffeeTable").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(4.5, 0.95, 0.75), Vector3(4.35, 0.58, 4.8), _material_for("wood_dark"), "KitchenCounter").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(0.95, 1.95, 0.95), Vector3(6.0, 1.05, 2.9), _material_for("metal"), "Fridge").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(1.05, 0.85, 0.9), Vector3(4.35, 0.53, 2.8), _material_for("metal"), "Stove").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(0.78, 0.78, 0.7), Vector3(5.75, 0.52, -2.1), _material_for("stone_light"), "BathroomSink").add_to_group("room_furniture_0511")
	_furniture_box(root, Vector3(0.72, 0.82, 0.72), Vector3(4.2, 0.50, -2.9), _material_for("stone_light"), "Toilet").add_to_group("room_furniture_0511")

	_create_loot_container(root, Vector3(5.4, 0.75, 4.0), "city_home", "city0511:%d:%d:%d:kitchen" % [coord.x, coord.y, slot])
	_create_loot_container(root, Vector3(-5.6, 0.75, -3.1), "city_home", "city0511:%d:%d:%d:bedroom" % [coord.x, coord.y, slot])
	if marker % 3 == 0:
		_create_loot_container(root, Vector3(4.4, 0.75, -3.8), "city_home", "city0511:%d:%d:%d:bath" % [coord.x, coord.y, slot])

	_add_house_facade_0511(root, marker)
	_add_house_roof(root, Vector2(LARGE_HOUSE_W_0511 + 0.75, LARGE_HOUSE_D_0511 + 0.7), 3.18, roof_mat)
	var roof := root.get_node_or_null("Roof") as Node3D
	if roof != null:
		roof.add_to_group("roof_cutaway_0511")

func _add_partition_z_0511(root: Node3D, z: float, x: float, length: float, mat: Material, label: String) -> void:
	var p := _solid_box(root, Vector3(length, 2.55, 0.18), Vector3(x, 1.34, z), mat, label)
	p.add_to_group("room_partition_0511")

func _add_partition_x_0511(root: Node3D, z: float, x: float, length: float, mat: Material, label: String) -> void:
	var p := _solid_box(root, Vector3(0.18, 2.55, length), Vector3(x, 1.34, z), mat, label)
	p.add_to_group("room_partition_0511")

func _add_house_facade_0511(root: Node3D, marker: int) -> void:
	# Janelas emolduradas, varanda, calha, chaminé e sinais de envelhecimento dão leitura e história ao asset.
	_add_window_0511(root, Vector3(-4.2, 1.7, 6.18), Vector2(2.0, 1.25))
	_add_window_0511(root, Vector3(4.2, 1.7, 6.18), Vector2(2.0, 1.25))
	_add_window_side_0511(root, Vector3(-7.24, 1.7, -2.7), Vector2(1.9, 1.2))
	_solid_box(root, Vector3(5.2, 0.18, 1.55), Vector3(0, 0.20, 6.8), _material_for("porch_wood"), "FrontPorch")
	_solid_box(root, Vector3(2.6, 0.16, 0.75), Vector3(0, 0.34, 7.55), _material_for("porch_wood"), "PorchStep")
	for x in [-2.35, 2.35]:
		_solid_box(root, Vector3(0.16, 2.35, 0.16), Vector3(x, 1.28, 6.78), _material_for("wood_dark"), "PorchPost")
	_solid_box(root, Vector3(0.55, 1.65, 0.55), Vector3(-4.8, 3.7, -2.5), _material_for("brick_weathered"), "Chimney")
	if marker % 2 == 0:
		for i in range(3):
			_flat_box(root, Vector3(1.5 + float(i) * 0.35, 0.03, 0.45), Vector3(-5.2 + float(i) * 0.8, 0.33, -6.22), _material_for("moss"))

func _add_window_0511(root: Node3D, pos: Vector3, size: Vector2) -> void:
	_flat_box(root, Vector3(size.x, size.y, 0.055), pos, _material_for("glass_dirty"))
	_solid_box(root, Vector3(size.x + 0.18, 0.10, 0.09), pos + Vector3(0, size.y * 0.5 + 0.06, 0.04), _material_for("wood_dark"), "WindowTrim")
	_solid_box(root, Vector3(size.x + 0.18, 0.10, 0.09), pos + Vector3(0, -size.y * 0.5 - 0.06, 0.04), _material_for("wood_dark"), "WindowTrim")
	_solid_box(root, Vector3(0.10, size.y, 0.09), pos + Vector3(-size.x * 0.5 - 0.05, 0, 0.04), _material_for("wood_dark"), "WindowTrim")
	_solid_box(root, Vector3(0.10, size.y, 0.09), pos + Vector3(size.x * 0.5 + 0.05, 0, 0.04), _material_for("wood_dark"), "WindowTrim")

func _add_window_side_0511(root: Node3D, pos: Vector3, size: Vector2) -> void:
	var glass := _flat_box(root, Vector3(0.055, size.y, size.x), pos, _material_for("glass_dirty"))
	glass.add_to_group("house_window_0511")

func _decorate_residential_yard_0511(parent: Node3D, origin: Vector3, sub: Vector2i, marker: int) -> void:
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = world_seed * 5119 + marker
	for i in range(4):
		var p := origin + Vector3(rng_local.randf_range(3.0, 20.5), 0.16, rng_local.randf_range(3.0, 20.5))
		_ground_patch(parent, p, rng_local.randf_range(0.55, 1.45), rng_local.randf_range(0.35, 0.85), rng_local.randf_range(0.0, TAU), _material_for("dirt_patch"), "yard_wear_0511")
	if marker % 3 != 1:
		_create_bush(parent, origin + Vector3(rng_local.randf_range(3.0, 6.0), 0.18, rng_local.randf_range(4.0, 19.0)), rng_local.randf_range(0.50, 0.78))
	if marker % 5 == 0:
		_create_tree(parent, origin + Vector3(4.5, 0.15, 5.0), rng_local.randf_range(0.58, 0.74), false)
	# Cerca parcial de fundo, nunca no acesso principal.
	var fence_mat: Material = _material_for("wood_dark")
	for i in range(4):
		var post_x := 4.0 + float(i) * 4.2
		var post := _solid_box(parent, Vector3(0.12, 1.0, 0.12), origin + Vector3(post_x, 0.52, 2.5), fence_mat, "YardFencePost")
		post.add_to_group("yard_fence_0511")
		if i < 3:
			_flat_box(parent, Vector3(4.2, 0.10, 0.10), origin + Vector3(post_x + 2.1, 0.62, 2.5), fence_mat)
			_flat_box(parent, Vector3(4.2, 0.10, 0.10), origin + Vector3(post_x + 2.1, 0.92, 2.5), fence_mat)

func get_city_debug_metrics() -> Dictionary:
	var result: Dictionary = super.get_city_debug_metrics()
	result["residential_houses_0511"] = get_tree().get_nodes_in_group("residential_house_0511").size()
	result["large_houses_0511"] = get_tree().get_nodes_in_group("large_house_0511").size()
	result["room_partitions_0511"] = get_tree().get_nodes_in_group("room_partition_0511").size()
	result["room_furniture_0511"] = get_tree().get_nodes_in_group("room_furniture_0511").size()
	result["residential_blocks_0511"] = get_tree().get_nodes_in_group("residential_block_0511").size()
	result["roof_cutaway_0511"] = get_tree().get_nodes_in_group("roof_cutaway_0511").size()
	result["block_sidewalks_0511"] = get_tree().get_nodes_in_group("block_sidewalk_0511").size()
	result["yard_fences_0511"] = get_tree().get_nodes_in_group("yard_fence_0511").size()
	return result
