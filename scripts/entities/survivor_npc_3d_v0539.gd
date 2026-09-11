extends CharacterBody3D

const ROLE_CONFIG_0539 := {
	"medic": {
		"role_name": "Socorrista",
		"body_color": "6f806f",
		"accent_color": "d9ddd2",
		"gift_item": "bandage",
		"gift_amount": 1,
		"walk_speed": 1.75,
		"flee_speed": 4.90
	},
	"mechanic": {
		"role_name": "Mecânico",
		"body_color": "715a3d",
		"accent_color": "c69b52",
		"gift_item": "gasoline",
		"gift_amount": 2,
		"walk_speed": 1.65,
		"flee_speed": 4.60
	},
	"scavenger": {
		"role_name": "Catador",
		"body_color": "4b5d52",
		"accent_color": "8c7660",
		"gift_item": "food",
		"gift_amount": 1,
		"walk_speed": 1.95,
		"flee_speed": 5.20
	}
}

var world_ref_0539: Node = null
var survivor_id_0539 := ""
var survivor_name_0539 := "Sobrevivente"
var role_id_0539 := "scavenger"
var health_0539 := 100.0
var hunger_0539 := 82.0
var thirst_0539 := 82.0
var trust_0539 := 0
var met_player_0539 := false
var gift_shared_0539 := false
var dead_0539 := false
var state_0539 := "wander"
var home_position_0539 := Vector3.ZERO
var wander_target_0539 := Vector3.ZERO
var flee_target_0539 := Vector3.ZERO
var flee_until_ms_0539 := 0
var wander_timer_0539 := 0.0
var last_noise_0539 := ""
var last_interaction_0539 := ""
var zombie_contact_cooldown_0539 := 0.0
var collision_0539: CollisionShape3D = null
var name_label_0539: Label3D = null

func configure_survivor_0539(id: String, survivor_name: String, role_id: String, state: Dictionary, world_node: Node) -> void:
	survivor_id_0539 = id
	survivor_name_0539 = survivor_name
	role_id_0539 = role_id if ROLE_CONFIG_0539.has(role_id) else "scavenger"
	world_ref_0539 = world_node
	health_0539 = clampf(float(state.get("health", 100.0)), 0.0, 100.0)
	hunger_0539 = clampf(float(state.get("hunger", 82.0)), 0.0, 100.0)
	thirst_0539 = clampf(float(state.get("thirst", 82.0)), 0.0, 100.0)
	trust_0539 = clampi(int(state.get("trust", 0)), 0, 100)
	met_player_0539 = bool(state.get("met_player", false))
	gift_shared_0539 = bool(state.get("gift_shared", false))
	dead_0539 = bool(state.get("dead", health_0539 <= 0.0))
	last_noise_0539 = str(state.get("last_noise", ""))
	last_interaction_0539 = str(state.get("last_interaction", ""))
	home_position_0539 = _dict_to_vec_0539(state.get("home", state.get("position", {})) as Dictionary)
	state_0539 = "dead" if dead_0539 else str(state.get("state", "wander"))

func _ready() -> void:
	add_to_group("survivor_0539")
	add_to_group("human_npc_0539")
	_build_visual_0539()
	_build_collision_0539()
	if home_position_0539 == Vector3.ZERO:
		home_position_0539 = global_position
	wander_target_0539 = home_position_0539
	wander_timer_0539 = 0.4 + float(abs(hash(survivor_id_0539)) % 170) / 100.0
	if dead_0539:
		_apply_dead_pose_0539()
	_refresh_label_0539()

func _physics_process(delta: float) -> void:
	if dead_0539:
		velocity = Vector3.ZERO
		return
	zombie_contact_cooldown_0539 = maxf(0.0, zombie_contact_cooldown_0539 - delta)
	_update_needs_0539(delta)
	if dead_0539:
		return

	var cfg := ROLE_CONFIG_0539[role_id_0539] as Dictionary
	var now_ms := Time.get_ticks_msec()
	var threat := _nearest_zombie_0539()
	if not threat.is_empty():
		var threat_pos := threat.get("position", global_position) as Vector3
		var distance := global_position.distance_to(threat_pos)
		if distance <= 9.5:
			_start_flee_0539(threat_pos, "zombie", 3800)
		if distance <= 1.65 and zombie_contact_cooldown_0539 <= 0.0:
			zombie_contact_cooldown_0539 = 1.35
			take_damage_0539(7.0, "zombie")

	var target := wander_target_0539
	var speed := float(cfg.get("walk_speed", 1.7))
	if now_ms < flee_until_ms_0539:
		state_0539 = "flee"
		target = flee_target_0539
		speed = float(cfg.get("flee_speed", 4.8))
	else:
		state_0539 = "wander"
		wander_timer_0539 -= delta
		if wander_timer_0539 <= 0.0 or Vector2(global_position.x - wander_target_0539.x, global_position.z - wander_target_0539.z).length() < 1.0:
			_choose_wander_target_0539()
			target = wander_target_0539

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
	global_position.y = 0.20

