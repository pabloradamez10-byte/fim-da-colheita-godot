extends "res://scripts/ui/inventory_ui.gd"

const ITEM_NAMES_0520 := {
	"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra",
	"food":"Comida", "water":"Água", "bandage":"Bandagem",
	"antiseptic":"Antisséptico", "ammo_9mm":"Munição 9mm", "shells":"Cartuchos"
}

func _refresh_contents() -> void:
	if player == null:
		return
	_clear_box(items_box)
	_clear_box(weapons_box)
	_clear_box(crafts_box)

	var snapshot: Dictionary = {}
	if player.has_method("get_inventory_snapshot"):
		var raw_snapshot: Variant = player.call("get_inventory_snapshot")
		if raw_snapshot is Dictionary:
			snapshot = raw_snapshot as Dictionary
	var shown_items := 0
	for id in ["wood", "stone", "fiber", "food", "water", "bandage", "antiseptic", "ammo_9mm", "shells"]:
		var amount := int(snapshot.get(id, 0))
		if amount <= 0:
			continue
		_add_item_row(str(id), amount)
		shown_items += 1
	if shown_items == 0:
		var empty := Label.new()
		empty.text = "Mochila vazia"
		empty.modulate = Color(0.75, 0.76, 0.72, 0.8)
		items_box.add_child(empty)

	var weapons: Array = []
	if player.has_method("get_owned_weapons"):
		var raw_weapons: Variant = player.call("get_owned_weapons")
		if raw_weapons is Array:
			weapons = raw_weapons as Array
	var equipped := ""
	if player.has_method("get_equipped_weapon"):
		equipped = str(player.call("get_equipped_weapon"))
	for raw_id in weapons:
		var weapon_id := str(raw_id)
		_add_weapon_row(weapon_id, weapon_id == equipped)

	if player.has_method("get_craft_recipes"):
		var raw_recipes: Variant = player.call("get_craft_recipes")
		if raw_recipes is Array:
			for raw_recipe in raw_recipes as Array:
				if raw_recipe is Dictionary:
					_add_craft_row(raw_recipe as Dictionary)
	if crafts_box.get_child_count() == 0:
		var none := Label.new()
		none.text = "Nada para fabricar agora"
		none.modulate = Color(0.75, 0.76, 0.72, 0.8)
		crafts_box.add_child(none)

func _add_item_row(id: String, amount: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(245, 34)
	var label := Label.new()
	label.text = "%s  x%d" % [ITEM_NAMES_0520.get(id, id), amount]
	label.custom_minimum_size = Vector2(155, 32)
	row.add_child(label)
	if id in ["food", "water", "bandage", "antiseptic"]:
		var use := Button.new()
		use.text = "USAR"
		use.custom_minimum_size = Vector2(72, 32)
		use.pressed.connect(_on_use_item.bind(id))
		row.add_child(use)
	items_box.add_child(row)
