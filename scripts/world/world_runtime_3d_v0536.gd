extends "res://scripts/world/world_runtime_3d_v0535.gd"

const PlayerV0536Script = preload("res://scripts/player/player_3d_v0536.gd")
const SAVE_VERSION_0536 := "0.5.36-alpha"
const MISSION_ORDER_0536 := ["scavenge_route", "first_harvest", "field_medic", "road_ready", "clear_path"]
const MISSION_DEFS_0536 := {
	"scavenge_route": {
		"title": "ROTA DE SUPRIMENTOS",
		"description": "Vasculhe 2 pontos de interesse especializados.",
		"event": "poi_loot",
		"target": 2,
		"reward_items": {"water": 2, "bandage": 1},
		"reward_skill": "scavenging",
		"reward_xp": 20
	},
	"first_harvest": {
		"title": "DO CHÃO À MESA",
		"description": "Colha uma cultura madura.",
		"event": "harvest",
		"target": 1,
		"reward_items": {"potato_seed": 2, "corn_seed": 2, "carrot_seed": 2},
		"reward_skill": "farming",
		"reward_xp": 20
	},
	"field_medic": {
		"title": "PRIMEIROS SOCORROS",
		"description": "Use 2 tratamentos médicos.",
		"event": "medicine_use",
		"target": 2,
		"reward_items": {"bandage": 2, "antiseptic": 1},
		"reward_skill": "medicine",
		"reward_xp": 20
	},
	"road_ready": {
		"title": "DE VOLTA À ESTRADA",
		"description": "Repare um veículo danificado.",
		"event": "vehicle_repair",
		"target": 1,
		"reward_items": {"gasoline": 3, "repair_kit": 1},
		"reward_skill": "mechanics",
		"reward_xp": 20
	},
	"clear_path": {
		"title": "LIMPEZA DA ÁREA",
		"description": "Acerte zumbis 8 vezes.",
		"event": "combat_hit",
		"target": 8,
		"reward_items": {"ammo_9mm": 12, "shells": 3},
		"reward_skill": "combat",
		"reward_xp": 25
	}
}

var mission_state_0536: Dictionary = {}
var mission_events_0536 := 0
var mission_completions_0536 := 0
var last_mission_event_0536 := ""
var last_mission_completed_0536 := ""

func _load_save() -> void:
	super._load_save()
	mission_state_0536.clear()
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	var raw_state: Variant = world_state.get("mission_state_0536", {})
	if raw_state is Dictionary:
		mission_state_0536 = (raw_state as Dictionary).duplicate(true)
	mission_events_0536 = int(world_state.get("mission_events_0536", 0))
	mission_completions_0536 = int(world_state.get("mission_completions_0536", 0))
	last_mission_event_0536 = str(world_state.get("last_mission_event_0536", ""))
	last_mission_completed_0536 = str(world_state.get("last_mission_completed_0536", ""))
	_ensure_missions_0536()

func _ready() -> void:
	super._ready()
	_ensure_missions_0536()

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0536Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _default_mission_state_0536() -> Dictionary:
	return {"progress": 0, "completed": false, "rewarded": false}

func _ensure_missions_0536() -> void:
	for mission_id in MISSION_ORDER_0536:
		if not mission_state_0536.has(mission_id) or not (mission_state_0536[mission_id] is Dictionary):
			mission_state_0536[mission_id] = _default_mission_state_0536()
			continue
		var state: Dictionary = mission_state_0536[mission_id] as Dictionary
		state["progress"] = maxi(0, int(state.get("progress", 0)))
		state["completed"] = bool(state.get("completed", false))
		state["rewarded"] = bool(state.get("rewarded", false))
		mission_state_0536[mission_id] = state

func report_mission_event_0536(event_id: String, amount: int = 1, source: String = "", target_player: Node = null) -> bool:
	if event_id == "" or amount <= 0:
		return false
	_ensure_missions_0536()
	var changed := false
	for mission_id in MISSION_ORDER_0536:
		var definition: Dictionary = MISSION_DEFS_0536[mission_id] as Dictionary
		if str(definition.get("event", "")) != event_id:
			continue
		var state: Dictionary = mission_state_0536[mission_id] as Dictionary
		if bool(state.get("completed", false)):
			continue
		var target := maxi(1, int(definition.get("target", 1)))
		var progress := mini(target, int(state.get("progress", 0)) + amount)
		state["progress"] = progress
		mission_state_0536[mission_id] = state
		changed = true
		if progress >= target:
			_complete_mission_0536(mission_id, target_player)
	if changed:
		mission_events_0536 += amount
		last_mission_event_0536 = "%s:%s" % [event_id, source]
		save_game()
	return changed

