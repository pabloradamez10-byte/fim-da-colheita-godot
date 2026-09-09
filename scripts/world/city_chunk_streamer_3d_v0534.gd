extends "res://scripts/world/city_chunk_streamer_3d_v0530.gd"

const CITY_POI_ROLES_0534 := ["hospital", "market", "workshop", "police"]
const CITY_POI_LABELS_0534 := {
	"hospital": "POSTO MÉDICO",
	"market": "MERCADO",
	"workshop": "OFICINA",
	"police": "DELEGACIA",
	"farm": "FAZENDA"
}
const CITY_POI_COLORS_0534 := {
	"hospital": Color("d6dfd9"),
	"market": Color("9aa85e"),
	"workshop": Color("b07b4c"),
	"police": Color("61758c"),
	"farm": Color("7b6a3f")
}

func _build_city_lot(parent: Node3D, origin: Vector3, coord: Vector2i, local: Vector2i, marker: int) -> void:
	super._build_city_lot(parent, origin, coord, local, marker)
	var block := _block_key(coord)
	var sub := _block_sub(coord)
	var slot := sub.y * 2 + sub.x
	var role_marker := int(abs(hash("poi0534:%d:%d:%d" % [world_seed, block.x, block.y])))
	# Um POI especializado a cada três quadras, mantendo a cidade majoritariamente residencial.
	if role_marker % 3 != 0:
		return
	var selected_slot := int(role_marker / 3) % 4
	if slot != selected_slot:
		return
	var role := str(CITY_POI_ROLES_0534[int(role_marker / 11) % CITY_POI_ROLES_0534.size()])
	var building := _last_city_building_0534(parent)
	if building == null:
		return
	_decorate_location_0534(building, role, "city0534:%d:%d:%d" % [block.x, block.y, slot])

func _build_rural_house(parent: Node3D, pos: Vector3, coord: Vector2i) -> void:
	super._build_rural_house(parent, pos, coord)
	var root := parent.get_node_or_null("RuralHouse_%d_%d" % [coord.x, coord.y]) as Node3D
	if root == null:
		return
	_decorate_location_0534(root, "farm", "farm0534:%d:%d" % [coord.x, coord.y])

func _last_city_building_0534(parent: Node3D) -> Node3D:
	var found: Node3D = null
	for raw in parent.get_children():
		if raw is Node3D and (raw as Node3D).is_in_group("city_building"):
			found = raw as Node3D
	return found

func _decorate_location_0534(root: Node3D, role: String, key_base: String) -> void:
	if root == null or root.has_meta("poi_role_0534"):
		return
	root.set_meta("poi_role_0534", role)
	root.add_to_group("poi_location_0534")
	root.add_to_group("poi_%s_0534" % role)

	var color := CITY_POI_COLORS_0534.get(role, Color("8a806f")) as Color
	var sign := _poi_box_0534(root, Vector3(3.3, 0.56, 0.16), Vector3(0.0, 2.72, 6.35), color, "PoiSign0534")
	sign.add_to_group("poi_sign_0534")
	var label := Label3D.new()
	label.name = "PoiLabel0534"
	label.text = str(CITY_POI_LABELS_0534.get(role, role.to_upper()))
	label.position = Vector3(0.0, 2.72, 6.46)
	label.font_size = 34
	label.pixel_size = 0.009
	label.outline_size = 6
	label.modulate = Color(0.98, 0.97, 0.90, 1.0)
	root.add_child(label)

	var offsets := [Vector3(-2.35, 0.48, 1.55), Vector3(2.15, 0.48, -1.55)]
	if role == "farm":
		offsets = [Vector3(-1.75, 0.48, 1.25), Vector3(1.75, 0.48, 1.25)]
	for i in range(offsets.size()):
		var crate := _poi_box_0534(root, Vector3(1.05, 0.92, 0.72), offsets[i], color.darkened(0.28), "PoiLoot0534_%d" % i)
		crate.add_to_group("poi_loot_0534")
		crate.set_meta("poi_role_0534", role)
		crate.set_meta("poi_key_0534", "%s:%d" % [key_base, i])
		if world != null and world.has_method("register_streamed_interaction"):
			world.call(
				"register_streamed_interaction",
				crate.global_position,
				"loot_poi_%s" % role,
				"%s:%d" % [key_base, i],
				crate,
				true
			)

func _poi_box_0534(parent: Node3D, size_value: Vector3, pos: Vector3, color: Color, node_name: String) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size_value
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	mesh.material = material
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

func get_location_catalog_0534() -> Dictionary:
	return {
		"city_roles": CITY_POI_ROLES_0534.duplicate(),
		"rural_role": "farm",
		"labels": CITY_POI_LABELS_0534.duplicate(true)
	}

func get_city_debug_metrics() -> Dictionary:
	var result := super.get_city_debug_metrics()
	result["poi_locations_0534"] = get_tree().get_nodes_in_group("poi_location_0534").size()
	result["poi_loot_0534"] = get_tree().get_nodes_in_group("poi_loot_0534").size()
	result["poi_hospital_0534"] = get_tree().get_nodes_in_group("poi_hospital_0534").size()
	result["poi_market_0534"] = get_tree().get_nodes_in_group("poi_market_0534").size()
	result["poi_workshop_0534"] = get_tree().get_nodes_in_group("poi_workshop_0534").size()
	result["poi_police_0534"] = get_tree().get_nodes_in_group("poi_police_0534").size()
	result["poi_farm_0534"] = get_tree().get_nodes_in_group("poi_farm_0534").size()
	return result
