extends "res://scripts/world/world_runtime_3d_v0537_final.gd"

const PlayerV0538Script = preload("res://scripts/player/player_3d_v0538.gd")
const AnimalV0538Script = preload("res://scripts/entities/animal_3d_v0538.gd")
const SAVE_VERSION_0538 := "0.5.38-alpha"
const ANIMAL_SPECIES_ORDER_0538 := ["rabbit", "deer", "boar", "chicken"]
const ANIMAL_COUNTS_0538 := {
	"rabbit": 6,
	"deer": 4,
	"boar": 4,
	"chicken": 4
}
const ANIMAL_YIELDS_0538 := {
	"rabbit": {"raw_game_meat": 2, "animal_hide": 1},
	"deer": {"raw_game_meat": 6, "animal_hide": 3},
	"boar": {"raw_game_meat": 5, "animal_hide": 2},
	"chicken": {"raw_game_meat": 2, "feathers": 3}
}

var animal_records_0538: Dictionary = {}
var animal_kills_0538 := 0
var animal_butchers_0538 := 0
var animal_noise_flees_0538 := 0
var animal_spawn_count_0538 := 0
var last_animal_event_0538 := ""

func _load_save() -> void:
	super._load_save()
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	var raw_records: Variant = world_state.get("animal_records_0538", {})
	animal_records_0538 = (raw_records as Dictionary).duplicate(true) if raw_records is Dictionary else {}
	animal_kills_0538 = int(world_state.get("animal_kills_0538", 0))
	animal_butchers_0538 = int(world_state.get("animal_butchers_0538", 0))
	animal_noise_flees_0538 = int(world_state.get("animal_noise_flees_0538", 0))
	last_animal_event_0538 = str(world_state.get("last_animal_event_0538", ""))

func _ready() -> void:
	super._ready()
	_ensure_animal_records_0538()
	_spawn_animals_0538()

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0538Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _ensure_animal_records_0538() -> void:
	for species in ANIMAL_SPECIES_ORDER_0538:
		var count := int(ANIMAL_COUNTS_0538.get(species, 0))
		for index in range(count):
			var id := "%s_%02d" % [species, index]
			if animal_records_0538.has(id) and animal_records_0538[id] is Dictionary:
				var existing: Dictionary = animal_records_0538[id] as Dictionary
				existing["id"] = id
				existing["species"] = species
				if not existing.has("position") or not (existing["position"] is Dictionary):
					existing["position"] = _vec_to_dict_0538(_initial_animal_point_0538(species, index))
				if not existing.has("home") or not (existing["home"] is Dictionary):
					existing["home"] = (existing["position"] as Dictionary).duplicate(true)
				if not existing.has("health"):
					existing["health"] = _species_health_0538(species)
				if not existing.has("dead"):
					existing["dead"] = false
				if not existing.has("harvested"):
					existing["harvested"] = false
				animal_records_0538[id] = existing
				continue
			var pos := _initial_animal_point_0538(species, index)
			animal_records_0538[id] = {
				"id": id,
				"species": species,
				"position": _vec_to_dict_0538(pos),
				"home": _vec_to_dict_0538(pos),
				"health": _species_health_0538(species),
				"dead": false,
				"harvested": false,
				"state": "wander",
				"last_noise": ""
			}

func _species_health_0538(species: String) -> float:
	match species:
		"deer": return 42.0
		"boar": return 68.0
		"chicken": return 14.0
		_: return 18.0

func _initial_animal_point_0538(species: String, index: int) -> Vector3:
	var species_index := ANIMAL_SPECIES_ORDER_0538.find(species)
	var marker := int(abs(hash("wildlife0538:%d:%s:%d" % [world_seed, species, index])))
	var angle := float(marker % 6283) / 1000.0
	var radius := 22.0 + float(int(marker / 19) % 37)
	var ring_offset := float(species_index) * 2.4
	return Vector3(cos(angle) * (radius + ring_offset), 0.34, sin(angle) * (radius + ring_offset))

