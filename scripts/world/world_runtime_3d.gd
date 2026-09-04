extends Node3D

const Player3DScript = preload("res://scripts/player/player_3d.gd")
const Zombie3DScript = preload("res://scripts/entities/zombie_3d.gd")

const SAVE_PATH := "user://fim_da_colheita_alpha_0_5_2.save.json"
const SAVE_VERSION := "0.5.2"
const CELL_SIZE := 4.0
const MAP_SIZE := 34

var world_seed: int = 104729
var farm_layout: int = 0
var rng := RandomNumberGenerator.new()
var height_noise := FastNoiseLite.new()
var moisture_noise := FastNoiseLite.new()
var materials: Dictionary = {}
var texture_cache: Dictionary = {}
var interactables: Array[Dictionary] = []
var harvested_keys: Array[String] = []
var generated_root: Node3D
var actors_root: Node3D
var player: CharacterBody3D
var save_cache: Dictionary = {}

var collider_count: int = 0
var texture_material_count: int = 0
var farmhouse_roof: Node3D = null
var farmhouse_interior: Node3D = null
var farmhouse_trigger: Area3D = null

func _ready() -> void:
	_load_save()
	_build_environment()
	_generate_world()
	_spawn_player()
	_spawn_zombies(14)
	_setup_autosave()

func _build_environment() -> void:
	_create_materials()
	var environment_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("7f8972")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d8d0b8")
	env.ambient_light_energy = 0.66
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_node.environment = env
	add_child(environment_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54.0, -38.0, 0.0)
	sun.light_energy = 1.18
	sun.light_color = Color("ffe8bd")
	sun.shadow_enabled = true
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-38.0, 142.0, 0.0)
	fill.light_energy = 0.22
	fill.light_color = Color("9fb2c0")
	fill.shadow_enabled = false
	add_child(fill)

func _create_materials() -> void:
	materials = {
		"grass": _textured_mat("grass", "607e49", "334c31", "grass", 0.96),
		"grass_alt": _textured_mat("grass_alt", "718d52", "465e38", "grass", 0.96),
		"fertile": _textured_mat("fertile", "624733", "30271f", "dirt", 1.0),
		"fertile_alt": _textured_mat("fertile_alt", "73523a", "403025", "dirt", 1.0),
		"dry": _textured_mat("dry", "927c58", "64533d", "dirt", 1.0),
		"road": _textured_mat("road", "7d6c52", "51473a", "road", 1.0),
		"road_alt": _textured_mat("road_alt", "927858", "5d4d3c", "road", 1.0),
		"wetland": _textured_mat("wetland", "4f6855", "2d473f", "mud", 0.92),
		"water": _textured_mat("water", "3e6974", "234854", "water", 0.28, 0.08),
		"rock": _textured_mat("rock", "77766e", "4c4e4c", "stone", 0.92),
		"stone_light": _textured_mat("stone_light", "918e83", "62625d", "stone", 0.92),
		"wood": _textured_mat("wood", "6b472d", "3d281c", "wood", 0.92),
		"wood_old": _textured_mat("wood_old", "79593d", "483522", "wood", 0.98),
		"wood_dark": _textured_mat("wood_dark", "413024", "241b17", "wood", 1.0),
		"roof": _textured_mat("roof", "41494a", "242a2b", "roof", 0.78, 0.12),
		"roof_rust": _textured_mat("roof_rust", "6f4b3b", "393738", "roof", 0.84, 0.16),
		"rust": _textured_mat("rust", "7f4935", "4a2b25", "rust", 0.9, 0.10),
		"window": _textured_mat("window", "7598a4", "46666f", "glass", 0.18, 0.06),
		"leaf": _textured_mat("leaf", "385733", "243b25", "leaf", 1.0),
		"leaf2": _textured_mat("leaf2", "536e3d", "324a2e", "leaf", 1.0),
		"crop": _textured_mat("crop", "718c3e", "405b2e", "leaf", 1.0),
		"metal": _textured_mat("metal", "555b59", "303534", "metal", 0.62, 0.34),
		"cloth": _textured_mat("cloth", "4a5143", "30372f", "fabric", 1.0),
		"interior_floor": _textured_mat("interior_floor", "805c3c", "4a3527", "wood", 0.96),
		"interior_wall": _textured_mat("interior_wall", "b39b76", "806e58", "plaster", 1.0),
		"highlight": _textured_mat("highlight", "c39a45", "7c632d", "metal", 0.72, 0.08)
	}
	texture_material_count = materials.size()

