extends "res://scripts/world/world_runtime_3d_v0538.gd"

const SurvivorNPCV0539Script = preload("res://scripts/entities/survivor_npc_3d_v0539.gd")
const SAVE_VERSION_0539 := "0.5.39-alpha"
const SURVIVOR_DEFS_0539 := {
	"helena": {"name": "Helena", "role": "medic", "anchor": Vector3(-20.0, 0.20, 15.0)},
	"davi": {"name": "Davi", "role": "mechanic", "anchor": Vector3(23.0, 0.20, 10.0)},
	"mauro": {"name": "Mauro", "role": "scavenger", "anchor": Vector3(7.0, 0.20, -27.0)}
}

var survivor_records_0539: Dictionary = {}
var survivor_interactions_0539 := 0
var survivor_assists_0539 := 0
var survivor_gifts_0539 := 0
var survivor_noise_flees_0539 := 0
var survivor_deaths_0539 := 0
var last_survivor_event_0539 := ""

func _load_save() -> void:
	super._load_save()
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	var raw_records: Variant = world_state.get("survivor_records_0539", {})
	survivor_records_0539 = (raw_records as Dictionary).duplicate(true) if raw_records is Dictionary else {}
	survivor_interactions_0539 = int(world_state.get("survivor_interactions_0539", 0))
	survivor_assists_0539 = int(world_state.get("survivor_assists_0539", 0))
	survivor_gifts_0539 = int(world_state.get("survivor_gifts_0539", 0))
	survivor_noise_flees_0539 = int(world_state.get("survivor_noise_flees_0539", 0))
	survivor_deaths_0539 = int(world_state.get("survivor_deaths_0539", 0))
	last_survivor_event_0539 = str(world_state.get("last_survivor_event_0539", ""))

func _ready() -> void:
	super._ready()
	_ensure_survivor_records_0539()
	_spawn_survivors_0539()

func _ensure_survivor_records_0539() -> void:
	for raw_id: Variant in SURVIVOR_DEFS_0539.keys():
		var id := str(raw_id)
		var definition := SURVIVOR_DEFS_0539[id] as Dictionary
		if survivor_records_0539.has(id) and survivor_records_0539[id] is Dictionary:
			var existing := survivor_records_0539[id] as Dictionary
			existing["id"] = id
			existing["name"] = str(definition.get("name", id))
			existing["role"] = str(definition.get("role", "scavenger"))
			if not existing.has("position") or not (existing["position"] is Dictionary):
				existing["position"] = _vec_to_dict_0539(_initial_survivor_point_0539(id))
			if not existing.has("home") or not (existing["home"] is Dictionary):
				existing["home"] = (existing["position"] as Dictionary).duplicate(true)
			if not existing.has("health"): existing["health"] = 100.0
			if not existing.has("hunger"): existing["hunger"] = 82.0
			if not existing.has("thirst"): existing["thirst"] = 82.0
			if not existing.has("trust"): existing["trust"] = 0
			if not existing.has("met_player"): existing["met_player"] = false
			if not existing.has("gift_shared"): existing["gift_shared"] = false
			if not existing.has("dead"): existing["dead"] = false
			if not existing.has("state"): existing["state"] = "wander"
			survivor_records_0539[id] = existing
			continue
		var pos := _initial_survivor_point_0539(id)
		survivor_records_0539[id] = {
			"id": id,
			"name": str(definition.get("name", id)),
			"role": str(definition.get("role", "scavenger")),
			"position": _vec_to_dict_0539(pos),
			"home": _vec_to_dict_0539(pos),
			"health": 100.0,
			"hunger": 82.0,
			"thirst": 82.0,
			"trust": 0,
			"met_player": false,
			"gift_shared": false,
			"dead": false,
			"state": "wander",
			"last_noise": "",
			"last_interaction": ""
		}

func _initial_survivor_point_0539(id: String) -> Vector3:
	var definition := SURVIVOR_DEFS_0539.get(id, {}) as Dictionary
	var anchor: Vector3 = definition.get("anchor", Vector3.ZERO) as Vector3
	var marker := int(abs(hash("survivor0539:%d:%s" % [world_seed, id])))
	var offset_x := float((marker % 7) - 3) * 0.55
	var offset_z := float((int(marker / 17) % 7) - 3) * 0.55
	return Vector3(anchor.x + offset_x, 0.20, anchor.z + offset_z)

func _spawn_survivors_0539() -> void:
	if actors_root == null or not is_instance_valid(actors_root):
		return
	_ensure_survivor_records_0539()
	for raw_id: Variant in survivor_records_0539.keys():
		var id := str(raw_id)
		var state := survivor_records_0539[id] as Dictionary
		var npc: CharacterBody3D = SurvivorNPCV0539Script.new()
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

