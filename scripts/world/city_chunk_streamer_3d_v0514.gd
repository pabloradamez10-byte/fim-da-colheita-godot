extends "res://scripts/world/city_chunk_streamer_3d_v0513.gd"

const InteractiveHinge0514 = preload("res://scripts/world/interactive_hinge_0512.gd")

func _build_large_house_0511(parent: Node3D, pos: Vector3, coord: Vector2i, slot: int, marker: int, yaw: float) -> void:
	super._build_large_house_0511(parent, pos, coord, slot, marker, yaw)
	var root := parent.get_node_or_null("CityHouse0511_%d_%d_%d" % [coord.x, coord.y, slot]) as Node3D
	if root == null:
		return
	_upgrade_room_partitions_0514(root, coord, slot)
	_add_room_identity_0514(root)
	_upgrade_contextual_loot_0514(root, coord, slot)

func _upgrade_room_partitions_0514(root: Node3D, coord: Vector2i, slot: int) -> void:
	# A 0.5.14 transforma as divisórias em paredes com vãos reais e portas internas.
	for node_name in ["HallDividerA", "HallDividerB", "BathroomWallB"]:
		var old := root.get_node_or_null(node_name)
		if old != null:
			old.queue_free()
	var inside: Material = _material_for("interior_wall_worn")

	# Porta do quarto esquerdo no divisor horizontal (z = 0).
	_solid_box(root, Vector3(1.55, 2.55, 0.18), Vector3(-4.60, 1.34, 0.0), inside, "BedroomA_WallL").add_to_group("room_partition_0514")
	_solid_box(root, Vector3(1.55, 2.55, 0.18), Vector3(-1.90, 1.34, 0.0), inside, "BedroomA_WallR").add_to_group("room_partition_0514")
	_add_internal_door_z_0514(root, Vector3(-3.80, 0.0, 0.02), 1.10, coord, slot, "bedroom_a", -96.0)

	# Porta do segundo quarto.
	_solid_box(root, Vector3(1.25, 2.55, 0.18), Vector3(1.86, 1.34, 0.0), inside, "BedroomB_WallL").add_to_group("room_partition_0514")
	_solid_box(root, Vector3(1.45, 2.55, 0.18), Vector3(4.34, 1.34, 0.0), inside, "BedroomB_WallR").add_to_group("room_partition_0514")
	_add_internal_door_z_0514(root, Vector3(2.50, 0.0, 0.02), 1.10, coord, slot, "bedroom_b", 96.0)

	# Banheiro: parede lateral com vão e porta estreita.
	_solid_box(root, Vector3(0.18, 2.55, 0.80), Vector3(3.10, 1.34, -3.25), inside, "BathroomDoorWallA").add_to_group("room_partition_0514")
	_solid_box(root, Vector3(0.18, 2.55, 0.80), Vector3(3.10, 1.34, -1.45), inside, "BathroomDoorWallB").add_to_group("room_partition_0514")
	_add_internal_door_x_0514(root, Vector3(3.10, 0.0, -2.85), 1.00, coord, slot, "bathroom", 92.0)

func _add_internal_door_z_0514(root: Node3D, hinge_pos: Vector3, width: float, coord: Vector2i, slot: int, suffix: String, angle: float) -> void:
	var hinge := Node3D.new()
	hinge.name = "InternalDoor0514_%s" % suffix
	hinge.position = hinge_pos
	hinge.set_script(InteractiveHinge0514)
	hinge.set("interaction_kind", "door")
	hinge.set("open_angle_degrees", angle)
	hinge.set("transition_seconds", 0.13)
	root.add_child(hinge)
	var panel := _solid_box(hinge, Vector3(width, 2.18, 0.10), Vector3(width * 0.5, 1.10, 0.0), _material_for("door_old"), "Panel")
	panel.add_to_group("internal_door_panel_0514")
	hinge.add_to_group("internal_door_0514")
	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", root.to_global(hinge_pos + Vector3(width * 0.5, 0.8, 0.0)), "door", "door0514:%d:%d:%d:%s" % [coord.x, coord.y, slot, suffix], hinge, true)

