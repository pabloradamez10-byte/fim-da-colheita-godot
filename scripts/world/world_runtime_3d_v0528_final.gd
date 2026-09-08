extends "res://scripts/world/world_runtime_3d_v0528.gd"

func _draw_piece_0527(root: Node3D, piece_id: String, override_material: Material, solid: bool, open_state: bool) -> void:
	if piece_id not in ["barricade", "campfire"]:
		super._draw_piece_0527(root, piece_id, override_material, solid, open_state)
		return
	var wood_mat: Material = override_material if override_material != null else materials["wood"]
	var dark_mat: Material = override_material if override_material != null else materials["wood_dark"]
	var stone_mat: Material = override_material if override_material != null else materials["rock"]
	if piece_id == "barricade":
		if solid:
			_solid_box(root, Vector3(2.74, 0.42, 0.62), Vector3(0.0, 0.32, 0.0), dark_mat, "BarricadeCollider0528")
		else:
			_box(root, Vector3(2.74, 0.42, 0.62), Vector3(0.0, 0.32, 0.0), dark_mat)
		for x: float in [-1.05, -0.52, 0.0, 0.52, 1.05]:
			var spike_root := Node3D.new()
			spike_root.position = Vector3(x, 0.54, -0.10)
			spike_root.rotation_degrees.x = -32.0
			root.add_child(spike_root)
			_box(spike_root, Vector3(0.14, 1.42, 0.14), Vector3(0.0, 0.55, 0.0), wood_mat)
		_box(root, Vector3(2.78, 0.14, 0.14), Vector3(0.0, 0.72, 0.13), wood_mat)
	elif piece_id == "campfire":
		for angle_index in range(8):
			var angle: float = float(angle_index) / 8.0 * TAU
			var stone_pos := Vector3(cos(angle) * 0.56, 0.12, sin(angle) * 0.56)
			_box(root, Vector3(0.34, 0.22, 0.28), stone_pos, stone_mat)
		var log_a := Node3D.new()
		log_a.rotation_degrees.y = 42.0
		root.add_child(log_a)
		_box(log_a, Vector3(1.05, 0.16, 0.18), Vector3(0.0, 0.18, 0.0), dark_mat)
		var log_b := Node3D.new()
		log_b.rotation_degrees.y = -42.0
		root.add_child(log_b)
		_box(log_b, Vector3(1.05, 0.16, 0.18), Vector3(0.0, 0.22, 0.0), wood_mat)
		if solid:
			_create_campfire_flame_0528(root)