func get_survivors_0539() -> Array[Node]:
	return get_tree().get_nodes_in_group("survivor_0539")

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var nearest: Node3D = null
	var best := 3.25
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		if bool(raw.get("dead_0539")):
			continue
		var npc := raw as Node3D
		var distance := pos.distance_to(npc.global_position)
		if distance < best:
			best = distance
			nearest = npc
	if nearest != null:
		return _interact_survivor_0539(nearest, target_player)
	return super.try_interact_near(pos, target_player)

func _interact_survivor_0539(npc: Node3D, target_player: Node) -> bool:
	if npc == null or target_player == null or bool(npc.get("dead_0539")):
		return false
	var id := str(npc.get("survivor_id_0539"))
	if id == "":
		return false
	survivor_interactions_0539 += 1
	var first_contact := false
	if npc.has_method("mark_met_0539"):
		first_contact = bool(npc.call("mark_met_0539"))
	if first_contact:
		last_survivor_event_0539 = "first_contact:%s" % id
		_sync_survivor_records_0539()
		save_game()
		return true

	var helped := ""
	var thirst := float(npc.get("thirst_0539"))
	var hunger := float(npc.get("hunger_0539"))
	var health := float(npc.get("health_0539"))
	if thirst < 65.0 and _consume_player_item_0539(target_player, "water", 1):
		helped = "water"
	elif hunger < 65.0 and _consume_player_item_0539(target_player, "food", 1):
		helped = "food"
	elif health < 72.0 and _consume_player_item_0539(target_player, "bandage", 1):
		helped = "bandage"
	if helped != "":
		npc.call("receive_aid_0539", helped)
		survivor_assists_0539 += 1
		last_survivor_event_0539 = "aid:%s:%s" % [id, helped]
		_sync_survivor_records_0539()
		save_game()
		return true

	var trust := int(npc.get("trust_0539"))
	var gifted := bool(npc.get("gift_shared_0539"))
	if trust >= 20 and not gifted:
		var role_cfg := npc.call("get_role_config_0539") as Dictionary
		var gift_item := str(role_cfg.get("gift_item", "food"))
		var gift_amount := int(role_cfg.get("gift_amount", 1))
		_give_player_item_0539(target_player, gift_item, gift_amount)
		npc.call("mark_gift_shared_0539")
		survivor_gifts_0539 += 1
		last_survivor_event_0539 = "gift:%s:%s:%d" % [id, gift_item, gift_amount]
	else:
		npc.call("add_trust_0539", 2, "conversation")
		last_survivor_event_0539 = "talk:%s" % id
	_sync_survivor_records_0539()
	save_game()
	return true

func _consume_player_item_0539(target_player: Node, item_id: String, amount: int) -> bool:
	if amount <= 0:
		return true
	if target_player.has_method("consume_inventory_item_0530"):
		return bool(target_player.call("consume_inventory_item_0530", item_id, amount))
	if not target_player.has_method("get_inventory_snapshot"):
		return false
	var snapshot := target_player.call("get_inventory_snapshot") as Dictionary
	var current := int(snapshot.get(item_id, 0))
	if current < amount:
		return false
	var inventory_value: Variant = target_player.get("inventory")
	if not (inventory_value is Dictionary):
		return false
	var inventory := (inventory_value as Dictionary).duplicate(true)
	inventory[item_id] = current - amount
	target_player.set("inventory", inventory)
	return true

func _give_player_item_0539(target_player: Node, item_id: String, amount: int) -> void:
	if amount <= 0:
		return
	if target_player.has_method("receive_inventory_item_0530"):
		target_player.call("receive_inventory_item_0530", item_id, amount)
	elif target_player.has_method("add_item"):
		target_player.call("add_item", item_id, amount)

func emit_noise_0519(pos: Vector3, radius: float, kind: String, source: Node = null) -> void:
	super.emit_noise_0519(pos, radius, kind, source)
	var fled := 0
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if source != null and raw == source:
			continue
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		var npc := raw as Node3D
		if npc.has_method("hear_noise_0539") and bool(npc.call("hear_noise_0539", pos, radius, kind)):
			fled += 1
	if fled > 0:
		survivor_noise_flees_0539 += fled
		last_survivor_event_0539 = "noise:%s:%d" % [kind, fled]

func register_survivor_death_0539(survivor_id: String, cause: String, pos: Vector3) -> void:
	_ensure_survivor_records_0539()
	if not survivor_records_0539.has(survivor_id):
		return
	var record := survivor_records_0539[survivor_id] as Dictionary
	if bool(record.get("dead", false)):
		return
	record["dead"] = true
	record["health"] = 0.0
	record["state"] = "dead"
	record["position"] = _vec_to_dict_0539(pos)
	record["last_interaction"] = "dead:%s" % cause
	survivor_records_0539[survivor_id] = record
	survivor_deaths_0539 += 1
	last_survivor_event_0539 = "death:%s:%s" % [survivor_id, cause]
	save_game()

