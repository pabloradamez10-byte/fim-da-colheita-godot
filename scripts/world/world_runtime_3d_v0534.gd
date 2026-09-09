extends "res://scripts/world/world_runtime_3d_v0533.gd"

const SAVE_VERSION_0534 := "0.5.34-alpha"
const LOCATION_ROLES_0534 := ["hospital", "market", "workshop", "police", "farm"]

var specialized_loot_found_0534 := {
	"hospital": 0,
	"market": 0,
	"workshop": 0,
	"police": 0,
	"farm": 0
}
var last_location_loot_0534 := ""

func _load_save() -> void:
	super._load_save()
	var world_state := save_cache.get("world", {}) as Dictionary
	var raw_counts: Variant = world_state.get("specialized_loot_found_0534", {})
	if raw_counts is Dictionary:
		for role in LOCATION_ROLES_0534:
			specialized_loot_found_0534[role] = int((raw_counts as Dictionary).get(role, 0))
	last_location_loot_0534 = str(world_state.get("last_location_loot_0534", ""))

func _grant_contextual_loot_0514(kind: String, key: String, source: Node3D, target_player: Node) -> void:
	if not kind.begins_with("loot_poi_"):
		super._grant_contextual_loot_0514(kind, key, source, target_player)
		return
	var role := kind.trim_prefix("loot_poi_")
	if role not in LOCATION_ROLES_0534:
		super._grant_contextual_loot_0514(kind, key, source, target_player)
		return
	var source_name := source.name if source != null else "none"
	var bundle := _build_location_loot_bundle_0534(role, key, source_name)
	_apply_location_loot_bundle_0534(bundle, target_player)
	specialized_loot_found_0534[role] = int(specialized_loot_found_0534.get(role, 0)) + 1
	last_location_loot_0534 = role

func _build_location_loot_bundle_0534(role: String, key: String, source_name: String = "none") -> Dictionary:
	var marker := int(abs(hash("locationloot0534:%s:%s:%d:%s" % [role, key, world_seed, source_name])))
	var items: Dictionary = {}
	var foods: Dictionary = {}
	var clothing: Array[String] = []
	var weapons: Array[String] = []

	match role:
		"hospital":
			items["bandage"] = 2 + marker % 3
			items["antiseptic"] = 1 + int(marker / 5) % 2
			items["water"] = 1 + int(marker / 9) % 2
			if marker % 100 < 34:
				clothing.append("work_gloves")
			if marker % 100 < 10:
				clothing.append("rain_jacket")
		"market":
			foods["potato"] = 1 + marker % 3
			foods["corn"] = 1 + int(marker / 3) % 3
			foods["carrot"] = 1 + int(marker / 7) % 3
			items["water"] = 1 + int(marker / 11) % 3
			if marker % 100 < 46:
				items["potato_seed"] = 1 + int(marker / 13) % 2
			if marker % 100 < 25:
				clothing.append("school_backpack")
		"workshop":
			items["repair_kit"] = 1 + marker % 2
			items["gasoline"] = 2 + int(marker / 3) % 5
			items["stone"] = 1 + int(marker / 7) % 3
			items["wood"] = 1 + int(marker / 11) % 3
			if marker % 100 < 58:
				clothing.append("work_gloves")
			if marker % 100 < 28:
				clothing.append("work_boots")
			if marker % 100 < 16:
				weapons.append("axe")
		"police":
			items["ammo_9mm"] = 8 + marker % 11
			items["shells"] = 2 + int(marker / 5) % 5
			items["bandage"] = 1 + int(marker / 9) % 2
			if marker % 100 < 48:
				weapons.append("pistol")
			if marker % 100 < 14:
				weapons.append("shotgun")
			if marker % 100 < 22:
				clothing.append("hiking_backpack")
		"farm":
			items["potato_seed"] = 2 + marker % 3
			items["corn_seed"] = 2 + int(marker / 3) % 3
			items["carrot_seed"] = 2 + int(marker / 7) % 3
			foods["potato"] = 1 + int(marker / 11) % 3
			foods["corn"] = 1 + int(marker / 13) % 2
			foods["carrot"] = 1 + int(marker / 17) % 3
			items["water"] = 1 + int(marker / 19) % 2
			if marker % 100 < 52:
				clothing.append("work_gloves")
			if marker % 100 < 38:
				clothing.append("work_boots")
		_:
			items["fiber"] = 1

	return {
		"role": role,
		"items": items,
		"foods": foods,
		"clothing": clothing,
		"weapons": weapons,
		"marker": marker
	}

func _apply_location_loot_bundle_0534(bundle: Dictionary, target_player: Node) -> void:
	if target_player == null:
		return
	var items := bundle.get("items", {}) as Dictionary
	for raw_id: Variant in items.keys():
		var item_id := str(raw_id)
		var amount := int(items[raw_id])
		if amount > 0 and target_player.has_method("add_item"):
			target_player.call("add_item", item_id, amount)

	var foods := bundle.get("foods", {}) as Dictionary
	for raw_id: Variant in foods.keys():
		var food_id := str(raw_id)
		var amount := int(foods[raw_id])
		if amount <= 0:
			continue
		if target_player.has_method("receive_food_item_0532"):
			target_player.call("receive_food_item_0532", food_id, amount, 100.0)
		elif target_player.has_method("add_item"):
			target_player.call("add_item", food_id, amount)

	var clothing := bundle.get("clothing", []) as Array
	if target_player.has_method("receive_clothing_0533"):
		for raw_id: Variant in clothing:
			target_player.call("receive_clothing_0533", str(raw_id), 1)

	var weapons := bundle.get("weapons", []) as Array
	if target_player.has_method("unlock_weapon"):
		for raw_id: Variant in weapons:
			target_player.call("unlock_weapon", str(raw_id))

func preview_location_loot_0534(role: String, key: String = "preview") -> Dictionary:
	if role not in LOCATION_ROLES_0534:
		return {}
	return _build_location_loot_bundle_0534(role, key, "preview")

func debug_grant_location_loot_0534(role: String, target_player: Node, key: String = "debug") -> bool:
	if role not in LOCATION_ROLES_0534 or target_player == null:
		return false
	var bundle := _build_location_loot_bundle_0534(role, key, "debug")
	_apply_location_loot_bundle_0534(bundle, target_player)
	specialized_loot_found_0534[role] = int(specialized_loot_found_0534.get(role, 0)) + 1
	last_location_loot_0534 = role
	return true

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_0534
	var world_state := payload.get("world", {}) as Dictionary
	world_state["specialized_loot_found_0534"] = specialized_loot_found_0534.duplicate(true)
	world_state["last_location_loot_0534"] = last_location_loot_0534
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func new_seed() -> void:
	for role in LOCATION_ROLES_0534:
		specialized_loot_found_0534[role] = 0
	last_location_loot_0534 = ""
	super.new_seed()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var total := 0
	for role in LOCATION_ROLES_0534:
		total += int(specialized_loot_found_0534.get(role, 0))
	result["location_loot_total_0534"] = total
	result["last_location_loot_0534"] = last_location_loot_0534
	return result

func get_location_loot_debug_0534() -> Dictionary:
	var total := 0
	for role in LOCATION_ROLES_0534:
		total += int(specialized_loot_found_0534.get(role, 0))
	return {
		"roles": LOCATION_ROLES_0534.duplicate(),
		"counts": specialized_loot_found_0534.duplicate(true),
		"total": total,
		"last": last_location_loot_0534,
		"save_version": SAVE_VERSION_0534
	}
