extends "res://scripts/player/player_3d_v0523.gd"

const EXTRA_FIELD_RECIPES_0524 := {
	"cordage": {
		"id": "cordage",
		"name": "Corda improvisada",
		"requirements": {"fiber": 3},
		"result_type": "item",
		"result_id": "cordage",
		"amount": 1,
		"station": "field"
	}
}

const WORKBENCH_RECIPES_0524 := {
	"plank_bundle": {
		"id": "plank_bundle",
		"name": "Tábuas preparadas",
		"requirements": {"wood": 2},
		"result_type": "item",
		"result_id": "plank",
		"amount": 3,
		"station": "workbench"
	},
	"stone_blade": {
		"id": "stone_blade",
		"name": "Lâmina de pedra",
		"requirements": {"stone": 2, "fiber": 1},
		"result_type": "item",
		"result_id": "stone_blade",
		"amount": 1,
		"station": "workbench"
	},
	"repair_kit": {
		"id": "repair_kit",
		"name": "Kit de reparo",
		"requirements": {"plank": 2, "cordage": 1, "stone_blade": 1},
		"result_type": "item",
		"result_id": "repair_kit",
		"amount": 1,
		"station": "workbench"
	}
}

const PROCESSED_ITEMS_0524 := ["plank", "cordage", "stone_blade", "repair_kit"]
const PROCESSED_DEATH_DROP_RATIO_0524 := 0.35

var last_workbench_key_0524 := ""
var last_craft_0524 := ""
var craft_count_0524 := 0
var workbench_repair_count_0524 := 0

func _ready() -> void:
	super._ready()
	_ensure_processed_inventory_0524()

func _ensure_processed_inventory_0524() -> void:
	for id in PROCESSED_ITEMS_0524:
		if not inventory.has(id):
			inventory[id] = 0

func activate_workbench_0524(key: String) -> bool:
	last_workbench_key_0524 = key
	last_hotbar_action_0523 = "workbench:%s" % key
	return true

func is_at_workbench_0524() -> bool:
	return world != null and world.has_method("is_near_workbench_0524") and bool(world.call("is_near_workbench_0524", global_position))

func get_craft_recipes() -> Array[Dictionary]:
	var result: Array[Dictionary] = super.get_craft_recipes()
	for id in ["cordage"]:
		result.append((EXTRA_FIELD_RECIPES_0524[id] as Dictionary).duplicate(true))
	for id in ["plank_bundle", "stone_blade", "repair_kit"]:
		var recipe := (WORKBENCH_RECIPES_0524[id] as Dictionary).duplicate(true)
		recipe["station_ok"] = is_at_workbench_0524()
		result.append(recipe)
	return result

func can_craft(recipe_id: String) -> bool:
	if EXTRA_FIELD_RECIPES_0524.has(recipe_id):
		return _has_recipe_requirements_0524(EXTRA_FIELD_RECIPES_0524[recipe_id] as Dictionary)
	if WORKBENCH_RECIPES_0524.has(recipe_id):
		if not is_at_workbench_0524():
			return false
		return _has_recipe_requirements_0524(WORKBENCH_RECIPES_0524[recipe_id] as Dictionary)
	return super.can_craft(recipe_id)

func _has_recipe_requirements_0524(recipe: Dictionary) -> bool:
	var requirements := recipe.get("requirements", {}) as Dictionary
	for raw_id in requirements.keys():
		var id := str(raw_id)
		if int(inventory.get(id, 0)) < int(requirements[raw_id]):
			return false
	return true

func craft_recipe(recipe_id: String) -> bool:
	if EXTRA_FIELD_RECIPES_0524.has(recipe_id):
		return _craft_extra_recipe_0524(EXTRA_FIELD_RECIPES_0524[recipe_id] as Dictionary)
	if WORKBENCH_RECIPES_0524.has(recipe_id):
		return _craft_extra_recipe_0524(WORKBENCH_RECIPES_0524[recipe_id] as Dictionary)
	var crafted := super.craft_recipe(recipe_id)
	if crafted:
		last_craft_0524 = recipe_id
		craft_count_0524 += 1
		_request_save_0524()
	return crafted

