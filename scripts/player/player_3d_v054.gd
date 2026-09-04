extends "res://scripts/player/player_3d.gd"

const RECIPES := {
	"bandage": {
		"id": "bandage",
		"name": "Bandagem",
		"requirements": {"fiber": 3},
		"result_type": "item",
		"result_id": "bandage",
		"amount": 1
	},
	"axe": {
		"id": "axe",
		"name": "Machadinha",
		"requirements": {"wood": 3, "stone": 2, "fiber": 1},
		"result_type": "weapon",
		"result_id": "axe",
		"amount": 1
	},
	"spear": {
		"id": "spear",
		"name": "Lança de madeira",
		"requirements": {"wood": 4, "fiber": 2},
		"result_type": "weapon",
		"result_id": "spear",
		"amount": 1
	}
}

func get_craft_recipes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ["bandage", "axe", "spear"]:
		var recipe := (RECIPES[id] as Dictionary).duplicate(true)
		if str(recipe.get("result_type", "")) == "weapon" and owned_weapons.has(str(recipe.get("result_id", ""))):
			continue
		result.append(recipe)
	return result

func can_craft(recipe_id: String) -> bool:
	if not RECIPES.has(recipe_id):
		return false
	var recipe := RECIPES[recipe_id] as Dictionary
	if str(recipe.get("result_type", "")) == "weapon" and owned_weapons.has(str(recipe.get("result_id", ""))):
		return false
	var requirements := recipe.get("requirements", {}) as Dictionary
	for raw_id in requirements.keys():
		var item_id := str(raw_id)
		if int(inventory.get(item_id, 0)) < int(requirements[raw_id]):
			return false
	return true

func craft_recipe(recipe_id: String) -> bool:
	if not can_craft(recipe_id):
		return false
	var recipe := RECIPES[recipe_id] as Dictionary
	var requirements := recipe.get("requirements", {}) as Dictionary
	for raw_id in requirements.keys():
		var item_id := str(raw_id)
		inventory[item_id] = int(inventory.get(item_id, 0)) - int(requirements[raw_id])
	var result_type := str(recipe.get("result_type", "item"))
	var result_id := str(recipe.get("result_id", ""))
	if result_type == "weapon":
		unlock_weapon(result_id)
	else:
		add_item(result_id, int(recipe.get("amount", 1)))
	return true

func _attack() -> void:
	var weapon := get_equipped_weapon()
	if weapon == "axe":
		if attack_cooldown > 0.0 or stamina < 9.0:
			return
		stamina -= 9.0
		attack_cooldown = 0.58
		_damage_nearest(2.7, 50.0)
		_animate_weapon_swing()
		return
	if weapon == "spear":
		if attack_cooldown > 0.0 or stamina < 6.0:
			return
		stamina -= 6.0
		attack_cooldown = 0.52
		_damage_nearest(3.7, 35.0)
		_animate_weapon_swing()
		return
	super._attack()

func _refresh_weapon_visual() -> void:
	if weapon_anchor == null:
		return
	var weapon := get_equipped_weapon()
	if weapon not in ["axe", "spear"]:
		super._refresh_weapon_visual()
		return
	for child in weapon_anchor.get_children():
		child.free()
	weapon_anchor.rotation_degrees = Vector3.ZERO
	if weapon == "axe":
		weapon_anchor.rotation_degrees = Vector3(-14.0, -5.0, -15.0)
		_box_to(weapon_anchor, Vector3(0.10, 0.10, 0.78), Vector3(0,0,-0.30), _material("6b452d"))
		_box_to(weapon_anchor, Vector3(0.42, 0.16, 0.12), Vector3(0,0,-0.74), _material("555b59"))
	else:
		weapon_anchor.rotation_degrees = Vector3(-6.0, 0.0, -7.0)
		_box_to(weapon_anchor, Vector3(0.10, 0.10, 1.65), Vector3(0,0,-0.70), _material("6b452d"))
		var tip := _box_to(weapon_anchor, Vector3(0.16, 0.12, 0.34), Vector3(0,0,-1.67), _material("777b77"))
		tip.rotation_degrees.y = 0.0

func get_weapon_summary() -> String:
	var weapon := get_equipped_weapon()
	if weapon == "axe":
		return "MACHADINHA — ferramenta / corpo a corpo"
	if weapon == "spear":
		return "LANÇA — corpo a corpo"
	return super.get_weapon_summary()

func get_inventory_summary() -> String:
	var names := {"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra", "food":"Comida", "water":"Água", "bandage":"Bandagem", "ammo_9mm":"9mm", "shells":"Cart."}
	var parts: Array[String] = []
	for id in ["wood","stone","fiber","food","water","bandage","ammo_9mm","shells"]:
		var amount := int(inventory.get(id, 0))
		if amount > 0:
			parts.append("%s %d" % [names[id], amount])
	if parts.is_empty():
		return "vazia"
	return " | ".join(parts)