func _sync_survivor_records_0539() -> void:
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if not raw.has_method("export_state_0539"):
			continue
		var state := raw.call("export_state_0539") as Dictionary
		var id := str(state.get("id", ""))
		if id != "":
			survivor_records_0539[id] = state.duplicate(true)

func save_game() -> void:
	_sync_survivor_records_0539()
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_0539
	var world_state := payload.get("world", {}) as Dictionary
	world_state["survivor_records_0539"] = survivor_records_0539.duplicate(true)
	world_state["survivor_interactions_0539"] = survivor_interactions_0539
	world_state["survivor_assists_0539"] = survivor_assists_0539
	world_state["survivor_gifts_0539"] = survivor_gifts_0539
	world_state["survivor_noise_flees_0539"] = survivor_noise_flees_0539
	world_state["survivor_deaths_0539"] = survivor_deaths_0539
	world_state["last_survivor_event_0539"] = last_survivor_event_0539
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if is_instance_valid(raw):
			raw.free()
	survivor_records_0539.clear()
	survivor_interactions_0539 = 0
	survivor_assists_0539 = 0
	survivor_gifts_0539 = 0
	survivor_noise_flees_0539 = 0
	survivor_deaths_0539 = 0
	last_survivor_event_0539 = ""
	super.new_seed()
	_ensure_survivor_records_0539()
	_spawn_survivors_0539()
	save_game()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var society := get_survivor_society_debug_0539()
	result["survivors_alive_0539"] = int(society.get("alive", 0))
	result["survivors_met_0539"] = int(society.get("met", 0))
	return result

func get_survivor_record_0539(survivor_id: String) -> Dictionary:
	_sync_survivor_records_0539()
	if not survivor_records_0539.has(survivor_id):
		return {}
	return (survivor_records_0539[survivor_id] as Dictionary).duplicate(true)

func interact_survivor_debug_0539(survivor_id: String, target_player: Node = null) -> bool:
	var receiver := target_player if target_player != null else player
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if str(raw.get("survivor_id_0539")) == survivor_id and raw is Node3D:
			return _interact_survivor_0539(raw as Node3D, receiver)
	return false

func set_survivor_needs_debug_0539(survivor_id: String, hunger: float, thirst: float, health: float = -1.0) -> bool:
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if str(raw.get("survivor_id_0539")) == survivor_id and raw.has_method("set_needs_debug_0539"):
			raw.call("set_needs_debug_0539", hunger, thirst, health)
			_sync_survivor_records_0539()
			return true
	return false

func set_survivor_trust_debug_0539(survivor_id: String, trust: int) -> bool:
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if str(raw.get("survivor_id_0539")) == survivor_id and raw.has_method("set_trust_debug_0539"):
			raw.call("set_trust_debug_0539", trust)
			_sync_survivor_records_0539()
			return true
	return false

func damage_survivor_debug_0539(survivor_id: String, amount: float) -> bool:
	for raw: Node in get_tree().get_nodes_in_group("survivor_0539"):
		if str(raw.get("survivor_id_0539")) == survivor_id and raw.has_method("take_damage_0539"):
			return bool(raw.call("take_damage_0539", amount, "debug"))
	return false

func get_survivor_society_debug_0539() -> Dictionary:
	_sync_survivor_records_0539()
	var alive := 0
	var dead := 0
	var met := 0
	var gifted := 0
	var trust_total := 0
	var roles: Dictionary = {}
	for raw_id: Variant in survivor_records_0539.keys():
		var state := survivor_records_0539[raw_id] as Dictionary
		var role := str(state.get("role", "scavenger"))
		roles[role] = int(roles.get(role, 0)) + 1
		trust_total += int(state.get("trust", 0))
		if bool(state.get("dead", false)):
			dead += 1
		else:
			alive += 1
		if bool(state.get("met_player", false)):
			met += 1
		if bool(state.get("gift_shared", false)):
			gifted += 1
	return {
		"records": survivor_records_0539.size(),
		"spawned": get_tree().get_nodes_in_group("survivor_0539").size(),
		"alive": alive,
		"dead": dead,
		"met": met,
		"gifted": gifted,
		"roles": roles,
		"role_count": roles.size(),
		"trust_total": trust_total,
		"interactions": survivor_interactions_0539,
		"assists": survivor_assists_0539,
		"gifts": survivor_gifts_0539,
		"noise_flees": survivor_noise_flees_0539,
		"deaths": survivor_deaths_0539,
		"last_event": last_survivor_event_0539,
		"wildlife_0538": has_method("get_animal_ecology_debug_0538"),
		"zombies_0537": has_method("get_zombie_ecology_debug_0537")
	}

func _vec_to_dict_0539(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0539(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.20)), float(value.get("z", 0.0)))