func _complete_mission_0536(mission_id: String, target_player: Node) -> void:
	if mission_id not in MISSION_DEFS_0536 or not mission_state_0536.has(mission_id):
		return
	var state: Dictionary = mission_state_0536[mission_id] as Dictionary
	if bool(state.get("completed", false)):
		return
	state["completed"] = true
	mission_state_0536[mission_id] = state
	mission_completions_0536 += 1
	last_mission_completed_0536 = mission_id
	_grant_mission_reward_0536(mission_id, target_player)

func _grant_mission_reward_0536(mission_id: String, target_player: Node) -> void:
	if target_player == null or mission_id not in MISSION_DEFS_0536:
		return
	var state: Dictionary = mission_state_0536[mission_id] as Dictionary
	if bool(state.get("rewarded", false)):
		return
	var definition: Dictionary = MISSION_DEFS_0536[mission_id] as Dictionary
	var reward_items: Dictionary = definition.get("reward_items", {}) as Dictionary
	for raw_id: Variant in reward_items.keys():
		var item_id := str(raw_id)
		var amount := int(reward_items[raw_id])
		if amount > 0 and target_player.has_method("add_item"):
			target_player.call("add_item", item_id, amount)
	var reward_skill := str(definition.get("reward_skill", ""))
	var reward_xp := int(definition.get("reward_xp", 0))
	if reward_skill != "" and reward_xp > 0 and target_player.has_method("award_skill_xp_0535"):
		target_player.call("award_skill_xp_0535", reward_skill, reward_xp, "mission_reward")
	state["rewarded"] = true
	mission_state_0536[mission_id] = state

func get_mission_snapshot_0536() -> Dictionary:
	_ensure_missions_0536()
	var missions: Array[Dictionary] = []
	var completed := 0
	for mission_id in MISSION_ORDER_0536:
		var definition: Dictionary = (MISSION_DEFS_0536[mission_id] as Dictionary).duplicate(true)
		var state: Dictionary = (mission_state_0536[mission_id] as Dictionary).duplicate(true)
		definition["id"] = mission_id
		definition["progress"] = int(state.get("progress", 0))
		definition["completed"] = bool(state.get("completed", false))
		definition["rewarded"] = bool(state.get("rewarded", false))
		if bool(state.get("completed", false)):
			completed += 1
		missions.append(definition)
	return {
		"missions": missions,
		"completed": completed,
		"total": MISSION_ORDER_0536.size(),
		"events": mission_events_0536,
		"last_event": last_mission_event_0536,
		"last_completed": last_mission_completed_0536
	}

func get_active_mission_summary_0536() -> String:
	var snapshot: Dictionary = get_mission_snapshot_0536()
	for raw: Variant in snapshot.get("missions", []):
		if not (raw is Dictionary):
			continue
		var mission: Dictionary = raw as Dictionary
		if bool(mission.get("completed", false)):
			continue
		return "%s %d/%d" % [str(mission.get("title", "OBJETIVO")), int(mission.get("progress", 0)), int(mission.get("target", 1))]
	return "TODOS OS OBJETIVOS CONCLUÍDOS"

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload: Dictionary = parsed as Dictionary
	payload["version"] = SAVE_VERSION_0536
	var world_state: Dictionary = payload.get("world", {}) as Dictionary
	world_state["mission_state_0536"] = mission_state_0536.duplicate(true)
	world_state["mission_events_0536"] = mission_events_0536
	world_state["mission_completions_0536"] = mission_completions_0536
	world_state["last_mission_event_0536"] = last_mission_event_0536
	world_state["last_mission_completed_0536"] = last_mission_completed_0536
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	mission_state_0536.clear()
	mission_events_0536 = 0
	mission_completions_0536 = 0
	last_mission_event_0536 = ""
	last_mission_completed_0536 = ""
	_ensure_missions_0536()
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result: Dictionary = super.get_world_summary()
	var snapshot: Dictionary = get_mission_snapshot_0536()
	result["missions_completed_0536"] = int(snapshot.get("completed", 0))
	result["missions_total_0536"] = int(snapshot.get("total", 0))
	result["mission_active_0536"] = get_active_mission_summary_0536()
	return result

func get_mission_debug_0536() -> Dictionary:
	var snapshot: Dictionary = get_mission_snapshot_0536()
	snapshot["player_0536"] = player != null and player.get_script() == PlayerV0536Script
	snapshot["save_version"] = SAVE_VERSION_0536
	return snapshot
