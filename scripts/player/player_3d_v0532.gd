extends "res://scripts/player/player_3d_v0531.gd"

const STARTING_CORN_SEEDS_0532 := 3
const STARTING_CARROT_SEEDS_0532 := 3
const FOOD_IDS_0532 := ["potato", "corn", "carrot", "cooked_potato", "roasted_corn", "vegetable_stew"]
const PERISHABLE_IDS_0532 := ["potato", "corn", "carrot", "cooked_potato", "roasted_corn", "vegetable_stew"]
const FOOD_SHELF_LIFE_MINUTES_0532 := {
	"potato": 4320.0,
	"corn": 2880.0,
	"carrot": 3600.0,
	"cooked_potato": 1440.0,
	"roasted_corn": 1080.0,
	"vegetable_stew": 720.0
}
const FOOD_HUNGER_GAIN_0532 := {
	"potato": 10.0,
	"corn": 14.0,
	"carrot": 9.0,
	"cooked_potato": 24.0,
	"roasted_corn": 26.0,
	"vegetable_stew": 42.0,
	"spoiled_food": 4.0
}
const FOOD_RECIPES_0532 := {
	"baked_potato": {
		"name": "Batata assada",
		"requirements": {"potato": 1},
		"output": "cooked_potato",
		"amount": 1,
		"fuel_cost": 8.0
	},
	"roasted_corn": {
		"name": "Milho assado",
		"requirements": {"corn": 1},
		"output": "roasted_corn",
		"amount": 1,
		"fuel_cost": 8.0
	},
	"vegetable_stew": {
		"name": "Ensopado de legumes",
		"requirements": {"potato": 1, "corn": 1, "carrot": 1, "water": 1},
		"output": "vegetable_stew",
		"amount": 2,
		"fuel_cost": 18.0
	}
}

var food_freshness_0532: Dictionary = {}
var food_sickness_0532 := 0.0
var meals_eaten_0532 := 0
var meals_cooked_0532 := 0
var spoiled_items_0532 := 0

func _ready() -> void:
	super._ready()
	_ensure_food_inventory_0532()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_food_sickness_0532(delta)

func _ensure_food_inventory_0532() -> void:
	if not inventory.has("corn_seed"):
		inventory["corn_seed"] = STARTING_CORN_SEEDS_0532
	if not inventory.has("carrot_seed"):
		inventory["carrot_seed"] = STARTING_CARROT_SEEDS_0532
	for id in ["corn", "carrot", "cooked_potato", "roasted_corn", "vegetable_stew", "spoiled_food"]:
		if not inventory.has(id):
			inventory[id] = 0
	for id in PERISHABLE_IDS_0532:
		if not food_freshness_0532.has(id):
			food_freshness_0532[id] = 100.0

func _update_food_sickness_0532(delta: float) -> void:
	if food_sickness_0532 <= 0.0:
		return
	food_sickness_0532 = maxf(0.0, food_sickness_0532 - 0.028 * delta)
	if food_sickness_0532 >= 28.0:
		stamina = maxf(0.0, stamina - 0.32 * delta)
	if food_sickness_0532 >= 55.0:
		thirst = maxf(0.0, thirst - 0.22 * delta)
		hunger = maxf(0.0, hunger - 0.18 * delta)
		pain_0519 = minf(100.0, pain_0519 + 0.025 * delta)
	if food_sickness_0532 >= 82.0:
		health = maxf(0.0, health - 0.20 * delta)
	if health <= 0.0:
		_respawn()

func receive_food_item_0532(item_id: String, amount: int = 1, freshness: float = 100.0) -> bool:
	if amount <= 0:
		return false
	_ensure_food_inventory_0532()
	var before := int(inventory.get(item_id, 0))
	inventory[item_id] = before + amount
	if item_id in PERISHABLE_IDS_0532:
		var current_freshness := float(food_freshness_0532.get(item_id, 100.0))
		var total := before + amount
		if total > 0:
			food_freshness_0532[item_id] = clampf((current_freshness * float(before) + clampf(freshness, 0.0, 100.0) * float(amount)) / float(total), 0.0, 100.0)
	_request_save_0524()
	return true

