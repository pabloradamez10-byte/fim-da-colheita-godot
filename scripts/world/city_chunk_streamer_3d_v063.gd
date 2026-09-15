extends "res://scripts/world/city_chunk_streamer_3d_v062.gd"

const BUILDING_VERSION_063 := "0.6.3-alpha"
const BuildingVisual := preload("res://scripts/visual/building_visual_063.gd")
const EXTRA_ROLES_063 := ["bar", "dairy", "pharmacy", "gas_station"]
const HOUSE_VARIANTS_063 := ["urban", "rural", "fortified"]
const UPPER_FLOOR_Y_063 := 3.25
const InteractiveHinge063 = preload("res://scripts/world/interactive_hinge_0512.gd")
const ESTABLISHMENT_SIZES_063 := {
	"hospital": Vector2(18.0, 16.0),
	"market": Vector2(18.0, 14.0),
	"bar": Vector2(13.0, 11.0),
	"dairy": Vector2(20.0, 16.0),
	"pharmacy": Vector2(12.0, 10.0),
	"workshop": Vector2(18.0, 14.0),
	"gas_station": Vector2(11.0, 9.0)
}

func _build_city_lot(parent: Node3D, origin: Vector3, coord: Vector2i, local: Vector2i, marker: int) -> void:
	super._build_city_lot(parent, origin, coord, local, marker)
	var root := _city_building_for_lot_063(parent, origin)
	if root == null:
		return
	var inherited_role := str(root.get_meta("poi_role_0534", ""))
	if inherited_role in ["hospital", "market", "workshop"]:
		_apply_building_role_063(root, inherited_role, coord, marker)
		return
	var role_slot := posmod(coord.x + coord.y * 5, 16)
	if inherited_role.is_empty() and role_slot < EXTRA_ROLES_063.size():
		var role: String = str(EXTRA_ROLES_063[role_slot])
		_apply_building_role_063(root, role, coord, marker)
		return
	if root.is_in_group("residential_house_0511"):
		var variant := posmod(marker + coord.x * 3 + coord.y * 5, HOUSE_VARIANTS_063.size())
		var sub := _block_sub(coord)
		_apply_two_story_house_063(root, coord, sub.y * 2 + sub.x, marker, variant)

func _city_building_for_lot_063(parent: Node3D, origin: Vector3) -> Node3D:
	# Evita reaproveitar o prédio do lote anterior quando o lote atual é estacionamento
	# ou terreno vazio. A construção legítima sempre nasce próxima ao centro do lote.
	var expected_center := origin + Vector3(10.4, 0.0, 10.4)
	var nearest: Node3D = null
	var best_distance := 2.0
	for raw in parent.get_children():
		if not (raw is Node3D) or not (raw as Node3D).is_in_group("city_building"):
			continue
		var candidate := raw as Node3D
		var delta := candidate.position - expected_center
		delta.y = 0.0
		if delta.length() < best_distance:
			best_distance = delta.length()
			nearest = candidate
	return nearest

func _apply_two_story_house_063(root: Node3D, coord: Vector2i, slot: int, marker: int, variant: int) -> void:
	_upgrade_two_story_house_063(root, coord, slot, marker, variant)
	BuildingVisual.apply(root, "house", variant)

func _upgrade_two_story_house_063(root: Node3D, coord: Vector2i, slot: int, marker: int, variant: int) -> void:
	if root == null or root.has_meta("two_story_house_063"):
		return
	var variant_index := posmod(variant, HOUSE_VARIANTS_063.size())
	var variant_name := str(HOUSE_VARIANTS_063[variant_index])
	root.set_meta("two_story_house_063", true)
	root.set_meta("house_variant_063", variant_name)
	root.set_meta("storeys_063", 2)
	root.set_meta("usable_area_063", 362)
	root.add_to_group("two_story_house_063")
	root.add_to_group("two_story_house_%s_063" % variant_name)

	var roof := root.get_node_or_null("Roof") as Node3D
	if roof != null:
		roof.position.y += UPPER_FLOOR_Y_063

	var upper := Node3D.new()
	upper.name = "UpperFloor063"
	upper.add_to_group("upper_floor_063")
	root.add_child(upper)
	_build_upper_floor_shell_063(upper, variant_index)
	_build_upper_floor_rooms_063(upper, coord, slot, variant_index)
	_build_staircase_063(root, upper, coord, slot)
	_build_upper_loot_063(root, upper, coord, slot, marker, variant_index)

