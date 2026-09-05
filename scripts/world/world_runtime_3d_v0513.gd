extends "res://scripts/world/world_runtime_3d_v0512.gd"

const INTERACT_DOOR_RANGE_0513 := 2.35
const INTERACT_LOOT_RANGE_0513 := 1.95
const INTERACT_WINDOW_RANGE_0513 := 1.20
const WATER_BLOCK_HEIGHT_0513 := 2.40

func _spawn_player() -> void:
	super._spawn_player()
	call_deferred("_recover_player_from_water_0513")

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var special_index := _pick_special_interactable_0513(pos, target_player)
	if special_index < 0:
		return super.try_interact_near(pos, target_player)

	var data := interactables[special_index] as Dictionary
	var kind := str(data.get("type", ""))
	var key := str(data.get("key", ""))
	var node_value: Variant = data.get("node")

	if kind == "door" or kind == "window":
		if node_value is Node3D and is_instance_valid(node_value as Node3D) and (node_value as Node3D).has_method("toggle_interaction"):
			(node_value as Node3D).call("toggle_interaction")
			return true
		return false

	if kind.begins_with("loot_"):
		var marker := int(abs(hash("roomloot0513:%s:%d" % [key, world_seed])))
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
		interactables.remove_at(special_index)
		save_game()
		return true

	return false

func _pick_special_interactable_0513(pos: Vector3, target_player: Node) -> int:
	# Mobile: door > contextual loot > window. Each category has its own short range,
	# so a nearby window no longer steals the action intended for a door.
	var facing := Vector3.ZERO
	var raw_facing: Variant = target_player.get("last_move_dir") if target_player != null else null
	if raw_facing is Vector3:
		facing = raw_facing as Vector3
		facing.y = 0.0
		if facing.length() > 0.01:
			facing = facing.normalized()

	for category in ["door", "loot", "window"]:
		var best_index := -1
		var best_distance := INF
		var max_range := INTERACT_DOOR_RANGE_0513 if category == "door" else (INTERACT_LOOT_RANGE_0513 if category == "loot" else INTERACT_WINDOW_RANGE_0513)
		for i in range(interactables.size()):
			var data := interactables[i] as Dictionary
			var kind := str(data.get("type", ""))
			if category == "door" and kind != "door":
				continue
			if category == "window" and kind != "window":
				continue
			if category == "loot" and not kind.begins_with("loot_"):
				continue
			var node_value: Variant = data.get("node")
			if node_value is Node3D and not is_instance_valid(node_value as Node3D):
				continue
			var target_pos := data.get("position", Vector3.ZERO) as Vector3
			var delta := target_pos - pos
			delta.y = 0.0
			var distance := delta.length()
			if distance > max_range:
				continue
			# Very close objects may be used from any angle. Otherwise they must be roughly in front.
			if facing.length() > 0.01 and distance > 0.72 and delta.length() > 0.01:
				var dot := facing.dot(delta.normalized())
				if dot < -0.05:
					continue
			if distance < best_distance:
				best_distance = distance
				best_index = i
		if best_index >= 0:
			return best_index
	return -1

func _create_terrain_multimesh(id: String, transforms: Array) -> void:
	super._create_terrain_multimesh(id, transforms)
	if id == "water" and not transforms.is_empty():
		_add_water_blockers_0513(generated_root, transforms)

func _add_water_blockers_0513(parent: Node3D, transforms: Array) -> void:
	if parent == null:
		return
	var body := StaticBody3D.new()
	body.name = "WaterBlocker0513"
	body.add_to_group("water_blocker_0513")
	parent.add_child(body)
	for raw in transforms:
		var t := raw as Transform3D
		var shape := BoxShape3D.new()
		shape.size = Vector3(CELL_SIZE * 0.94, WATER_BLOCK_HEIGHT_0513, CELL_SIZE * 0.94)
		var collision := CollisionShape3D.new()
		collision.shape = shape
		collision.position = Vector3(t.origin.x, 0.92, t.origin.z)
		body.add_child(collision)
		collider_count += 1

func is_water_at_0513(world_pos: Vector3) -> bool:
	var gx := roundi(world_pos.x / CELL_SIZE)
	var gz := roundi(world_pos.z / CELL_SIZE)
	var h := height_noise.get_noise_2d(float(gx), float(gz))
	var m := moisture_noise.get_noise_2d(float(gx), float(gz))
	return _terrain_id(gx, gz, h, m) == "water"

func _recover_player_from_water_0513() -> void:
	if player == null or not is_instance_valid(player):
		return
	if not is_water_at_0513(player.global_position):
		return
	var base_gx := roundi(player.global_position.x / CELL_SIZE)
	var base_gz := roundi(player.global_position.z / CELL_SIZE)
	for radius in range(1, 13):
		for dz in range(-radius, radius + 1):
			for dx in range(-radius, radius + 1):
				if abs(dx) != radius and abs(dz) != radius:
					continue
				var candidate := Vector3(float(base_gx + dx) * CELL_SIZE, 0.20, float(base_gz + dz) * CELL_SIZE)
				if not is_water_at_0513(candidate):
					player.global_position = candidate
					save_game()
					return

func get_debug_0513() -> Dictionary:
	return {
		"water_blockers": get_tree().get_nodes_in_group("water_blocker_0513").size(),
		"interaction_priority": ["door", "loot", "window"]
	}
