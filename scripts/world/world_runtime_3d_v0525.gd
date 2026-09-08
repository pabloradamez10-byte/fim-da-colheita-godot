extends "res://scripts/world/world_runtime_3d_v0524.gd"

const PlayerV0525Script = preload("res://scripts/player/player_3d_v0525.gd")
const SAVE_VERSION_0525 := "0.5.25-alpha"

var workbench_status_label_0525: Label3D = null
var production_label_timer_0525 := 0.0

func _ready() -> void:
	super._ready()
	_build_workbench_status_label_0525()

func _process(delta: float) -> void:
	super._process(delta)
	production_label_timer_0525 += delta
	if production_label_timer_0525 >= 0.20:
		production_label_timer_0525 = 0.0
		_update_workbench_status_label_0525()

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0525Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _build_workbench_status_label_0525() -> void:
	if starter_workbench_0524 == null or not is_instance_valid(starter_workbench_0524):
		return
	if workbench_status_label_0525 != null and is_instance_valid(workbench_status_label_0525):
		return
	workbench_status_label_0525 = Label3D.new()
	workbench_status_label_0525.name = "ProductionStatus0525"
	workbench_status_label_0525.position = Vector3(0.0, 2.25, 0.0)
	workbench_status_label_0525.text = "BANCADA"
	workbench_status_label_0525.font_size = 24
	workbench_status_label_0525.outline_size = 5
	workbench_status_label_0525.modulate = Color(0.95, 0.78, 0.38, 0.95)
	workbench_status_label_0525.add_to_group("production_status_0525")
	starter_workbench_0524.add_child(workbench_status_label_0525)
	_update_workbench_status_label_0525()

func _update_workbench_status_label_0525() -> void:
	if workbench_status_label_0525 == null or not is_instance_valid(workbench_status_label_0525):
		return
	if player == null or not player.has_method("get_production_status_0525"):
		workbench_status_label_0525.text = "BANCADA"
		return
	var status := player.call("get_production_status_0525") as Dictionary
	var queue_size := int(status.get("queue_size", 0))
	var current := status.get("current", {}) as Dictionary
	if queue_size <= 0 or current.is_empty():
		workbench_status_label_0525.text = "BANCADA"
		return
	var station := str(current.get("station", "field"))
	if station != "workbench":
		workbench_status_label_0525.text = "BANCADA\nFila %d" % queue_size
		return
	var state := str(current.get("state", "queued"))
	var remaining := int(ceil(float(current.get("remaining", 0.0))))
	var state_text := "PRODUZINDO"
	if state in ["waiting_station", "paused_station"]:
		state_text = "PAUSADA"
	elif state in ["waiting_tool", "paused_tool"]:
		state_text = "SEM FERRAMENTA"
	elif state == "waiting_resources":
		state_text = "SEM MATERIAL"
	workbench_status_label_0525.text = "%s\n%s • %ds" % [state_text, str(current.get("name", "Produção")), remaining]

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0525,
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
	call_deferred("_build_workbench_status_label_0525")

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	if player != null and player.has_method("get_production_status_0525"):
		var status := player.call("get_production_status_0525") as Dictionary
		result["production_queue_0525"] = int(status.get("queue_size", 0))
		result["production_state_0525"] = str(status.get("state", "idle"))
	return result

func get_production_debug_0525() -> Dictionary:
	var player_debug: Dictionary = {}
	if player != null and player.has_method("get_production_debug_0525"):
		player_debug = player.call("get_production_debug_0525") as Dictionary
	return {
		"player_0525": player != null and player.get_script() == PlayerV0525Script,
		"label": workbench_status_label_0525 != null and is_instance_valid(workbench_status_label_0525),
		"workbenches": get_tree().get_nodes_in_group("workbench_0524").size(),
		"player": player_debug
	}