func _add_internal_door_x_0514(root: Node3D, hinge_pos: Vector3, width: float, coord: Vector2i, slot: int, suffix: String, angle: float) -> void:
	var hinge := Node3D.new()
	hinge.name = "InternalDoor0514_%s" % suffix
	hinge.position = hinge_pos
	hinge.set_script(InteractiveHinge0514)
	hinge.set("interaction_kind", "door")
	hinge.set("open_angle_degrees", angle)
	hinge.set("transition_seconds", 0.13)
	root.add_child(hinge)
	var panel := _solid_box(hinge, Vector3(0.10, 2.18, width), Vector3(0.0, 1.10, width * 0.5), _material_for("door_old"), "Panel")
	panel.add_to_group("internal_door_panel_0514")
	hinge.add_to_group("internal_door_0514")
	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", root.to_global(hinge_pos + Vector3(0.0, 0.8, width * 0.5)), "door", "door0514:%d:%d:%d:%s" % [coord.x, coord.y, slot, suffix], hinge, true)

func _add_room_identity_0514(root: Node3D) -> void:
	# Sala: tapete, estante e televisão deixam a função do cômodo legível sem texto.
	var rug := _flat_box(root, Vector3(3.9, 0.025, 2.7), Vector3(-3.6, 0.315, 3.2), _material_for("cloth"))
	rug.name = "LivingRug0514"
	rug.add_to_group("room_detail_0514")
	_furniture_box(root, Vector3(2.25, 0.62, 0.48), Vector3(-5.35, 0.52, 4.85), _material_for("wood_dark"), "TVStand0514").add_to_group("room_detail_0514")
	_furniture_box(root, Vector3(1.75, 1.05, 0.16), Vector3(-5.35, 1.25, 4.60), _material_for("metal"), "Television0514").add_to_group("room_detail_0514")
	var shelf := _furniture_box(root, Vector3(1.45, 1.95, 0.42), Vector3(-6.05, 1.05, 1.25), _material_for("wood_dark"), "Bookshelf0514")
	shelf.add_to_group("room_detail_0514")

	# Cozinha: pia, despensa e mesa com cadeiras.
	_furniture_box(root, Vector3(1.55, 0.92, 0.75), Vector3(2.35, 0.56, 4.80), _material_for("metal"), "KitchenSink0514").add_to_group("room_detail_0514")
	var pantry := _furniture_box(root, Vector3(1.10, 2.00, 0.72), Vector3(6.05, 1.08, 4.35), _material_for("wood_dark"), "Pantry0514")
	pantry.add_to_group("room_detail_0514")
	_furniture_box(root, Vector3(2.25, 0.18, 1.45), Vector3(2.25, 0.92, 2.85), _material_for("wood"), "DiningTable0514").add_to_group("room_detail_0514")
	for chair_pos in [Vector3(0.85, 0.50, 2.85), Vector3(3.65, 0.50, 2.85), Vector3(2.25, 0.50, 1.85), Vector3(2.25, 0.50, 3.85)]:
		_furniture_box(root, Vector3(0.55, 0.80, 0.55), chair_pos, _material_for("wood_dark"), "DiningChair0514").add_to_group("room_detail_0514")

	# Quartos: cômoda e criado-mudo em cada quarto.
	var dresser_a := _furniture_box(root, Vector3(1.60, 1.05, 0.58), Vector3(-2.20, 0.63, -5.10), _material_for("wood_dark"), "DresserA0514")
	dresser_a.add_to_group("room_detail_0514")
	_furniture_box(root, Vector3(0.62, 0.58, 0.62), Vector3(-3.10, 0.46, -3.35), _material_for("wood"), "NightstandA0514").add_to_group("room_detail_0514")
	var dresser_b := _furniture_box(root, Vector3(1.60, 1.05, 0.58), Vector3(5.55, 0.63, -4.95), _material_for("wood_dark"), "DresserB0514")
	dresser_b.add_to_group("room_detail_0514")
	_furniture_box(root, Vector3(0.62, 0.58, 0.62), Vector3(3.45, 0.46, -4.35), _material_for("wood"), "NightstandB0514").add_to_group("room_detail_0514")

	# Banheiro: box, gabinete e armário de remédios.
	_furniture_box(root, Vector3(1.35, 0.14, 1.35), Vector3(5.65, 0.36, -3.85), _material_for("stone_light"), "ShowerTray0514").add_to_group("room_detail_0514")
	var medicine := _furniture_box(root, Vector3(0.82, 0.85, 0.26), Vector3(5.75, 1.55, -1.55), _material_for("metal"), "MedicineCabinet0514")
	medicine.add_to_group("room_detail_0514")

	_mark_room_0514(root, "LivingRoom0514", "room_living_0514", Vector3(-3.6, 0.2, 3.0))
	_mark_room_0514(root, "KitchenRoom0514", "room_kitchen_0514", Vector3(3.8, 0.2, 3.3))
	_mark_room_0514(root, "BedroomARoom0514", "room_bedroom_0514", Vector3(-3.7, 0.2, -3.5))
	_mark_room_0514(root, "BedroomBRoom0514", "room_bedroom_0514", Vector3(2.0, 0.2, -4.0))
	_mark_room_0514(root, "BathroomRoom0514", "room_bathroom_0514", Vector3(4.9, 0.2, -2.5))

