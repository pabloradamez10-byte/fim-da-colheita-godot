class_name ChunkStreamer3D
extends Node3D

const CELL_SIZE := 4.0
const CHUNK_CELLS := 8
const LOAD_RADIUS := 2
const UNLOAD_RADIUS := 3
const BASE_HALF_CELLS := 17

var world: Node = null
var player: Node3D = null
var world_seed: int = 104729
var loaded_chunks: Dictionary = {}
var height_noise := FastNoiseLite.new()
var moisture_noise := FastNoiseLite.new()
var fallback_materials: Dictionary = {}
var refresh_timer := 0.0
var last_center := Vector2i(999999, 999999)

func _ready() -> void:
	add_to_group("chunk_streamer")
	world = get_parent()
	_setup_materials()
	_sync_seed(true)
	set_process(true)

func _process(delta: float) -> void:
	refresh_timer += delta
	if refresh_timer < 0.25:
		return
	refresh_timer = 0.0
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	_sync_seed(false)
	var center := _world_to_chunk(player.global_position)
	if center != last_center:
		last_center = center
		_stream_around(center)

func _sync_seed(force: bool) -> void:
	var next_seed := world_seed
	if world != null:
		var raw: Variant = world.get("world_seed")
		if raw != null:
			next_seed = int(raw)
	if force or next_seed != world_seed:
		world_seed = next_seed
		height_noise.seed = world_seed
		height_noise.frequency = 0.045
		height_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		moisture_noise.seed = world_seed + 9173
		moisture_noise.frequency = 0.055
		moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		_clear_chunks()
		last_center = Vector2i(999999, 999999)

func _world_to_chunk(pos: Vector3) -> Vector2i:
	var chunk_world := CELL_SIZE * float(CHUNK_CELLS)
	return Vector2i(floori(pos.x / chunk_world), floori(pos.z / chunk_world))

func _stream_around(center: Vector2i) -> void:
	for cz in range(center.y - LOAD_RADIUS, center.y + LOAD_RADIUS + 1):
		for cx in range(center.x - LOAD_RADIUS, center.x + LOAD_RADIUS + 1):
			var key := Vector2i(cx, cz)
			if not loaded_chunks.has(key):
				_generate_chunk(key)
	var to_remove: Array[Vector2i] = []
	for raw_key in loaded_chunks.keys():
		var key := raw_key as Vector2i
		if abs(key.x - center.x) > UNLOAD_RADIUS or abs(key.y - center.y) > UNLOAD_RADIUS:
			to_remove.append(key)
	for key in to_remove:
		var node := loaded_chunks.get(key) as Node3D
		if node != null and is_instance_valid(node):
			node.queue_free()
		loaded_chunks.erase(key)

func _generate_chunk(coord: Vector2i) -> void:
	var root := Node3D.new()
	root.name = "Chunk_%d_%d" % [coord.x, coord.y]
	add_child(root)
	loaded_chunks[coord] = root

	var by_type: Dictionary = {"grass":[],"fertile":[],"dry":[],"road":[],"wetland":[],"water":[],"rock":[]}
	for lz in range(CHUNK_CELLS):
		for lx in range(CHUNK_CELLS):
			var gx := coord.x * CHUNK_CELLS + lx
			var gz := coord.y * CHUNK_CELLS + lz
			# A 0.5.2 já gera a região central. Aqui só continuamos além dela.
			if abs(gx) < BASE_HALF_CELLS and abs(gz) < BASE_HALF_CELLS:
				continue
			var h := height_noise.get_noise_2d(float(gx), float(gz))
			var m := moisture_noise.get_noise_2d(float(gx), float(gz))
			var id := _terrain_id(gx, gz, h, m)
			var y := -0.18 if id == "water" else 0.0
			(by_type[id] as Array).append(Transform3D(Basis.IDENTITY, Vector3(gx * CELL_SIZE, y, gz * CELL_SIZE)))
			_generate_nature_cell(root, gx, gz, id)

	for raw_id in by_type.keys():
		var id := str(raw_id)
		var transforms := by_type[id] as Array
		if not transforms.is_empty():
			_create_terrain_multimesh(root, id, transforms)

func _terrain_id(gx: int, gz: int, h: float, m: float) -> String:
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

