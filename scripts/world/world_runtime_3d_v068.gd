extends "res://scripts/world/world_runtime_3d_v067.gd"

const PlayerV068Script = preload("res://scripts/player/player_3d_v068.gd")
const ZombieV068Script = preload("res://scripts/entities/zombie_3d_v068.gd")

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV068Script.new()
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
		var zombie: CharacterBody3D = ZombieV068Script.new()
		zombie.name = zombie_name
		zombie.call("configure_horde_0537", horde_id, member_index, (i + horde_id * 2) % ZOMBIE_PROFILE_COUNT_05402)
		zombie.position = spawn_pos
		actors_root.add_child(zombie)