func _build_upper_floor_shell_063(upper: Node3D, variant: int) -> void:
	var floor_mat: Material = _material_for("wood_floor_old")
	var wall_choices := ["house_plaster_worn", "wood_siding", "brick_weathered"]
	var wall_mat: Material = _material_for(wall_choices[variant])
	# Quatro placas deixam um vão real de 2,4 x 3,6 m para a escada.
	_solid_box(upper, Vector3(14.6, 0.18, 6.2), Vector3(0.0, UPPER_FLOOR_Y_063, -3.1), floor_mat, "UpperFloorBack063")
	_solid_box(upper, Vector3(5.5, 0.18, 6.2), Vector3(-4.55, UPPER_FLOOR_Y_063, 3.1), floor_mat, "UpperFloorFrontL063")
	_solid_box(upper, Vector3(6.7, 0.18, 6.2), Vector3(3.95, UPPER_FLOOR_Y_063, 3.1), floor_mat, "UpperFloorFrontR063")
	_solid_box(upper, Vector3(2.4, 0.18, 0.8), Vector3(-0.6, UPPER_FLOOR_Y_063, 5.8), floor_mat, "UpperFloorStairLanding063")

	_solid_box(upper, Vector3(14.6, 3.05, 0.26), Vector3(0.0, 4.78, -6.05), wall_mat, "UpperBackWall063")
	_solid_box(upper, Vector3(14.6, 3.05, 0.26), Vector3(0.0, 4.78, 6.05), wall_mat, "UpperFrontWall063")
	_solid_box(upper, Vector3(0.26, 3.05, 12.4), Vector3(-7.17, 4.78, 0.0), wall_mat, "UpperLeftWall063")
	_solid_box(upper, Vector3(0.26, 3.05, 12.4), Vector3(7.17, 4.78, 0.0), wall_mat, "UpperRightWall063")
	for child in upper.get_children():
		if child is Node:
			(child as Node).add_to_group("upper_structure_063")

func _build_upper_floor_rooms_063(upper: Node3D, coord: Vector2i, slot: int, variant: int) -> void:
	var inside: Material = _material_for("interior_wall_worn")
	# Corredor central com duas portas reais, separando os ambientes da frente e dos fundos.
	_solid_box(upper, Vector3(2.6, 2.55, 0.18), Vector3(-5.85, 4.58, 0.0), inside, "UpperDividerA063")
	_solid_box(upper, Vector3(4.7, 2.55, 0.18), Vector3(-0.85, 4.58, 0.0), inside, "UpperDividerB063")
	_solid_box(upper, Vector3(4.3, 2.55, 0.18), Vector3(5.15, 4.58, 0.0), inside, "UpperDividerC063")
	_add_internal_door_z_0514(upper, Vector3(-4.55, UPPER_FLOOR_Y_063, 0.02), 1.20, coord, slot, "upper_left_063", -94.0)
	_add_internal_door_z_0514(upper, Vector3(1.50, UPPER_FLOOR_Y_063, 0.02), 1.20, coord, slot, "upper_right_063", 94.0)

	var split_x := -1.0 if variant == 0 else (1.4 if variant == 1 else 0.2)
	_solid_box(upper, Vector3(0.18, 2.55, 5.3), Vector3(split_x, 4.58, -3.30), inside, "UpperRearSplit063")
	_solid_box(upper, Vector3(0.18, 2.55, 3.0), Vector3(split_x, 4.58, 4.40), inside, "UpperFrontSplit063")
	upper.set_meta("room_layout_063", ["family", "colonial", "fortified"][variant])

