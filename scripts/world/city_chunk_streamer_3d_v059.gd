extends "res://scripts/world/city_chunk_streamer_3d_v058.gd"

func _build_garage(parent: Node3D, pos: Vector3, coord: Vector2i, variant: int) -> void:
	super._build_garage(parent, pos, coord, variant)
	var root := parent.get_node_or_null("CityGarage_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	if root.get_node_or_null("GarageDoorCollider059") == null:
		var door := _solid_box(root, Vector3(5.85, 2.45, 0.22), Vector3(0, 1.45, 4.02), _material_for("metal"), "GarageDoorCollider059")
		door.add_to_group("garage_door_collision")

func _build_rural_garage(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_garage(parent, pos, coord)
	var root := parent.get_node_or_null("RuralGarage_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	if root.get_node_or_null("RuralGarageDoorCollider059") == null:
		var door := _solid_box(root, Vector3(5.7, 2.35, 0.22), Vector3(0, 1.40, 3.42), _material_for("metal"), "RuralGarageDoorCollider059")
		door.add_to_group("garage_door_collision")

func get_city_debug_metrics() -> Dictionary:
	var result: Dictionary = super.get_city_debug_metrics()
	result["garage_door_colliders"] = get_tree().get_nodes_in_group("garage_door_collision").size()
	return result
