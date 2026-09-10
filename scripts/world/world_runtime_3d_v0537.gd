extends "res://scripts/world/world_runtime_3d_v0536.gd"

const ZombieV0537Script = preload("res://scripts/entities/zombie_3d_v0537.gd")
const SAVE_VERSION_0537 := "0.5.37-alpha"
const HORDE_COUNT_0537 := 4
const HORDE_MIGRATION_INTERVAL_0537 := 8.0
const HORDE_ALERT_SECONDS_0537 := 16.0
const DOOR_HEALTH_0537 := 78.0
const WINDOW_HEALTH_0537 := 38.0

const LOUD_NOISE_MULTIPLIER_0537 := {
	"pistol": 1.38,
	"shotgun": 1.62,
	"vehicle_engine": 1.22,
	"vehicle_crash": 1.55,
	"vehicle_hit_zombie": 1.30,
	"zombie_structure": 1.10,
	"zombie_hinge_0537": 1.08,
	"hurt": 1.08
}

var horde_records_0537: Dictionary = {}
var horde_migration_timer_0537 := 0.0
var horde_migrations_0537 := 0
var horde_noise_alerts_0537 := 0
var loud_noise_events_0537 := 0
var barrier_breaches_0537 := 0
var hinge_damage_events_0537 := 0
var hinge_health_0537: Dictionary = {}
var breached_interactions_0537: Array[String] = []
var last_horde_noise_0537 := ""
var last_breach_key_0537 := ""

func _load_save() -> void:
	super._load_save()
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	var raw_hordes: Variant = world_state.get("horde_records_0537", {})
	if raw_hordes is Dictionary:
		horde_records_0537 = (raw_hordes as Dictionary).duplicate(true)
	else:
		horde_records_0537 = {}
	var raw_hinge_health: Variant = world_state.get("hinge_health_0537", {})
	if raw_hinge_health is Dictionary:
		hinge_health_0537 = (raw_hinge_health as Dictionary).duplicate(true)
	else:
		hinge_health_0537 = {}
	breached_interactions_0537.clear()
	var raw_breaches: Variant = world_state.get("breached_interactions_0537", [])
	if raw_breaches is Array:
		for raw_key: Variant in raw_breaches:
			var key := str(raw_key)
			if key != "" and key not in breached_interactions_0537:
				breached_interactions_0537.append(key)
	horde_migrations_0537 = int(world_state.get("horde_migrations_0537", 0))
	horde_noise_alerts_0537 = int(world_state.get("horde_noise_alerts_0537", 0))
	loud_noise_events_0537 = int(world_state.get("loud_noise_events_0537", 0))
	barrier_breaches_0537 = int(world_state.get("barrier_breaches_0537", 0))
	hinge_damage_events_0537 = int(world_state.get("hinge_damage_events_0537", 0))
	last_horde_noise_0537 = str(world_state.get("last_horde_noise_0537", ""))
	last_breach_key_0537 = str(world_state.get("last_breach_key_0537", ""))
	_ensure_horde_records_0537()

func _ready() -> void:
	_ensure_horde_records_0537()
	super._ready()
	_ensure_horde_records_0537()

func _spawn_zombies(count: int) -> void:
	_ensure_horde_records_0537()
	var spawn_count := maxi(14, count)
	for i in range(spawn_count):
		var zombie_name := "Zombie_%02d" % i
		if dead_zombies_0520.has(zombie_name):
			continue
		var horde_id := i % HORDE_COUNT_0537
		var member_index := int(i / HORDE_COUNT_0537)
		var record: Dictionary = horde_records_0537.get(str(horde_id), {}) as Dictionary
		var center := _dict_to_vec_0537(record.get("spawn", {}) as Dictionary)
		var member_angle := float(member_index * 2 + horde_id) * 1.31
		var member_radius := 1.8 + float(member_index % 3) * 1.25
		var spawn_pos := center + Vector3(cos(member_angle) * member_radius, 0.20, sin(member_angle) * member_radius)
		spawn_pos.y = 0.20
		var zombie: CharacterBody3D = ZombieV0537Script.new()
		zombie.name = zombie_name
		zombie.call("configure_horde_0537", horde_id, member_index, (i + horde_id * 2) % 5)
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func _process(delta: float) -> void:
	super._process(delta)
	horde_migration_timer_0537 += delta
	if horde_migration_timer_0537 >= HORDE_MIGRATION_INTERVAL_0537:
		horde_migration_timer_0537 = 0.0
		_update_horde_migration_0537()

