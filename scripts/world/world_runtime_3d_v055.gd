extends "res://scripts/world/world_runtime_3d_v054.gd"

func _create_materials() -> void:
	super._create_materials()
	materials["asphalt"] = _textured_mat("asphalt", "2d3131", "171a1a", "road", 0.98)
	materials["concrete"] = _textured_mat("concrete", "85847c", "5e5e59", "stone", 0.96)
	materials["lane_yellow"] = _textured_mat("lane_yellow", "c49a32", "8e6d22", "road", 0.90)
	materials["lane_white"] = _textured_mat("lane_white", "d6d5c8", "9c9b91", "road", 0.90)
	materials["vehicle_red"] = _textured_mat("vehicle_red", "754032", "3e2723", "metal", 0.68, 0.16)
	materials["vehicle_blue"] = _textured_mat("vehicle_blue", "384f5c", "25343a", "metal", 0.68, 0.16)
	materials["vehicle_white"] = _textured_mat("vehicle_white", "aaa79b", "6f706d", "metal", 0.72, 0.14)
	materials["vehicle_dark"] = _textured_mat("vehicle_dark", "292d2c", "171a19", "metal", 0.74, 0.18)
	materials["glass_dark"] = _textured_mat("glass_dark", "40535a", "1d2b30", "glass", 0.18, 0.08)
	materials["loot"] = _textured_mat("loot", "765328", "3f2d19", "wood", 0.92)
