extends CharacterBody3D

const SPECIES_0538 := {
	"rabbit": {
		"name": "Coelho",
		"health": 18.0,
		"walk_speed": 1.15,
		"flee_speed": 5.10,
		"hearing": 18.0,
		"flee_distance": 8.0,
		"body": Vector3(0.72, 0.48, 1.00),
		"body_color": "8b7256",
		"accent_color": "d7c2a4"
	},
	"deer": {
		"name": "Veado",
		"health": 42.0,
		"walk_speed": 1.25,
		"flee_speed": 5.80,
		"hearing": 24.0,
		"flee_distance": 11.0,
		"body": Vector3(1.05, 0.82, 1.65),
		"body_color": "805a38",
		"accent_color": "d8b77c"
	},
	"boar": {
		"name": "Javali",
		"health": 68.0,
		"walk_speed": 1.05,
		"flee_speed": 4.15,
		"hearing": 20.0,
		"flee_distance": 6.5,
		"body": Vector3(1.20, 0.82, 1.70),
		"body_color": "51463d",
		"accent_color": "9b8a76"
	},
	"chicken": {
		"name": "Galinha",
		"health": 14.0,
		"walk_speed": 0.95,
		"flee_speed": 3.80,
		"hearing": 14.0,
		"flee_distance": 7.0,
		"body": Vector3(0.58, 0.58, 0.70),
		"body_color": "c6b58e",
		"accent_color": "e8ded0"
	}
}

var world_ref_0538: Node = null
var animal_id_0538 := ""
var species_id_0538 := "rabbit"
var health_0538 := 18.0
var max_health_0538 := 18.0
var dead_0538 := false
var harvested_0538 := false
var home_position_0538 := Vector3.ZERO
var wander_target_0538 := Vector3.ZERO
var flee_target_0538 := Vector3.ZERO
var flee_until_ms_0538 := 0
var wander_timer_0538 := 0.0
var last_noise_0538 := ""
var last_threat_0538 := ""
var state_0538 := "wander"
var collision_0538: CollisionShape3D = null

func configure_animal_0538(id: String, species: String, state: Dictionary, world_node: Node) -> void:
	animal_id_0538 = id
	species_id_0538 = species if SPECIES_0538.has(species) else "rabbit"
	world_ref_0538 = world_node
	var cfg: Dictionary = SPECIES_0538[species_id_0538] as Dictionary
	max_health_0538 = float(cfg.get("health", 18.0))
	health_0538 = clampf(float(state.get("health", max_health_0538)), 0.0, max_health_0538)
	dead_0538 = bool(state.get("dead", health_0538 <= 0.0))
	harvested_0538 = bool(state.get("harvested", false))
	home_position_0538 = _dict_to_vec_0538(state.get("home", state.get("position", {})) as Dictionary)
	last_noise_0538 = str(state.get("last_noise", ""))
	state_0538 = "carcass" if dead_0538 else "wander"

func _ready() -> void:
	add_to_group("animal_0538")
	add_to_group("huntable_0538")
	_build_visual_0538()
	_build_collision_0538()
	if home_position_0538 == Vector3.ZERO:
		home_position_0538 = global_position
	wander_target_0538 = home_position_0538
	wander_timer_0538 = 0.35 + float(abs(hash(animal_id_0538)) % 120) / 100.0
	if dead_0538:
		_apply_dead_pose_0538()

func _physics_process(delta: float) -> void:
	if dead_0538 or harvested_0538:
		velocity = Vector3.ZERO
		return
	var cfg: Dictionary = SPECIES_0538[species_id_0538] as Dictionary
	var now_ms := Time.get_ticks_msec()
	var threat := _nearest_threat_0538()
	if not threat.is_empty():
		var threat_pos: Vector3 = threat.get("position", global_position) as Vector3
		var flee_distance := float(cfg.get("flee_distance", 7.0))
		if global_position.distance_to(threat_pos) <= flee_distance:
			_start_flee_0538(threat_pos, str(threat.get("kind", "threat")), 3400)

	var speed := float(cfg.get("walk_speed", 1.0))
	var target := wander_target_0538
	if now_ms < flee_until_ms_0538:
		state_0538 = "flee"
		speed = float(cfg.get("flee_speed", 4.0))
		target = flee_target_0538
	else:
		state_0538 = "wander"
		wander_timer_0538 -= delta
		if wander_timer_0538 <= 0.0 or Vector2(global_position.x - wander_target_0538.x, global_position.z - wander_target_0538.z).length() < 1.1:
			_choose_wander_target_0538()
			target = wander_target_0538

	var flat := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	if flat.length() > 0.18:
		var direction := flat.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		rotation.y = atan2(-direction.x, -direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 3.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, speed * 3.0 * delta)
	velocity.y = 0.0
	move_and_slide()
	global_position.x = clampf(global_position.x, -64.0, 64.0)
	global_position.z = clampf(global_position.z, -64.0, 64.0)
	global_position.y = 0.34