func _ensure_horde_records_0537() -> void:
	for horde_id in range(HORDE_COUNT_0537):
		var key := str(horde_id)
		if horde_records_0537.has(key) and horde_records_0537[key] is Dictionary:
			var existing: Dictionary = horde_records_0537[key] as Dictionary
			if not existing.has("phase"):
				existing["phase"] = 0
			if not existing.has("alert_until_ms"):
				existing["alert_until_ms"] = 0
			if not existing.has("last_noise"):
				existing["last_noise"] = ""
			if not existing.has("spawn") or not (existing["spawn"] is Dictionary):
				existing["spawn"] = _vec_to_dict_0537(_initial_horde_point_0537(horde_id, false))
			if not existing.has("target") or not (existing["target"] is Dictionary):
				existing["target"] = _vec_to_dict_0537(_initial_horde_point_0537(horde_id, true))
			horde_records_0537[key] = existing
			continue
		var spawn := _initial_horde_point_0537(horde_id, false)
		var target := _initial_horde_point_0537(horde_id, true)
		horde_records_0537[key] = {
			"spawn": _vec_to_dict_0537(spawn),
			"target": _vec_to_dict_0537(target),
			"phase": 0,
			"alert_until_ms": 0,
			"last_noise": ""
		}

func _initial_horde_point_0537(horde_id: int, target: bool) -> Vector3:
	var salt := 71 if target else 19
	var marker := int(abs(hash("horde0537:%d:%d:%d" % [world_seed, horde_id, salt])))
	var angle := float(marker % 6283) / 1000.0
	var radius := 24.0 + float(int(marker / 17) % 25)
	if target:
		radius = 16.0 + float(int(marker / 23) % 32)
	return Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)

func _update_horde_migration_0537() -> void:
	_ensure_horde_records_0537()
	var now_ms := Time.get_ticks_msec()
	for horde_id in range(HORDE_COUNT_0537):
		var key := str(horde_id)
		var record: Dictionary = horde_records_0537[key] as Dictionary
		if int(record.get("alert_until_ms", 0)) > now_ms:
			continue
		var target := _dict_to_vec_0537(record.get("target", {}) as Dictionary)
		var center := _horde_center_0537(horde_id)
		var close_to_target := center != Vector3.ZERO and Vector2(center.x - target.x, center.z - target.z).length() < 5.5
		var phase := int(record.get("phase", 0))
		if close_to_target or ((phase + horde_id + int(Time.get_ticks_msec() / 8000)) % 3 == 0):
			force_horde_migration_0537(horde_id)

func force_horde_migration_0537(horde_id: int) -> bool:
	_ensure_horde_records_0537()
	if horde_id < 0 or horde_id >= HORDE_COUNT_0537:
		return false
	var key := str(horde_id)
	var record: Dictionary = horde_records_0537[key] as Dictionary
	var phase := int(record.get("phase", 0)) + 1
	var marker := int(abs(hash("migration0537:%d:%d:%d" % [world_seed, horde_id, phase])))
	var angle := float(marker % 6283) / 1000.0
	var radius := 18.0 + float(int(marker / 31) % 37)
	var anchor := Vector3.ZERO
	if player != null and is_instance_valid(player) and phase % 3 == 0:
		anchor = player.global_position
		radius = 11.0 + float(int(marker / 47) % 16)
	var target := anchor + Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
	record["target"] = _vec_to_dict_0537(target)
	record["phase"] = phase
	record["alert_until_ms"] = 0
	record["last_noise"] = "migration"
	horde_records_0537[key] = record
	horde_migrations_0537 += 1
	return true

func get_horde_target_0537(horde_id: int) -> Vector3:
	_ensure_horde_records_0537()
	if horde_id < 0 or horde_id >= HORDE_COUNT_0537:
		return Vector3.ZERO
	var record: Dictionary = horde_records_0537[str(horde_id)] as Dictionary
	return _dict_to_vec_0537(record.get("target", {}) as Dictionary)

