class_name InventoryUI
extends CanvasLayer

var player: Node = null
var overlay: ColorRect
var panel: Panel
var items_box: VBoxContainer
var weapons_box: VBoxContainer
var toggle_button: Button
var refresh_timer := 0.0

const ITEM_NAMES := {
	"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra",
	"food":"Comida", "water":"Água", "bandage":"Bandagem",
	"ammo_9mm":"Munição 9mm", "shells":"Cartuchos"
}

const WEAPON_NAMES := {
	"machete":"Facão", "pistol":"Pistola 9mm", "shotgun":"Espingarda"
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
		if refresh_timer >= 0.35:
			refresh_timer = 0.0
			_refresh_contents()

func _build_ui() -> void:
	overlay = ColorRect.new()
	overlay.color = Color(0.015,0.018,0.014,0.72)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	panel = Panel.new()
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := Label.new()
	title.text = "MOCHILA E EQUIPAMENTO"
	title.position = Vector2(22,16)
	title.add_theme_font_size_override("font_size", 22)
	panel.add_child(title)

	var close := Button.new()
	close.text = "FECHAR"
	close.position = Vector2(565,12)
	close.size = Vector2(90,40)
	close.pressed.connect(toggle_inventory)
	panel.add_child(close)

	var items_title := Label.new()
	items_title.text = "ITENS"
	items_title.position = Vector2(24,64)
	items_title.add_theme_font_size_override("font_size", 17)
	panel.add_child(items_title)

	items_box = VBoxContainer.new()
	items_box.position = Vector2(24,92)
	items_box.size = Vector2(305,350)
	items_box.add_theme_constant_override("separation", 5)
	panel.add_child(items_box)

	var weapons_title := Label.new()
	weapons_title.text = "ARMAS / EQUIPADO"
	weapons_title.position = Vector2(355,64)
	weapons_title.add_theme_font_size_override("font_size", 17)
	panel.add_child(weapons_title)

	weapons_box = VBoxContainer.new()
	weapons_box.position = Vector2(355,92)
	weapons_box.size = Vector2(300,260)
	weapons_box.add_theme_constant_override("separation", 8)
	panel.add_child(weapons_box)

	var help := Label.new()
	help.text = "Toque em USAR para consumir • EQUIPAR troca a arma ativa"
	help.position = Vector2(24,447)
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
	panel.size = Vector2(680,500)
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
	for child in items_box.get_children():
		child.queue_free()
	for child in weapons_box.get_children():
		child.queue_free()

	var snapshot: Dictionary = {}
	if player.has_method("get_inventory_snapshot"):
		var raw_snapshot: Variant = player.call("get_inventory_snapshot")
		if raw_snapshot is Dictionary:
			snapshot = raw_snapshot as Dictionary
	for id in ["wood","stone","fiber","food","water","bandage","ammo_9mm","shells"]:
		_add_item_row(str(id), int(snapshot.get(id,0)))

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

func _add_item_row(id: String, amount: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(300,34)
	var label := Label.new()
	label.text = "%s  x%d" % [ITEM_NAMES.get(id,id), amount]
	label.custom_minimum_size = Vector2(205,32)
	row.add_child(label)
	if id in ["food","water","bandage"]:
		var use := Button.new()
		use.text = "USAR"
		use.disabled = amount <= 0
		use.custom_minimum_size = Vector2(78,32)
		use.pressed.connect(_on_use_item.bind(id))
		row.add_child(use)
	items_box.add_child(row)

func _add_weapon_row(id: String, equipped: bool) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(295,42)
	var label := Label.new()
	label.text = "%s%s" % [WEAPON_NAMES.get(id,id), "  [EQUIPADO]" if equipped else ""]
	label.custom_minimum_size = Vector2(185,38)
	row.add_child(label)
	var equip := Button.new()
	equip.text = "ATIVO" if equipped else "EQUIPAR"
	equip.disabled = equipped
	equip.custom_minimum_size = Vector2(92,38)
	equip.pressed.connect(_on_equip_weapon.bind(id))
	row.add_child(equip)
	weapons_box.add_child(row)

func _on_use_item(id: String) -> void:
	if player != null and player.has_method("use_inventory_item"):
		player.call("use_inventory_item", id)
		_refresh_contents()

func _on_equip_weapon(id: String) -> void:
	if player != null and player.has_method("equip_weapon"):
		player.call("equip_weapon", id)
		_refresh_contents()

func is_inventory_open() -> bool:
	return panel != null and panel.visible