func _nearest_threat_0538() -> Dictionary:
	var nearest_distance := 9999.0
	var result: Dictionary = {}
	if world_ref_0538 != null:
		var player_value: Variant = world_ref_0538.get("player")
		if player_value is Node3D and is_instance_valid(player_value as Node3D):
			var target_player := player_value as Node3D
			var d := global_position.distance_to(target_player.global_position)
			if d < nearest_distance:
				nearest_distance = d
				result = {"position": target_player.global_position, "kind": "player"}
	for raw: Node in get_tree().get_nodes_in_group("zombie_0537"):
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		var zombie := raw as Node3D
		var distance := global_position.distance_to(zombie.global_position)
		if distance < nearest_distance and distance <= 12.0:
			nearest_distance = distance
			result = {"position": zombie.global_position, "kind": "zombie"}
	return result

func _choose_wander_target_0538() -> void:
	var tick := int(Time.get_ticks_msec() / 2100)
	var marker := int(abs(hash("animal0538:%s:%d" % [animal_id_0538, tick])))
	var angle := float(marker % 6283) / 1000.0
	var radius := 3.0 + float(int(marker / 17) % 8)
	wander_target_0538 = home_position_0538 + Vector3(cos(angle) * radius, 0.34, sin(angle) * radius)
	wander_target_0538.x = clampf(wander_target_0538.x, -62.0, 62.0)
	wander_target_0538.z = clampf(wander_target_0538.z, -62.0, 62.0)
	wander_timer_0538 = 2.0 + float(int(marker / 31) % 30) / 10.0

func _start_flee_0538(source_pos: Vector3, source_kind: String, duration_ms: int = 4200) -> void:
	var away := Vector3(global_position.x - source_pos.x, 0.0, global_position.z - source_pos.z)
	if away.length() < 0.1:
		var marker := float(abs(hash(animal_id_0538)) % 6283) / 1000.0
		away = Vector3(cos(marker), 0.0, sin(marker))
	away = away.normalized()
	flee_target_0538 = global_position + away * 16.0
	flee_target_0538.x = clampf(flee_target_0538.x, -63.0, 63.0)
	flee_target_0538.z = clampf(flee_target_0538.z, -63.0, 63.0)
	flee_until_ms_0538 = maxi(flee_until_ms_0538, Time.get_ticks_msec() + duration_ms)
	last_threat_0538 = source_kind
	state_0538 = "flee"

func hear_noise_0538(pos: Vector3, radius: float, kind: String) -> bool:
	if dead_0538 or harvested_0538:
		return false
	var cfg: Dictionary = SPECIES_0538[species_id_0538] as Dictionary
	var hearing := float(cfg.get("hearing", 16.0))
	var effective := maxf(radius, hearing)
	if global_position.distance_to(pos) > effective:
		return false
	last_noise_0538 = kind
	_start_flee_0538(pos, "noise:%s" % kind, 4800)
	return true

func take_damage(amount: float) -> bool:
	if dead_0538 or harvested_0538 or amount <= 0.0:
		return false
	health_0538 = maxf(0.0, health_0538 - amount)
	var player_pos := global_position - Vector3(1.0, 0.0, 1.0)
	if world_ref_0538 != null:
		var player_value: Variant = world_ref_0538.get("player")
		if player_value is Node3D and is_instance_valid(player_value as Node3D):
			player_pos = (player_value as Node3D).global_position
	_start_flee_0538(player_pos, "damaged", 6500)
	if health_0538 <= 0.001:
		_die_0538()
	return true

func _die_0538() -> void:
	if dead_0538:
		return
	dead_0538 = true
	health_0538 = 0.0
	state_0538 = "carcass"
	velocity = Vector3.ZERO
	_apply_dead_pose_0538()
	if world_ref_0538 != null and world_ref_0538.has_method("register_animal_kill_0538"):
		world_ref_0538.call("register_animal_kill_0538", animal_id_0538, species_id_0538, global_position)

func _apply_dead_pose_0538() -> void:
	rotation_degrees.z = 82.0
	global_position.y = 0.27
	if collision_0538 != null:
		collision_0538.set_deferred("disabled", true)

func mark_harvested_0538() -> void:
	harvested_0538 = true
	state_0538 = "harvested"

func is_alive_0538() -> bool:
	return not dead_0538 and not harvested_0538

func get_species_config_0538() -> Dictionary:
	return (SPECIES_0538[species_id_0538] as Dictionary).duplicate(true)