func _horde_center_0537(horde_id: int) -> Vector3:
	var total := Vector3.ZERO
	var count := 0
	for raw: Node in get_tree().get_nodes_in_group("zombie_0537"):
		if not (raw is Node3D):
			continue
		var zombie := raw as Node3D
		if int(zombie.get("horde_id_0537")) != horde_id:
			continue
		total += zombie.global_position
		count += 1
	if count <= 0:
		return Vector3.ZERO
	return total / float(count)

func emit_noise_0519(pos: Vector3, radius: float, kind: String, source: Node = null) -> void:
	super.emit_noise_0519(pos, radius, kind, source)
	var multiplier := float(LOUD_NOISE_MULTIPLIER_0537.get(kind, 1.0))
	if multiplier <= 1.001:
		return
	loud_noise_events_0537 += 1
	var expanded_radius := radius * multiplier
	for raw: Node in get_tree().get_nodes_in_group("zombie_0537"):
		if not (raw is Node3D):
			continue
		var zombie := raw as Node3D
		if source != null and zombie == source:
			continue
		if zombie.global_position.distance_to(pos) > expanded_radius:
			continue
		if zombie.has_method("hear_noise_0519"):
			zombie.call("hear_noise_0519", pos, expanded_radius, kind)

func register_horde_noise_0537(horde_id: int, pos: Vector3, radius: float, kind: String) -> void:
	_ensure_horde_records_0537()
	if horde_id < 0 or horde_id >= HORDE_COUNT_0537:
		return
	var key := str(horde_id)
	var record: Dictionary = horde_records_0537[key] as Dictionary
	var current_target := _dict_to_vec_0537(record.get("target", {}) as Dictionary)
	var should_replace := str(record.get("last_noise", "")) != kind or Vector2(current_target.x - pos.x, current_target.z - pos.z).length() > 2.5
	record["target"] = _vec_to_dict_0537(pos)
	record["alert_until_ms"] = Time.get_ticks_msec() + int((HORDE_ALERT_SECONDS_0537 + minf(radius * 0.12, 10.0)) * 1000.0)
	record["last_noise"] = kind
	horde_records_0537[key] = record
	if should_replace:
		horde_noise_alerts_0537 += 1
		last_horde_noise_0537 = "%d:%s" % [horde_id, kind]

func register_streamed_interaction(pos: Vector3, kind: String, key: String, node: Node3D = null, persistent: bool = true) -> void:
	super.register_streamed_interaction(pos, kind, key, node, persistent)
	if node == null or kind not in ["door", "window"]:
		return
	if hinge_health_0537.has(key):
		node.set_meta("zombie_health_0537", float(hinge_health_0537[key]))
	if key in breached_interactions_0537:
		call_deferred("_force_open_hinge_0537", node)

func damage_world_hinge_0537(hinge: Node3D, amount: float, source: String = "zombie") -> bool:
	if hinge == null or not is_instance_valid(hinge) or amount <= 0.0:
		return false
	var key := _interaction_key_for_node_0537(hinge)
	if key == "":
		key = "runtime_hinge:%d" % hinge.get_instance_id()
	if key in breached_interactions_0537:
		_force_open_hinge_0537(hinge)
		return true
	var kind := str(hinge.get("interaction_kind"))
	var max_health := WINDOW_HEALTH_0537 if kind == "window" else DOOR_HEALTH_0537
	var health := float(hinge_health_0537.get(key, max_health))
	health = maxf(0.0, health - amount)
	hinge_health_0537[key] = health
	hinge.set_meta("zombie_health_0537", health)
	hinge.set_meta("zombie_max_health_0537", max_health)
	hinge_damage_events_0537 += 1
	if health > 0.0:
		return true
	if key not in breached_interactions_0537:
		breached_interactions_0537.append(key)
	barrier_breaches_0537 += 1
	last_breach_key_0537 = key
	hinge.set_meta("zombie_breach_source_0537", source)
	_force_open_hinge_0537(hinge)
	super.emit_noise_0519(hinge.global_position, 13.0 if kind == "door" else 10.0, "barrier_breach_0537", hinge)
	save_game()
	return true

