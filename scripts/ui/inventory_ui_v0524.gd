extends "res://scripts/ui/inventory_ui_v0523.gd"

const ITEM_NAMES_0524 := {
	"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra",
	"food":"Comida", "water":"Água", "bandage":"Bandagem",
	"antiseptic":"Antisséptico", "ammo_9mm":"Munição 9mm", "shells":"Cartuchos",
	"plank":"Tábuas", "cordage":"Corda", "stone_blade":"Lâmina pedra", "repair_kit":"Kit reparo"
}

var station_label_0524: Label
var craft_scroll_0524: ScrollContainer
var station_context_key_0524 := ""

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0524")
	_build_station_ui_0524()

func _build_station_ui_0524() -> void:
	station_label_0524 = Label.new()
	station_label_0524.name = "StationStatus0524"
	station_label_0524.position = Vector2(300, 448)
	station_label_0524.size = Vector2(535, 24)
	station_label_0524.add_theme_font_size_override("font_size", 12)
	station_label_0524.modulate = Color(0.92, 0.78, 0.43, 0.96)
	panel.add_child(station_label_0524)

	# O crafting cresceu além da altura fixa da coluna original; a lista vira rolável no mobile.
	if crafts_box != null and crafts_box.get_parent() == panel:
		panel.remove_child(crafts_box)
		craft_scroll_0524 = ScrollContainer.new()
		craft_scroll_0524.name = "CraftScroll0524"
		craft_scroll_0524.position = Vector2(580, 90)
		craft_scroll_0524.size = Vector2(270, 350)
		craft_scroll_0524.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		panel.add_child(craft_scroll_0524)
		crafts_box.position = Vector2.ZERO
		crafts_box.size = Vector2(250, 620)
		crafts_box.custom_minimum_size = Vector2(245, 620)
		craft_scroll_0524.add_child(crafts_box)
	_update_station_label_0524()

func open_workbench_0524(key: String) -> void:
	station_context_key_0524 = key
	panel.visible = true
	overlay.visible = true
	_refresh_contents()

func _refresh_contents() -> void:
	if player == null:
		return
	_clear_box(items_box)
	_clear_box(weapons_box)
	_clear_box(crafts_box)
	_update_station_label_0524()

	var snapshot: Dictionary = {}
	if player.has_method("get_inventory_snapshot"):
		var raw_snapshot: Variant = player.call("get_inventory_snapshot")
		if raw_snapshot is Dictionary:
			snapshot = raw_snapshot as Dictionary
	var shown_items := 0
	for id in ["wood", "stone", "fiber", "plank", "cordage", "stone_blade", "repair_kit", "food", "water", "bandage", "antiseptic", "ammo_9mm", "shells"]:
		var amount := int(snapshot.get(id, 0))
		if amount <= 0:
			continue
		_add_item_row(id, amount)
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
	label.text = "%s  x%d" % [ITEM_NAMES_0524.get(id, id), amount]
	label.custom_minimum_size = Vector2(155, 32)
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)
	if id in ["food", "water", "bandage", "antiseptic"]:
		var use := Button.new()
		use.text = "USAR"
		use.custom_minimum_size = Vector2(72, 32)
		use.pressed.connect(_on_use_item.bind(id))
		row.add_child(use)
	items_box.add_child(row)

