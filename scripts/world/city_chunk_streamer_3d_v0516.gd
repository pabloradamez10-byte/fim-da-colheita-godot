extends "res://scripts/world/city_chunk_streamer_3d_v0515.gd"

const InteractiveHinge0516 = preload("res://scripts/world/interactive_hinge_0512.gd")

func _build_large_house_0511(parent: Node3D, pos: Vector3, coord: Vector2i, slot: int, marker: int, yaw: float) -> void:
	super._build_large_house_0511(parent, pos, coord, slot, marker, yaw)
	var root := parent.get_node_or_null("CityHouse0511_%d_%d_%d" % [coord.x, coord.y, slot]) as Node3D
	if root == null:
		return
	_make_residential_entry_walkable_0516(root)
	_ensure_residential_front_door_0516(root, coord, slot)

func _make_residential_entry_walkable_0516(root: Node3D) -> void:
	# O player atual se move em um plano e não possui step-up automático. Pisos/degraus
	# muito baixos viravam uma parede invisível na entrada. Mantemos o visual, mas
	# retiramos colisão apenas das superfícies horizontais de acesso.
	for node_name in ["Foundation", "FrontPorch", "PorchStep"]:
		var body := root.get_node_or_null(node_name) as StaticBody3D
		if body == null:
			continue
		_disable_body_collision_0516(body)
		body.add_to_group("walkable_threshold_0516")

func _disable_body_collision_0516(body: StaticBody3D) -> void:
	body.collision_layer = 0
	body.collision_mask = 0
	for child in body.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", true)

func _ensure_residential_front_door_0516(root: Node3D, coord: Vector2i, slot: int) -> void:
	var hinge := root.get_node_or_null("InteractiveFrontDoor0512") as Node3D
	if hinge == null:
		hinge = Node3D.new()
		hinge.name = "InteractiveFrontDoor0512"
		hinge.position = Vector3(-0.64, 0.0, 6.11)
		hinge.set_script(InteractiveHinge0516)
		hinge.set("interaction_kind", "door")
		hinge.set("open_angle_degrees", -108.0)
		hinge.set("transition_seconds", 0.13)
		root.add_child(hinge)
		var panel := _solid_box(hinge, Vector3(1.28, 2.28, 0.14), Vector3(0.64, 1.18, 0.0), _material_for("door_old"), "Panel")
		panel.add_to_group("functional_door_panel_0512")
		panel.add_to_group("functional_door_panel_0516")
	else:
		hinge.add_to_group("front_door_verified_0516")

	if world != null and world.has_method("register_streamed_interaction"):
		world.call("register_streamed_interaction", root.to_global(Vector3(0.0, 0.8, 6.11)), "door", "door0512:%d:%d:%d:front" % [coord.x, coord.y, slot], hinge, true)

func _build_rural_house(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_house(parent, pos, coord)
	var root := parent.get_node_or_null("RuralHouse_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	# Mesmo problema de degrau existia no piso rural.
	var floor_body := root.get_node_or_null("RuralFloor") as StaticBody3D
	if floor_body != null:
		_disable_body_collision_0516(floor_body)
		floor_body.add_to_group("walkable_threshold_0516")
	# As casas rurais antigas tinham somente o vão. Agora todas recebem uma porta funcional.
	if root.get_node_or_null("InteractiveRuralDoor0516") == null:
		var hinge := Node3D.new()
		hinge.name = "InteractiveRuralDoor0516"
		hinge.position = Vector3(-0.58, 0.0, 3.46)
		hinge.set_script(InteractiveHinge0516)
		hinge.set("interaction_kind", "door")
		hinge.set("open_angle_degrees", -105.0)
		hinge.set("transition_seconds", 0.13)
		root.add_child(hinge)
		var panel := _solid_box(hinge, Vector3(1.16, 2.18, 0.13), Vector3(0.58, 1.12, 0.0), _material_for("door_old"), "Panel")
		panel.add_to_group("functional_rural_door_0516")
		hinge.add_to_group("rural_door_0516")
		if world != null and world.has_method("register_streamed_interaction"):
			world.call("register_streamed_interaction", root.to_global(Vector3(0.0, 0.8, 3.46)), "door", "door0516:rural:%d:%d" % [coord.x, coord.y], hinge, true)

func get_city_debug_metrics() -> Dictionary:
	var result: Dictionary = super.get_city_debug_metrics()
	result["walkable_thresholds_0516"] = get_tree().get_nodes_in_group("walkable_threshold_0516").size()
	result["front_doors_verified_0516"] = get_tree().get_nodes_in_group("front_door_verified_0516").size()
	result["rural_doors_0516"] = get_tree().get_nodes_in_group("rural_door_0516").size()
	return result
