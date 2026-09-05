extends "res://scripts/world/world_runtime_3d_v0514.gd"

func _build_environment() -> void:
	super._build_environment()
	_install_visual_materials_0515()
	for child in get_children():
		if child is WorldEnvironment:
			var world_env := child as WorldEnvironment
			if world_env.environment != null:
				world_env.environment.background_color = Color("65705f")
				world_env.environment.ambient_light_color = Color("b8b39d")
				world_env.environment.ambient_light_energy = 0.50
		elif child is DirectionalLight3D:
			var light := child as DirectionalLight3D
			if light.shadow_enabled:
				light.light_energy = 1.04
				light.light_color = Color("f2d8aa")
			else:
				light.light_energy = 0.16
				light.light_color = Color("8796a1")

func _install_visual_materials_0515() -> void:
	materials["grass_dead_0515"] = _textured_mat("grass_dead_0515", "677151", "3e4632", "grass", 1.0)
	materials["mud_stain_0515"] = _textured_mat("mud_stain_0515", "5b4636", "332a24", "mud", 1.0)
	materials["wall_stain_0515"] = _textured_mat("wall_stain_0515", "6d6658", "3c3832", "plaster", 1.0)
	materials["roof_moss_0515"] = _textured_mat("roof_moss_0515", "46583a", "283421", "leaf", 1.0)
	materials["trash_dark_0515"] = _textured_mat("trash_dark_0515", "2c302d", "171a18", "fabric", 1.0)
	materials["wood_bleached_0515"] = _textured_mat("wood_bleached_0515", "786b58", "493f35", "wood", 1.0)
	materials["concrete_cracked_0515"] = _textured_mat("concrete_cracked_0515", "777269", "4e4b45", "stone", 1.0)
	texture_material_count = materials.size()

func _generate_ground_details() -> void:
	super._generate_ground_details()
	_add_macro_ground_breakup_0515()

func _add_macro_ground_breakup_0515() -> void:
	if generated_root == null:
		return
	var half: int = MAP_SIZE / 2
	var placed: int = 0
	for gz in range(-half, half, 2):
		for gx in range(-half, half, 2):
			if placed >= 72:
				return
			var marker: int = int(abs(hash("macro0515:%d:%d:%d" % [world_seed, gx, gz]))) % 100
			if marker > 24:
				continue
			var h: float = height_noise.get_noise_2d(float(gx), float(gz))
			var m: float = moisture_noise.get_noise_2d(float(gx), float(gz))
			var terrain: String = _terrain_id(gx, gz, h, m)
			if terrain in ["water", "rock", "road"]:
				continue
			var px: float = float(gx) * CELL_SIZE + float((marker % 7) - 3) * 0.38
			var pz: float = float(gz) * CELL_SIZE + float((marker % 5) - 2) * 0.46
			var mat: Material = materials["grass_dead_0515"] if marker % 2 == 0 else materials["mud_stain_0515"]
			_organic_patch_0515(Vector3(px, 0.135, pz), 1.7 + float(marker % 5) * 0.28, 0.9 + float(marker % 4) * 0.22, float(marker % 31) * 0.17, mat)
			placed += 1

func _organic_patch_0515(pos: Vector3, radius_x: float, radius_z: float, yaw: float, mat: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = 0.028
	mesh.radial_segments = 10
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.rotation.y = yaw
	node.scale = Vector3(radius_x, 1.0, radius_z)
	node.add_to_group("macro_ground_breakup_0515")
	generated_root.add_child(node)

func get_debug_0515() -> Dictionary:
	return {
		"macro_ground_patches": get_tree().get_nodes_in_group("macro_ground_breakup_0515").size(),
		"visual_materials": 7
	}
