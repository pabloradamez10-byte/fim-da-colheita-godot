class_name World3D
extends Node3D

const Player3DScript = preload("res://scripts/player/player_3d.gd")
const Zombie3DScript = preload("res://scripts/entities/zombie_3d.gd")

const SAVE_PATH := "user://fim_da_colheita_alpha_0_5.save.json"
const SAVE_VERSION := "0.5.0"
const CELL_SIZE := 4.0
const MAP_SIZE := 34

var world_seed: int = 104729
var rng := RandomNumberGenerator.new()
var height_noise := FastNoiseLite.new()
var moisture_noise := FastNoiseLite.new()
var terrain: Dictionary = {}
var materials: Dictionary = {}
var interactables: Array[Dictionary] = []
var harvested_keys: Array[String] = []
var farm_layout := 0
var generated_root: Node3D
var actors_root: Node3D
var player: CharacterBody3D
var save_cache: Dictionary = {}

func _ready() -> void:
	_load_save()
	_build_environment()
	_generate_world()
	_spawn_player()
	_spawn_zombies(14)
	_setup_autosave()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

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
		"saved_at_unix": Time.get_unix_time_from_system(),
		"world": {
			"seed": world_seed,
			"farm_layout": farm_layout,
			"harvested": harvested_keys.duplicate()
		},
		"player": player.call("export_save_state") if player.has_method("export_save_state") else {}
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func _setup_autosave() -> void:
	var timer := Timer.new()
	timer.wait_time = 20.0
	timer.autostart = true
	timer.timeout.connect(save_game)
	add_child(timer)

