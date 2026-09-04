extends "res://scripts/world/city_chunk_streamer_3d_v0511.gd"

const InteractiveHinge0512 = preload("res://scripts/world/interactive_hinge_0512.gd")

func _build_large_house_0511(parent: Node3D, pos: Vector3, coord: Vector2i, slot: int, marker: int, yaw: float) -> void:
	super._build_large_house_0511(parent, pos, coord, slot, marker, yaw)
	var root := parent.get_node_or_null("CityHouse0511_%d_%d_%d" % [coord.x, coord.y, slot]) as Node3D
	if root == null:
		return

	_remove_legacy_room_loot_0512(root, coord, slot)
	_replace_front_wall_0512(root)
	_add_interactive_front_door_0512(root, coord, slot)
	_add_interactive_front_window_0512(root, Vector3(-4.2, 1.7, 6.18), 2.0, 1.25, coord, slot, "left")
	_add_interactive_front_window_0512(root, Vector3(4.2, 1.7, 6.18), 2.0, 1.25, coord, slot, "right")
	_register_room_furniture_loot_0512(root, coord, slot)

func _remove_legacy_room_loot_0512(root: Node3D, coord: Vector2i, slot: int) -> void:
	if world != null and world.has_method("unregister_streamed_key"):
		for suffix in ["kitchen", "bedroom", "bath"]:
			world.call("unregister_streamed_key", "city0511:%d:%d:%d:%s" % [coord.x, coord.y, slot, suffix])
	for raw in get_tree().get_nodes_in_group("loot_container"):
		if raw is Node and root.is_ancestor_of(raw as Node):
			(raw as Node).queue_free()

func _replace_front_wall_0512(root: Node3D) -> void:
	for name in ["FrontLeft", "FrontRight", "FrontDoor"]:
		var old := root.get_node_or_null(name)
		if old != null:
			old.queue_free()
	for pos in [Vector3(-4.2, 1.7, 6.18), Vector3(4.2, 1.7, 6.18)]:
		_remove_mesh_near_0512(root, pos)

	var wall := _material_for("house_plaster_worn")
	# Fachada modular com dois vãos reais de janela e vão central de porta.
	_solid_box(root, Vector3(2.05, 3.05, 0.26), Vector3(-6.275, 1.53, 6.05), wall, "FrontOuterL")
	_solid_box(root, Vector3(2.55, 3.05, 0.26), Vector3(-1.875, 1.53, 6.05), wall, "FrontInnerL")
	_solid_box(root, Vector3(2.55, 3.05, 0.26), Vector3(1.875, 1.53, 6.05), wall, "FrontInnerR")
	_solid_box(root, Vector3(2.05, 3.05, 0.26), Vector3(6.275, 1.53, 6.05), wall, "FrontOuterR")
	for x in [-4.2, 4.2]:
		_solid_box(root, Vector3(2.1, 1.02, 0.26), Vector3(x, 0.51, 6.05), wall, "WindowLower")
		_solid_box(root, Vector3(2.1, 0.70, 0.26), Vector3(x, 2.70, 6.05), wall, "WindowUpper")

func _remove_mesh_near_0512(root: Node3D, local_pos: Vector3) -> void:
	for child in root.get_children():
		if child is MeshInstance3D and (child as MeshInstance3D).position.distance_to(local_pos) < 0.18:
			(child as MeshInstance3D).queue_free()

func _add_interactive_front_door_0512(root: Node3D, coord: Vector2i, slot: int) -> void:
	var hinge := Node3D.new()
	hinge.name = "InteractiveFrontDoor0512"
	hinge.position = Vector3(-0.575, 0.0, 6.11)
	hinge.set_script(InteractiveHinge0512)
	hinge.set("interaction_kind", "door")
	hinge.set("open_angle_degrees", -94.0)
	root.add_child(hinge)
	var panel := _solid_box(hinge, Vector3(1.15, 2.28, 0.18), Vector3(0.575, 1.18, 0), _material_for("door_old"), "Panel")
	panel.add_to_group("functional_door_panel_0512")
	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", root.to_global(Vector3(0, 0.8, 6.11)), "door", "door0512:%d:%d:%d:front" % [coord.x, coord.y, slot], hinge, true)

func _add_interactive_front_window_0512(root: Node3D, center: Vector3, width: float, height: float, coord: Vector2i, slot: int, side: String) -> void:
	var hinge := Node3D.new()
	hinge.name = "InteractiveWindow0512_%s" % side
	hinge.position = center + Vector3(-width * 0.5, 0, 0)
	hinge.set_script(InteractiveHinge0512)
	hinge.set("interaction_kind", "window")
	hinge.set("open_angle_degrees", -78.0 if side == "left" else 78.0)
	root.add_child(hinge)
	var panel := _solid_box(hinge, Vector3(width, height, 0.065), Vector3(width * 0.5, 0, 0), _material_for("glass_dirty"), "Panel")
	panel.add_to_group("functional_window_panel_0512")
	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", root.to_global(center), "window", "window0512:%d:%d:%d:%s" % [coord.x, coord.y, slot, side], hinge, true)

func _register_room_furniture_loot_0512(root: Node3D, coord: Vector2i, slot: int) -> void:
	if world == null or not world.has_method("register_streamed_interaction"):
		return
	var entries := [
		["Fridge", "loot_kitchen", "fridge"],
		["WardrobeA", "loot_bedroom", "wardrobe"],
		["BathroomSink", "loot_bathroom", "bathroom"],
		["CoffeeTable", "loot_living", "living"]
	]
	for entry in entries:
		var node := root.get_node_or_null(str(entry[0])) as Node3D
		if node == null:
			continue
		node.add_to_group("contextual_loot_furniture_0512")
		world.call("register_streamed_interaction", node.global_position, str(entry[1]), "roomloot0512:%d:%d:%d:%s" % [coord.x, coord.y, slot, str(entry[2])], node, true)

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["interactive_doors_0512"] = get_tree().get_nodes_in_group("interactive_door_0512").size()
	result["interactive_windows_0512"] = get_tree().get_nodes_in_group("interactive_window_0512").size()
	result["contextual_loot_0512"] = get_tree().get_nodes_in_group("contextual_loot_furniture_0512").size()
	result["functional_door_panels_0512"] = get_tree().get_nodes_in_group("functional_door_panel_0512").size()
	result["functional_window_panels_0512"] = get_tree().get_nodes_in_group("functional_window_panel_0512").size()
	return result