func _build_staircase_063(root: Node3D, upper: Node3D, coord: Vector2i, slot: int) -> void:
	var stair_mat: Material = _material_for("wood_dark")
	var stair_root := Node3D.new()
	stair_root.name = "Staircase063"
	stair_root.add_to_group("staircase_063")
	root.add_child(stair_root)
	for i in range(9):
		var t := float(i) / 8.0
		var step := _flat_box(stair_root, Vector3(2.1, 0.16, 0.62), Vector3(-0.6, 0.38 + t * 2.72, 4.9 - t * 2.75), stair_mat)
		step.name = "StairStep063_%02d" % i
		step.add_to_group("stair_step_063")

	var up_marker := Node3D.new()
	up_marker.name = "StairsUp063"
	up_marker.position = Vector3(-0.6, 0.35, 4.65)
	up_marker.set_meta("stair_target_063", root.to_global(Vector3(1.10, UPPER_FLOOR_Y_063 + 0.28, 3.15)))
	up_marker.add_to_group("stair_interaction_063")
	root.add_child(up_marker)

	var down_marker := Node3D.new()
	down_marker.name = "StairsDown063"
	down_marker.position = Vector3(1.10, UPPER_FLOOR_Y_063 + 0.28, 3.15)
	down_marker.set_meta("stair_target_063", root.to_global(Vector3(-0.6, 0.25, 5.25)))
	down_marker.add_to_group("stair_interaction_063")
	upper.add_child(down_marker)

	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", up_marker.global_position, "stairs_up_063", "stairs063:%d:%d:%d:up" % [coord.x, coord.y, slot], up_marker, false)
		world.call("register_streamed_interaction", down_marker.global_position, "stairs_down_063", "stairs063:%d:%d:%d:down" % [coord.x, coord.y, slot], down_marker, false)

func _build_upper_loot_063(root: Node3D, upper: Node3D, coord: Vector2i, slot: int, marker: int, variant: int) -> void:
	var offset: float = float([-0.5, 0.4, 0.0][variant])
	var wardrobe := _furniture_box(upper, Vector3(1.35, 2.00, 0.72), Vector3(-5.85, 4.32, -4.85), _material_for("wood_dark"), "UpperWardrobe063")
	var cabinet := _furniture_box(upper, Vector3(1.45, 1.25, 0.62), Vector3(5.75, 3.97, -4.90), _material_for("wood"), "UpperCabinet063")
	var chest := _furniture_box(upper, Vector3(1.50, 0.82, 0.88), Vector3(-4.2 + offset, 3.75, 4.70), _material_for("wood_dark"), "UpperChest063")
	var crate := _furniture_box(upper, Vector3(1.05, 0.92, 0.78), Vector3(3.85, 3.76, 4.85), _material_for("wood"), "UpperStorageCrate063")
	var medicine := _furniture_box(upper, Vector3(0.82, 0.92, 0.30), Vector3(5.85, 4.35, 4.80), _material_for("metal"), "UpperMedicineCabinet063")
	wardrobe.add_to_group("loot_wardrobe_063")
	cabinet.add_to_group("loot_cabinet_063")
	chest.add_to_group("loot_chest_063")
	crate.add_to_group("loot_crate_063")
	medicine.add_to_group("loot_cabinet_063")
	for source_raw in [wardrobe, cabinet, chest, crate, medicine]:
		var source := source_raw as Node3D
		source.add_to_group("upper_loot_furniture_063")
		source.add_to_group("loot_container_furniture_063")
	wardrobe.set_meta("loot_container_type_063", "wardrobe")
	cabinet.set_meta("loot_container_type_063", "cabinet")
	chest.set_meta("loot_container_type_063", "chest")
	crate.set_meta("loot_container_type_063", "storage_crate")
	medicine.set_meta("loot_container_type_063", "medicine_cabinet")
	if world == null or not world.has_method("register_streamed_interaction"):
		return
	var entries := [
		[wardrobe, "loot_wardrobe", "wardrobe"],
		[cabinet, "loot_living", "cabinet"],
		[chest, "loot_bedroom", "chest"],
		[crate, "loot_living", "crate"],
		[medicine, "loot_medicine", "medicine"]
	]
	for entry in entries:
		var node := entry[0] as Node3D
		world.call("register_streamed_interaction", node.global_position, str(entry[1]), "upperloot063:%d:%d:%d:%s:%d" % [coord.x, coord.y, slot, str(entry[2]), marker], node, true)

