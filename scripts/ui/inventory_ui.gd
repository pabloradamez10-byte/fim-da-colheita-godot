class_name InventoryUI
extends CanvasLayer

var player: Node = null
var overlay: ColorRect
var panel: Panel
var items_box: VBoxContainer
var weapons_box: VBoxContainer
var crafts_box: VBoxContainer
var toggle_button: Button
var refresh_timer := 0.0

const ITEM_NAMES := {
	"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra",
	"food":"Comida", "water":"Água", "bandage":"Bandagem",
	"ammo_9mm":"Munição 9mm", "shells":"Cartuchos"
}

const WEAPON_NAMES := {
	"machete":"Facão", "pistol":"Pistola 9mm", "shotgun":"Espingarda",
	"axe":"Machadinha", "spear":"Lança"
}

func _ready() -> void:
	layer = 20
	_build_ui()
	get_viewport().size_changed.connect(_refresh_layout)
	_refresh_layout()

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if panel != null and panel.visible:
		refresh_timer += delta
		if refresh_timer >= 0.30:
			refresh_timer = 0.0
			_refresh_contents()

func _build_ui() -> void:
	overlay = ColorRect.new()
	overlay.color = Color(0.015,0.018,0.014,0.76)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	panel = Panel.new()
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := Label.new()
	title.text = "MOCHILA • EQUIPAMENTO • CRAFT"
	title.position = Vector2(22,16)
	title.add_theme_font_size_override("font_size", 22)
	panel.add_child(title)

	var close := Button.new()
	close.text = "FECHAR"
	close.position = Vector2(755,12)
	close.size = Vector2(88,40)
	close.pressed.connect(toggle_inventory)
	panel.add_child(close)

	var items_title := Label.new()
	items_title.text = "MOCHILA"
	items_title.position = Vector2(24,64)
	items_title.add_theme_font_size_override("font_size", 17)
	panel.add_child(items_title)

	items_box = VBoxContainer.new()
	items_box.position = Vector2(24,92)
	items_box.size = Vector2(255,360)
	items_box.add_theme_constant_override("separation", 5)
	panel.add_child(items_box)

	var weapons_title := Label.new()
	weapons_title.text = "EQUIPAMENTO"
	weapons_title.position = Vector2(300,64)
	weapons_title.add_theme_font_size_override("font_size", 17)
	panel.add_child(weapons_title)

	weapons_box = VBoxContainer.new()
	weapons_box.position = Vector2(300,92)
	weapons_box.size = Vector2(265,350)
	weapons_box.add_theme_constant_override("separation", 8)
	panel.add_child(weapons_box)

	var crafts_title := Label.new()
	crafts_title.text = "CRAFT"
	crafts_title.position = Vector2(585,64)
	crafts_title.add_theme_font_size_override("font_size", 17)
	panel.add_child(crafts_title)

	crafts_box = VBoxContainer.new()
	crafts_box.position = Vector2(585,92)
	crafts_box.size = Vector2(255,350)
	crafts_box.add_theme_constant_override("separation", 9)
	panel.add_child(crafts_box)

	var help := Label.new()
	help.text = "Itens zerados ficam ocultos • USAR consome • EQUIPAR ativa • FABRICAR usa recursos"
	help.position = Vector2(24,475)
	help.modulate = Color(0.8,0.82,0.75,0.8)
	panel.add_child(help)

	toggle_button = Button.new()
	toggle_button.text = "MOCHILA"
	toggle_button.add_theme_font_size_override("font_size", 14)
	toggle_button.pressed.connect(toggle_inventory)
	add_child(toggle_button)

func _refresh_layout() -> void:
	var size := get_viewport().get_visible_rect().size
	overlay.position = Vector2.ZERO
	overlay.size = size
	panel.size = Vector2(865,530)
	panel.position = (size - panel.size) * 0.5
	toggle_button.size = Vector2(124,54)
	toggle_button.position = Vector2(size.x - 142.0, size.y - 330.0)

