extends "res://scripts/world/world_runtime_3d_v0539.gd"

const AtlasDecisionEngineV0540Script = preload("res://scripts/ai/atlas_decision_engine_v0540.gd")
const SurvivorNPCV0540Script = preload("res://scripts/entities/survivor_npc_3d_v0540.gd")
const SAVE_VERSION_0540 := "0.5.40-alpha"
const DECISION_INTERVAL_0540 := 1.25

var decision_engine_0540 = AtlasDecisionEngineV0540Script.new()
var decision_records_0540: Dictionary = {}
var decision_action_counts_0540: Dictionary = {}
var decision_cycles_0540 := 0
var decision_evaluations_0540 := 0
var decision_switches_0540 := 0
var decision_accumulator_0540 := 0.0
var last_decision_event_0540 := ""

func _load_save() -> void:
	super._load_save()
	var world_state := save_cache.get("world", {}) as Dictionary
	var raw_records: Variant = world_state.get("decision_records_0540", {})
	decision_records_0540 = (raw_records as Dictionary).duplicate(true) if raw_records is Dictionary else {}
	var raw_counts: Variant = world_state.get("decision_action_counts_0540", {})
	decision_action_counts_0540 = (raw_counts as Dictionary).duplicate(true) if raw_counts is Dictionary else {}
	decision_cycles_0540 = int(world_state.get("decision_cycles_0540", 0))
	decision_evaluations_0540 = int(world_state.get("decision_evaluations_0540", 0))
	decision_switches_0540 = int(world_state.get("decision_switches_0540", 0))
	last_decision_event_0540 = str(world_state.get("last_decision_event_0540", ""))

func _ready() -> void:
	super._ready()
	call_deferred("_initial_decision_cycle_0540")

func _process(delta: float) -> void:
	super._process(delta)
	decision_accumulator_0540 += delta
	if decision_accumulator_0540 >= DECISION_INTERVAL_0540:
		decision_accumulator_0540 = 0.0
		_run_decision_cycle_0540()

func _spawn_survivors_0539() -> void:
	if actors_root == null or not is_instance_valid(actors_root):
		return
	_ensure_survivor_records_0539()
	for raw_id: Variant in survivor_records_0539.keys():
		var id := str(raw_id)
		var state := survivor_records_0539[id] as Dictionary
		var npc: CharacterBody3D = SurvivorNPCV0540Script.new()
		npc.name = "Survivor_%s" % id
		npc.call(
			"configure_survivor_0539",
			id,
			str(state.get("name", id)),
			str(state.get("role", "scavenger")),
			state,
			self
		)
		npc.position = _dict_to_vec_0539(state.get("position", {}) as Dictionary)
		actors_root.add_child(npc)

func _initial_decision_cycle_0540() -> void:
	await get_tree().process_frame
	_run_decision_cycle_0540()

func _run_decision_cycle_0540() -> void:
	decision_cycles_0540 += 1
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		var npc := raw as Node3D
		if not npc.has_method("apply_decision_0540"):
			continue
		var context := _build_decision_context_0540(npc)
		var decision := decision_engine_0540.call("evaluate_0540", context) as Dictionary
		var id := str(context.get("survivor_id", ""))
		var previous := decision_records_0540.get(id, {}) as Dictionary
		var previous_action := str(previous.get("action", ""))
		var action := str(decision.get("action", "role_patrol"))
		if previous_action != "" and previous_action != action:
			decision_switches_0540 += 1
		var target := _resolve_decision_target_0540(npc, action, context)
		decision["target"] = _vec_to_dict_0540(target)
		decision["cycle"] = decision_cycles_0540
		decision["day"] = int(context.get("day", 1))
		decision["minute"] = float(context.get("minute", 0.0))
		decision["target_kind"] = _target_kind_0540(action, context)
		decision_records_0540[id] = decision.duplicate(true)
		decision_action_counts_0540[action] = int(decision_action_counts_0540.get(action, 0)) + 1
		decision_evaluations_0540 += 1
		npc.call("apply_decision_0540", decision, target, decision_cycles_0540)
		last_decision_event_0540 = "%s:%s:%s" % [id, action, str(decision.get("reason", ""))]