func _rebuild_establishment_063(root: Node3D, role: String, coord: Vector2i, marker: int) -> void:
	if root == null or root.has_meta("dedicated_establishment_063"):
		return
	if world != null and world.has_method("unregister_interactions_for_root_063"):
		world.call("unregister_interactions_for_root_063", root)
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()

	var size := ESTABLISHMENT_SIZES_063[role] as Vector2
	root.set_script(RoofCutaway0511)
	root.set("half_size", Vector2(size.x * 0.52, size.y * 0.52))
	root.set_meta("dedicated_establishment_063", true)
	root.set_meta("establishment_role_063", role)
	root.set_meta("footprint_063", size)
	root.set_meta("storeys_063", 2 if role == "hospital" else 1)
	root.add_to_group("dedicated_establishment_063")
	root.add_to_group("dedicated_%s_063" % role)

	_build_establishment_shell_063(root, role, size, coord)
	_build_establishment_layout_063(root, role, size, coord, marker)
	if role == "hospital":
		_build_hospital_upper_floor_063(root, size, coord, marker)
		_add_flat_roof(root, Vector3(size.x + 0.65, 0.20, size.y + 0.65), 6.58, _material_for("roof_zinc_old"))
	else:
		_add_flat_roof(root, Vector3(size.x + 0.55, 0.20, size.y + 0.55), 3.34, _material_for("roof_zinc_old"))

func _build_establishment_shell_063(root: Node3D, role: String, size: Vector2, coord: Vector2i) -> void:
	var wall_name := "brick_weathered" if role in ["workshop", "dairy"] else "house_plaster_worn"
	var wall_mat: Material = _material_for(wall_name)
	var floor := _solid_box(root, Vector3(size.x, 0.24, size.y), Vector3(0.0, 0.12, 0.0), _material_for("concrete"), "EstablishmentFloor063")
	_disable_body_collision_0516(floor)
	floor.add_to_group("walkable_threshold_0516")
	_solid_box(root, Vector3(size.x, 3.12, 0.26), Vector3(0.0, 1.56, -size.y * 0.5 + 0.13), wall_mat, "EstablishmentBack063")
	_solid_box(root, Vector3(0.26, 3.12, size.y), Vector3(-size.x * 0.5 + 0.13, 1.56, 0.0), wall_mat, "EstablishmentLeft063")
	_solid_box(root, Vector3(0.26, 3.12, size.y), Vector3(size.x * 0.5 - 0.13, 1.56, 0.0), wall_mat, "EstablishmentRight063")
	var door_width := 1.65
	var side_width := (size.x - door_width) * 0.5
	var front_z := size.y * 0.5 - 0.13
	_solid_box(root, Vector3(side_width, 3.12, 0.26), Vector3(-(door_width + side_width) * 0.5, 1.56, front_z), wall_mat, "EstablishmentFrontL063")
	_solid_box(root, Vector3(side_width, 3.12, 0.26), Vector3((door_width + side_width) * 0.5, 1.56, front_z), wall_mat, "EstablishmentFrontR063")
	_add_establishment_door_063(root, role, coord, front_z + 0.08, door_width)

func _add_establishment_door_063(root: Node3D, role: String, coord: Vector2i, front_z: float, width: float) -> void:
	var hinge := Node3D.new()
	hinge.name = "EstablishmentFrontDoor063"
	hinge.position = Vector3(-width * 0.5, 0.0, front_z)
	hinge.set_script(InteractiveHinge063)
	hinge.set("interaction_kind", "door")
	hinge.set("open_angle_degrees", -102.0)
	hinge.set("transition_seconds", 0.13)
	root.add_child(hinge)
	var panel := _solid_box(hinge, Vector3(width, 2.35, 0.14), Vector3(width * 0.5, 1.18, 0.0), _material_for("door_old"), "Panel")
	panel.add_to_group("establishment_door_panel_063")
	hinge.add_to_group("establishment_door_063")
	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", root.to_global(Vector3(0.0, 0.85, front_z)), "door", "door063:%s:%d:%d" % [role, coord.x, coord.y], hinge, true)

