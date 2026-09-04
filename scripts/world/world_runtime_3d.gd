extends Node3D

const Player3DScript = preload("res://scripts/player/player_3d.gd")
const Zombie3DScript = preload("res://scripts/entities/zombie_3d.gd")

const SAVE_PATH := "user://fim_da_colheita_alpha_0_5_1.save.json"
const CELL_SIZE := 4.0
const MAP_SIZE := 34

var world_seed: int = 104729
var farm_layout: int = 0
var rng := RandomNumberGenerator.new()
var height_noise := FastNoiseLite.new()
var moisture_noise := FastNoiseLite.new()
var materials: Dictionary = {}
var interactables: Array[Dictionary] = []
var harvested_keys: Array[String] = []
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

func _build_environment() -> void:
	_create_materials()
	var environment_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("8a957a")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d4cfb8")
	env.ambient_light_energy = 0.72
	environment_node.environment = env
	add_child(environment_node)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.light_energy = 1.1
	sun.light_color = Color("fff0cf")
	sun.shadow_enabled = true
	add_child(sun)

func _create_materials() -> void:
	materials = {
		"grass": _mat("566f43"), "grass_dark": _mat("3f5937"),
		"fertile": _mat("5a4430"), "dry": _mat("887352"),
		"road": _mat("75664f"), "wetland": _mat("4f6450"),
		"water": _mat("355d67"), "rock": _mat("66665f"),
		"wood": _mat("5d3d28"), "wood_old": _mat("76553a"),
		"wood_dark": _mat("36281f"), "roof": _mat("333a3d"),
		"rust": _mat("75422f"), "window": _mat("72909a"),
		"leaf": _mat("345331"), "leaf2": _mat("4d6638"),
		"crop": _mat("607a35"), "metal": _mat("494d4c"),
		"highlight": _mat("c49b42")
	}

