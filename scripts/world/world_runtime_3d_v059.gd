extends "res://scripts/world/world_runtime_3d_v058.gd"

const PlayerV059Script = preload("res://scripts/player/player_3d_v059.gd")
const ZombieV059Script = preload("res://scripts/entities/zombie_3d_v059.gd")

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV059Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))

func _spawn_zombies(count: int) -> void:
	for i in range(count):
		var zombie: CharacterBody3D = ZombieV059Script.new()
		zombie.name = "Zombie_%02d" % i
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(18.0, 52.0)
		zombie.position = Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
		actors_root.add_child(zombie)