func _update_needs_0539(delta: float) -> void:
	hunger_0539 = maxf(0.0, hunger_0539 - 0.018 * delta)
	thirst_0539 = maxf(0.0, thirst_0539 - 0.028 * delta)
	if hunger_0539 <= 0.0 or thirst_0539 <= 0.0:
		health_0539 = maxf(0.0, health_0539 - 0.30 * delta)
	if health_0539 <= 0.001:
		_die_0539("needs")

func _nearest_zombie_0539() -> Dictionary:
	var best := 9999.0
	var result: Dictionary = {}
	for raw: Node in get_tree().get_nodes_in_group("zombie_0537"):
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		var zombie := raw as Node3D
		var distance := global_position.distance_to(zombie.global_position)
		if distance < best:
			best = distance
			result = {"position": zombie.global_position, "distance": distance}
	return result

func _choose_wander_target_0539() -> void:
	var tick := int(Time.get_ticks_msec() / 2400)
	var marker := int(abs(hash("survivor0539:%s:%d" % [survivor_id_0539, tick])))
	var angle := float(marker % 6283) / 1000.0
	var radius := 3.0 + float(int(marker / 29) % 7)
	wander_target_0539 = home_position_0539 + Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
	wander_target_0539.x = clampf(wander_target_0539.x, -62.0, 62.0)
	wander_target_0539.z = clampf(wander_target_0539.z, -62.0, 62.0)
	wander_timer_0539 = 2.2 + float(int(marker / 41) % 28) / 10.0

func _start_flee_0539(source_pos: Vector3, source_kind: String, duration_ms: int = 4200) -> void:
	var away := Vector3(global_position.x - source_pos.x, 0.0, global_position.z - source_pos.z)
	if away.length() < 0.1:
		var marker := float(abs(hash(survivor_id_0539)) % 6283) / 1000.0
		away = Vector3(cos(marker), 0.0, sin(marker))
	away = away.normalized()
	flee_target_0539 = global_position + away * 15.0
	flee_target_0539.x = clampf(flee_target_0539.x, -63.0, 63.0)
	flee_target_0539.z = clampf(flee_target_0539.z, -63.0, 63.0)
	flee_until_ms_0539 = maxi(flee_until_ms_0539, Time.get_ticks_msec() + duration_ms)
	last_noise_0539 = source_kind
	state_0539 = "flee"

func hear_noise_0539(pos: Vector3, radius: float, kind: String) -> bool:
	if dead_0539:
		return false
	var effective := maxf(radius, 17.0)
	if global_position.distance_to(pos) > effective:
		return false
	last_noise_0539 = kind
	_start_flee_0539(pos, "noise:%s" % kind, 5000)
	return true

func take_damage_0539(amount: float, source_kind: String = "damage") -> bool:
	if dead_0539 or amount <= 0.0:
		return false
	health_0539 = maxf(0.0, health_0539 - amount)
	last_interaction_0539 = "hurt:%s" % source_kind
	if health_0539 <= 0.001:
		_die_0539(source_kind)
	return true

func receive_aid_0539(kind: String) -> void:
	match kind:
		"water":
			thirst_0539 = minf(100.0, thirst_0539 + 42.0)
			trust_0539 = mini(100, trust_0539 + 7)
		"food":
			hunger_0539 = minf(100.0, hunger_0539 + 34.0)
			trust_0539 = mini(100, trust_0539 + 7)
		"bandage":
			health_0539 = minf(100.0, health_0539 + 36.0)
			trust_0539 = mini(100, trust_0539 + 9)
	last_interaction_0539 = "aid:%s" % kind
	_refresh_label_0539()

func mark_met_0539() -> bool:
	if met_player_0539:
		return false
	met_player_0539 = true
	trust_0539 = mini(100, trust_0539 + 12)
	last_interaction_0539 = "first_contact"
	_refresh_label_0539()
	return true

func add_trust_0539(amount: int, reason: String = "talk") -> void:
	trust_0539 = clampi(trust_0539 + amount, 0, 100)
	last_interaction_0539 = reason
	_refresh_label_0539()

func mark_gift_shared_0539() -> void:
	gift_shared_0539 = true
	last_interaction_0539 = "shared_supplies"
	trust_0539 = mini(100, trust_0539 + 3)
	_refresh_label_0539()

func set_needs_debug_0539(hunger_value: float, thirst_value: float, health_value: float = -1.0) -> void:
	hunger_0539 = clampf(hunger_value, 0.0, 100.0)
	thirst_0539 = clampf(thirst_value, 0.0, 100.0)
	if health_value >= 0.0:
		health_0539 = clampf(health_value, 0.0, 100.0)
	_refresh_label_0539()

func set_trust_debug_0539(value: int) -> void:
	trust_0539 = clampi(value, 0, 100)
	_refresh_label_0539()

func _die_0539(cause: String) -> void:
	if dead_0539:
		return
	dead_0539 = true
	health_0539 = 0.0
	state_0539 = "dead"
	velocity = Vector3.ZERO
	_apply_dead_pose_0539()
	last_interaction_0539 = "dead:%s" % cause
	if world_ref_0539 != null and world_ref_0539.has_method("register_survivor_death_0539"):
		world_ref_0539.call("register_survivor_death_0539", survivor_id_0539, cause, global_position)