func _spawn_animals_0538() -> void:
	if actors_root == null or not is_instance_valid(actors_root):
		return
	_ensure_animal_records_0538()
	animal_spawn_count_0538 = 0
	for raw_id: Variant in animal_records_0538.keys():
		var id := str(raw_id)
		var state: Dictionary = animal_records_0538[id] as Dictionary
		if bool(state.get("harvested", false)):
			continue
		var animal: CharacterBody3D = AnimalV0538Script.new()
		animal.name = "Animal_%s" % id
		var species := str(state.get("species", "rabbit"))
		animal.call("configure_animal_0538", id, species, state, self)
		animal.position = _dict_to_vec_0538(state.get("position", {}) as Dictionary)
		actors_root.add_child(animal)
		animal_spawn_count_0538 += 1

func get_huntable_animals_0538() -> Array[Node]:
	return get_tree().get_nodes_in_group("animal_0538")

func register_animal_kill_0538(animal_id: String, species: String, pos: Vector3) -> void:
	_ensure_animal_records_0538()
	if not animal_records_0538.has(animal_id):
		return
	var record: Dictionary = animal_records_0538[animal_id] as Dictionary
	if bool(record.get("dead", false)):
		return
	record["species"] = species
	record["position"] = _vec_to_dict_0538(pos)
	record["health"] = 0.0
	record["dead"] = true
	record["state"] = "carcass"
	animal_records_0538[animal_id] = record
	animal_kills_0538 += 1
	last_animal_event_0538 = "kill:%s:%s" % [species, animal_id]
	if player != null and player.has_method("award_skill_xp_0535"):
		player.call("award_skill_xp_0535", "combat", 8, "animal_kill")
	save_game()

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var nearest: Node3D = null
	var best := 3.2
	for raw: Node in get_tree().get_nodes_in_group("animal_0538"):
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		var animal := raw as Node3D
		if not bool(animal.get("dead_0538")) or bool(animal.get("harvested_0538")):
			continue
		var distance := pos.distance_to(animal.global_position)
		if distance < best:
			best = distance
			nearest = animal
	if nearest != null:
		return butcher_animal_0538(str(nearest.get("animal_id_0538")), target_player)
	return super.try_interact_near(pos, target_player)

func butcher_animal_0538(animal_id: String, target_player: Node = null) -> bool:
	_ensure_animal_records_0538()
	if not animal_records_0538.has(animal_id):
		return false
	var record: Dictionary = animal_records_0538[animal_id] as Dictionary
	if not bool(record.get("dead", false)) or bool(record.get("harvested", false)):
		return false
	var species := str(record.get("species", "rabbit"))
	var yields: Dictionary = ANIMAL_YIELDS_0538.get(species, {}) as Dictionary
	var receiver := target_player if target_player != null else player
	if receiver == null:
		return false
	for raw_item: Variant in yields.keys():
		var item_id := str(raw_item)
		var amount := int(yields[raw_item])
		if amount <= 0:
			continue
		if receiver.has_method("receive_hunting_item_0538"):
			receiver.call("receive_hunting_item_0538", item_id, amount, 100.0)
		elif receiver.has_method("add_item"):
			receiver.call("add_item", item_id, amount)
	record["harvested"] = true
	record["state"] = "harvested"
	animal_records_0538[animal_id] = record
	animal_butchers_0538 += 1
	last_animal_event_0538 = "butcher:%s:%s" % [species, animal_id]
	if receiver.has_method("award_skill_xp_0535"):
		receiver.call("award_skill_xp_0535", "scavenging", 12, "butcher_animal")
	for raw: Node in get_tree().get_nodes_in_group("animal_0538"):
		if str(raw.get("animal_id_0538")) != animal_id:
			continue
		if raw.has_method("mark_harvested_0538"):
			raw.call("mark_harvested_0538")
		raw.queue_free()
		break
	save_game()
	return true

func emit_noise_0519(pos: Vector3, radius: float, kind: String, source: Node = null) -> void:
	super.emit_noise_0519(pos, radius, kind, source)
	var fled := 0
	for raw: Node in get_tree().get_nodes_in_group("animal_0538"):
		if source != null and raw == source:
			continue
		if not (raw is Node3D) or not is_instance_valid(raw):
			continue
		var animal := raw as Node3D
		if animal.has_method("hear_noise_0538") and bool(animal.call("hear_noise_0538", pos, radius, kind)):
			fled += 1
	if fled > 0:
		animal_noise_flees_0538 += fled
		last_animal_event_0538 = "noise:%s:%d" % [kind, fled]

