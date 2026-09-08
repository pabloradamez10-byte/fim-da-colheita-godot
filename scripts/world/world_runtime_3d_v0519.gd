extends "res://scripts/world/world_runtime_3d_v0516.gd"

const PlayerV0519Script = preload("res://scripts/player/player_3d_v0519.gd")
const ZombieV0519Script = preload("res://scripts/entities/zombie_3d_v0519.gd")
const NOISE_HISTORY_LIMIT_0519 := 48

var noise_events_0519: Array[Dictionary] = []

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0519Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _spawn_zombies(count: int) -> void:
	for i in range(count):
		var zombie: CharacterBody3D = ZombieV0519Script.new()
		zombie.name = "Zombie_%02d" % i
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(18.0, 52.0)
		zombie.position = Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
		actors_root.add_child(zombie)

func emit_noise_0519(pos: Vector3, radius: float, kind: String, source: Node = null) -> void:
	var now := Time.get_ticks_msec()
	_prune_noise_0519(now, 6500)
	noise_events_0519.append({
		"position": pos,
		"radius": maxf(0.25, radius),
		"kind": kind,
		"created_ms": now,
		"source_id": source.get_instance_id() if source != null and is_instance_valid(source) else 0
	})
	while noise_events_0519.size() > NOISE_HISTORY_LIMIT_0519:
		noise_events_0519.pop_front()

func get_loudest_noise_for_0519(listener_pos: Vector3, max_age_ms: int = 4800) -> Dictionary:
	var now := Time.get_ticks_msec()
	_prune_noise_0519(now, max_age_ms)
	var best: Dictionary = {}
	var best_score := -INF
	for event in noise_events_0519:
		var event_pos := event.get("position", Vector3.ZERO) as Vector3
		var radius := float(event.get("radius", 0.0))
		var distance := listener_pos.distance_to(event_pos)
		if distance > radius:
			continue
		var age := float(now - int(event.get("created_ms", now))) / 1000.0
		var score := (radius - distance) - age * 0.65
		if score > best_score:
			best_score = score
			best = event.duplicate(true)
			best["distance"] = distance
			best["score"] = score
	return best

func _prune_noise_0519(now_ms: int, max_age_ms: int) -> void:
	for i in range(noise_events_0519.size() - 1, -1, -1):
		var event := noise_events_0519[i] as Dictionary
		if now_ms - int(event.get("created_ms", now_ms)) > max_age_ms:
			noise_events_0519.remove_at(i)

func get_noise_debug_0519() -> Dictionary:
	var kinds: Array[String] = []
	for event in noise_events_0519:
		kinds.append(str(event.get("kind", "?")))
	return {
		"count": noise_events_0519.size(),
		"kinds": kinds,
		"player_0519": player != null and player.get_script() == PlayerV0519Script,
		"zombie_ai_0519": get_tree().get_nodes_in_group("zombies").size()
	}