func _mark_room_0514(root: Node3D, node_name: String, group_name: String, pos: Vector3) -> void:
	var marker := Node3D.new()
	marker.name = node_name
	marker.position = pos
	marker.add_to_group(group_name)
	root.add_child(marker)

func _upgrade_contextual_loot_0514(root: Node3D, coord: Vector2i, slot: int) -> void:
	if world == null or not world.has_method("register_streamed_interaction"):
		return
	var entries := [
		["Fridge", "loot_fridge", "roomloot0512:%d:%d:%d:fridge" % [coord.x, coord.y, slot]],
		["WardrobeA", "loot_wardrobe", "roomloot0512:%d:%d:%d:wardrobe" % [coord.x, coord.y, slot]],
		["BathroomSink", "loot_bathroom", "roomloot0512:%d:%d:%d:bathroom" % [coord.x, coord.y, slot]],
		["CoffeeTable", "loot_living", "roomloot0512:%d:%d:%d:living" % [coord.x, coord.y, slot]],
		["Pantry0514", "loot_pantry", "roomloot0514:%d:%d:%d:pantry" % [coord.x, coord.y, slot]],
		["DresserA0514", "loot_wardrobe", "roomloot0514:%d:%d:%d:dresser_a" % [coord.x, coord.y, slot]],
		["DresserB0514", "loot_wardrobe", "roomloot0514:%d:%d:%d:dresser_b" % [coord.x, coord.y, slot]],
		["MedicineCabinet0514", "loot_medicine", "roomloot0514:%d:%d:%d:medicine" % [coord.x, coord.y, slot]],
		["Bookshelf0514", "loot_living", "roomloot0514:%d:%d:%d:bookshelf" % [coord.x, coord.y, slot]]
	]
	for entry in entries:
		var node := root.get_node_or_null(str(entry[0])) as Node3D
		if node == null:
			continue
		node.add_to_group("contextual_loot_furniture_0514")
		world.call("register_streamed_interaction", node.global_position, str(entry[1]), str(entry[2]), node, true)

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["internal_doors_0514"] = get_tree().get_nodes_in_group("internal_door_0514").size()
	result["room_details_0514"] = get_tree().get_nodes_in_group("room_detail_0514").size()
	result["room_living_0514"] = get_tree().get_nodes_in_group("room_living_0514").size()
	result["room_kitchen_0514"] = get_tree().get_nodes_in_group("room_kitchen_0514").size()
	result["room_bedroom_0514"] = get_tree().get_nodes_in_group("room_bedroom_0514").size()
	result["room_bathroom_0514"] = get_tree().get_nodes_in_group("room_bathroom_0514").size()
	result["contextual_loot_0514"] = get_tree().get_nodes_in_group("contextual_loot_furniture_0514").size()
	return result
