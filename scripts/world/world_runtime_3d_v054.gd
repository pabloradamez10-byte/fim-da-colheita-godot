extends "res://scripts/world/world_runtime_3d.gd"

const PlayerV054Script = preload("res://scripts/player/player_3d_v054.gd")

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV054Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.75, 3.5))

func _register_interactable(pos: Vector3, kind: String, key: String, node: Node3D = null) -> void:
	if harvested_keys.has(key):
		return
	for i in range(interactables.size()):
		var existing := interactables[i] as Dictionary
		if str(existing.get("key", "")) == key:
			existing["position"] = pos
			existing["type"] = kind
			existing["node"] = node
			interactables[i] = existing
			return
	interactables.append({"position": pos, "type": kind, "key": key, "node": node})

func register_streamed_loot(pos: Vector3, kind: String, key: String, node: Node3D = null) -> void:
	_register_interactable(pos, kind, key, node)

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var nearest := -1
	var best := 3.2
	for i in range(interactables.size()):
		var data := interactables[i] as Dictionary
		var d := pos.distance_to(data.get("position", Vector3.ZERO) as Vector3)
		if d < best:
			best = d
			nearest = i
	if nearest < 0:
		return false
	var data := interactables[nearest] as Dictionary
	var kind := str(data.get("type", ""))
	var key := str(data.get("key", ""))
	var marker := abs(hash("loot:%s:%d" % [key, world_seed]))
	match kind:
		"tree":
			target_player.call("add_item", "wood", 3)
		"rock":
			target_player.call("add_item", "stone", 2)
		"bush":
			target_player.call("add_item", "fiber", 2)
		"farmhouse_supply":
			target_player.call("unlock_weapon", "pistol")
			target_player.call("add_item", "ammo_9mm", 18)
			target_player.call("add_item", "food", 2)
		"barn_supply":
			target_player.call("unlock_weapon", "shotgun")
			target_player.call("add_item", "shells", 8)
			target_player.call("add_item", "wood", 4)
		"city_home", "rural_home":
			target_player.call("add_item", "food", 1 + marker % 3)
			target_player.call("add_item", "water", 1 + int(marker / 3) % 2)
			target_player.call("add_item", "fiber", 1 + int(marker / 7) % 2)
			if marker % 4 == 0:
				target_player.call("add_item", "bandage", 1)
		"city_garage", "rural_garage":
			target_player.call("add_item", "wood", 2 + marker % 4)
			target_player.call("add_item", "stone", 1 + int(marker / 5) % 3)
			if marker % 5 == 0:
				target_player.call("add_item", "ammo_9mm", 5 + marker % 7)
			if marker % 13 == 0:
				target_player.call("unlock_weapon", "pistol")
		"city_market":
			target_player.call("add_item", "food", 3 + marker % 3)
			target_player.call("add_item", "water", 2 + int(marker / 3) % 3)
			if marker % 2 == 0:
				target_player.call("add_item", "bandage", 1)
		"city_armory":
			target_player.call("unlock_weapon", "pistol")
			target_player.call("add_item", "ammo_9mm", 12 + marker % 10)
			if marker % 3 == 0:
				target_player.call("unlock_weapon", "shotgun")
				target_player.call("add_item", "shells", 4 + marker % 5)
		_:
			target_player.call("add_item", "water", 1)
	var node_value: Variant = data.get("node")
	if node_value is Node3D and is_instance_valid(node_value as Node3D):
		(node_value as Node3D).queue_free()
	harvested_keys.append(key)
	interactables.remove_at(nearest)
	save_game()
	return true

func get_world_summary() -> Dictionary:
	var summary: Dictionary = super.get_world_summary()
	var streamer := get_tree().get_first_node_in_group("chunk_streamer")
	if streamer != null and streamer.has_method("get_city_debug_metrics"):
		var metrics := streamer.call("get_city_debug_metrics") as Dictionary
		summary["chunks"] = int(metrics.get("chunks", 0))
		summary["city_buildings"] = int(metrics.get("city_buildings", 0))
		summary["rural_buildings"] = int(metrics.get("rural_buildings", 0))
		summary["city_distance"] = int(metrics.get("city_distance", -1))
	return summary