func advance_food_decay_0532(minutes: float) -> void:
	if minutes <= 0.0:
		return
	_ensure_food_inventory_0532()
	for item_id in PERISHABLE_IDS_0532:
		var amount := int(inventory.get(item_id, 0))
		if amount <= 0:
			food_freshness_0532[item_id] = 100.0
			continue
		var shelf_life := float(FOOD_SHELF_LIFE_MINUTES_0532.get(item_id, 1440.0))
		var freshness := float(food_freshness_0532.get(item_id, 100.0))
		freshness = maxf(0.0, freshness - (100.0 * minutes / maxf(1.0, shelf_life)))
		food_freshness_0532[item_id] = freshness
		if freshness <= 0.001:
			inventory[item_id] = 0
			inventory["spoiled_food"] = int(inventory.get("spoiled_food", 0)) + amount
			spoiled_items_0532 += amount
			food_freshness_0532[item_id] = 100.0
	_request_save_0524()

func get_food_freshness_0532(item_id: String) -> float:
	if item_id == "spoiled_food":
		return 0.0
	return clampf(float(food_freshness_0532.get(item_id, 100.0)), 0.0, 100.0)

func use_inventory_item(id: String) -> bool:
	if id in FOOD_IDS_0532 or id == "spoiled_food":
		return eat_food_0532(id)
	return super.use_inventory_item(id)

func eat_food_0532(item_id: String) -> bool:
	var amount := int(inventory.get(item_id, 0))
	if amount <= 0:
		return false
	inventory[item_id] = amount - 1
	var freshness := get_food_freshness_0532(item_id)
	var hunger_gain := float(FOOD_HUNGER_GAIN_0532.get(item_id, 8.0))
	if item_id != "spoiled_food":
		var quality_factor := lerpf(0.55, 1.0, freshness / 100.0)
		hunger_gain *= quality_factor
		if freshness < 35.0:
			food_sickness_0532 = minf(100.0, food_sickness_0532 + (35.0 - freshness) * 0.55)
	else:
		food_sickness_0532 = minf(100.0, food_sickness_0532 + 48.0)
	hunger = minf(100.0, hunger + hunger_gain)
	if item_id == "vegetable_stew":
		thirst = minf(100.0, thirst + 12.0)
	elif item_id == "carrot":
		thirst = minf(100.0, thirst + 2.0)
	meals_eaten_0532 += 1
	if int(inventory.get(item_id, 0)) <= 0 and item_id in PERISHABLE_IDS_0532:
		food_freshness_0532[item_id] = 100.0
	_request_save_0524()
	return true

func get_food_recipes_0532() -> Array:
	var result: Array = []
	for raw_id: Variant in FOOD_RECIPES_0532.keys():
		var recipe_id := str(raw_id)
		var recipe := (FOOD_RECIPES_0532[raw_id] as Dictionary).duplicate(true)
		recipe["id"] = recipe_id
		recipe["can_cook"] = can_cook_recipe_0532(recipe_id)
		result.append(recipe)
	return result

func get_food_recipe_0532(recipe_id: String) -> Dictionary:
	if not FOOD_RECIPES_0532.has(recipe_id):
		return {}
	var recipe := (FOOD_RECIPES_0532[recipe_id] as Dictionary).duplicate(true)
	recipe["id"] = recipe_id
	return recipe

func can_cook_recipe_0532(recipe_id: String) -> bool:
	if not FOOD_RECIPES_0532.has(recipe_id):
		return false
	var requirements := (FOOD_RECIPES_0532[recipe_id] as Dictionary).get("requirements", {}) as Dictionary
	for raw_id: Variant in requirements.keys():
		if int(inventory.get(str(raw_id), 0)) < int(requirements[raw_id]):
			return false
	return true

