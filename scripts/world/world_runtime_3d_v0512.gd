extends "res://scripts/world/world_runtime_3d_v0511.gd"

func register_streamed_interaction(pos: Vector3, kind: String, key: String, node: Node3D = null, persistent: bool = true) -> void:
	if kind.begins_with("loot_") and harvested_keys.has(key):
		return
	for i in range(interactables.size()):
		var existing := interactables[i] as Dictionary
		if str(existing.get("key", "")) == key:
			existing["position"] = pos
			existing["type"] = kind
			existing["node"] = node
			existing["persistent"] = persistent
			interactables[i] = existing
			return
	interactables.append({"position": pos, "type": kind, "key": key, "node": node, "persistent": persistent})

func unregister_streamed_key(key: String) -> void:
	for i in range(interactables.size() - 1, -1, -1):
		var data := interactables[i] as Dictionary
		if str(data.get("key", "")) == key:
			interactables.remove_at(i)

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var nearest := -1
	var best := 3.25
	for i in range(interactables.size()):
		var data := interactables[i] as Dictionary
		var node_value: Variant = data.get("node")
		if node_value is Node3D and not is_instance_valid(node_value as Node3D):
			continue
		var d := pos.distance_to(data.get("position", Vector3.ZERO) as Vector3)
		if d < best:
			best = d
			nearest = i
	if nearest < 0:
		return false

	var data := interactables[nearest] as Dictionary
	var kind := str(data.get("type", ""))
	var key := str(data.get("key", ""))
	var node_value: Variant = data.get("node")

	if kind == "door" or kind == "window":
		if node_value is Node3D and is_instance_valid(node_value as Node3D) and (node_value as Node3D).has_method("toggle_interaction"):
			(node_value as Node3D).call("toggle_interaction")
			return true
		return false

	if kind.begins_with("loot_"):
		var marker := int(abs(hash("roomloot0512:%s:%d" % [key, world_seed])))
		match kind:
			"loot_kitchen":
				target_player.call("add_item", "food", 1 + marker % 3)
				if marker % 4 != 1:
					target_player.call("add_item", "water", 1 + int(marker / 5) % 2)
			"loot_bedroom":
				target_player.call("add_item", "fiber", 1 + marker % 3)
				if marker % 3 == 0:
					target_player.call("add_item", "bandage", 1)
			"loot_bathroom":
				target_player.call("add_item", "bandage", 1 + marker % 2)
				if marker % 4 == 0:
					target_player.call("add_item", "water", 1)
			"loot_living":
				target_player.call("add_item", "fiber", 1)
				if marker % 2 == 0:
					target_player.call("add_item", "food", 1)
			_:
				target_player.call("add_item", "water", 1)
		harvested_keys.append(key)
		interactables.remove_at(nearest)
		save_game()
		return true

	return super.try_interact_near(pos, target_player)

func get_interaction_debug_0512() -> Dictionary:
	var doors := 0
	var windows := 0
	var room_loot := 0
	for raw in interactables:
		var data := raw as Dictionary
		var kind := str(data.get("type", ""))
		if kind == "door": doors += 1
		elif kind == "window": windows += 1
		elif kind.begins_with("loot_"): room_loot += 1
	return {"doors": doors, "windows": windows, "room_loot": room_loot}