func _build_environment() -> void:
	_create_materials()
	var environment_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("91a07f")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c7c3ad")
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_node.environment = env
	add_child(environment_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.light_energy = 1.15
	sun.light_color = Color("fff0cf")
	sun.shadow_enabled = true
	add_child(sun)

func _create_materials() -> void:
	materials = {
		"grass": _mat("566f43", 0.98),
		"grass_dark": _mat("3f5937", 1.0),
		"fertile": _mat("5a4430", 1.0),
		"dry": _mat("887352", 1.0),
		"road": _mat("75664f", 1.0),
		"wetland": _mat("4f6450", 1.0),
		"water": _mat("355d67", 0.65),
		"rock": _mat("66665f", 1.0),
		"wood": _mat("5d3d28", 1.0),
		"wood_dark": _mat("36281f", 1.0),
		"wood_old": _mat("76553a", 1.0),
		"roof": _mat("333a3d", 0.85, 0.08),
		"rust": _mat("75422f", 0.85, 0.2),
		"window": _mat("72909a", 0.35, 0.05),
		"leaf": _mat("345331", 1.0),
		"leaf2": _mat("4d6638", 1.0),
		"crop": _mat("607a35", 1.0),
		"skin": _mat("b98c68", 0.9),
		"cloth": _mat("35473b", 1.0),
		"zombie": _mat("718065", 1.0),
		"blood": _mat("5c1717", 0.9),
		"metal": _mat("494d4c", 0.65, 0.35),
		"highlight": _mat("c49b42", 0.8, 0.1)
	}

func _mat(hex: String, roughness: float = 1.0, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(hex)
	material.roughness = roughness
	material.metallic = metallic
	return material

func _generate_world() -> void:
	if generated_root != null and is_instance_valid(generated_root):
		generated_root.free()
	generated_root = Node3D.new()
	generated_root.name = "GeneratedWorld"
	add_child(generated_root)
	interactables.clear()
	terrain.clear()

	rng.seed = world_seed
	height_noise.seed = world_seed
	height_noise.frequency = 0.045
	height_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	moisture_noise.seed = world_seed + 9173
	moisture_noise.frequency = 0.055
	moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	farm_layout = int(abs(world_seed)) % 4

	var terrain_transforms: Dictionary = {}
	for key in ["grass", "fertile", "dry", "road", "wetland", "water", "rock"]:
		terrain_transforms[key] = []

	var half := MAP_SIZE / 2
	for gz in range(-half, half):
		for gx in range(-half, half):
			var h := height_noise.get_noise_2d(gx, gz)
			var m := moisture_noise.get_noise_2d(gx, gz)
			var id := _terrain_id(gx, gz, h, m)
			terrain[Vector2i(gx, gz)] = id
			var y := -0.18 if id == "water" else 0.0
			terrain_transforms[id].append(Transform3D(Basis.IDENTITY, Vector3(gx * CELL_SIZE, y, gz * CELL_SIZE)))

	for id in terrain_transforms:
		_create_terrain_multimesh(id, terrain_transforms[id])

	_generate_nature()
	_generate_farm()
	_generate_secondary_pois()

func _terrain_id(gx: int, gz: int, h: float, m: float) -> String:
	# Área da propriedade fica habitável, mas sua orientação/entorno muda por seed.
	if abs(gx) < 6 and abs(gz) < 6:
		if _is_road(gx, gz):
			return "road"
		return "grass" if (gx + gz) % 4 != 0 else "fertile"
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
	var wave := sin(float(gz + (world_seed % 17)) * 0.23) * 2.2
	var primary := abs(float(gx) - wave) < 1.15
	var branch_wave := cos(float(gx - (world_seed % 11)) * 0.18) * 3.0 + 7.0
	var secondary := abs(float(gz) - branch_wave) < 0.8 and gx > -12
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
		multi.set_instance_transform(i, transforms[i])
	var node := MultiMeshInstance3D.new()
	node.multimesh = multi
	generated_root.add_child(node)

func _generate_nature() -> void:
	var half := MAP_SIZE / 2
	for gz in range(-half, half):
		for gx in range(-half, half):
			if abs(gx) < 8 and abs(gz) < 8:
				continue
			var id: String = terrain.get(Vector2i(gx, gz), "grass")
			if id in ["water", "road"]:
				continue
			var local_rng := RandomNumberGenerator.new()
			local_rng.seed = world_seed * 31 + gx * 92821 + gz * 68917
			var roll := local_rng.randf()
			var pos := Vector3(gx * CELL_SIZE + local_rng.randf_range(-1.2, 1.2), 0.15, gz * CELL_SIZE + local_rng.randf_range(-1.2, 1.2))
			if id in ["grass", "fertile", "wetland"] and roll < 0.16:
				var pinus := local_rng.randf() < 0.38
				_create_tree(pos, local_rng.randf_range(0.82, 1.32), pinus)
				if local_rng.randf() < 0.32:
					_register_interactable(pos, "tree", "tree:%d:%d" % [gx, gz])
			elif roll < 0.23:
				_create_bush(pos, local_rng.randf_range(0.7, 1.2))
				if local_rng.randf() < 0.4:
					_register_interactable(pos, "bush", "bush:%d:%d" % [gx, gz])
			elif id in ["rock", "dry"] and roll < 0.18:
				_create_rock(pos, local_rng.randf_range(0.7, 1.3))
				_register_interactable(pos, "rock", "rock:%d:%d" % [gx, gz])

func _generate_farm() -> void:
	var farm := Node3D.new()
	farm.name = "ProceduralFarm"
	farm.rotation_degrees.y = float(farm_layout * 90)
	generated_root.add_child(farm)

	_create_farmhouse(farm, Vector3(-8, 0.2, -5))
	_create_barn(farm, Vector3(11, 0.2, -6))
	_create_well(farm, Vector3(3, 0.2, 10))
	_create_garden(farm, Vector3(-9, 0.2, 9))
	_create_fence_rect(farm, Vector3.ZERO, Vector2(33, 29))
	_create_crate(farm, Vector3(-4, 0.7, -1), "farmhouse_supply", "crate:farmhouse")
	_create_crate(farm, Vector3(9, 0.7, -2), "barn_supply", "crate:barn")
	_create_crate(farm, Vector3(1, 0.7, 9), "well_supply", "crate:well")

	# Detalhes de abandono e história visual.
	_create_barrel(farm, Vector3(8, 0.65, -10))
	_create_barrel(farm, Vector3(10, 0.65, -10))
	_create_rock(Vector3(-14, 0.2, 5), 1.2, farm)
	_create_bush(Vector3(-13, 0.2, -7), 1.15, farm)
	_create_bush(Vector3(14, 0.2, 6), 0.9, farm)

func _generate_secondary_pois() -> void:
	for i in range(3):
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(42.0, 58.0)
		var pos := Vector3(cos(angle) * radius, 0.2, sin(angle) * radius)
		if i == 0:
			_create_hunting_shed(pos, "poi:shed:%d" % i)
		elif i == 1:
			_create_abandoned_checkpoint(pos, "poi:checkpoint:%d" % i)
		else:
			_create_ruined_camp(pos, "poi:camp:%d" % i)

func _create_farmhouse(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	_box(root, Vector3(10.5, 4.2, 8.5), Vector3(0, 2.1, 0), materials["wood_old"])
	# Telhado de duas águas.
	var roof_l := _box(root, Vector3(6.0, 0.34, 9.2), Vector3(-2.35, 4.75, 0), materials["roof"])
	roof_l.rotation_degrees.z = -25.0
	var roof_r := _box(root, Vector3(6.0, 0.34, 9.2), Vector3(2.35, 4.75, 0), materials["roof"])
	roof_r.rotation_degrees.z = 25.0
	_box(root, Vector3(2.0, 2.8, 0.18), Vector3(0, 1.4, 4.34), materials["wood_dark"])
	_box(root, Vector3(1.4, 1.5, 0.12), Vector3(-3.1, 2.2, 4.38), materials["window"])
	_box(root, Vector3(1.4, 1.5, 0.12), Vector3(3.1, 2.2, 4.38), materials["window"])
	_box(root, Vector3(7.5, 0.25, 2.2), Vector3(0, 0.25, 5.2), materials["wood_dark"])
	for x in [-3.4, 3.4]:
		_box(root, Vector3(0.22, 2.7, 0.22), Vector3(x, 1.5, 5.9), materials["wood_dark"])
	_box(root, Vector3(1.0, 2.0, 1.0), Vector3(-3.8, 5.1, -2.0), materials["rust"])

func _create_barn(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	_box(root, Vector3(12.0, 5.0, 9.0), Vector3(0, 2.5, 0), materials["rust"])
	var roof_l := _box(root, Vector3(6.7, 0.38, 9.8), Vector3(-2.8, 5.75, 0), materials["roof"])
	roof_l.rotation_degrees.z = -28.0
	var roof_r := _box(root, Vector3(6.7, 0.38, 9.8), Vector3(2.8, 5.75, 0), materials["roof"])
	roof_r.rotation_degrees.z = 28.0
	_box(root, Vector3(4.6, 3.8, 0.2), Vector3(0, 1.9, 4.6), materials["wood_dark"])
	for x in [-2.4, 2.4]:
		_box(root, Vector3(0.25, 5.0, 0.22), Vector3(x, 2.5, 4.65), materials["wood"])
	_create_silo(root, Vector3(7.5, 0, -1.5))

func _create_silo(parent: Node3D, pos: Vector3) -> void:
	var body := _cylinder(parent, 2.0, 5.8, pos + Vector3(0, 2.9, 0), materials["metal"], 12)
	body.scale = Vector3(1.0, 1.0, 1.0)
	var roof := _cone(parent, 2.15, 1.8, pos + Vector3(0, 6.65, 0), materials["rust"], 12)
	roof.rotation_degrees.y = 15.0

func _create_well(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	_cylinder(root, 1.4, 1.0, Vector3(0, 0.5, 0), materials["rock"], 12)
	for x in [-1.3, 1.3]:
		_box(root, Vector3(0.18, 2.8, 0.18), Vector3(x, 1.7, 0), materials["wood_dark"])
	var roof_l := _box(root, Vector3(1.8, 0.18, 3.4), Vector3(-0.72, 3.0, 0), materials["roof"])
	roof_l.rotation_degrees.z = -28
	var roof_r := _box(root, Vector3(1.8, 0.18, 3.4), Vector3(0.72, 3.0, 0), materials["roof"])
	roof_r.rotation_degrees.z = 28

func _create_garden(parent: Node3D, pos: Vector3) -> void:
	for row in range(4):
		_box(parent, Vector3(8.0, 0.12, 1.0), pos + Vector3(0, 0.08, row * 1.7), materials["fertile"])
		for plant in range(7):
			var p := pos + Vector3(-3.3 + plant * 1.1, 0.35, row * 1.7)
			var stem := _cylinder(parent, 0.06, 0.5, p, materials["crop"], 6)
			stem.rotation_degrees.z = rng.randf_range(-8, 8)

func _create_fence_rect(parent: Node3D, center: Vector3, size: Vector2) -> void:
	var x_half := size.x / 2.0
	var z_half := size.y / 2.0
	for x in range(int(-x_half), int(x_half) + 1, 3):
		_fence_segment(parent, center + Vector3(x, 0, -z_half), true)
		_fence_segment(parent, center + Vector3(x, 0, z_half), true)
	for z in range(int(-z_half), int(z_half) + 1, 3):
		if abs(z) < 3:
			continue
		_fence_segment(parent, center + Vector3(-x_half, 0, z), false)
		_fence_segment(parent, center + Vector3(x_half, 0, z), false)

func _fence_segment(parent: Node3D, pos: Vector3, along_x: bool) -> void:
	_box(parent, Vector3(0.18, 1.7, 0.18), pos + Vector3(0, 0.85, 0), materials["wood_dark"])
	var rail_size := Vector3(3.0, 0.14, 0.14) if along_x else Vector3(0.14, 0.14, 3.0)
	for y in [0.65, 1.25]:
		_box(parent, rail_size, pos + Vector3(0, y, 0), materials["wood_old"])

func _create_crate(parent: Node3D, pos: Vector3, loot_type: String, key: String) -> void:
	if harvested_keys.has(key):
		return
	var root := Node3D.new()
	root.position = pos
	parent.add_child(root)
	_box(root, Vector3(1.25, 1.0, 1.25), Vector3.ZERO, materials["wood"])
	for offset in [-0.45, 0.45]:
		_box(root, Vector3(0.08, 1.04, 1.3), Vector3(offset, 0, 0), materials["wood_dark"])
	_register_interactable(root.global_position, loot_type, key, root)

func _create_barrel(parent: Node3D, pos: Vector3) -> void:
	_cylinder(parent, 0.55, 1.2, pos, materials["rust"], 10)

func _create_hunting_shed(pos: Vector3, key: String) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees.y = rng.randi_range(0, 3) * 90.0
	generated_root.add_child(root)
	_box(root, Vector3(5.0, 3.0, 4.0), Vector3(0, 1.5, 0), materials["wood_dark"])
	var roof := _box(root, Vector3(5.8, 0.3, 4.8), Vector3(0, 3.3, 0), materials["roof"])
	roof.rotation_degrees.z = 8.0
	_create_crate(root, Vector3(1.3, 0.7, 1.2), "hunting_supply", key + ":crate")

func _create_abandoned_checkpoint(pos: Vector3, key: String) -> void:
	var root := Node3D.new()
	root.position = pos
	generated_root.add_child(root)
	_box(root, Vector3(6.0, 0.25, 8.0), Vector3(0, 0.12, 0), materials["road"])
	_box(root, Vector3(3.2, 2.4, 2.5), Vector3(-1.8, 1.2, 0), materials["metal"])
	_box(root, Vector3(0.18, 3.0, 7.0), Vector3(2.4, 1.5, 0), materials["rust"])
	_create_barrel(root, Vector3(-2.0, 0.6, 2.6))
	_create_crate(root, Vector3(0.5, 0.7, -2.4), "checkpoint_supply", key + ":crate")

func _create_ruined_camp(pos: Vector3, key: String) -> void:
	var root := Node3D.new()
	root.position = pos
	generated_root.add_child(root)
	_box(root, Vector3(5.0, 0.16, 4.0), Vector3(0, 0.1, 0), materials["dry"])
	# Barraca improvisada
	var tarp := _box(root, Vector3(4.2, 0.15, 3.2), Vector3(0, 1.6, 0), materials["cloth"])
	tarp.rotation_degrees.z = 18
	_create_barrel(root, Vector3(2.6, 0.6, 1.5))
	_create_crate(root, Vector3(-2.0, 0.7, -1.0), "camp_supply", key + ":crate")

func _create_tree(pos: Vector3, scale_value: float, pinus: bool = false, parent: Node3D = null) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	(parent if parent != null else generated_root).add_child(root)
	_cylinder(root, 0.25, 3.8, Vector3(0, 1.9, 0), materials["wood_dark"], 7)
	if pinus:
		_cone(root, 2.2, 3.6, Vector3(0, 4.1, 0), materials["leaf"], 8)
		_cone(root, 1.65, 2.8, Vector3(0, 5.5, 0), materials["leaf2"], 8)
	else:
		_sphere(root, 2.15, Vector3(0, 4.0, 0), materials["leaf"], Vector3(1.15, 0.85, 1.0))
		_sphere(root, 1.65, Vector3(1.2, 4.25, 0.3), materials["leaf2"], Vector3(1, 0.85, 1))

func _create_bush(pos: Vector3, scale_value: float, parent: Node3D = null) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	(parent if parent != null else generated_root).add_child(root)
	_sphere(root, 0.8, Vector3(-0.4, 0.7, 0), materials["leaf"], Vector3(1.0, 0.65, 1.0))
	_sphere(root, 0.7, Vector3(0.5, 0.65, 0.15), materials["leaf2"], Vector3(1.1, 0.7, 1.0))

func _create_rock(pos: Vector3, scale_value: float, parent: Node3D = null) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	(parent if parent != null else generated_root).add_child(root)
	_sphere(root, 0.75, Vector3(0, 0.45, 0), materials["rock"], Vector3(1.2, 0.6, 0.9))

func _register_interactable(pos: Vector3, type: String, key: String, node: Node3D = null) -> void:
	if harvested_keys.has(key):
		return
	interactables.append({"position": pos, "type": type, "key": key, "node": node})

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var nearest := -1
	var best := 3.2
	for i in range(interactables.size()):
		var item: Dictionary = interactables[i]
		var d := pos.distance_to(item["position"])
		if d < best:
			best = d
			nearest = i
	if nearest < 0:
		return false
	var data: Dictionary = interactables[nearest]
	var type := str(data["type"])
	var key := str(data["key"])
	match type:
		"tree":
			target_player.call("add_item", "wood", 3)
		"rock":
			target_player.call("add_item", "stone", 2)
		"bush":
			target_player.call("add_item", "fiber", 2)
		"farmhouse_supply":
			target_player.call("unlock_weapon", "pistol")
			target_player.call("add_item", "ammo_9mm", 18)
			target_player.call("add_item", "food", 2)
		"barn_supply":
			target_player.call("unlock_weapon", "shotgun")
			target_player.call("add_item", "shells", 8)
			target_player.call("add_item", "wood", 5)
		"well_supply":
			target_player.call("add_item", "water", 3)
		"hunting_supply":
			target_player.call("add_item", "shells", 4)
			target_player.call("add_item", "food", 1)
		"checkpoint_supply":
			target_player.call("add_item", "ammo_9mm", 12)
			target_player.call("add_item", "bandage", 2)
		"camp_supply":
			target_player.call("add_item", "water", 2)
			target_player.call("add_item", "fiber", 4)
	if data.get("node") != null and is_instance_valid(data["node"]):
		(data["node"] as Node3D).visible = false
	harvested_keys.append(key)
	interactables.remove_at(nearest)
	save_game()
	return true

func _spawn_player() -> void:
	if actors_root == null:
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
	if actors_root == null:
		return
	for i in range(count):
		var zombie: CharacterBody3D = Zombie3DScript.new()
		zombie.name = "Zombie_%02d" % i
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(18.0, 52.0)
		zombie.position = Vector3(cos(angle) * radius, 0.75, sin(angle) * radius)
		actors_root.add_child(zombie)

func _farm_to_world(local: Vector3) -> Vector3:
	var basis := Basis(Vector3.UP, deg_to_rad(float(farm_layout * 90)))
	return basis * local

func new_seed() -> void:
	world_seed = int(Time.get_unix_time_from_system()) % 2000000000
	harvested_keys.clear()
	save_cache.clear()
	_generate_world()
	if player != null:
		player.call("reset_for_new_world")
		player.global_position = _farm_to_world(Vector3(0, 0.75, 3.5))
	for child in actors_root.get_children():
		if child != player:
			child.free()
	_spawn_zombies(14)
	save_game()

func get_world_summary() -> Dictionary:
	return {"seed": world_seed, "layout": farm_layout, "zombies": get_tree().get_nodes_in_group("zombies").size()}

func get_zombies() -> Array[Node]:
	return get_tree().get_nodes_in_group("zombies")

func _box(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)
	return node

func _cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, segments: int = 8) -> MeshInstance3D:
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

func _cone(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, segments: int = 8) -> MeshInstance3D:
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

func _sphere(parent: Node3D, radius: float, pos: Vector3, material: Material, scale_value: Vector3 = Vector3.ONE) -> MeshInstance3D:
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
