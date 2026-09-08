extends "res://scripts/world/world_runtime_3d_v0519.gd"

const PlayerV0520Script = preload("res://scripts/player/player_3d_v0520.gd")
const ZombieV0520Script = preload("res://scripts/entities/zombie_3d_v0520.gd")
const SAVE_VERSION_0520 := "0.5.20-alpha"

var dead_zombies_0520: Array[String] = []
var corpse_records_0520: Dictionary = {}
var death_bags_0520: Dictionary = {}
var kills_0520 := 0
var deaths_0520 := 0

func _ready() -> void:
	super._ready()
	_restore_persistent_loot_0520()

func _load_save() -> void:
	super._load_save()
	dead_zombies_0520.clear()
	corpse_records_0520.clear()
	death_bags_0520.clear()
	var world_state := save_cache.get("world", {}) as Dictionary
	for raw_name in world_state.get("dead_zombies_0520", []):
		dead_zombies_0520.append(str(raw_name))
	var raw_corpses: Variant = world_state.get("corpse_records_0520", {})
	if raw_corpses is Dictionary:
		corpse_records_0520 = (raw_corpses as Dictionary).duplicate(true)
	var raw_bags: Variant = world_state.get("death_bags_0520", {})
	if raw_bags is Dictionary:
		death_bags_0520 = (raw_bags as Dictionary).duplicate(true)
	kills_0520 = int(world_state.get("kills_0520", dead_zombies_0520.size()))
	deaths_0520 = int(world_state.get("deaths_0520", 0))

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0520,
		"world": {
			"seed": world_seed,
			"farm_layout": farm_layout,
			"harvested": harvested_keys.duplicate(),
			"dead_zombies_0520": dead_zombies_0520.duplicate(),
			"corpse_records_0520": corpse_records_0520.duplicate(true),
			"death_bags_0520": death_bags_0520.duplicate(true),
			"kills_0520": kills_0520,
			"deaths_0520": deaths_0520
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0520Script.new()
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
		var zombie_name := "Zombie_%02d" % i
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(18.0, 52.0)
		var spawn_pos := Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
		# Sempre consumimos os mesmos números aleatórios antes de pular um morto,
		# preservando a posição determinística dos sobreviventes do mesmo seed.
		if dead_zombies_0520.has(zombie_name):
			continue
		var zombie: CharacterBody3D = ZombieV0520Script.new()
		zombie.name = zombie_name
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func register_zombie_death_0520(zombie_name: String, pos: Vector3, zombie_variant: int) -> void:
	if dead_zombies_0520.has(zombie_name):
		return
	dead_zombies_0520.append(zombie_name)
	kills_0520 += 1
	var key := "zcorpse0520:%s" % zombie_name
	var record := {
		"position": _vec_to_dict_0520(pos),
		"loot": _roll_zombie_loot_0520(zombie_name, zombie_variant),
		"variant": zombie_variant
	}
	corpse_records_0520[key] = record
	_spawn_loot_marker_0520(key, record, "loot_zombie_0520")
	save_game()

func register_player_death_0520(pos: Vector3, dropped: Dictionary) -> String:
	deaths_0520 += 1
	if dropped.is_empty():
		return ""
	var key := "deathbag0520:%d:%d:%d" % [world_seed, int(Time.get_unix_time_from_system()), deaths_0520]
	var record := {
		"position": _vec_to_dict_0520(pos),
		"loot": dropped.duplicate(true)
	}
	death_bags_0520[key] = record
	_spawn_loot_marker_0520(key, record, "loot_deathbag_0520")
	return key

func _roll_zombie_loot_0520(zombie_name: String, zombie_variant: int) -> Dictionary:
	var marker := int(abs(hash("zloot0520:%d:%s:%d" % [world_seed, zombie_name, zombie_variant])))
	var loot: Dictionary = {"fiber": 1 + marker % 2}
	if marker % 3 == 0:
		loot["food"] = 1
	if marker % 5 == 0:
		loot["bandage"] = 1
	if marker % 4 == 0:
		loot["ammo_9mm"] = 2 + int(marker / 7) % 4
	if marker % 11 == 0:
		loot["shells"] = 1
	if marker % 7 == 0:
		loot["antiseptic"] = 1
	return loot

func _grant_contextual_loot_0514(kind: String, key: String, source: Node3D, target_player: Node) -> void:
	if kind == "loot_zombie_0520" or kind == "loot_deathbag_0520":
		var records := corpse_records_0520 if kind == "loot_zombie_0520" else death_bags_0520
		var record := records.get(key, {}) as Dictionary
		var loot := record.get("loot", {}) as Dictionary
		if target_player != null and target_player.has_method("add_item"):
			for raw_id in loot.keys():
				target_player.call("add_item", str(raw_id), int(loot[raw_id]))
		records.erase(key)
		if source != null and is_instance_valid(source):
			source.queue_free()
		return
	super._grant_contextual_loot_0514(kind, key, source, target_player)

func _restore_persistent_loot_0520() -> void:
	for raw_key in corpse_records_0520.keys():
		var key := str(raw_key)
		_spawn_loot_marker_0520(key, corpse_records_0520[key] as Dictionary, "loot_zombie_0520")
	for raw_key in death_bags_0520.keys():
		var key := str(raw_key)
		_spawn_loot_marker_0520(key, death_bags_0520[key] as Dictionary, "loot_deathbag_0520")

func _spawn_loot_marker_0520(key: String, record: Dictionary, kind: String) -> void:
	if actors_root == null or harvested_keys.has(key):
		return
	# Evita duplicar marcador durante restauração ou chamadas repetidas.
	for raw in interactables:
		var data := raw as Dictionary
		if str(data.get("key", "")) == key:
			return
	var pos := _dict_to_vec_0520(record.get("position", {}) as Dictionary)
	var root := Node3D.new()
	root.name = "Corpse0520" if kind == "loot_zombie_0520" else "LostBackpack0520"
	root.global_position = pos
	root.add_to_group("corpse_loot_0520" if kind == "loot_zombie_0520" else "death_bag_0520")
	actors_root.add_child(root)
	if kind == "loot_zombie_0520":
		_box(root, Vector3(1.18, 0.22, 0.54), Vector3(0.0, 0.14, 0.0), materials["cloth"])
		_sphere(root, 0.25, Vector3(0.0, 0.19, -0.58), materials["wetland"], Vector3(0.95, 0.70, 0.95))
		_box(root, Vector3(0.24, 0.12, 0.72), Vector3(-0.48, 0.11, 0.18), materials["wood_dark"])
	else:
		_box(root, Vector3(0.82, 0.56, 0.42), Vector3(0.0, 0.31, 0.0), materials["wood_dark"])
		_box(root, Vector3(0.64, 0.08, 0.46), Vector3(0.0, 0.61, 0.0), materials["highlight"])
	register_streamed_interaction(pos, kind, key, root, true)

func get_respawn_position_0520() -> Vector3:
	return _farm_to_world(Vector3(0, 0.20, 3.5))

func new_seed() -> void:
	dead_zombies_0520.clear()
	corpse_records_0520.clear()
	death_bags_0520.clear()
	kills_0520 = 0
	deaths_0520 = 0
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["kills_0520"] = kills_0520
	result["deaths_0520"] = deaths_0520
	result["corpses_0520"] = corpse_records_0520.size()
	result["death_bags_0520"] = death_bags_0520.size()
	return result

func get_survival_loop_debug_0520() -> Dictionary:
	return {
		"dead_zombies": dead_zombies_0520.size(),
		"corpses": corpse_records_0520.size(),
		"death_bags": death_bags_0520.size(),
		"kills": kills_0520,
		"deaths": deaths_0520,
		"player_0520": player != null and player.get_script() == PlayerV0520Script
	}

func _vec_to_dict_0520(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0520(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.20)), float(value.get("z", 0.0)))
