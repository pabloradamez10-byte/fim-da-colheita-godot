extends "res://scripts/world/city_chunk_streamer_3d_v0517.gd"

func _build_large_house_0511(parent: Node3D, pos: Vector3, coord: Vector2i, slot: int, marker: int, yaw: float) -> void:
	super._build_large_house_0511(parent, pos, coord, slot, marker, yaw)
	var root := parent.get_node_or_null("CityHouse0511_%d_%d_%d" % [coord.x, coord.y, slot]) as Node3D
	if root == null:
		return
	root.add_to_group("shelter_structure_0521")
	_register_bed_0521(root, "BedA", coord, slot, "a")
	_register_bed_0521(root, "BedB", coord, slot, "b")

func _register_bed_0521(root: Node3D, node_name: String, coord: Vector2i, slot: int, suffix: String) -> void:
	var bed := root.get_node_or_null(node_name) as Node3D
	if bed == null:
		return
	bed.add_to_group("sleep_surface_0521")
	if world != null and world.has_method("register_streamed_interaction"):
		world.call(
			"register_streamed_interaction",
			bed.global_position,
			"sleep_bed_0521",
			"sleep0521:%d:%d:%d:%s" % [coord.x, coord.y, slot, suffix],
			bed,
			true
		)

func _build_rural_house(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_house(parent, pos, coord)
	var root := parent.get_node_or_null("RuralHouse_%d_%d" % [coord.x, coord.y]) as Node3D
	if root != null:
		root.add_to_group("shelter_structure_0521")

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["shelters_0521"] = get_tree().get_nodes_in_group("shelter_structure_0521").size()
	result["beds_0521"] = get_tree().get_nodes_in_group("sleep_surface_0521").size()
	return result
