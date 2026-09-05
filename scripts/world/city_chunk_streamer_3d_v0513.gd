extends "res://scripts/world/city_chunk_streamer_3d_v0512.gd"

const WATER_BLOCK_HEIGHT_0513 := 2.40

func _replace_front_wall_0512(root: Node3D) -> void:
	# 0.5.13: mantém os vãos reais da 0.5.12, mas alarga a passagem central.
	for name in ["FrontLeft", "FrontRight", "FrontDoor", "FrontOuterL", "FrontInnerL", "FrontInnerR", "FrontOuterR"]:
		var old := root.get_node_or_null(name)
		if old != null:
			old.queue_free()
	for pos in [Vector3(-4.2, 1.7, 6.18), Vector3(4.2, 1.7, 6.18)]:
		_remove_mesh_near_0512(root, pos)

	var wall := _material_for("house_plaster_worn")
	_solid_box(root, Vector3(2.05, 3.05, 0.26), Vector3(-6.275, 1.53, 6.05), wall, "FrontOuterL")
	_solid_box(root, Vector3(2.35, 3.05, 0.26), Vector3(-1.975, 1.53, 6.05), wall, "FrontInnerL")
	_solid_box(root, Vector3(2.35, 3.05, 0.26), Vector3(1.975, 1.53, 6.05), wall, "FrontInnerR")
	_solid_box(root, Vector3(2.05, 3.05, 0.26), Vector3(6.275, 1.53, 6.05), wall, "FrontOuterR")
	for x in [-4.2, 4.2]:
		_solid_box(root, Vector3(2.1, 1.02, 0.26), Vector3(x, 0.51, 6.05), wall, "WindowLower")
		_solid_box(root, Vector3(2.1, 0.70, 0.26), Vector3(x, 2.70, 6.05), wall, "WindowUpper")

func _add_interactive_front_door_0512(root: Node3D, coord: Vector2i, slot: int) -> void:
	var hinge := Node3D.new()
	hinge.name = "InteractiveFrontDoor0512"
	hinge.position = Vector3(-0.64, 0.0, 6.11)
	hinge.set_script(InteractiveHinge0512)
	hinge.set("interaction_kind", "door")
	hinge.set("open_angle_degrees", -108.0)
	root.add_child(hinge)
	# Porta visual um pouco mais larga que na 0.5.12; collider é reduzido pelo hinge.
	var panel := _solid_box(hinge, Vector3(1.28, 2.28, 0.16), Vector3(0.64, 1.18, 0), _material_for("door_old"), "Panel")
	panel.add_to_group("functional_door_panel_0512")
	panel.add_to_group("functional_door_panel_0513")
	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", root.to_global(Vector3(0, 0.8, 6.11)), "door", "door0512:%d:%d:%d:front" % [coord.x, coord.y, slot], hinge, true)

func _create_terrain_multimesh(parent: Node3D, id: String, transforms: Array) -> void:
	super._create_terrain_multimesh(parent, id, transforms)
	if id != "water" or transforms.is_empty():
		return
	var body := StaticBody3D.new()
	body.name = "StreamWaterBlocker0513"
	body.add_to_group("water_blocker_0513")
	body.add_to_group("stream_water_blocker_0513")
	parent.add_child(body)
	for raw in transforms:
		var t := raw as Transform3D
		var shape := BoxShape3D.new()
		shape.size = Vector3(CELL_SIZE * 0.94, WATER_BLOCK_HEIGHT_0513, CELL_SIZE * 0.94)
		var collision := CollisionShape3D.new()
		collision.shape = shape
		collision.position = Vector3(t.origin.x, 0.92, t.origin.z)
		body.add_child(collision)

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["door_clearance_0513"] = get_tree().get_nodes_in_group("door_clearance_0513").size()
	result["water_blockers_0513"] = get_tree().get_nodes_in_group("water_blocker_0513").size()
	return result