func _build_decision_context_0540(npc: Node3D) -> Dictionary:
	var npc_pos := npc.global_position
	var threat := _nearest_zombie_context_0540(npc_pos)
	var player_distance := 9999.0
	var player_pos := npc_pos
	if player != null and is_instance_valid(player):
		player_pos = player.global_position
		player_distance = npc_pos.distance_to(player_pos)
	var time_state := get_time_state_0521() if has_method("get_time_state_0521") else {}
	return {
		"survivor_id": str(npc.get("survivor_id_0539")),
		"role": str(npc.get("role_id_0539")),
		"health": float(npc.get("health_0539")),
		"hunger": float(npc.get("hunger_0539")),
		"thirst": float(npc.get("thirst_0539")),
		"trust": int(npc.get("trust_0539")),
		"met_player": bool(npc.get("met_player_0539")),
		"dead": bool(npc.get("dead_0539")),
		"position": npc_pos,
		"home": npc.get("home_position_0539") as Vector3,
		"player_position": player_pos,
		"player_distance": player_distance,
		"zombie_position": threat.get("position", npc_pos) as Vector3,
		"zombie_distance": float(threat.get("distance", 9999.0)),
		"night": bool(time_state.get("night", false)),
		"day": int(time_state.get("day", 1)),
		"minute": float(time_state.get("minutes", 0.0))
	}

func _nearest_zombie_context_0540(pos: Vector3) -> Dictionary:
	var best := 9999.0
	var result: Dictionary = {"distance": best, "position": pos}
	for raw: Node in get_tree().get_nodes_in_group("zombie_0537"):
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		var zombie := raw as Node3D
		var distance := pos.distance_to(zombie.global_position)
		if distance < best:
			best = distance
			result = {"distance": distance, "position": zombie.global_position}
	return result

func _resolve_decision_target_0540(npc: Node3D, action: String, context: Dictionary) -> Vector3:
	var home := context.get("home", npc.global_position) as Vector3
	var player_pos := context.get("player_position", npc.global_position) as Vector3
	var met_player := bool(context.get("met_player", false))
	var player_distance := float(context.get("player_distance", 9999.0))
	match action:
		"flee_threat":
			return context.get("zombie_position", npc.global_position) as Vector3
		"seek_water":
			if met_player and player_distance < 38.0:
				return _player_approach_point_0540(player_pos, npc, 2.3)
			return home + Vector3(-5.0, 0.0, 4.0)
		"seek_food":
			if met_player and player_distance < 38.0:
				return _player_approach_point_0540(player_pos, npc, 2.6)
			return home + Vector3(5.5, 0.0, -3.5)
		"seek_medical":
			if met_player and player_distance < 38.0:
				return _player_approach_point_0540(player_pos, npc, 2.1)
			return home
		"return_home":
			return home
		"regroup_player":
			return _player_approach_point_0540(player_pos, npc, 3.2)
		_:
			return _role_patrol_target_0540(npc, home)

func _player_approach_point_0540(player_pos: Vector3, npc: Node3D, distance: float) -> Vector3:
	var away := Vector3(npc.global_position.x - player_pos.x, 0.0, npc.global_position.z - player_pos.z)
	if away.length() < 0.1:
		var marker := float(abs(hash(str(npc.get("survivor_id_0539")))) % 6283) / 1000.0
		away = Vector3(cos(marker), 0.0, sin(marker))
	return player_pos + away.normalized() * distance + Vector3(0.0, 0.20 - player_pos.y, 0.0)