func toggle_inventory() -> void:
	var next := not panel.visible
	panel.visible = next
	overlay.visible = next
	if next:
		_refresh_contents()

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
	for id in ["wood","stone","fiber","food","water","bandage","ammo_9mm","shells"]:
		var amount := int(snapshot.get(id,0))
		if amount <= 0:
			continue
		_add_item_row(str(id), amount)
		shown_items += 1
	if shown_items == 0:
		var empty := Label.new()
		empty.text = "Mochila vazia"
		empty.modulate = Color(0.75,0.76,0.72,0.8)
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
		var id := str(raw_id)
		_add_weapon_row(id, id == equipped)

	if player.has_method("get_craft_recipes"):
		var raw_recipes: Variant = player.call("get_craft_recipes")
		if raw_recipes is Array:
			for raw_recipe in raw_recipes as Array:
				if raw_recipe is Dictionary:
					_add_craft_row(raw_recipe as Dictionary)
	if crafts_box.get_child_count() == 0:
		var none := Label.new()
		none.text = "Nada para fabricar agora"
		none.modulate = Color(0.75,0.76,0.72,0.8)
		crafts_box.add_child(none)

func _clear_box(box: VBoxContainer) -> void:
	for child in box.get_children():
		child.queue_free()

func _add_item_row(id: String, amount: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(245,34)
	var label := Label.new()
	label.text = "%s  x%d" % [ITEM_NAMES.get(id,id), amount]
	label.custom_minimum_size = Vector2(155,32)
	row.add_child(label)
	if id in ["food","water","bandage"]:
		var use := Button.new()
		use.text = "USAR"
		use.custom_minimum_size = Vector2(72,32)
		use.pressed.connect(_on_use_item.bind(id))
		row.add_child(use)
	items_box.add_child(row)

func _add_weapon_row(id: String, equipped: bool) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(255,42)
	var label := Label.new()
	label.text = "%s%s" % [WEAPON_NAMES.get(id,id), "  ✓" if equipped else ""]
	label.custom_minimum_size = Vector2(150,38)
	row.add_child(label)
	var equip := Button.new()
	equip.text = "ATIVO" if equipped else "EQUIPAR"
	equip.disabled = equipped
	equip.custom_minimum_size = Vector2(92,38)
	equip.pressed.connect(_on_equip_weapon.bind(id))
	row.add_child(equip)
	weapons_box.add_child(row)

func _add_craft_row(recipe: Dictionary) -> void:
	var recipe_id := str(recipe.get("id", ""))
	var container := VBoxContainer.new()
	container.custom_minimum_size = Vector2(245,82)
	var name_label := Label.new()
	name_label.text = str(recipe.get("name", recipe_id))
	name_label.add_theme_font_size_override("font_size", 15)
	container.add_child(name_label)
	var req := recipe.get("requirements", {}) as Dictionary
	var parts: Array[String] = []
	for raw_id in req.keys():
		var item_id := str(raw_id)
		parts.append("%s x%d" % [ITEM_NAMES.get(item_id,item_id), int(req[raw_id])])
	var req_label := Label.new()
	req_label.text = " + ".join(parts)
	req_label.modulate = Color(0.82,0.78,0.67,0.9)
	container.add_child(req_label)
	var craft := Button.new()
	craft.text = "FABRICAR"
	craft.custom_minimum_size = Vector2(110,34)
	if player != null and player.has_method("can_craft"):
		craft.disabled = not bool(player.call("can_craft", recipe_id))
	craft.pressed.connect(_on_craft.bind(recipe_id))
	container.add_child(craft)
	crafts_box.add_child(container)

func _on_use_item(id: String) -> void:
	if player != null and player.has_method("use_inventory_item"):
		player.call("use_inventory_item", id)
		_refresh_contents()

func _on_equip_weapon(id: String) -> void:
	if player != null and player.has_method("equip_weapon"):
		player.call("equip_weapon", id)
		_refresh_contents()

func _on_craft(recipe_id: String) -> void:
	if player != null and player.has_method("craft_recipe"):
		player.call("craft_recipe", recipe_id)
		_refresh_contents()

func is_inventory_open() -> bool:
	return panel != null and panel.visible