func _add_stock_partition_063(root: Node3D, size: Vector2, z: float, coord: Vector2i, role: String, floor_y: float = 0.0) -> void:
	var door_width := 1.40
	var side_width := (size.x - door_width) * 0.5
	var inside: Material = _material_for("interior_wall_worn")
	_solid_box(root, Vector3(side_width, 2.55, 0.18), Vector3(-(door_width + side_width) * 0.5, floor_y + 1.34, z), inside, "StockPartitionL063")
	_solid_box(root, Vector3(side_width, 2.55, 0.18), Vector3((door_width + side_width) * 0.5, floor_y + 1.34, z), inside, "StockPartitionR063")
	_add_internal_door_z_0514(root, Vector3(-door_width * 0.5, floor_y, z + 0.02), door_width, coord, 0, "%s_stock_%d" % [role, roundi(floor_y * 10.0)], -94.0)

func _build_establishment_layout_063(root: Node3D, role: String, size: Vector2, coord: Vector2i, marker: int) -> void:
	var back_z := -size.y * 0.28
	_add_stock_partition_063(root, size, back_z, coord, role)
	match role:
		"hospital":
			_add_role_furniture_063(root, Vector3(5.0, 1.05, 0.75), Vector3(-5.0, 0.58, 5.6), "HospitalReception063", role, coord, marker, 0, "reception")
			_add_role_furniture_063(root, Vector3(2.25, 0.72, 1.05), Vector3(-4.8, 0.55, -5.6), "HospitalBedA063", role, coord, marker, 1, "treatment")
			_add_role_furniture_063(root, Vector3(2.25, 0.72, 1.05), Vector3(0.0, 0.55, -5.6), "HospitalBedB063", role, coord, marker, 2, "treatment")
			_add_role_furniture_063(root, Vector3(1.25, 2.00, 0.65), Vector3(7.5, 1.05, -6.5), "HospitalMedicine063", role, coord, marker, 3, "medicine")
		"market":
			for i in range(4):
				_add_role_furniture_063(root, Vector3(10.0, 1.65, 0.62), Vector3(0.0, 0.86, -4.8 + float(i) * 2.55), "MarketAisle063_%d" % i, role, coord, marker, i, "shelf")
			_add_role_furniture_063(root, Vector3(4.0, 1.05, 0.78), Vector3(-5.8, 0.58, 5.5), "MarketCheckout063", role, coord, marker, 4, "checkout")
		"bar":
			_add_role_furniture_063(root, Vector3(7.0, 1.12, 0.85), Vector3(0.0, 0.60, -3.9), "BarCounter063", role, coord, marker, 0, "counter")
			for i in range(3):
				_add_role_furniture_063(root, Vector3(1.8, 0.18, 1.8), Vector3(-3.0 + float(i) * 3.0, 0.82, 2.1), "BarTable063_%d" % i, role, coord, marker, i + 1, "table")
		"dairy":
			for i in range(3):
				_add_role_furniture_063(root, Vector3(3.2, 2.25, 3.2), Vector3(-6.2 + float(i) * 6.2, 1.18, -5.4), "DairyTank063_%d" % i, role, coord, marker, i, "tank")
			_add_role_furniture_063(root, Vector3(8.0, 1.10, 1.15), Vector3(2.5, 0.62, 3.7), "DairyProcessing063", role, coord, marker, 3, "processing")
			_add_role_furniture_063(root, Vector3(3.0, 2.10, 0.75), Vector3(-7.8, 1.08, 4.6), "DairyColdStore063", role, coord, marker, 4, "cold_store")
		"pharmacy":
			for i in range(3):
				_add_role_furniture_063(root, Vector3(5.6, 1.85, 0.55), Vector3(0.0, 0.96, -3.4 + float(i) * 2.1), "PharmacyShelf063_%d" % i, role, coord, marker, i, "medicine_shelf")
			_add_role_furniture_063(root, Vector3(4.3, 1.05, 0.75), Vector3(-3.0, 0.58, 3.8), "PharmacyCounter063", role, coord, marker, 3, "counter")
			_add_role_furniture_063(root, Vector3(1.2, 2.0, 0.65), Vector3(4.7, 1.04, -3.8), "PharmacyCabinet063", role, coord, marker, 4, "cabinet")
		"workshop":
			_add_role_furniture_063(root, Vector3(7.0, 0.95, 0.95), Vector3(0.0, 0.54, -5.4), "WorkshopBench063", role, coord, marker, 0, "workbench")
			_add_role_furniture_063(root, Vector3(0.70, 2.30, 5.0), Vector3(-7.5, 1.18, -0.8), "WorkshopRackA063", role, coord, marker, 1, "tools")
			_add_role_furniture_063(root, Vector3(0.70, 2.30, 5.0), Vector3(7.5, 1.18, -0.8), "WorkshopRackB063", role, coord, marker, 2, "parts")
			_add_role_furniture_063(root, Vector3(1.6, 0.9, 1.0), Vector3(-4.8, 0.56, 4.8), "WorkshopChest063", role, coord, marker, 3, "chest")
		"gas_station":
			_add_role_furniture_063(root, Vector3(5.0, 1.00, 0.72), Vector3(-2.2, 0.56, -2.8), "GasStoreCounter063", role, coord, marker, 0, "counter")
			_add_role_furniture_063(root, Vector3(4.5, 1.75, 0.60), Vector3(2.4, 0.91, 0.0), "GasStoreShelf063", role, coord, marker, 1, "shelf")
			_add_role_furniture_063(root, Vector3(1.0, 2.0, 1.0), Vector3(4.3, 1.04, -3.2), "GasStoreFridge063", role, coord, marker, 2, "fridge")
			_build_gas_forecourt_063(root, role, coord, marker)