func _role_patrol_target_0540(npc: Node3D, home: Vector3) -> Vector3:
	var role := str(npc.get("role_id_0539"))
	var id := str(npc.get("survivor_id_0539"))
	var phase := decision_cycles_0540 + int(abs(hash(id)) % 5)
	var base_angle := float(phase % 8) / 8.0 * TAU
	var radius := 7.0
	match role:
		"medic": radius = 6.0
		"mechanic": radius = 8.0
		"scavenger": radius = 11.0
	var target := home + Vector3(cos(base_angle) * radius, 0.0, sin(base_angle) * radius)
	target.x = clampf(target.x, -62.0, 62.0)
	target.z = clampf(target.z, -62.0, 62.0)
	target.y = 0.20
	return target

func _target_kind_0540(action: String, context: Dictionary) -> String:
	if action in ["seek_water", "seek_food", "seek_medical"]:
		if bool(context.get("met_player", false)) and float(context.get("player_distance", 9999.0)) < 38.0:
			return "player_help"
		return "search_area"
	if action == "regroup_player":
		return "player"
	if action == "return_home":
		return "home"
	if action == "flee_threat":
		return "threat"
	return "role_route"

func save_game() -> void:
	# Sync NPC decision state into the survivor records before the inherited save.
	_sync_survivor_records_0539()
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_0540
	var world_state := payload.get("world", {}) as Dictionary
	world_state["decision_records_0540"] = decision_records_0540.duplicate(true)
	world_state["decision_action_counts_0540"] = decision_action_counts_0540.duplicate(true)
	world_state["decision_cycles_0540"] = decision_cycles_0540
	world_state["decision_evaluations_0540"] = decision_evaluations_0540
	world_state["decision_switches_0540"] = decision_switches_0540
	world_state["last_decision_event_0540"] = last_decision_event_0540
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	decision_records_0540.clear()
	decision_action_counts_0540.clear()
	decision_cycles_0540 = 0
	decision_evaluations_0540 = 0
	decision_switches_0540 = 0
	decision_accumulator_0540 = 0.0
	last_decision_event_0540 = ""
	super.new_seed()
	_run_decision_cycle_0540()
	save_game()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var engine := get_decision_engine_debug_0540()
	result["decision_cycles_0540"] = int(engine.get("cycles", 0))
	result["decision_switches_0540"] = int(engine.get("switches", 0))
	result["last_decision_0540"] = str(engine.get("last_event", ""))
	return result

func force_decision_cycle_debug_0540() -> Dictionary:
	_run_decision_cycle_0540()
	return get_decision_engine_debug_0540()

func evaluate_decision_debug_0540(context: Dictionary) -> Dictionary:
	return decision_engine_0540.call("evaluate_0540", context) as Dictionary

func get_survivor_decision_0540(survivor_id: String) -> Dictionary:
	if decision_records_0540.has(survivor_id):
		return (decision_records_0540[survivor_id] as Dictionary).duplicate(true)
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if str(raw.get("survivor_id_0539")) == survivor_id and raw.has_method("get_decision_state_0540"):
			return raw.call("get_decision_state_0540") as Dictionary
	return {}

func get_decision_engine_debug_0540() -> Dictionary:
	var engine_debug := decision_engine_0540.call("get_engine_debug_0540") as Dictionary
	var current_actions: Dictionary = {}
	for raw_id: Variant in decision_records_0540.keys():
		var record := decision_records_0540[raw_id] as Dictionary
		current_actions[str(raw_id)] = str(record.get("action", ""))
	return {
		"version": SAVE_VERSION_0540,
		"engine": engine_debug,
		"cycles": decision_cycles_0540,
		"evaluations": decision_evaluations_0540,
		"switches": decision_switches_0540,
		"records": decision_records_0540.size(),
		"action_counts": decision_action_counts_0540.duplicate(true),
		"current_actions": current_actions,
		"last_event": last_decision_event_0540,
		"survivors_0539": has_method("get_survivor_society_debug_0539"),
		"wildlife_0538": has_method("get_animal_ecology_debug_0538"),
		"zombies_0537": has_method("get_zombie_ecology_debug_0537")
	}

func _vec_to_dict_0540(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}