func _mat(hex: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(hex)
	mat.roughness = 0.95
	return mat

func _generate_world() -> void:
	if generated_root != null and is_instance_valid(generated_root):
		generated_root.queue_free()
	generated_root = Node3D.new()
	generated_root.name = "GeneratedWorld"
	add_child(generated_root)
	interactables.clear()
	rng.seed = world_seed
	height_noise.seed = world_seed
	height_noise.frequency = 0.045
	moisture_noise.seed = world_seed + 9173
	moisture_noise.frequency = 0.055
	farm_layout = abs(world_seed) % 4
	_generate_terrain()
	_generate_nature()
	_generate_farm()
	_generate_secondary_pois()

func _generate_terrain() -> void:
	var by_type: Dictionary = {"grass":[],"fertile":[],"dry":[],"road":[],"wetland":[],"water":[],"rock":[]}
	var half: int = MAP_SIZE / 2
	for gz in range(-half, half):
		for gx in range(-half, half):
			var h: float = height_noise.get_noise_2d(float(gx), float(gz))
			var m: float = moisture_noise.get_noise_2d(float(gx), float(gz))
			var id: String = _terrain_id(gx, gz, h, m)
			var y: float = -0.18 if id == "water" else 0.0
			(by_type[id] as Array).append(Transform3D(Basis.IDENTITY, Vector3(gx * CELL_SIZE, y, gz * CELL_SIZE)))
	for id in by_type.keys():
		_create_terrain_multimesh(str(id), by_type[id] as Array)

func _terrain_id(gx: int, gz: int, h: float, m: float) -> String:
	if abs(gx) < 7 and abs(gz) < 7:
		return "road" if _is_road(gx, gz) else ("fertile" if (gx + gz) % 5 == 0 else "grass")
	if _is_road(gx, gz): return "road"
	if h < -0.46: return "water"
	if h < -0.30 and m > 0.05: return "wetland"
	if h > 0.58: return "rock"
	if m > 0.28: return "fertile"
	if m < -0.34: return "dry"
	return "grass"

func _is_road(gx: int, gz: int) -> bool:
	var wave: float = sin(float(gz + (world_seed % 17)) * 0.23) * 2.2
	var primary: bool = abs(float(gx) - wave) < 1.15
	var branch_wave: float = cos(float(gx - (world_seed % 11)) * 0.18) * 3.0 + 7.0
	var secondary: bool = abs(float(gz) - branch_wave) < 0.8 and gx > -12
	return primary or secondary

func _create_terrain_multimesh(id: String, transforms: Array) -> void:
	if transforms.is_empty(): return
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
	node.multimesh = multi
	generated_root.add_child(node)

func _generate_nature() -> void:
	var half: int = MAP_SIZE / 2
	for gz in range(-half, half):
		for gx in range(-half, half):
			if abs(gx) < 8 and abs(gz) < 8: continue
			var local_rng := RandomNumberGenerator.new()
			local_rng.seed = world_seed * 31 + gx * 92821 + gz * 68917
			var roll: float = local_rng.randf()
			var pos := Vector3(gx * CELL_SIZE + local_rng.randf_range(-1.2,1.2), 0.15, gz * CELL_SIZE + local_rng.randf_range(-1.2,1.2))
			var h: float = height_noise.get_noise_2d(float(gx), float(gz))
			var m: float = moisture_noise.get_noise_2d(float(gx), float(gz))
			var id: String = _terrain_id(gx, gz, h, m)
			if id in ["water","road"]: continue
			if id in ["grass","fertile","wetland"] and roll < 0.16:
				_create_tree(pos, local_rng.randf_range(0.82,1.32), local_rng.randf() < 0.42)
				if local_rng.randf() < 0.28: _register_interactable(pos, "tree", "tree:%d:%d" % [gx,gz])
			elif roll < 0.23:
				_create_bush(pos, local_rng.randf_range(0.7,1.2))
			elif id in ["rock","dry"] and roll < 0.18:
				_create_rock(pos, local_rng.randf_range(0.7,1.3))

func _generate_farm() -> void:
	var farm := Node3D.new()
	farm.name = "ProceduralFarm"
	farm.rotation_degrees.y = float(farm_layout * 90)
	generated_root.add_child(farm)
	_create_farmhouse(farm, Vector3(-8,0.2,-5))
	_create_barn(farm, Vector3(11,0.2,-6))
	_create_well(farm, Vector3(3,0.2,10))
	_create_garden(farm, Vector3(-9,0.2,9))
	_create_fence_rect(farm, Vector2(33,29))
	_create_crate(farm, Vector3(-4,0.7,-1), "farmhouse_supply", "crate:farmhouse")
	_create_crate(farm, Vector3(9,0.7,-2), "barn_supply", "crate:barn")

func _create_farmhouse(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new(); root.position = pos; parent.add_child(root)
	_box(root, Vector3(10.5,4.2,8.5), Vector3(0,2.1,0), materials["wood_old"])
	var roof_l := _box(root, Vector3(6.0,0.34,9.2), Vector3(-2.35,4.75,0), materials["roof"]); roof_l.rotation_degrees.z = -25.0
	var roof_r := _box(root, Vector3(6.0,0.34,9.2), Vector3(2.35,4.75,0), materials["roof"]); roof_r.rotation_degrees.z = 25.0
	_box(root, Vector3(2.0,2.8,0.18), Vector3(0,1.4,4.34), materials["wood_dark"])
	_box(root, Vector3(1.4,1.5,0.12), Vector3(-3.1,2.2,4.38), materials["window"])
	_box(root, Vector3(1.4,1.5,0.12), Vector3(3.1,2.2,4.38), materials["window"])
	_box(root, Vector3(7.5,0.25,2.2), Vector3(0,0.25,5.2), materials["wood_dark"])

func _create_barn(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new(); root.position = pos; parent.add_child(root)
	_box(root, Vector3(9.0,5.2,7.0), Vector3(0,2.6,0), materials["rust"])
	var roof := _box(root, Vector3(10.0,0.4,8.0), Vector3(0,5.5,0), materials["roof"]); roof.rotation_degrees.z = 7.0
	_box(root, Vector3(3.0,3.5,0.18), Vector3(0,1.75,3.6), materials["wood_dark"])

func _create_well(parent: Node3D, pos: Vector3) -> void:
	var root := Node3D.new(); root.position = pos; parent.add_child(root)
	_cylinder(root, 1.15, 1.1, Vector3(0,0.55,0), materials["rock"], 12)
	_box(root, Vector3(0.18,2.5,0.18), Vector3(-1.2,1.5,0), materials["wood_dark"])
	_box(root, Vector3(0.18,2.5,0.18), Vector3(1.2,1.5,0), materials["wood_dark"])
	_box(root, Vector3(3.1,0.20,1.8), Vector3(0,2.75,0), materials["roof"])

func _create_garden(parent: Node3D, pos: Vector3) -> void:
	for row in range(4):
		for col in range(5):
			_box(parent, Vector3(0.55,0.7,0.55), pos + Vector3(col*1.15,0.35,row*1.15), materials["crop"])

func _create_fence_rect(parent: Node3D, size: Vector2) -> void:
	for x in range(-16,17,3):
		_box(parent, Vector3(0.18,1.7,0.18), Vector3(float(x),0.85,-size.y/2.0), materials["wood_dark"])
		_box(parent, Vector3(0.18,1.7,0.18), Vector3(float(x),0.85,size.y/2.0), materials["wood_dark"])
	for z in range(-14,15,3):
		_box(parent, Vector3(0.18,1.7,0.18), Vector3(-size.x/2.0,0.85,float(z)), materials["wood_dark"])
		_box(parent, Vector3(0.18,1.7,0.18), Vector3(size.x/2.0,0.85,float(z)), materials["wood_dark"])

func _generate_secondary_pois() -> void:
	for i in range(3):
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(42.0,58.0)
		var pos := Vector3(cos(angle)*radius,0.2,sin(angle)*radius)
		var root := Node3D.new(); root.position = pos; generated_root.add_child(root)
		_box(root, Vector3(5.0,3.0,4.0), Vector3(0,1.5,0), materials["wood_dark"])
		_box(root, Vector3(5.8,0.3,4.8), Vector3(0,3.3,0), materials["roof"])
		_create_crate(root, Vector3(1.2,0.7,1.1), "camp_supply", "poi:%d" % i)

func _create_tree(pos: Vector3, scale_value: float, pinus: bool) -> void:
	var root := Node3D.new(); root.position = pos; root.scale = Vector3.ONE * scale_value; generated_root.add_child(root)
	_cylinder(root,0.25,3.8,Vector3(0,1.9,0),materials["wood_dark"],7)
	if pinus:
		_cone(root,2.2,3.6,Vector3(0,4.1,0),materials["leaf"],8)
		_cone(root,1.65,2.8,Vector3(0,5.5,0),materials["leaf2"],8)
	else:
		_sphere(root,2.15,Vector3(0,4.0,0),materials["leaf"],Vector3(1.15,0.85,1.0))

func _create_bush(pos: Vector3, scale_value: float) -> void:
	var root := Node3D.new(); root.position = pos; root.scale = Vector3.ONE * scale_value; generated_root.add_child(root)
	_sphere(root,0.8,Vector3(-0.4,0.7,0),materials["leaf"],Vector3(1.0,0.65,1.0))
	_sphere(root,0.7,Vector3(0.5,0.65,0.15),materials["leaf2"],Vector3(1.1,0.7,1.0))

func _create_rock(pos: Vector3, scale_value: float) -> void:
	var root := Node3D.new(); root.position = pos; root.scale = Vector3.ONE * scale_value; generated_root.add_child(root)
	_sphere(root,0.75,Vector3(0,0.45,0),materials["rock"],Vector3(1.2,0.6,0.9))

func _create_crate(parent: Node3D, pos: Vector3, kind: String, key: String) -> void:
	if harvested_keys.has(key): return
	var node := _box(parent, Vector3(1.2,1.0,1.0), pos, materials["wood"])
	_register_interactable(parent.to_global(pos), kind, key, node)

func _register_interactable(pos: Vector3, kind: String, key: String, node: Node3D = null) -> void:
	if harvested_keys.has(key): return
	interactables.append({"position":pos,"type":kind,"key":key,"node":node})

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var nearest: int = -1
	var best: float = 3.2
	for i in range(interactables.size()):
		var data: Dictionary = interactables[i]
		var d: float = pos.distance_to(data["position"] as Vector3)
		if d < best: best = d; nearest = i
	if nearest < 0: return false
	var data: Dictionary = interactables[nearest]
	var kind: String = str(data["type"])
	if kind == "tree": target_player.call("add_item","wood",3)
	elif kind == "farmhouse_supply": target_player.call("unlock_weapon","pistol"); target_player.call("add_item","ammo_9mm",18); target_player.call("add_item","food",2)
	elif kind == "barn_supply": target_player.call("unlock_weapon","shotgun"); target_player.call("add_item","shells",8)
	else: target_player.call("add_item","water",1)
	if data.get("node") != null and is_instance_valid(data["node"]): (data["node"] as Node3D).visible = false
	harvested_keys.append(str(data["key"]))
	interactables.remove_at(nearest)
	save_game()
	return true

func _spawn_player() -> void:
	actors_root = Node3D.new(); actors_root.name = "Actors"; add_child(actors_root)
	player = Player3DScript.new(); player.name = "Player"; player.set("world", self); actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"): player.call("import_save_state", state)
	else: player.global_position = _farm_to_world(Vector3(0,0.75,3.5))

func _spawn_zombies(count: int) -> void:
	for i in range(count):
		var zombie: CharacterBody3D = Zombie3DScript.new(); zombie.name = "Zombie_%02d" % i
		var angle: float = rng.randf_range(0.0, TAU); var radius: float = rng.randf_range(18.0,52.0)
		zombie.position = Vector3(cos(angle)*radius,0.75,sin(angle)*radius); actors_root.add_child(zombie)

func _farm_to_world(local: Vector3) -> Vector3:
	return Basis(Vector3.UP, deg_to_rad(float(farm_layout * 90))) * local

func new_seed() -> void:
	world_seed = int(Time.get_unix_time_from_system()) % 2000000000
	harvested_keys.clear(); save_cache.clear(); _generate_world()
	if player != null: player.call("reset_for_new_world"); player.global_position = _farm_to_world(Vector3(0,0.75,3.5))
	for child in actors_root.get_children():
		if child != player: child.queue_free()
	_spawn_zombies(14); save_game()

func get_world_summary() -> Dictionary:
	return {"seed":world_seed,"layout":farm_layout,"zombies":get_tree().get_nodes_in_group("zombies").size()}

func get_zombies() -> Array[Node]:
	return get_tree().get_nodes_in_group("zombies")

func _setup_autosave() -> void:
	var timer := Timer.new(); timer.wait_time = 20.0; timer.autostart = true; timer.timeout.connect(save_game); add_child(timer)

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null: return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		save_cache = parsed as Dictionary
		var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
		world_seed = int(world_state.get("seed",world_seed)); farm_layout = int(world_state.get("farm_layout",0))
		for key in world_state.get("harvested",[]): harvested_keys.append(str(key))

func save_game() -> void:
	if player == null: return
	var payload := {"version":"0.5.1","world":{"seed":world_seed,"farm_layout":farm_layout,"harvested":harvested_keys.duplicate()},"player":player.call("export_save_state")}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(payload))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST: save_game()

func _box(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new(); mesh.size = size; mesh.material = material
	var node := MeshInstance3D.new(); node.mesh = mesh; node.position = pos; parent.add_child(node); return node

func _cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, segments: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new(); mesh.top_radius = radius; mesh.bottom_radius = radius; mesh.height = height; mesh.radial_segments = segments; mesh.material = material
	var node := MeshInstance3D.new(); node.mesh = mesh; node.position = pos; parent.add_child(node); return node

func _cone(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, segments: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new(); mesh.top_radius = 0.05; mesh.bottom_radius = radius; mesh.height = height; mesh.radial_segments = segments; mesh.material = material
	var node := MeshInstance3D.new(); node.mesh = mesh; node.position = pos; parent.add_child(node); return node

func _sphere(parent: Node3D, radius: float, pos: Vector3, material: Material, scale_value: Vector3) -> MeshInstance3D:
	var mesh := SphereMesh.new(); mesh.radius = radius; mesh.height = radius * 2.0; mesh.radial_segments = 8; mesh.rings = 4; mesh.material = material
	var node := MeshInstance3D.new(); node.mesh = mesh; node.position = pos; node.scale = scale_value; parent.add_child(node); return node