func _apply_dead_pose_0539() -> void:
	rotation_degrees.z = 88.0
	global_position.y = 0.14
	if collision_0539 != null:
		collision_0539.set_deferred("disabled", true)
	_refresh_label_0539()

func get_relation_tier_0539() -> String:
	if trust_0539 >= 60:
		return "confiável"
	if trust_0539 >= 35:
		return "amigável"
	if trust_0539 >= 15:
		return "conhecido"
	return "estranho"

func get_role_config_0539() -> Dictionary:
	return (ROLE_CONFIG_0539[role_id_0539] as Dictionary).duplicate(true)

func export_state_0539() -> Dictionary:
	return {
		"id": survivor_id_0539,
		"name": survivor_name_0539,
		"role": role_id_0539,
		"position": _vec_to_dict_0539(global_position),
		"home": _vec_to_dict_0539(home_position_0539),
		"health": health_0539,
		"hunger": hunger_0539,
		"thirst": thirst_0539,
		"trust": trust_0539,
		"met_player": met_player_0539,
		"gift_shared": gift_shared_0539,
		"dead": dead_0539,
		"state": state_0539,
		"last_noise": last_noise_0539,
		"last_interaction": last_interaction_0539
	}

func get_survivor_debug_0539() -> Dictionary:
	var result := export_state_0539()
	result["relation"] = get_relation_tier_0539()
	result["role_name"] = str((ROLE_CONFIG_0539[role_id_0539] as Dictionary).get("role_name", role_id_0539))
	return result

func _build_collision_0539() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.70
	collision_0539 = CollisionShape3D.new()
	collision_0539.shape = shape
	collision_0539.position.y = 0.86
	add_child(collision_0539)

func _build_visual_0539() -> void:
	var cfg := ROLE_CONFIG_0539[role_id_0539] as Dictionary
	var body_mat := _material_0539(Color(str(cfg.get("body_color", "4b5d52"))))
	var accent_mat := _material_0539(Color(str(cfg.get("accent_color", "8c7660"))))
	var skin_mat := _material_0539(Color("b98c68"))
	var dark_mat := _material_0539(Color("2a2b29"))
	_mesh_box_0539(Vector3(0.66, 0.82, 0.36), Vector3(0, 1.35, 0), body_mat)
	_mesh_box_0539(Vector3(0.25, 0.80, 0.25), Vector3(-0.19, 0.55, 0), dark_mat)
	_mesh_box_0539(Vector3(0.25, 0.80, 0.25), Vector3(0.19, 0.55, 0), dark_mat)
	_mesh_box_0539(Vector3(0.20, 0.72, 0.20), Vector3(-0.45, 1.35, 0), body_mat)
	_mesh_box_0539(Vector3(0.20, 0.72, 0.20), Vector3(0.45, 1.35, 0), body_mat)
	_mesh_sphere_0539(0.31, Vector3(0, 2.02, 0), skin_mat, Vector3(0.90, 1.0, 0.90))
	_mesh_box_0539(Vector3(0.60, 0.76, 0.22), Vector3(0, 1.37, 0.30), accent_mat)
	if role_id_0539 == "medic":
		_mesh_box_0539(Vector3(0.28, 0.08, 0.05), Vector3(0, 1.42, -0.20), _material_0539(Color("d8d8d0")))
		_mesh_box_0539(Vector3(0.08, 0.28, 0.05), Vector3(0, 1.42, -0.20), _material_0539(Color("a8443b")))
	elif role_id_0539 == "mechanic":
		_mesh_box_0539(Vector3(0.54, 0.12, 0.10), Vector3(0, 1.78, -0.18), accent_mat)
	else:
		_mesh_box_0539(Vector3(0.44, 0.10, 0.14), Vector3(0, 1.75, -0.18), accent_mat)
	name_label_0539 = Label3D.new()
	name_label_0539.position = Vector3(0, 2.62, 0)
	name_label_0539.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label_0539.font_size = 28
	name_label_0539.modulate = Color(0.92, 0.90, 0.78, 0.95)
	name_label_0539.outline_size = 5
	add_child(name_label_0539)

func _refresh_label_0539() -> void:
	if name_label_0539 == null:
		return
	var role_name := str((ROLE_CONFIG_0539[role_id_0539] as Dictionary).get("role_name", role_id_0539))
	if dead_0539:
		name_label_0539.text = "%s • morto" % survivor_name_0539
	else:
		name_label_0539.text = "%s • %s • %s" % [survivor_name_0539, role_name, get_relation_tier_0539()]

func _mesh_box_0539(size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	add_child(node)
	return node

func _mesh_sphere_0539(radius: float, pos: Vector3, material: Material, scale_value: Vector3) -> MeshInstance3D:
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

func _material_0539(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.95
	return material

func _vec_to_dict_0539(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0539(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.20)), float(value.get("z", 0.0)))