func cook_food_recipe_0532(recipe_id: String) -> bool:
	if not can_cook_recipe_0532(recipe_id):
		return false
	var recipe := FOOD_RECIPES_0532[recipe_id] as Dictionary
	var requirements := recipe.get("requirements", {}) as Dictionary
	for raw_id: Variant in requirements.keys():
		var item_id := str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(requirements[raw_id])
		if item_id in PERISHABLE_IDS_0532 and int(inventory.get(item_id, 0)) <= 0:
			food_freshness_0532[item_id] = 100.0
	var output := str(recipe.get("output", ""))
	var output_amount := int(recipe.get("amount", 1))
	if output == "":
		return false
	receive_food_item_0532(output, output_amount, 100.0)
	meals_cooked_0532 += output_amount
	_request_save_0524()
	return true

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var corn_seed := int(inventory.get("corn_seed", 0))
	var carrot_seed := int(inventory.get("carrot_seed", 0))
	var corn := int(inventory.get("corn", 0))
	var carrot := int(inventory.get("carrot", 0))
	var cooked := int(inventory.get("cooked_potato", 0)) + int(inventory.get("roasted_corn", 0)) + int(inventory.get("vegetable_stew", 0))
	if corn_seed > 0:
		result += " | Milho-semente %d" % corn_seed
	if carrot_seed > 0:
		result += " | Cenoura-semente %d" % carrot_seed
	if corn > 0:
		result += " | Milho %d" % corn
	if carrot > 0:
		result += " | Cenoura %d" % carrot
	if cooked > 0:
		result += " | Refeições %d" % cooked
	return result

func _extract_death_drop_0520() -> Dictionary:
	var dropped := super._extract_death_drop_0520()
	for item_id in ["potato_seed", "corn_seed", "carrot_seed", "potato", "corn", "carrot", "cooked_potato", "roasted_corn", "vegetable_stew", "spoiled_food"]:
		var amount := int(inventory.get(item_id, 0))
		if amount < 2:
			continue
		var loss := maxi(1, int(floor(float(amount) * DEATH_DROP_RATIO_0520)))
		loss = mini(loss, amount)
		inventory[item_id] = amount - loss
		dropped[item_id] = loss
	return dropped

func get_vitals() -> Dictionary:
	var result := super.get_vitals()
	result["food_sickness_0532"] = food_sickness_0532
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["food_freshness_0532"] = food_freshness_0532.duplicate(true)
	state["food_sickness_0532"] = food_sickness_0532
	state["meals_eaten_0532"] = meals_eaten_0532
	state["meals_cooked_0532"] = meals_cooked_0532
	state["spoiled_items_0532"] = spoiled_items_0532
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	var raw_freshness: Variant = state.get("food_freshness_0532", {})
	food_freshness_0532 = (raw_freshness as Dictionary).duplicate(true) if raw_freshness is Dictionary else {}
	food_sickness_0532 = float(state.get("food_sickness_0532", 0.0))
	meals_eaten_0532 = int(state.get("meals_eaten_0532", 0))
	meals_cooked_0532 = int(state.get("meals_cooked_0532", 0))
	spoiled_items_0532 = int(state.get("spoiled_items_0532", 0))
	_ensure_food_inventory_0532()

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	inventory["corn_seed"] = STARTING_CORN_SEEDS_0532
	inventory["carrot_seed"] = STARTING_CARROT_SEEDS_0532
	for id in ["corn", "carrot", "cooked_potato", "roasted_corn", "vegetable_stew", "spoiled_food"]:
		inventory[id] = 0
	food_freshness_0532.clear()
	for id in PERISHABLE_IDS_0532:
		food_freshness_0532[id] = 100.0
	food_sickness_0532 = 0.0
	meals_eaten_0532 = 0
	meals_cooked_0532 = 0
	spoiled_items_0532 = 0

func _respawn() -> void:
	super._respawn()
	food_sickness_0532 = minf(food_sickness_0532, 20.0)

func get_food_debug_0532() -> Dictionary:
	return {
		"corn_seed": int(inventory.get("corn_seed", 0)),
		"carrot_seed": int(inventory.get("carrot_seed", 0)),
		"corn": int(inventory.get("corn", 0)),
		"carrot": int(inventory.get("carrot", 0)),
		"cooked_potato": int(inventory.get("cooked_potato", 0)),
		"roasted_corn": int(inventory.get("roasted_corn", 0)),
		"vegetable_stew": int(inventory.get("vegetable_stew", 0)),
		"spoiled_food": int(inventory.get("spoiled_food", 0)),
		"freshness": food_freshness_0532.duplicate(true),
		"sickness": food_sickness_0532,
		"eaten": meals_eaten_0532,
		"cooked": meals_cooked_0532,
		"spoiled": spoiled_items_0532
	}