func _add_role_furniture_063(root: Node3D, size: Vector3, pos: Vector3, node_name: String, role: String, coord: Vector2i, marker: int, index: int, container_type: String) -> StaticBody3D:
	var node := _furniture_box(root, size, pos, _material_for("wood_dark" if container_type in ["counter", "table", "chest"] else "metal"), node_name)
	node.add_to_group("establishment_furniture_063")
	node.add_to_group("establishment_loot_063")
	node.add_to_group("establishment_loot_%s_063" % role)
	node.set_meta("loot_container_type_063", container_type)
	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", node.global_position, "loot_poi_%s" % role, "establishment063:%s:%d:%d:%d:%d" % [role, coord.x, coord.y, marker, index], node, true)
	return node

func _build_hospital_upper_floor_063(root: Node3D, size: Vector2, coord: Vector2i, marker: int) -> void:
	var upper := Node3D.new()
	upper.name = "UpperFloor063"
	upper.add_to_group("upper_floor_063")
	root.add_child(upper)
	var floor_mat: Material = _material_for("tile_floor_old")
	_solid_box(upper, Vector3(size.x, 0.18, size.y * 0.5), Vector3(0.0, UPPER_FLOOR_Y_063, -size.y * 0.25), floor_mat, "HospitalUpperBack063")
	_solid_box(upper, Vector3(6.6, 0.18, size.y * 0.5), Vector3(-5.7, UPPER_FLOOR_Y_063, size.y * 0.25), floor_mat, "HospitalUpperFrontL063")
	_solid_box(upper, Vector3(9.0, 0.18, size.y * 0.5), Vector3(4.5, UPPER_FLOOR_Y_063, size.y * 0.25), floor_mat, "HospitalUpperFrontR063")
	var wall: Material = _material_for("house_plaster_worn")
	_solid_box(upper, Vector3(size.x, 3.05, 0.26), Vector3(0.0, 4.78, -size.y * 0.5 + 0.13), wall, "HospitalUpperBackWall063")
	_solid_box(upper, Vector3(size.x, 3.05, 0.26), Vector3(0.0, 4.78, size.y * 0.5 - 0.13), wall, "HospitalUpperFrontWall063")
	_solid_box(upper, Vector3(0.26, 3.05, size.y), Vector3(-size.x * 0.5 + 0.13, 4.78, 0.0), wall, "HospitalUpperLeftWall063")
	_solid_box(upper, Vector3(0.26, 3.05, size.y), Vector3(size.x * 0.5 - 0.13, 4.78, 0.0), wall, "HospitalUpperRightWall063")
	_add_stock_partition_063(upper, size, -1.0, coord, "hospital_upper", UPPER_FLOOR_Y_063)
	_build_staircase_063(root, upper, coord, 7)
	for i in range(3):
		_add_role_furniture_063(upper, Vector3(2.3, 0.72, 1.05), Vector3(-5.5 + float(i) * 5.3, 3.80, -5.4), "HospitalWardBed063_%d" % i, "hospital", coord, marker, 10 + i, "ward")
	_add_role_furniture_063(upper, Vector3(1.4, 2.0, 0.7), Vector3(7.5, 4.34, 5.6), "HospitalUpperSupply063", "hospital", coord, marker, 13, "medicine")

