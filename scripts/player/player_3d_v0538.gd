extends "res://scripts/player/player_3d_v0536.gd"

const GAME_FOOD_IDS_0538 := ["raw_game_meat", "cooked_game_meat"]
const GAME_FOOD_SHELF_LIFE_0538 := {
	"raw_game_meat": 720.0,
	"cooked_game_meat": 1440.0
}
const GAME_MEAT_RECIPE_0538 := {
	"id": "cooked_game_meat",
	"name": "Carne de caça assada",
	"requirements": {"raw_game_meat": 1},
	"output": "cooked_game_meat",
	"amount": 1,
	"fuel_cost": 10.0
}

var game_food_freshness_0538: Dictionary = {
	"raw_game_meat": 100.0,
	"cooked_game_meat": 100.0
}
var animals_hit_0538 := 0
var game_meat_eaten_0538 := 0
var game_meat_cooked_0538 := 0

func _ready() -> void:
	super._ready()
	_ensure_hunting_inventory_0538()

func _ensure_hunting_inventory_0538() -> void:
	for item_id in ["raw_game_meat", "cooked_game_meat", "animal_hide", "feathers"]:
		if not inventory.has(item_id):
			inventory[item_id] = 0
	for item_id in GAME_FOOD_IDS_0538:
		if not game_food_freshness_0538.has(item_id):
			game_food_freshness_0538[item_id] = 100.0

func receive_hunting_item_0538(item_id: String, amount: int = 1, freshness: float = 100.0) -> bool:
	if amount <= 0:
		return false
	_ensure_hunting_inventory_0538()
	var before := int(inventory.get(item_id, 0))
	inventory[item_id] = before + amount
	if item_id in GAME_FOOD_IDS_0538:
		var current := float(game_food_freshness_0538.get(item_id, 100.0))
		var total := before + amount
		game_food_freshness_0538[item_id] = clampf((current * float(before) + clampf(freshness, 0.0, 100.0) * float(amount)) / float(maxi(1, total)), 0.0, 100.0)
	_request_save_0524()
	return true

func _damage_nearest(max_range: float, damage: float) -> void:
	if world == null:
		return
	var nearest: Node3D = null
	var nearest_is_animal := false
	var best := max_range
	if world.has_method("get_zombies"):
		for candidate in world.call("get_zombies"):
			var zombie := candidate as Node3D
			if zombie == null or not is_instance_valid(zombie):
				continue
			var distance := global_position.distance_to(zombie.global_position)
			if distance < best:
				best = distance
				nearest = zombie
				nearest_is_animal = false
	if world.has_method("get_huntable_animals_0538"):
		for candidate in world.call("get_huntable_animals_0538"):
			if not (candidate is Node3D):
				continue
			var animal := candidate as Node3D
			if not is_instance_valid(animal):
				continue
			if animal.has_method("is_alive_0538") and not bool(animal.call("is_alive_0538")):
				continue
			var distance := global_position.distance_to(animal.global_position)
			if distance < best:
				best = distance
				nearest = animal
				nearest_is_animal = true
	if nearest == null or not nearest.has_method("take_damage"):
		return
	nearest.call("take_damage", damage * get_combat_damage_multiplier_0535())
	if nearest_is_animal:
		animals_hit_0538 += 1
		award_skill_xp_0535("combat", 4, "animal_hit")
	else:
		award_skill_xp_0535("combat", 5, "hit")

func advance_food_decay_0532(minutes: float) -> void:
	super.advance_food_decay_0532(minutes)
	if minutes <= 0.0:
		return
	_ensure_hunting_inventory_0538()
	for item_id in GAME_FOOD_IDS_0538:
		var amount := int(inventory.get(item_id, 0))
		if amount <= 0:
			game_food_freshness_0538[item_id] = 100.0
			continue
		var shelf_life := float(GAME_FOOD_SHELF_LIFE_0538.get(item_id, 720.0))
		var freshness := float(game_food_freshness_0538.get(item_id, 100.0))
		freshness = maxf(0.0, freshness - (100.0 * minutes / maxf(1.0, shelf_life)))
		game_food_freshness_0538[item_id] = freshness
		if freshness <= 0.001:
			inventory[item_id] = 0
			inventory["spoiled_food"] = int(inventory.get("spoiled_food", 0)) + amount
			spoiled_items_0532 += amount
			game_food_freshness_0538[item_id] = 100.0
	_request_save_0524()

func get_food_freshness_0532(item_id: String) -> float:
	if item_id in GAME_FOOD_IDS_0538:
		return clampf(float(game_food_freshness_0538.get(item_id, 100.0)), 0.0, 100.0)
	return super.get_food_freshness_0532(item_id)

func use_inventory_item(id: String) -> bool:
	if id in GAME_FOOD_IDS_0538:
		return eat_game_meat_0538(id)
	return super.use_inventory_item(id)