func _interaction_key_for_node_0537(target: Node3D) -> String:
	for raw: Variant in interactables:
		if not (raw is Dictionary):
			continue
		var data := raw as Dictionary
		var node_value: Variant = data.get("node")
		if node_value is Node3D and node_value == target:
			return str(data.get("key", ""))
	return ""

func _force_open_hinge_0537(hinge: Node3D) -> void:
	if hinge == null or not is_instance_valid(hinge):
		return
	hinge.set_meta("breached_0537", true)
	if not hinge.is_in_group("zombie_breached_hinge_0537"):
		hinge.add_to_group("zombie_breached_hinge_0537")
	var is_open := bool(hinge.get("is_open"))
	if not is_open and hinge.has_method("toggle_interaction"):
		hinge.call("toggle_interaction")

func _vec_to_dict_0537(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0537(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.20)), float(value.get("z", 0.0)))

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload: Dictionary = parsed as Dictionary
	payload["version"] = SAVE_VERSION_0537
	var world_state: Dictionary = payload.get("world", {}) as Dictionary
	world_state["horde_records_0537"] = horde_records_0537.duplicate(true)
	world_state["horde_migrations_0537"] = horde_migrations_0537
	world_state["horde_noise_alerts_0537"] = horde_noise_alerts_0537
	world_state["loud_noise_events_0537"] = loud_noise_events_0537
	world_state["barrier_breaches_0537"] = barrier_breaches_0537
	world_state["hinge_damage_events_0537"] = hinge_damage_events_0537
	world_state["hinge_health_0537"] = hinge_health_0537.duplicate(true)
	world_state["breached_interactions_0537"] = breached_interactions_0537.duplicate()
	world_state["last_horde_noise_0537"] = last_horde_noise_0537
	world_state["last_breach_key_0537"] = last_breach_key_0537
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	horde_records_0537.clear()
	hinge_health_0537.clear()
	breached_interactions_0537.clear()
	horde_migrations_0537 = 0
	horde_noise_alerts_0537 = 0
	loud_noise_events_0537 = 0
	barrier_breaches_0537 = 0
	hinge_damage_events_0537 = 0
	last_horde_noise_0537 = ""
	last_breach_key_0537 = ""
	_ensure_horde_records_0537()
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result: Dictionary = super.get_world_summary()
	var ecology := get_zombie_ecology_debug_0537()
	result["hordes_0537"] = int(ecology.get("hordes", 0))
	result["zombies_0537"] = int(ecology.get("zombies", 0))
	result["migrating_0537"] = int(ecology.get("migrating", 0))
	result["breaches_0537"] = barrier_breaches_0537
	return result

func get_zombie_ecology_debug_0537() -> Dictionary:
	_ensure_horde_records_0537()
	var horde_counts: Dictionary = {}
	var profile_counts: Dictionary = {}
	var migrating := 0
	var sprite_count := 0
	for raw: Node in get_tree().get_nodes_in_group("zombie_0537"):
		var horde_id := int(raw.get("horde_id_0537"))
		var profile_name := str(raw.get("archetype_0520"))
		horde_counts[str(horde_id)] = int(horde_counts.get(str(horde_id), 0)) + 1
		profile_counts[profile_name] = int(profile_counts.get(profile_name, 0)) + 1
		if str(raw.get("alert_state_0519")) == "migrate":
			migrating += 1
		if raw.get_node_or_null("ZombieSprite0537") != null:
			sprite_count += 1
	return {
		"zombies": get_tree().get_nodes_in_group("zombie_0537").size(),
		"hordes": HORDE_COUNT_0537,
		"horde_counts": horde_counts,
		"profiles": profile_counts,
		"visual_profiles": 5,
		"animation_frames": 8,
		"sprites": sprite_count,
		"migrating": migrating,
		"migrations": horde_migrations_0537,
		"noise_alerts": horde_noise_alerts_0537,
		"loud_noise_events": loud_noise_events_0537,
		"hinge_damage_events": hinge_damage_events_0537,
		"breaches": barrier_breaches_0537,
		"breached_keys": breached_interactions_0537.duplicate(),
		"last_noise": last_horde_noise_0537,
		"last_breach": last_breach_key_0537,
		"save_version": SAVE_VERSION_0537
	}
