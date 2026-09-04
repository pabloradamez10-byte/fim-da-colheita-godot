extends "res://scripts/world/world_runtime_3d_v054.gd"

func _create_materials() -> void:
	super._create_materials()
	# Paleta mais escura e menos lavada. As texturas continuam geradas offline,
	# sem depender de arquivos externos, mas com contraste/sujeira mais visíveis.
	materials["grass"] = _textured_mat("v056_grass", "49653a", "263b2b", "grass", 1.0)
	materials["grass_alt"] = _textured_mat("v056_grass_alt", "587341", "314b31", "grass", 1.0)
	materials["grass_dark"] = _textured_mat("v056_grass_dark", "365333", "1f3426", "grass", 1.0)
	materials["fertile"] = _textured_mat("v056_fertile", "5a412e", "2d211a", "dirt", 1.0)
	materials["fertile_alt"] = _textured_mat("v056_fertile_alt", "684a32", "38271d", "dirt", 1.0)
	materials["dry"] = _textured_mat("v056_dry", "806846", "493c2c", "dirt", 1.0)
	materials["road"] = _textured_mat("v056_road", "665843", "3e372e", "road", 1.0)
	materials["road_alt"] = _textured_mat("v056_road_alt", "735f46", "46392d", "road", 1.0)
	materials["asphalt"] = _textured_mat("v056_asphalt", "34393a", "181d1f", "road", 0.97)
	materials["asphalt_dark"] = _textured_mat("v056_asphalt_dark", "292e30", "111517", "road", 0.99)
	materials["concrete"] = _textured_mat("v056_concrete", "88857a", "575951", "stone", 0.98)
	materials["concrete_dark"] = _textured_mat("v056_concrete_dark", "696b65", "41443f", "stone", 0.98)
	materials["dirt_patch"] = _textured_mat("v056_dirt_patch", "5c4632", "2f271e", "dirt", 1.0)
	materials["mud_patch"] = _textured_mat("v056_mud_patch", "414336", "252b25", "mud", 1.0)
	materials["gravel"] = _textured_mat("v056_gravel", "716b60", "42413d", "stone", 1.0)
	materials["lane_yellow"] = _textured_mat("v056_lane_yellow", "b89b36", "776722", "metal", 0.95)
	materials["lane_white"] = _textured_mat("v056_lane_white", "d0cbbb", "85857f", "stone", 0.95)
	materials["vehicle_red"] = _textured_mat("v056_vehicle_red", "713b31", "332724", "rust", 0.72, 0.12)
	materials["vehicle_blue"] = _textured_mat("v056_vehicle_blue", "405864", "26363d", "metal", 0.70, 0.14)
	materials["vehicle_white"] = _textured_mat("v056_vehicle_white", "aaa79c", "686b66", "metal", 0.76, 0.12)
	materials["vehicle_dark"] = _textured_mat("v056_vehicle_dark", "1c1f1f", "080a0a", "rubber", 1.0)
	materials["glass_dark"] = _textured_mat("v056_glass_dark", "31434a", "17262c", "glass", 0.24, 0.05)
	materials["loot"] = _textured_mat("v056_loot", "73502f", "382719", "wood", 1.0)
	materials["roof"] = _textured_mat("v056_roof", "343c3e", "171d1f", "roof", 0.88, 0.08)
	materials["roof_rust"] = _textured_mat("v056_roof_rust", "664236", "302626", "rust", 0.92, 0.10)
	materials["interior_wall"] = _textured_mat("v056_plaster", "9a876a", "665847", "plaster", 1.0)
	materials["interior_floor"] = _textured_mat("v056_floor", "68492f", "35261d", "wood", 1.0)
	materials["wood_old"] = _textured_mat("v056_wood_old", "664b35", "35271c", "wood", 1.0)
	materials["rust"] = _textured_mat("v056_rust", "6e4132", "35251f", "rust", 0.96, 0.08)
	texture_material_count = materials.size()

func _build_environment() -> void:
	super._build_environment()
	for child in get_children():
		if child is WorldEnvironment:
			var environment_node := child as WorldEnvironment
			var env: Environment = environment_node.environment
			if env != null:
				env.background_color = Color("626b5d")
				env.ambient_light_color = Color("b9b5a4")
				env.ambient_light_energy = 0.50
		elif child is DirectionalLight3D:
			var light := child as DirectionalLight3D
			light.light_energy *= 0.82