func eat_game_meat_0538(item_id: String) -> bool:
	_ensure_hunting_inventory_0538()
	var amount := int(inventory.get(item_id, 0))
	if amount <= 0:
		return false
	inventory[item_id] = amount - 1
	var freshness := get_food_freshness_0532(item_id)
	if item_id == "raw_game_meat":
		hunger = minf(100.0, hunger + 9.0 * lerpf(0.55, 1.0, freshness / 100.0))
		food_sickness_0532 = minf(100.0, food_sickness_0532 + 36.0 + maxf(0.0, 35.0 - freshness) * 0.50)
	else:
		hunger = minf(100.0, hunger + 34.0 * lerpf(0.72, 1.0, freshness / 100.0))
		if freshness < 30.0:
			food_sickness_0532 = minf(100.0, food_sickness_0532 + (30.0 - freshness) * 0.45)
	game_meat_eaten_0538 += 1
	if int(inventory.get(item_id, 0)) <= 0:
		game_food_freshness_0538[item_id] = 100.0
	_request_save_0524()
	return true

func get_food_recipes_0532() -> Array:
	var result: Array = super.get_food_recipes_0532()
	var recipe := GAME_MEAT_RECIPE_0538.duplicate(true)
	recipe["can_cook"] = can_cook_recipe_0532("cooked_game_meat")
	result.append(recipe)
	return result

func get_food_recipe_0532(recipe_id: String) -> Dictionary:
	if recipe_id == "cooked_game_meat":
		return GAME_MEAT_RECIPE_0538.duplicate(true)
	return super.get_food_recipe_0532(recipe_id)

func can_cook_recipe_0532(recipe_id: String) -> bool:
	if recipe_id == "cooked_game_meat":
		return int(inventory.get("raw_game_meat", 0)) >= 1
	return super.can_cook_recipe_0532(recipe_id)

func cook_food_recipe_0532(recipe_id: String) -> bool:
	if recipe_id != "cooked_game_meat":
		return super.cook_food_recipe_0532(recipe_id)
	if not can_cook_recipe_0532(recipe_id):
		return false
	inventory["raw_game_meat"] = int(inventory.get("raw_game_meat", 0)) - 1
	if int(inventory.get("raw_game_meat", 0)) <= 0:
		game_food_freshness_0538["raw_game_meat"] = 100.0
	receive_hunting_item_0538("cooked_game_meat", 1, 100.0)
	game_meat_cooked_0538 += 1
	meals_cooked_0532 += 1
	_request_save_0524()
	return true

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var raw_meat := int(inventory.get("raw_game_meat", 0))
	var cooked_meat := int(inventory.get("cooked_game_meat", 0))
	var hides := int(inventory.get("animal_hide", 0))
	var feathers_count := int(inventory.get("feathers", 0))
	if raw_meat > 0:
		result += " | Carne crua %d" % raw_meat
	if cooked_meat > 0:
		result += " | Carne assada %d" % cooked_meat
	if hides > 0:
		result += " | Couro %d" % hides
	if feathers_count > 0:
		result += " | Penas %d" % feathers_count
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["game_food_freshness_0538"] = game_food_freshness_0538.duplicate(true)
	state["animals_hit_0538"] = animals_hit_0538
	state["game_meat_eaten_0538"] = game_meat_eaten_0538
	state["game_meat_cooked_0538"] = game_meat_cooked_0538
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	var raw_freshness: Variant = state.get("game_food_freshness_0538", {})
	game_food_freshness_0538 = (raw_freshness as Dictionary).duplicate(true) if raw_freshness is Dictionary else {}
	animals_hit_0538 = int(state.get("animals_hit_0538", 0))
	game_meat_eaten_0538 = int(state.get("game_meat_eaten_0538", 0))
	game_meat_cooked_0538 = int(state.get("game_meat_cooked_0538", 0))
	_ensure_hunting_inventory_0538()

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	inventory["raw_game_meat"] = 0
	inventory["cooked_game_meat"] = 0
	inventory["animal_hide"] = 0
	inventory["feathers"] = 0
	game_food_freshness_0538 = {"raw_game_meat": 100.0, "cooked_game_meat": 100.0}
	animals_hit_0538 = 0
	game_meat_eaten_0538 = 0
	game_meat_cooked_0538 = 0

func get_hunting_player_debug_0538() -> Dictionary:
	_ensure_hunting_inventory_0538()
	return {
		"inventory": get_inventory_snapshot(),
		"freshness": game_food_freshness_0538.duplicate(true),
		"animals_hit": animals_hit_0538,
		"meat_eaten": game_meat_eaten_0538,
		"meat_cooked": game_meat_cooked_0538,
		"cooking_available": can_cook_recipe_0532("cooked_game_meat")
	}
