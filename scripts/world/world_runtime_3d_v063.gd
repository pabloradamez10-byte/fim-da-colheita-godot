extends "res://scripts/world/world_runtime_3d_v062.gd"

const BUILDING_VERSION_063 := "0.6.3-alpha"
const STAIR_INTERACTION_RANGE_063 := 2.25
const FLOOR_INTERACTION_HEIGHT_063 := 1.45
const EXTRA_LOCATION_ROLES_063 := ["bar", "dairy", "pharmacy", "gas_station"]

var specialized_loot_found_063 := {
	"bar": 0,
	"dairy": 0,
	"pharmacy": 0,
	"gas_station": 0
}

func _load_save() -> void:
	super._load_save()
	var world_state: Dictionary = save_cache.get("world", {}) as Dictionary
	var raw: Variant = world_state.get("specialized_loot_found_063", {})
	if raw is Dictionary:
		for role in EXTRA_LOCATION_ROLES_063:
			specialized_loot_found_063[role] = int((raw as Dictionary).get(role, 0))

func unregister_interactions_for_root_063(building_root: Node3D) -> void:
	if building_root == null:
		return
	for i in range(interactables.size() - 1, -1, -1):
		var data := interactables[i] as Dictionary
		var node_value: Variant = data.get("node")
		if node_value is Node and (node_value == building_root or building_root.is_ancestor_of(node_value as Node)):
			interactables.remove_at(i)

func _grant_contextual_loot_0514(kind: String, key: String, source: Node3D, target_player: Node) -> void:
	if not kind.begins_with("loot_poi_"):
		super._grant_contextual_loot_0514(kind, key, source, target_player)
		return
	var role := kind.trim_prefix("loot_poi_")
	if role not in EXTRA_LOCATION_ROLES_063:
		super._grant_contextual_loot_0514(kind, key, source, target_player)
		return
	if target_player == null or not target_player.has_method("add_item"):
		return
	var marker := int(abs(hash("locationloot063:%s:%s:%d" % [role, key, world_seed])))
	match role:
		"bar":
			target_player.call("add_item", "food", 1 + marker % 2)
			target_player.call("add_item", "water", 1 + int(marker / 3) % 2)
			if marker % 3 == 0:
				target_player.call("add_item", "fiber", 1)
		"dairy":
			target_player.call("add_item", "food", 2 + marker % 3)
			target_player.call("add_item", "water", 1 + int(marker / 5) % 2)
		"pharmacy":
			target_player.call("add_item", "bandage", 2 + marker % 3)
			target_player.call("add_item", "antiseptic", 1 + int(marker / 7) % 2)
		"gas_station":
			target_player.call("add_item", "gasoline", 2 + marker % 5)
			if marker % 2 == 0:
				target_player.call("add_item", "food", 1)
			if marker % 3 == 0:
				target_player.call("add_item", "water", 1)
	specialized_loot_found_063[role] = int(specialized_loot_found_063.get(role, 0)) + 1
	if target_player.has_method("award_skill_xp_0535"):
		target_player.call("award_skill_xp_0535", "scavenging", 8, kind)

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	var world_state: Dictionary = payload.get("world", {}) as Dictionary
	world_state["specialized_loot_found_063"] = specialized_loot_found_063.duplicate(true)
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	for role in EXTRA_LOCATION_ROLES_063:
		specialized_loot_found_063[role] = 0
	super.new_seed()

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var stair_index := _nearest_stair_interaction_063(pos)
	if stair_index >= 0:
		var data := interactables[stair_index] as Dictionary
		var node_value: Variant = data.get("node")
		if node_value is Node3D and is_instance_valid(node_value as Node3D) and target_player is Node3D:
			var target: Variant = (node_value as Node3D).get_meta("stair_target_063", null)
			if target is Vector3:
				(target_player as Node3D).global_position = target as Vector3
				_refresh_stair_cutaway_063(node_value as Node3D, target_player as Node3D)
				save_game()
				return true
	return super.try_interact_near(pos, target_player)

func _refresh_stair_cutaway_063(stair_node: Node3D, target_player: Node3D) -> void:
	var cursor: Node = stair_node
	while cursor != null:
		if cursor.has_method("refresh_cutaway_063"):
			cursor.call("refresh_cutaway_063", target_player)
			return
		cursor = cursor.get_parent()

func _nearest_stair_interaction_063(pos: Vector3) -> int:
	var nearest := -1
	var best := STAIR_INTERACTION_RANGE_063
	for i in range(interactables.size()):
		var data := interactables[i] as Dictionary
		var kind := str(data.get("type", ""))
		if kind not in ["stairs_up_063", "stairs_down_063"]:
			continue
		var node_value: Variant = data.get("node")
		if node_value is Node3D and not is_instance_valid(node_value as Node3D):
			continue
		var distance := pos.distance_to(data.get("position", Vector3.ZERO) as Vector3)
		if distance < best:
			best = distance
			nearest = i
	return nearest

func _pick_special_interactable_0513(pos: Vector3, target_player: Node) -> int:
	# Mantém a prioridade histórica, mas impede abrir móveis através do piso/teto.
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
			if absf(delta.y) > FLOOR_INTERACTION_HEIGHT_063:
				continue
			delta.y = 0.0
			var distance := delta.length()
			if distance > max_range:
				continue
			if facing.length() > 0.01 and distance > 0.72 and delta.length() > 0.01:
				if facing.dot(delta.normalized()) < -0.05:
					continue
			if distance < best_distance:
				best_distance = distance
				best_index = i
		if best_index >= 0:
			return best_index
	return -1

func get_building_asset_debug_063() -> Dictionary:
	var streamer := get_node_or_null("ChunkStreamer")
	if streamer != null and streamer.has_method("get_building_asset_debug_063"):
		return streamer.call("get_building_asset_debug_063") as Dictionary
	return {"version": BUILDING_VERSION_063, "assets": 0, "full_exteriors": 0, "roles": {}, "two_story_houses": 0, "staircases": 0, "upper_loot": 0, "dedicated_establishments": {}, "establishment_loot": 0}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["building_assets_063"] = get_building_asset_debug_063()
	result["specialized_loot_found_063"] = specialized_loot_found_063.duplicate(true)
	return result