func _add_weapon_row(id: String, equipped: bool) -> void:
	var container := VBoxContainer.new()
	container.custom_minimum_size = Vector2(255, 60)

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(255, 38)
	container.add_child(row)

	var durability := 100
	var broken := false
	if player != null and player.has_method("get_weapon_durability_percent_0523"):
		durability = int(player.call("get_weapon_durability_percent_0523", id))
	if player != null and player.has_method("is_weapon_broken_0523"):
		broken = bool(player.call("is_weapon_broken_0523", id))

	var label := Label.new()
	label.text = "%s%s\n%s" % [WEAPON_NAMES_0523.get(id, id), " ✓" if equipped else "", "QUEBRADA" if broken else "DUR %d%%" % durability]
	label.custom_minimum_size = Vector2(112, 38)
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)

	var equip := Button.new()
	equip.text = "ATIVO" if equipped else "EQUIP."
	equip.disabled = equipped
	equip.custom_minimum_size = Vector2(66, 36)
	equip.add_theme_font_size_override("font_size", 10)
	equip.pressed.connect(_on_equip_weapon.bind(id))
	row.add_child(equip)

	var full_repair := player != null and player.has_method("can_workbench_repair_0524") and bool(player.call("can_workbench_repair_0524", id))
	var field_repair := player != null and player.has_method("can_repair_weapon_0523") and bool(player.call("can_repair_weapon_0523", id))
	var repair := Button.new()
	repair.text = "REVISÃO" if full_repair else "REPARAR"
	repair.custom_minimum_size = Vector2(70, 36)
	repair.add_theme_font_size_override("font_size", 9)
	repair.disabled = not full_repair and not field_repair
	repair.pressed.connect(_on_repair_weapon_0524.bind(id))
	row.add_child(repair)

	var cost_label := Label.new()
	cost_label.modulate = Color(0.78, 0.75, 0.66, 0.82)
	cost_label.add_theme_font_size_override("font_size", 10)
	if full_repair:
		cost_label.text = "Bancada: Kit reparo x1 → 100%"
	else:
		cost_label.text = "Campo: " + _repair_cost_text_0523(id)
	container.add_child(cost_label)
	weapons_box.add_child(container)

func _on_repair_weapon_0524(id: String) -> void:
	var repaired := false
	if player != null and player.has_method("can_workbench_repair_0524") and bool(player.call("can_workbench_repair_0524", id)):
		repaired = bool(player.call("workbench_repair_weapon_0524", id))
	elif player != null and player.has_method("repair_weapon_0523"):
		repaired = bool(player.call("repair_weapon_0523", id))
	if repaired:
		_refresh_contents()

func _add_craft_row(recipe: Dictionary) -> void:
	var recipe_id := str(recipe.get("id", ""))
	var station := str(recipe.get("station", "field"))
	var container := VBoxContainer.new()
	container.custom_minimum_size = Vector2(245, 72)

	var title_row := HBoxContainer.new()
	container.add_child(title_row)
	var name_label := Label.new()
	name_label.text = str(recipe.get("name", recipe_id))
	name_label.custom_minimum_size = Vector2(150, 22)
	name_label.add_theme_font_size_override("font_size", 13)
	title_row.add_child(name_label)
	var station_label := Label.new()
	station_label.text = "BANCADA" if station == "workbench" else "CAMPO"
	station_label.modulate = Color(0.95, 0.73, 0.30, 0.95) if station == "workbench" else Color(0.70, 0.80, 0.66, 0.85)
	station_label.add_theme_font_size_override("font_size", 9)
	title_row.add_child(station_label)

	var req := recipe.get("requirements", {}) as Dictionary
	var parts: Array[String] = []
	for raw_id in req.keys():
		var item_id := str(raw_id)
		parts.append("%s x%d" % [ITEM_NAMES_0524.get(item_id, item_id), int(req[raw_id])])
	var req_label := Label.new()
	req_label.text = " + ".join(parts)
	req_label.modulate = Color(0.82, 0.78, 0.67, 0.9)
	req_label.add_theme_font_size_override("font_size", 10)
	container.add_child(req_label)

	var craft := Button.new()
	craft.text = "FABRICAR"
	craft.custom_minimum_size = Vector2(110, 30)
	craft.add_theme_font_size_override("font_size", 10)
	if player != null and player.has_method("can_craft"):
		craft.disabled = not bool(player.call("can_craft", recipe_id))
	craft.pressed.connect(_on_craft.bind(recipe_id))
	container.add_child(craft)
	crafts_box.add_child(container)

func _update_station_label_0524() -> void:
	if station_label_0524 == null:
		return
	var at_workbench := player != null and player.has_method("is_at_workbench_0524") and bool(player.call("is_at_workbench_0524"))
	if at_workbench:
		station_label_0524.text = "BANCADA ATIVA • produção processada e revisão total liberadas"
		station_label_0524.modulate = Color(0.95, 0.76, 0.30, 1.0)
	else:
		station_label_0524.text = "CRAFT DE CAMPO • aproxime-se da bancada para receitas de estação"
		station_label_0524.modulate = Color(0.72, 0.76, 0.68, 0.88)
