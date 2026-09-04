extends "res://scripts/world/world_runtime_3d_v055.gd"

func _create_materials() -> void:
	super._create_materials()
	# Paleta mais próxima de um survival isométrico: menos saturação e transições mais naturais.
	materials["city_grass"] = _textured_mat("city_grass057", "536a43", "394b35", "grass", 1.0)
	materials["grass_dark"] = _textured_mat("grass_dark057", "3f5638", "2d3e2b", "grass", 1.0)
	materials["dirt_patch"] = _textured_mat("dirt_patch057", "685342", "46372d", "dirt", 1.0)
	materials["dirt_dark"] = _textured_mat("dirt_dark057", "544237", "382d27", "dirt", 1.0)
	materials["asphalt"] = _textured_mat("asphalt057", "34383a", "202426", "road", 1.0)
	materials["asphalt_dark"] = _textured_mat("asphalt_dark057", "25292b", "171a1c", "road", 1.0)
	materials["sidewalk"] = _textured_mat("sidewalk057", "777a78", "5b5f5d", "stone", 0.98)
	materials["curb"] = _textured_mat("curb057", "8b8d88", "696b68", "stone", 0.98)
	materials["driveway"] = _textured_mat("driveway057", "60625f", "444744", "stone", 1.0)
	materials["brick"] = _textured_mat("brick057", "744637", "4a3029", "rust", 1.0)
	materials["brick_dark"] = _textured_mat("brick_dark057", "56362d", "38251f", "rust", 1.0)
	materials["roof_shingle"] = _textured_mat("roof_shingle057", "333a3e", "24292c", "roof", 0.96)
	materials["road_marking_yellow"] = _textured_mat("road_yellow057", "aa8c3a", "79672f", "road", 0.92)
	materials["road_marking_white"] = _textured_mat("road_white057", "c4c4ba", "96978f", "road", 0.92)
	materials["trash"] = _textured_mat("trash057", "343936", "232725", "metal", 0.9, 0.08)
	materials["fence_metal"] = _textured_mat("fence057", "4a4e4b", "303431", "metal", 0.86, 0.16)