func _sync_animal_records_0538() -> void:
	for raw: Node in get_tree().get_nodes_in_group("animal_0538"):
		if not raw.has_method("export_state_0538"):
			continue
		var state := raw.call("export_state_0538") as Dictionary
		var id := str(state.get("id", ""))
		if id != "":
			animal_records_0538[id] = state.duplicate(true)

func save_game() -> void:
	_sync_animal_records_0538()
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload: Dictionary = parsed as Dictionary
	payload["version"] = SAVE_VERSION_0538
	var world_state: Dictionary = payload.get("world", {}) as Dictionary
	world_state["animal_records_0538"] = animal_records_0538.duplicate(true)
	world_state["animal_kills_0538"] = animal_kills_0538
	world_state["animal_butchers_0538"] = animal_butchers_0538
	world_state["animal_noise_flees_0538"] = animal_noise_flees_0538
	world_state["last_animal_event_0538"] = last_animal_event_0538
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	for raw: Node in get_tree().get_nodes_in_group("animal_0538"):
		if is_instance_valid(raw):
			raw.free()
	animal_records_0538.clear()
	animal_kills_0538 = 0
	animal_butchers_0538 = 0
	animal_noise_flees_0538 = 0
	last_animal_event_0538 = ""
	super.new_seed()
	_ensure_animal_records_0538()
	_spawn_animals_0538()
	save_game()

func get_world_summary() -> Dictionary:
	var result: Dictionary = super.get_world_summary()
	var wildlife := get_animal_ecology_debug_0538()
	result["animals_alive_0538"] = int(wildlife.get("alive", 0))
	result["animal_carcasses_0538"] = int(wildlife.get("carcasses", 0))
	result["animal_species_0538"] = int(wildlife.get("species_count", 0))
	return result

func get_mission_debug_0536() -> Dictionary:
	var result: Dictionary = super.get_mission_debug_0536()
	result["player_0536"] = player != null and player.has_method("get_mission_bridge_debug_0536")
	result["player_0538"] = player != null and player.has_method("get_hunting_player_debug_0538")
	return result

func get_animal_record_0538(animal_id: String) -> Dictionary:
	_sync_animal_records_0538()
	if not animal_records_0538.has(animal_id):
		return {}
	return (animal_records_0538[animal_id] as Dictionary).duplicate(true)

func damage_animal_debug_0538(animal_id: String, amount: float) -> bool:
	for raw: Node in get_tree().get_nodes_in_group("animal_0538"):
		if str(raw.get("animal_id_0538")) == animal_id and raw.has_method("take_damage"):
			return bool(raw.call("take_damage", amount))
	return false

func get_animal_ecology_debug_0538() -> Dictionary:
	_sync_animal_records_0538()
	var alive := 0
	var carcasses := 0
	var harvested := 0
	var fleeing := 0
	var species_counts: Dictionary = {}
	for raw_id: Variant in animal_records_0538.keys():
		var state: Dictionary = animal_records_0538[raw_id] as Dictionary
		var species := str(state.get("species", "rabbit"))
		species_counts[species] = int(species_counts.get(species, 0)) + 1
		if bool(state.get("harvested", false)):
			harvested += 1
		elif bool(state.get("dead", false)):
			carcasses += 1
		else:
			alive += 1
	for raw: Node in get_tree().get_nodes_in_group("animal_0538"):
		if str(raw.get("state_0538")) == "flee":
			fleeing += 1
	return {
		"records": animal_records_0538.size(),
		"spawned": get_tree().get_nodes_in_group("animal_0538").size(),
		"alive": alive,
		"carcasses": carcasses,
		"harvested": harvested,
		"species": species_counts,
		"species_count": species_counts.size(),
		"fleeing": fleeing,
		"kills": animal_kills_0538,
		"butchered": animal_butchers_0538,
		"noise_flees": animal_noise_flees_0538,
		"last_event": last_animal_event_0538,
		"save_version": SAVE_VERSION_0538,
		"player_0538": player != null and player.has_method("get_hunting_player_debug_0538")
	}

func _vec_to_dict_0538(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0538(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.34)), float(value.get("z", 0.0)))
