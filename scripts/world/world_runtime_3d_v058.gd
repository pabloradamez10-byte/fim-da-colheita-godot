extends "res://scripts/world/world_runtime_3d_v056.gd"

const PlayerV058Script = preload("res://scripts/player/player_3d_v058.gd")

func _create_materials() -> void:
	super._create_materials()
	# Passo visual rumo a um survival isométrico mais denso: menos saturação e mais contraste de materiais.
	materials["grass"] = _textured_mat("v058_grass", "3f5936", "233629", "grass", 1.0)
	materials["grass_alt"] = _textured_mat("v058_grass_alt", "4a633c", "2b402e", "grass", 1.0)
	materials["grass_dark"] = _textured_mat("v058_grass_dark", "30482f", "1d2d22", "grass", 1.0)
	materials["asphalt"] = _textured_mat("v058_asphalt", "303536", "15191b", "road", 0.99)
	materials["asphalt_dark"] = _textured_mat("v058_asphalt_dark", "23282a", "0e1113", "road", 1.0)
	materials["sidewalk"] = _textured_mat("v058_sidewalk", "85837b", "555650", "stone", 0.98)
	materials["curb"] = _textured_mat("v058_curb", "77776f", "4b4d48", "stone", 0.98)
	materials["driveway"] = _textured_mat("v058_driveway", "67665f", "3d403c", "stone", 1.0)
	materials["dirt_dark"] = _textured_mat("v058_dirt_dark", "574231", "2b231d", "dirt", 1.0)
	materials["road_marking_yellow"] = _textured_mat("v058_yellow", "b59a38", "71631f", "metal", 0.94)
	materials["road_marking_white"] = _textured_mat("v058_white", "c8c5b9", "83837d", "stone", 0.96)
	materials["fence_metal"] = _textured_mat("v058_fence", "555a58", "303533", "metal", 0.80, 0.12)
	materials["trash"] = _textured_mat("v058_trash", "3d4a43", "202825", "metal", 0.95)
	texture_material_count = materials.size()

func _build_environment() -> void:
	super._build_environment()
	for child in get_children():
		if child is WorldEnvironment:
			var environment_node := child as WorldEnvironment
			var env: Environment = environment_node.environment
			if env != null:
				env.background_color = Color("555e53")
				env.ambient_light_color = Color("aca99c")
				env.ambient_light_energy = 0.46

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV058Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.75, 3.5))
