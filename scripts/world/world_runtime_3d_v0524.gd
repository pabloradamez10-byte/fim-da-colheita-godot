extends "res://scripts/world/world_runtime_3d_v0523.gd"

const PlayerV0524Script = preload("res://scripts/player/player_3d_v0524.gd")
const SAVE_VERSION_0524 := "0.5.24-alpha"
const WORKBENCH_RANGE_0524 := 2.85
const STARTER_WORKBENCH_KEY_0524 := "workbench0524:starter_farm"

var starter_workbench_0524: Node3D = null
var workbench_interactions_0524 := 0

func _ready() -> void:
	super._ready()
	_build_starter_workbench_0524()

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0524Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _build_starter_workbench_0524() -> void:
	if starter_workbench_0524 != null and is_instance_valid(starter_workbench_0524):
		return
	starter_workbench_0524 = Node3D.new()
	starter_workbench_0524.name = "StarterFarmWorkbench0524"
	starter_workbench_0524.add_to_group("workbench_0524")
	starter_workbench_0524.add_to_group("craft_station_0524")
	add_child(starter_workbench_0524)
	starter_workbench_0524.global_position = _farm_to_world(Vector3(5.4, 0.20, 4.2))

	# Bancada velha da propriedade: tampo, pernas, prateleira, painel de ferramentas e morsa.
	_box(starter_workbench_0524, Vector3(2.35, 0.18, 0.88), Vector3(0.0, 0.88, 0.0), materials["wood_dark"])
	for x in [-0.95, 0.95]:
		for z in [-0.30, 0.30]:
			_box(starter_workbench_0524, Vector3(0.14, 0.82, 0.14), Vector3(x, 0.43, z), materials["wood"])
	_box(starter_workbench_0524, Vector3(2.05, 0.10, 0.62), Vector3(0.0, 0.36, 0.0), materials["wood"])
	_box(starter_workbench_0524, Vector3(2.20, 1.08, 0.08), Vector3(0.0, 1.46, 0.37), materials["wood_dark"])
	_box(starter_workbench_0524, Vector3(0.12, 0.58, 0.10), Vector3(-0.58, 1.48, 0.31), materials["metal"])
	_box(starter_workbench_0524, Vector3(0.52, 0.10, 0.10), Vector3(-0.58, 1.68, 0.31), materials["metal"])
	_box(starter_workbench_0524, Vector3(0.32, 0.22, 0.28), Vector3(0.72, 1.06, -0.16), materials["metal"])
	_box(starter_workbench_0524, Vector3(0.12, 0.28, 0.12), Vector3(0.86, 1.18, -0.16), materials["metal"])

	register_streamed_interaction(
		starter_workbench_0524.global_position,
		"workbench_0524",
		STARTER_WORKBENCH_KEY_0524,
		starter_workbench_0524,
		true
	)

func is_near_workbench_0524(pos: Vector3) -> bool:
	return _nearest_workbench_0524(pos) != null

func _nearest_workbench_0524(pos: Vector3) -> Node3D:
	var nearest: Node3D = null
	var best := WORKBENCH_RANGE_0524
	for raw in get_tree().get_nodes_in_group("workbench_0524"):
		if not (raw is Node3D):
			continue
		var node := raw as Node3D
		if not is_instance_valid(node):
			continue
		var distance := Vector2(pos.x - node.global_position.x, pos.z - node.global_position.z).length()
		if distance <= best:
			best = distance
			nearest = node
	return nearest

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var bench := _nearest_workbench_0524(pos)
	if bench != null:
		workbench_interactions_0524 += 1
		var key := STARTER_WORKBENCH_KEY_0524
		if target_player != null and target_player.has_method("activate_workbench_0524"):
			target_player.call("activate_workbench_0524", key)
		for raw_ui in get_tree().get_nodes_in_group("inventory_ui_0524"):
			if raw_ui != null and raw_ui.has_method("open_workbench_0524"):
				raw_ui.call("open_workbench_0524", key)
		return true
	return super.try_interact_near(pos, target_player)

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0524,
		"world": {
			"seed": world_seed,
			"farm_layout": farm_layout,
			"harvested": harvested_keys.duplicate(),
			"dead_zombies_0520": dead_zombies_0520.duplicate(),
			"corpse_records_0520": corpse_records_0520.duplicate(true),
			"death_bags_0520": death_bags_0520.duplicate(true),
			"kills_0520": kills_0520,
			"deaths_0520": deaths_0520,
			"world_day_0521": world_day_0521,
			"world_minutes_0521": world_minutes_0521
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	super.new_seed()
	call_deferred("_build_starter_workbench_0524")

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["workbenches_0524"] = get_tree().get_nodes_in_group("workbench_0524").size()
	result["near_workbench_0524"] = player != null and is_near_workbench_0524(player.global_position)
	return result

func get_crafting_debug_0524() -> Dictionary:
	var player_debug: Dictionary = {}
	if player != null and player.has_method("get_crafting_debug_0524"):
		player_debug = player.call("get_crafting_debug_0524") as Dictionary
	return {
		"workbenches": get_tree().get_nodes_in_group("workbench_0524").size(),
		"interactions": workbench_interactions_0524,
		"near": player != null and is_near_workbench_0524(player.global_position),
		"player_0524": player != null and player.get_script() == PlayerV0524Script,
		"player": player_debug
	}