func export_state_0538() -> Dictionary:
	return {
		"id": animal_id_0538,
		"species": species_id_0538,
		"position": _vec_to_dict_0538(global_position),
		"home": _vec_to_dict_0538(home_position_0538),
		"health": health_0538,
		"dead": dead_0538,
		"harvested": harvested_0538,
		"state": state_0538,
		"last_noise": last_noise_0538
	}

func get_animal_debug_0538() -> Dictionary:
	return export_state_0538()

func _build_collision_0538() -> void:
	var cfg: Dictionary = SPECIES_0538[species_id_0538] as Dictionary
	var body_size: Vector3 = cfg.get("body", Vector3(0.8, 0.6, 1.0)) as Vector3
	var shape := BoxShape3D.new()
	shape.size = Vector3(maxf(0.35, body_size.x * 0.72), maxf(0.35, body_size.y), maxf(0.45, body_size.z * 0.76))
	collision_0538 = CollisionShape3D.new()
	collision_0538.shape = shape
	collision_0538.position.y = body_size.y * 0.55
	add_child(collision_0538)

func _build_visual_0538() -> void:
	var cfg: Dictionary = SPECIES_0538[species_id_0538] as Dictionary
	var body_size: Vector3 = cfg.get("body", Vector3(0.8, 0.6, 1.0)) as Vector3
	var body_mat := _material_0538(Color(str(cfg.get("body_color", "8b7256"))))
	var accent_mat := _material_0538(Color(str(cfg.get("accent_color", "d7c2a4"))))
	var dark_mat := _material_0538(Color("302b27"))
	var red_mat := _material_0538(Color("a83b2f"))
	_mesh_box_0538(body_size, Vector3(0.0, body_size.y * 0.72, 0.0), body_mat)
	var head_pos := Vector3(0.0, body_size.y * 1.02, -body_size.z * 0.57)
	_mesh_sphere_0538(maxf(0.18, body_size.x * 0.28), head_pos, accent_mat, Vector3(1.0, 0.90, 1.15))

	if species_id_0538 == "rabbit":
		_mesh_box_0538(Vector3(0.11, 0.54, 0.12), head_pos + Vector3(-0.13, 0.38, 0.03), accent_mat)
		_mesh_box_0538(Vector3(0.11, 0.54, 0.12), head_pos + Vector3(0.13, 0.38, 0.03), accent_mat)
		_mesh_sphere_0538(0.17, Vector3(0.0, body_size.y * 0.78, body_size.z * 0.62), accent_mat, Vector3.ONE)
	elif species_id_0538 == "deer":
		for x in [-0.34, 0.34]:
			_mesh_box_0538(Vector3(0.13, 0.78, 0.13), Vector3(x, 0.42, -0.45), dark_mat)
			_mesh_box_0538(Vector3(0.13, 0.78, 0.13), Vector3(x, 0.42, 0.48), dark_mat)
		_mesh_box_0538(Vector3(0.08, 0.55, 0.08), head_pos + Vector3(-0.18, 0.42, 0.0), dark_mat)
		_mesh_box_0538(Vector3(0.08, 0.55, 0.08), head_pos + Vector3(0.18, 0.42, 0.0), dark_mat)
	elif species_id_0538 == "boar":
		for x in [-0.42, 0.42]:
			_mesh_box_0538(Vector3(0.18, 0.58, 0.18), Vector3(x, 0.34, -0.48), dark_mat)
			_mesh_box_0538(Vector3(0.18, 0.58, 0.18), Vector3(x, 0.34, 0.50), dark_mat)
		_mesh_box_0538(Vector3(0.55, 0.18, 0.32), head_pos + Vector3(0.0, -0.05, -0.22), dark_mat)
	elif species_id_0538 == "chicken":
		_mesh_box_0538(Vector3(0.09, 0.36, 0.09), Vector3(-0.15, 0.20, 0.0), dark_mat)
		_mesh_box_0538(Vector3(0.09, 0.36, 0.09), Vector3(0.15, 0.20, 0.0), dark_mat)
		_mesh_box_0538(Vector3(0.10, 0.20, 0.16), head_pos + Vector3(0.0, 0.23, 0.0), red_mat)
		_mesh_box_0538(Vector3(0.16, 0.10, 0.30), head_pos + Vector3(0.0, -0.02, -0.22), red_mat)

func _material_0538(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.92
	return mat

func _mesh_box_0538(size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	add_child(node)
	return node

func _mesh_sphere_0538(radius: float, pos: Vector3, material: Material, scale_value: Vector3) -> MeshInstance3D:
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
	add_child(node)
	return node

func _vec_to_dict_0538(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0538(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.34)), float(value.get("z", 0.0)))