func _generate_nature_cell(parent: Node3D, gx: int, gz: int, terrain_id: String) -> void:
	if terrain_id in ["water", "road"]:
		return
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = world_seed * 131 + gx * 92821 + gz * 68917
	var roll := local_rng.randf()
	var pos := Vector3(gx * CELL_SIZE + local_rng.randf_range(-1.15,1.15), 0.15, gz * CELL_SIZE + local_rng.randf_range(-1.15,1.15))
	if terrain_id in ["grass","fertile","wetland"] and roll < 0.115:
		_create_tree(parent, pos, local_rng.randf_range(0.78,1.28), local_rng.randf() < 0.45)
	elif terrain_id in ["rock","dry"] and roll < 0.10:
		_create_rock(parent, pos, local_rng.randf_range(0.72,1.25))
	elif roll < 0.17:
		_create_bush(parent, pos, local_rng.randf_range(0.65,1.1))

func _create_terrain_multimesh(parent: Node3D, id: String, transforms: Array) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(CELL_SIZE + 0.03, 0.24, CELL_SIZE + 0.03)
	mesh.material = _material_for(id)
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i in range(transforms.size()):
		multi.set_instance_transform(i, transforms[i] as Transform3D)
	var node := MultiMeshInstance3D.new()
	node.multimesh = multi
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)

func _material_for(id: String) -> Material:
	if world != null:
		var raw: Variant = world.get("materials")
		if raw is Dictionary:
			var mats := raw as Dictionary
			if mats.has(id) and mats[id] is Material:
				return mats[id] as Material
	return fallback_materials.get(id, fallback_materials["grass"]) as Material

func _setup_materials() -> void:
	fallback_materials = {
		"grass": _mat("617c48"), "fertile": _mat("654a31"), "dry": _mat("967b58"),
		"road": _mat("806e52"), "wetland": _mat("526b55"), "water": _mat("386876"),
		"rock": _mat("6c6d67"), "wood": _mat("4c3425"), "leaf": _mat("3f6035"), "leaf2": _mat("58753e")
	}

func _mat(hex: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(hex)
	mat.roughness = 0.96
	return mat

func _create_tree(parent: Node3D, pos: Vector3, scale_value: float, pinus: bool) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	parent.add_child(root)
	_cylinder(root, 0.25, 3.8, Vector3(0,1.9,0), _material_for("wood"), 7)
	if pinus:
		_cone(root, 2.1, 3.4, Vector3(0,4.0,0), _material_for("leaf"), 8)
		_cone(root, 1.55, 2.6, Vector3(0,5.35,0), _material_for("leaf2"), 8)
	else:
		_sphere(root, 2.0, Vector3(0,4.0,0), _material_for("leaf"), Vector3(1.15,0.85,1.0))
	_add_static_box(root, Vector3(0.58,3.8,0.58), Vector3(0,1.9,0))

func _create_rock(parent: Node3D, pos: Vector3, scale_value: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	parent.add_child(root)
	_sphere(root, 0.75, Vector3(0,0.45,0), _material_for("rock"), Vector3(1.2,0.6,0.9))
	_add_static_box(root, Vector3(1.35,0.8,1.1), Vector3(0,0.42,0))

func _create_bush(parent: Node3D, pos: Vector3, scale_value: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	parent.add_child(root)
	_sphere(root,0.78,Vector3(-0.35,0.65,0),_material_for("leaf"),Vector3(1.0,0.65,1.0))
	_sphere(root,0.68,Vector3(0.45,0.62,0.12),_material_for("leaf2"),Vector3(1.1,0.7,1.0))

func _add_static_box(parent: Node3D, size: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.add_to_group("chunk_collision")
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = pos
	body.add_child(collision)
	parent.add_child(body)

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

func _clear_chunks() -> void:
	for raw_node in loaded_chunks.values():
		var node := raw_node as Node3D
		if node != null and is_instance_valid(node):
			node.queue_free()
	loaded_chunks.clear()

func get_loaded_chunk_count() -> int:
	return loaded_chunks.size()

func debug_force_chunk(coord: Vector2i) -> int:
	if not loaded_chunks.has(coord):
		_generate_chunk(coord)
	return loaded_chunks.size()