func _build_gas_forecourt_063(root: Node3D, role: String, coord: Vector2i, marker: int) -> void:
	var metal: Material = _material_for("metal")
	var canopy := Node3D.new()
	canopy.name = "GasCanopy063"
	canopy.add_to_group("gas_forecourt_063")
	root.add_child(canopy)
	_flat_box(canopy, Vector3(15.0, 0.26, 6.5), Vector3(0.0, 4.0, 8.0), metal)
	for x in [-6.5, 6.5]:
		_solid_box(canopy, Vector3(0.28, 4.0, 0.28), Vector3(x, 2.0, 8.0), metal, "GasCanopyPost063")
	for i in range(2):
		_add_role_furniture_063(root, Vector3(1.0, 1.65, 0.75), Vector3(-3.0 + float(i) * 6.0, 0.86, 8.0), "FuelPump063_%d" % i, role, coord, marker, 10 + i, "fuel_pump")

func _apply_building_role_063(root: Node3D, role: String, coord: Vector2i = Vector2i.ZERO, marker: int = 0) -> void:
	if root == null or not BuildingVisual.has_role(role):
		return
	if root.is_in_group("city_building") and ESTABLISHMENT_SIZES_063.has(role):
		_rebuild_establishment_063(root, role, coord, marker)
	BuildingVisual.apply(root, role)
	root.set_meta("poi_role_063", role)
	root.add_to_group("poi_location_063")
	root.add_to_group("poi_%s_063" % role)
	var old_label := root.get_node_or_null("PoiLabel0534") as Label3D
	if old_label != null:
		old_label.visible = false
	var old_sign := root.get_node_or_null("PoiSign0534") as MeshInstance3D
	if old_sign != null:
		old_sign.visible = false

func get_building_asset_debug_063() -> Dictionary:
	var roles := {}
	var dedicated := {}
	var role_names := ["house"]
	role_names.append_array(BuildingVisual.TEXTURES.keys())
	for role in role_names:
		roles[role] = get_tree().get_nodes_in_group("building_asset_%s_063" % role).size()
		if role != "house":
			dedicated[role] = get_tree().get_nodes_in_group("dedicated_%s_063" % role).size()
	return {
		"version": BUILDING_VERSION_063,
		"assets": get_tree().get_nodes_in_group("building_asset_063").size(),
		"full_exteriors": get_tree().get_nodes_in_group("full_building_asset_063").size(),
		"roles": roles,
		"roof_cutaway_preserved": true,
		"doors_and_collisions_preserved": true,
		"two_story_houses": get_tree().get_nodes_in_group("two_story_house_063").size(),
		"house_variants": HOUSE_VARIANTS_063.duplicate(),
		"staircases": get_tree().get_nodes_in_group("staircase_063").size(),
		"upper_loot": get_tree().get_nodes_in_group("upper_loot_furniture_063").size(),
		"dedicated_establishments": dedicated,
		"establishment_loot": get_tree().get_nodes_in_group("establishment_loot_063").size(),
		"nature_version": NATURE_VERSION_062
	}