func _craft_extra_recipe_0524(recipe: Dictionary) -> bool:
	var recipe_id := str(recipe.get("id", ""))
	if not can_craft(recipe_id):
		return false
	var requirements := recipe.get("requirements", {}) as Dictionary
	for raw_id in requirements.keys():
		var id := str(raw_id)
		inventory[id] = int(inventory.get(id, 0)) - int(requirements[raw_id])
	add_item(str(recipe.get("result_id", "")), int(recipe.get("amount", 1)))
	last_craft_0524 = recipe_id
	craft_count_0524 += 1
	_request_save_0524()
	return true

func can_workbench_repair_0524(id: String) -> bool:
	if not owned_weapons.has(id):
		return false
	if not is_at_workbench_0524():
		return false
	if int(inventory.get("repair_kit", 0)) <= 0:
		return false
	return get_weapon_durability_0523(id) < get_weapon_max_durability_0523(id) - 0.01

func workbench_repair_weapon_0524(id: String) -> bool:
	if not can_workbench_repair_0524(id):
		return false
	inventory["repair_kit"] = int(inventory.get("repair_kit", 0)) - 1
	weapon_durability_0523[id] = get_weapon_max_durability_0523(id)
	if last_broken_weapon_0523 == id:
		last_broken_weapon_0523 = ""
	last_hotbar_action_0523 = "workbench_repair:%s" % id
	workbench_repair_count_0524 += 1
	_request_save_0524()
	return true

func _extract_death_drop_0520() -> Dictionary:
	var dropped := super._extract_death_drop_0520()
	for id in PROCESSED_ITEMS_0524:
		var amount := int(inventory.get(id, 0))
		if amount < 2:
			continue
		var loss := mini(amount, maxi(1, int(floor(float(amount) * PROCESSED_DEATH_DROP_RATIO_0524))))
		inventory[id] = amount - loss
		dropped[id] = int(dropped.get(id, 0)) + loss
	return dropped

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var extra: Array[String] = []
	if int(inventory.get("plank", 0)) > 0:
		extra.append("Tábuas %d" % int(inventory.get("plank", 0)))
	if int(inventory.get("cordage", 0)) > 0:
		extra.append("Cordas %d" % int(inventory.get("cordage", 0)))
	if int(inventory.get("stone_blade", 0)) > 0:
		extra.append("Lâmina %d" % int(inventory.get("stone_blade", 0)))
	if int(inventory.get("repair_kit", 0)) > 0:
		extra.append("Kit %d" % int(inventory.get("repair_kit", 0)))
	if not extra.is_empty():
		result += " | " + " | ".join(extra)
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["last_workbench_key_0524"] = last_workbench_key_0524
	state["last_craft_0524"] = last_craft_0524
	state["craft_count_0524"] = craft_count_0524
	state["workbench_repair_count_0524"] = workbench_repair_count_0524
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	_ensure_processed_inventory_0524()
	last_workbench_key_0524 = str(state.get("last_workbench_key_0524", ""))
	last_craft_0524 = str(state.get("last_craft_0524", ""))
	craft_count_0524 = int(state.get("craft_count_0524", 0))
	workbench_repair_count_0524 = int(state.get("workbench_repair_count_0524", 0))

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	_ensure_processed_inventory_0524()
	for id in PROCESSED_ITEMS_0524:
		inventory[id] = 0
	last_workbench_key_0524 = ""
	last_craft_0524 = ""
	craft_count_0524 = 0
	workbench_repair_count_0524 = 0

func get_crafting_debug_0524() -> Dictionary:
	return {
		"at_workbench": is_at_workbench_0524(),
		"last_workbench": last_workbench_key_0524,
		"last_craft": last_craft_0524,
		"craft_count": craft_count_0524,
		"workbench_repairs": workbench_repair_count_0524,
		"processed": {
			"plank": int(inventory.get("plank", 0)),
			"cordage": int(inventory.get("cordage", 0)),
			"stone_blade": int(inventory.get("stone_blade", 0)),
			"repair_kit": int(inventory.get("repair_kit", 0))
		}
	}

func _request_save_0524() -> void:
	if world != null and world.has_method("save_game"):
		world.call_deferred("save_game")