func _textured_mat(key: String, base_hex: String, accent_hex: String, pattern: String, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.albedo_texture = _make_texture(key, Color(base_hex), Color(accent_hex), pattern)
	mat.roughness = roughness
	mat.metallic = metallic
	return mat

func _make_texture(key: String, base: Color, accent: Color, pattern: String) -> ImageTexture:
	if texture_cache.has(key):
		return texture_cache[key] as ImageTexture
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = abs(hash(key)) + 137
	for y in range(64):
		for x in range(64):
			var noise: float = local_rng.randf_range(0.0, 1.0)
			var t: float = noise * 0.20
			if pattern == "wood":
				t += 0.24 if (x % 12) < 2 else 0.0
				t += 0.10 if ((x + y / 5) % 23) < 2 else 0.0
			elif pattern == "roof":
				t += 0.28 if (x % 9) < 2 else 0.0
				t += 0.10 if (y % 17) < 2 else 0.0
			elif pattern == "road":
				t += 0.18 if noise > 0.82 else 0.0
				t += 0.10 if (x + y) % 21 < 2 else 0.0
			elif pattern == "grass" or pattern == "leaf":
				t += 0.24 if noise > 0.86 else 0.0
				t += 0.08 if ((x * 3 + y * 7) % 19) < 3 else 0.0
			elif pattern == "stone" or pattern == "dirt" or pattern == "mud":
				t += 0.30 if noise > 0.88 else 0.0
			elif pattern == "rust":
				t += 0.34 if noise > 0.76 else 0.0
			elif pattern == "water":
				t += 0.16 if (y % 8) < 2 else 0.0
			elif pattern == "plaster":
				t += 0.12 if noise > 0.90 else 0.0
			elif pattern == "fabric":
				t += 0.10 if ((x + y) % 8) < 2 else 0.0
			elif pattern == "glass":
				t += 0.12 if (x + y) % 16 < 2 else 0.0
			elif pattern == "metal":
				t += 0.16 if noise > 0.90 else 0.0
			image.set_pixel(x, y, base.lerp(accent, clampf(t, 0.0, 0.72)))
	var texture := ImageTexture.create_from_image(image)
	texture_cache[key] = texture
	return texture

func _generate_world() -> void:
	if generated_root != null and is_instance_valid(generated_root):
		generated_root.queue_free()
	generated_root = Node3D.new()
	generated_root.name = "GeneratedWorld"
	add_child(generated_root)
	interactables.clear()
	collider_count = 0
	farmhouse_roof = null
	farmhouse_interior = null
	farmhouse_trigger = null
	rng.seed = world_seed
	height_noise.seed = world_seed
	height_noise.frequency = 0.045
	height_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	moisture_noise.seed = world_seed + 9173
	moisture_noise.frequency = 0.055
	moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	farm_layout = abs(world_seed) % 4
	_generate_terrain()
	_generate_ground_details()
	_generate_nature()
	_generate_farm()
	_generate_secondary_pois()

func _generate_terrain() -> void:
	var by_type: Dictionary = {
		"grass": [], "grass_alt": [], "fertile": [], "fertile_alt": [],
		"dry": [], "road": [], "road_alt": [], "wetland": [], "water": [], "rock": []
	}
	var half: int = MAP_SIZE / 2
	for gz in range(-half, half):
		for gx in range(-half, half):
			var h: float = height_noise.get_noise_2d(float(gx), float(gz))
			var m: float = moisture_noise.get_noise_2d(float(gx), float(gz))
			var base_id: String = _terrain_id(gx, gz, h, m)
			var visual_id: String = _terrain_visual_variant(base_id, gx, gz)
			var y: float = -0.18 if base_id == "water" else 0.0
			(by_type[visual_id] as Array).append(Transform3D(Basis.IDENTITY, Vector3(gx * CELL_SIZE, y, gz * CELL_SIZE)))
	for id in by_type.keys():
		_create_terrain_multimesh(str(id), by_type[id] as Array)

func _terrain_visual_variant(base_id: String, gx: int, gz: int) -> String:
	var marker: int = abs(hash("%d:%d:%d" % [world_seed, gx, gz])) % 10
	if base_id == "grass" and marker < 3:
		return "grass_alt"
	if base_id == "fertile" and marker < 4:
		return "fertile_alt"
	if base_id == "road" and marker < 4:
		return "road_alt"
	return base_id

func _terrain_id(gx: int, gz: int, h: float, m: float) -> String:
	if abs(gx) < 7 and abs(gz) < 7:
		if _is_road(gx, gz):
			return "road"
		return "fertile" if (gx + gz) % 5 == 0 else "grass"
	if _is_road(gx, gz):
		return "road"
	if h < -0.46:
		return "water"
	if h < -0.30 and m > 0.05:
		return "wetland"
	if h > 0.58:
		return "rock"
	if m > 0.28:
		return "fertile"
	if m < -0.34:
		return "dry"
	return "grass"

func _is_road(gx: int, gz: int) -> bool:
	var wave: float = sin(float(gz + (world_seed % 17)) * 0.23) * 2.2
	var primary: bool = abs(float(gx) - wave) < 1.15
	var branch_wave: float = cos(float(gx - (world_seed % 11)) * 0.18) * 3.0 + 7.0
	var secondary: bool = abs(float(gz) - branch_wave) < 0.8 and gx > -12
	return primary or secondary

func _create_terrain_multimesh(id: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var mesh := BoxMesh.new()
	mesh.size = Vector3(CELL_SIZE + 0.03, 0.24, CELL_SIZE + 0.03)
	mesh.material = materials[id]
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i in range(transforms.size()):
		multi.set_instance_transform(i, transforms[i] as Transform3D)
	var node := MultiMeshInstance3D.new()
	node.name = "Terrain_%s" % id
	node.multimesh = multi
	generated_root.add_child(node)

func _generate_ground_details() -> void:
	var transforms: Array[Transform3D] = []
	var half: int = MAP_SIZE / 2
	for gz in range(-half, half):
		for gx in range(-half, half):
			if abs(gx) < 7 and abs(gz) < 7:
				continue
			var h: float = height_noise.get_noise_2d(float(gx), float(gz))
			var m: float = moisture_noise.get_noise_2d(float(gx), float(gz))
			var id: String = _terrain_id(gx, gz, h, m)
			if id not in ["grass", "fertile", "wetland"]:
				continue
			var marker: int = abs(hash("detail:%d:%d:%d" % [world_seed, gx, gz])) % 100
			if marker > 22:
				continue
			var px: float = gx * CELL_SIZE + float((marker % 7) - 3) * 0.18
			var pz: float = gz * CELL_SIZE + float((marker % 5) - 2) * 0.22
			transforms.append(Transform3D(Basis.IDENTITY, Vector3(px, 0.27, pz)))
	if transforms.is_empty():
		return
	var blade := BoxMesh.new()
	blade.size = Vector3(0.12, 0.42, 0.12)
	blade.material = materials["leaf2"]
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = blade
	multi.instance_count = transforms.size()
	for i in range(transforms.size()):
		multi.set_instance_transform(i, transforms[i])
	var detail_node := MultiMeshInstance3D.new()
	detail_node.name = "GroundDetails"
	detail_node.multimesh = multi
	generated_root.add_child(detail_node)

func _generate_nature() -> void:
	var half: int = MAP_SIZE / 2
	for gz in range(-half, half):
		for gx in range(-half, half):
			if abs(gx) < 8 and abs(gz) < 8:
				continue
			var local_rng := RandomNumberGenerator.new()
			local_rng.seed = world_seed * 31 + gx * 92821 + gz * 68917
			var roll: float = local_rng.randf()
			var pos := Vector3(gx * CELL_SIZE + local_rng.randf_range(-1.2, 1.2), 0.15, gz * CELL_SIZE + local_rng.randf_range(-1.2, 1.2))
			var h: float = height_noise.get_noise_2d(float(gx), float(gz))
			var m: float = moisture_noise.get_noise_2d(float(gx), float(gz))
			var id: String = _terrain_id(gx, gz, h, m)
			if id in ["water", "road"]:
				continue
			if id in ["grass", "fertile", "wetland"] and roll < 0.16:
				var tree_node: Node3D = _create_tree(pos, local_rng.randf_range(0.82, 1.32), local_rng.randf() < 0.42)
				if local_rng.randf() < 0.30:
					_register_interactable(pos, "tree", "tree:%d:%d" % [gx, gz], tree_node)
			elif roll < 0.23:
				var bush_node: Node3D = _create_bush(pos, local_rng.randf_range(0.7, 1.2))
				if local_rng.randf() < 0.42:
					_register_interactable(pos, "bush", "bush:%d:%d" % [gx, gz], bush_node)
			elif id in ["rock", "dry"] and roll < 0.18:
				var rock_node: Node3D = _create_rock(pos, local_rng.randf_range(0.7, 1.3))
				_register_interactable(pos, "rock", "rock:%d:%d" % [gx, gz], rock_node)

func _generate_farm() -> void:
	var farm := Node3D.new()
	farm.name = "ProceduralFarm"
	farm.rotation_degrees.y = float(farm_layout * 90)
	generated_root.add_child(farm)
	_create_farmhouse(farm, Vector3(-8, 0.2, -5))
	_create_barn(farm, Vector3(11, 0.2, -6))
	_create_well(farm, Vector3(3, 0.2, 10))
	_create_garden(farm, Vector3(-9, 0.2, 9))
	_create_fence_rect(farm, Vector2(33, 29))
	_create_crate(farm, Vector3(9, 0.7, -1.4), "barn_supply", "crate:barn")
	_create_barrel(farm, Vector3(7.4, 0.75, -10.0))
	_create_barrel(farm, Vector3(9.0, 0.75, -10.0))

func _create_farmhouse(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Farmhouse"
	root.position = pos
	parent.add_child(root)

	farmhouse_interior = Node3D.new()
	farmhouse_interior.name = "FarmhouseInterior"
	root.add_child(farmhouse_interior)

	_box(farmhouse_interior, Vector3(10.0, 0.18, 8.0), Vector3(0, 0.10, 0), materials["interior_floor"])
	_box(farmhouse_interior, Vector3(2.2, 0.05, 2.9), Vector3(1.3, 0.22, -1.2), materials["cloth"])

	# Paredes modulares: a frente tem um vão real de porta para o jogador entrar.
	_solid_box(root, Vector3(10.5, 3.9, 0.28), Vector3(0, 1.95, -4.25), materials["wood_old"], "HouseBackWall")
	_solid_box(root, Vector3(0.28, 3.9, 8.5), Vector3(-5.25, 1.95, 0), materials["wood_old"], "HouseLeftWall")
	_solid_box(root, Vector3(0.28, 3.9, 8.5), Vector3(5.25, 1.95, 0), materials["wood_old"], "HouseRightWall")
	_solid_box(root, Vector3(4.15, 3.9, 0.28), Vector3(-3.18, 1.95, 4.25), materials["wood_old"], "HouseFrontLeft")
	_solid_box(root, Vector3(4.15, 3.9, 0.28), Vector3(3.18, 1.95, 4.25), materials["wood_old"], "HouseFrontRight")
	_solid_box(root, Vector3(2.2, 0.8, 0.28), Vector3(0, 3.50, 4.25), materials["wood_dark"], "HouseDoorLintel")

	# Detalhes exteriores e interiores.
	_box(root, Vector3(1.45, 1.45, 0.08), Vector3(-3.15, 2.15, 4.40), materials["window"])
	_box(root, Vector3(1.45, 1.45, 0.08), Vector3(3.15, 2.15, 4.40), materials["window"])
	_box(root, Vector3(1.50, 1.35, 0.08), Vector3(5.42, 2.20, -1.5), materials["window"])
	_box(root, Vector3(7.0, 0.22, 2.0), Vector3(0, 0.25, 5.1), materials["wood_dark"])
	for y in [0.55, 1.15, 1.75, 2.35, 2.95, 3.55]:
		_box(root, Vector3(10.2, 0.06, 0.05), Vector3(0, y, -4.40), materials["wood_dark"])

	# Porta aberta para leitura visual, sem colisão no vão.
	var door := _box(root, Vector3(1.75, 2.75, 0.14), Vector3(1.12, 1.38, 4.55), materials["wood_dark"])
	door.rotation_degrees.y = 68.0

	# Móveis com colisão dentro da casa.
	_solid_box(farmhouse_interior, Vector3(2.6, 0.18, 1.45), Vector3(-1.6, 1.00, -1.7), materials["wood"], "InteriorTable")
	for leg in [Vector3(-2.5, 0.52, -2.15), Vector3(-0.7, 0.52, -2.15), Vector3(-2.5, 0.52, -1.25), Vector3(-0.7, 0.52, -1.25)]:
		_box(farmhouse_interior, Vector3(0.16, 0.9, 0.16), leg, materials["wood_dark"])
	_solid_box(farmhouse_interior, Vector3(2.5, 0.55, 4.1), Vector3(3.3, 0.50, -1.25), materials["cloth"], "InteriorBed")
	_solid_box(farmhouse_interior, Vector3(1.5, 2.4, 0.75), Vector3(-4.0, 1.2, -2.9), materials["wood_dark"], "InteriorCabinet")
	_box(farmhouse_interior, Vector3(0.65, 0.9, 0.65), Vector3(-1.6, 0.55, 1.7), materials["metal"])
	_create_crate(farmhouse_interior, Vector3(2.6, 0.62, 2.3), "farmhouse_supply", "crate:farmhouse")

	farmhouse_roof = Node3D.new()
	farmhouse_roof.name = "FarmhouseRoof"
	root.add_child(farmhouse_roof)
	var roof_l := _box(farmhouse_roof, Vector3(6.2, 0.34, 9.4), Vector3(-2.40, 4.72, 0), materials["roof"])
	roof_l.rotation_degrees.z = -25.0
	var roof_r := _box(farmhouse_roof, Vector3(6.2, 0.34, 9.4), Vector3(2.40, 4.72, 0), materials["roof"])
	roof_r.rotation_degrees.z = 25.0
	_box(farmhouse_roof, Vector3(0.9, 2.1, 0.9), Vector3(-3.0, 5.35, -1.6), materials["rust"])

	farmhouse_trigger = Area3D.new()
	farmhouse_trigger.name = "FarmhouseInteriorTrigger"
	farmhouse_trigger.monitoring = true
	farmhouse_trigger.monitorable = true
	farmhouse_trigger.position = Vector3(0, 1.55, 0)
	var trigger_shape := BoxShape3D.new()
	trigger_shape.size = Vector3(9.8, 3.0, 7.8)
	var trigger_collision := CollisionShape3D.new()
	trigger_collision.shape = trigger_shape
	farmhouse_trigger.add_child(trigger_collision)
	root.add_child(farmhouse_trigger)
	farmhouse_trigger.body_entered.connect(Callable(self, "_on_house_body_entered").bind(farmhouse_roof))
	farmhouse_trigger.body_exited.connect(Callable(self, "_on_house_body_exited").bind(farmhouse_roof))

func _on_house_body_entered(body: Node3D, roof_root: Node3D) -> void:
	if body.is_in_group("player") and is_instance_valid(roof_root):
		roof_root.visible = false

func _on_house_body_exited(body: Node3D, roof_root: Node3D) -> void:
	if body.is_in_group("player") and is_instance_valid(roof_root):
		roof_root.visible = true

func _create_barn(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Barn"
	root.position = pos
	parent.add_child(root)
	_box(root, Vector3(9.0, 0.18, 7.0), Vector3(0, 0.10, 0), materials["fertile_alt"])
	_solid_box(root, Vector3(9.0, 5.2, 0.30), Vector3(0, 2.6, -3.5), materials["rust"], "BarnBack")
	_solid_box(root, Vector3(0.30, 5.2, 7.0), Vector3(-4.5, 2.6, 0), materials["rust"], "BarnLeft")
	_solid_box(root, Vector3(0.30, 5.2, 7.0), Vector3(4.5, 2.6, 0), materials["rust"], "BarnRight")
	_solid_box(root, Vector3(2.0, 5.2, 0.30), Vector3(-3.5, 2.6, 3.5), materials["rust"], "BarnFrontLeft")
	_solid_box(root, Vector3(2.0, 5.2, 0.30), Vector3(3.5, 2.6, 3.5), materials["rust"], "BarnFrontRight")
	var roof := _box(root, Vector3(10.0, 0.42, 8.0), Vector3(0, 5.55, 0), materials["roof_rust"])
	roof.rotation_degrees.z = 7.0
	_box(root, Vector3(5.0, 0.10, 0.14), Vector3(0, 4.35, 3.72), materials["wood_dark"])

func _create_well(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Well"
	root.position = pos
	parent.add_child(root)
	_solid_cylinder(root, 1.15, 1.1, Vector3(0, 0.55, 0), materials["stone_light"], 12, "WellBase")
	_solid_box(root, Vector3(0.20, 2.5, 0.20), Vector3(-1.2, 1.5, 0), materials["wood_dark"], "WellPostL")
	_solid_box(root, Vector3(0.20, 2.5, 0.20), Vector3(1.2, 1.5, 0), materials["wood_dark"], "WellPostR")
	_box(root, Vector3(3.1, 0.20, 1.8), Vector3(0, 2.75, 0), materials["roof_rust"])

func _create_garden(parent: Node3D, pos: Vector3) -> void:
	var garden_root := Node3D.new()
	garden_root.name = "Garden"
	garden_root.position = pos
	parent.add_child(garden_root)
	for row in range(4):
		_box(garden_root, Vector3(6.0, 0.10, 0.72), Vector3(2.2, 0.10, row * 1.15), materials["fertile"])
		for col in range(5):
			_box(garden_root, Vector3(0.42, 0.65, 0.42), Vector3(col * 1.1, 0.38, row * 1.15), materials["crop"])

func _create_fence_rect(parent: Node3D, size: Vector2) -> void:
	var half_x: float = size.x / 2.0
	var half_z: float = size.y / 2.0
	for x in range(-15, 16, 3):
		_solid_box(parent, Vector3(0.18, 1.75, 0.18), Vector3(float(x), 0.88, -half_z), materials["wood_dark"], "FencePost")
		_solid_box(parent, Vector3(0.18, 1.75, 0.18), Vector3(float(x), 0.88, half_z), materials["wood_dark"], "FencePost")
		if x < 15:
			_solid_box(parent, Vector3(3.0, 0.12, 0.14), Vector3(float(x) + 1.5, 0.62, -half_z), materials["wood"], "FenceRail")
			_solid_box(parent, Vector3(3.0, 0.12, 0.14), Vector3(float(x) + 1.5, 1.24, -half_z), materials["wood"], "FenceRail")
			var gate_mid: float = float(x) + 1.5
			if abs(gate_mid) > 2.2:
				_solid_box(parent, Vector3(3.0, 0.12, 0.14), Vector3(gate_mid, 0.62, half_z), materials["wood"], "FenceRail")
				_solid_box(parent, Vector3(3.0, 0.12, 0.14), Vector3(gate_mid, 1.24, half_z), materials["wood"], "FenceRail")
	for z in range(-12, 13, 3):
		_solid_box(parent, Vector3(0.18, 1.75, 0.18), Vector3(-half_x, 0.88, float(z)), materials["wood_dark"], "FencePost")
		_solid_box(parent, Vector3(0.18, 1.75, 0.18), Vector3(half_x, 0.88, float(z)), materials["wood_dark"], "FencePost")
		if z < 12:
			_solid_box(parent, Vector3(0.14, 0.12, 3.0), Vector3(-half_x, 0.62, float(z) + 1.5), materials["wood"], "FenceRail")
			_solid_box(parent, Vector3(0.14, 0.12, 3.0), Vector3(-half_x, 1.24, float(z) + 1.5), materials["wood"], "FenceRail")
			_solid_box(parent, Vector3(0.14, 0.12, 3.0), Vector3(half_x, 0.62, float(z) + 1.5), materials["wood"], "FenceRail")
			_solid_box(parent, Vector3(0.14, 0.12, 3.0), Vector3(half_x, 1.24, float(z) + 1.5), materials["wood"], "FenceRail")

func _generate_secondary_pois() -> void:
	for i in range(3):
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(42.0, 58.0)
		var pos := Vector3(cos(angle) * radius, 0.2, sin(angle) * radius)
		var root := Node3D.new()
		root.position = pos
		root.rotation_degrees.y = float(rng.randi_range(0, 3) * 90)
		generated_root.add_child(root)
		_solid_box(root, Vector3(5.0, 3.0, 0.28), Vector3(0, 1.5, -2.0), materials["wood_dark"], "POIBack")
		_solid_box(root, Vector3(0.28, 3.0, 4.0), Vector3(-2.5, 1.5, 0), materials["wood_old"], "POILeft")
		_solid_box(root, Vector3(0.28, 3.0, 4.0), Vector3(2.5, 1.5, 0), materials["wood_old"], "POIRight")
		_box(root, Vector3(5.8, 0.30, 4.8), Vector3(0, 3.30, 0), materials["roof_rust"])
		_create_crate(root, Vector3(1.2, 0.7, 1.1), "camp_supply", "poi:%d" % i)

func _create_tree(pos: Vector3, scale_value: float, pinus: bool) -> Node3D:
	var root := Node3D.new()
	root.name = "Tree"
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	generated_root.add_child(root)
	_solid_cylinder(root, 0.30, 3.8, Vector3(0, 1.9, 0), materials["wood_dark"], 7, "TreeTrunk")
	if pinus:
		_cone(root, 2.2, 3.6, Vector3(0, 4.1, 0), materials["leaf"], 8)
		_cone(root, 1.65, 2.8, Vector3(0, 5.5, 0), materials["leaf2"], 8)
	else:
		_sphere(root, 2.15, Vector3(0, 4.0, 0), materials["leaf"], Vector3(1.15, 0.85, 1.0))
		_sphere(root, 1.40, Vector3(1.1, 4.15, 0.25), materials["leaf2"], Vector3(1.0, 0.8, 1.0))
	return root

func _create_bush(pos: Vector3, scale_value: float) -> Node3D:
	var root := Node3D.new()
	root.name = "Bush"
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	generated_root.add_child(root)
	_sphere(root, 0.8, Vector3(-0.4, 0.7, 0), materials["leaf"], Vector3(1.0, 0.65, 1.0))
	_sphere(root, 0.7, Vector3(0.5, 0.65, 0.15), materials["leaf2"], Vector3(1.1, 0.7, 1.0))
	return root

func _create_rock(pos: Vector3, scale_value: float) -> Node3D:
	var root := Node3D.new()
	root.name = "Rock"
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	generated_root.add_child(root)
	_solid_sphere(root, 0.72, Vector3(0, 0.45, 0), materials["rock"], Vector3(1.2, 0.62, 0.9), "RockBody")
	return root

func _create_barrel(parent: Node3D, pos: Vector3) -> void:
	_solid_cylinder(parent, 0.55, 1.35, pos, materials["rust"], 10, "Barrel")

func _create_crate(parent: Node3D, pos: Vector3, kind: String, key: String) -> void:
	if harvested_keys.has(key):
		return
	var node := _solid_box(parent, Vector3(1.2, 1.0, 1.0), pos, materials["wood"], "LootCrate")
	_box(node, Vector3(1.28, 0.08, 0.08), Vector3(0, 0.0, 0.52), materials["wood_dark"])
	_box(node, Vector3(0.08, 1.05, 0.08), Vector3(0.50, 0.0, 0.52), materials["wood_dark"])
	_register_interactable(parent.to_global(pos), kind, key, node)

func _register_interactable(pos: Vector3, kind: String, key: String, node: Node3D = null) -> void:
	if harvested_keys.has(key):
		return
	interactables.append({"position": pos, "type": kind, "key": key, "node": node})

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var nearest: int = -1
	var best: float = 3.2
	for i in range(interactables.size()):
		var data: Dictionary = interactables[i]
		var d: float = pos.distance_to(data["position"] as Vector3)
		if d < best:
			best = d
			nearest = i
	if nearest < 0:
		return false
	var data: Dictionary = interactables[nearest]
	var kind: String = str(data["type"])
	if kind == "tree":
		target_player.call("add_item", "wood", 3)
	elif kind == "rock":
		target_player.call("add_item", "stone", 2)
	elif kind == "bush":
		target_player.call("add_item", "fiber", 2)
	elif kind == "farmhouse_supply":
		target_player.call("unlock_weapon", "pistol")
		target_player.call("add_item", "ammo_9mm", 18)
		target_player.call("add_item", "food", 2)
	elif kind == "barn_supply":
		target_player.call("unlock_weapon", "shotgun")
		target_player.call("add_item", "shells", 8)
		target_player.call("add_item", "wood", 4)
	else:
		target_player.call("add_item", "water", 1)
	var node_value: Variant = data.get("node")
	if node_value is Node3D and is_instance_valid(node_value as Node3D):
		(node_value as Node3D).queue_free()
	harvested_keys.append(str(data["key"]))
	interactables.remove_at(nearest)
	save_game()
	return true

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = Player3DScript.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.75, 3.5))

func _spawn_zombies(count: int) -> void:
	for i in range(count):
		var zombie: CharacterBody3D = Zombie3DScript.new()
		zombie.name = "Zombie_%02d" % i
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(18.0, 52.0)
		zombie.position = Vector3(cos(angle) * radius, 0.75, sin(angle) * radius)
		actors_root.add_child(zombie)

func _farm_to_world(local: Vector3) -> Vector3:
	return Basis(Vector3.UP, deg_to_rad(float(farm_layout * 90))) * local

func new_seed() -> void:
	world_seed = abs(hash("%s:%s" % [str(Time.get_unix_time_from_system()), str(Time.get_ticks_msec())])) % 2000000000
	harvested_keys.clear()
	save_cache.clear()
	_generate_world()
	if player != null:
		player.call("reset_for_new_world")
		player.global_position = _farm_to_world(Vector3(0, 0.75, 3.5))
	for child in actors_root.get_children():
		if child != player:
			child.queue_free()
	_spawn_zombies(14)
	save_game()

func get_world_summary() -> Dictionary:
	return {
		"seed": world_seed,
		"layout": farm_layout,
		"zombies": get_tree().get_nodes_in_group("zombies").size(),
		"colliders": collider_count,
		"interior": farmhouse_trigger != null
	}

func get_debug_metrics() -> Dictionary:
	return {
		"colliders": collider_count,
		"materials": texture_material_count,
		"roof": farmhouse_roof != null,
		"interior": farmhouse_interior != null,
		"trigger": farmhouse_trigger != null,
		"interactables": interactables.size()
	}

func get_zombies() -> Array[Node]:
	return get_tree().get_nodes_in_group("zombies")

func _setup_autosave() -> void:
	var timer := Timer.new()
	timer.wait_time = 20.0
	timer.autostart = true
	timer.timeout.connect(save_game)
	add_child(timer)

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		save_cache = parsed as Dictionary
		var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
		world_seed = int(world_state.get("seed", world_seed))
		farm_layout = int(world_state.get("farm_layout", 0))
		for key in world_state.get("harvested", []):
			harvested_keys.append(str(key))

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION,
		"world": {
			"seed": world_seed,
			"farm_layout": farm_layout,
			"harvested": harvested_keys.duplicate()
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func _box(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

func _solid_box(parent: Node3D, size: Vector3, pos: Vector3, material: Material, label: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	parent.add_child(body)
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var mesh_node := MeshInstance3D.new()
	mesh_node.mesh = mesh
	body.add_child(mesh_node)
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	collider_count += 1
	return body

func _solid_cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, segments: int, label: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	parent.add_child(body)
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.material = material
	var mesh_node := MeshInstance3D.new()
	mesh_node.mesh = mesh
	body.add_child(mesh_node)
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	collider_count += 1
	return body

func _solid_sphere(parent: Node3D, radius: float, pos: Vector3, material: Material, scale_value: Vector3, label: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	body.scale = scale_value
	parent.add_child(body)
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = material
	var mesh_node := MeshInstance3D.new()
	mesh_node.mesh = mesh
	body.add_child(mesh_node)
	var shape := SphereShape3D.new()
	shape.radius = radius
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	collider_count += 1
	return body

func _cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, segments: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

func _cone(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, segments: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

func _sphere(parent: Node3D, radius: float, pos: Vector3, material: Material, scale_value: Vector3) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.scale = scale_value
	parent.add_child(node)
	return node
