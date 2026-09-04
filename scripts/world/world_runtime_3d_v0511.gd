extends "res://scripts/world/world_runtime_3d_v0510.gd"

func _create_materials() -> void:
	super._create_materials()
	# Materiais alinhados à Atlas Art Bible: naturais, dessaturados e envelhecidos.
	materials["house_plaster"] = _textured_mat("v0511_house_plaster", "8a806e", "5c554a", "stone", 0.98)
	materials["house_plaster_worn"] = _textured_mat("v0511_house_plaster_worn", "766b5b", "413d35", "stone", 1.0)
	materials["brick_weathered"] = _textured_mat("v0511_brick_weathered", "735044", "382b27", "stone", 1.0)
	materials["wood_siding"] = _textured_mat("v0511_wood_siding", "6b5541", "382d25", "wood", 1.0)
	materials["wood_floor_old"] = _textured_mat("v0511_wood_floor_old", "66513d", "332a22", "wood", 0.98)
	materials["tile_floor_old"] = _textured_mat("v0511_tile_floor_old", "77736b", "4c4944", "stone", 0.98)
	materials["interior_wall_worn"] = _textured_mat("v0511_interior_wall", "a29a88", "676153", "stone", 0.98)
	materials["roof_ceramic_old"] = _textured_mat("v0511_roof_ceramic", "6f4035", "342725", "dirt", 1.0)
	materials["roof_zinc_old"] = _textured_mat("v0511_roof_zinc", "565b58", "2e3433", "metal", 0.88, 0.18)
	materials["glass_dirty"] = _textured_mat("v0511_glass_dirty", "667c78", "293a3a", "metal", 0.58, 0.20)
	materials["door_old"] = _textured_mat("v0511_door_old", "574437", "2d241f", "wood", 1.0)
	materials["porch_wood"] = _textured_mat("v0511_porch_wood", "5f4b37", "30261e", "wood", 1.0)
	materials["moss"] = _textured_mat("v0511_moss", "455a39", "263522", "grass", 1.0)
	texture_material_count = materials.size()
