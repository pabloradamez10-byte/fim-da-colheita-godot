extends "res://scripts/ui/inventory_ui_v0532.gd"

const CLOTHING_ORDER_0533 := [
	"baseball_cap", "motorcycle_helmet", "tshirt", "hoodie", "rain_jacket",
	"work_gloves", "jeans", "cargo_pants", "sneakers", "work_boots",
	"school_backpack", "hiking_backpack"
]

var equipment_scroll_0533: ScrollContainer
var equipment_box_0533: VBoxContainer
var equipment_stats_0533: Label

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0533")
	_build_equipment_ui_0533()
	_refresh_layout()

func _refresh_layout() -> void:
	super._refresh_layout()
	if panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var desired := Vector2(1160.0, 580.0)
	var scale_factor := minf(1.0, minf((viewport_size.x - 28.0) / desired.x, (viewport_size.y - 28.0) / desired.y))
	scale_factor = maxf(0.72, scale_factor)
	panel.size = desired
	panel.scale = Vector2(scale_factor, scale_factor)
	panel.position = (viewport_size - desired * scale_factor) * 0.5
	if overlay != null:
		overlay.position = Vector2.ZERO
		overlay.size = viewport_size

func _build_equipment_ui_0533() -> void:
	if panel == null:
		return
	for child: Node in panel.get_children():
		if child is Button and (child as Button).text == "FECHAR":
			(child as Button).position = Vector2(1048, 12)
			(child as Button).size = Vector2(88, 40)
		elif child is Label and (child as Label).text == "MOCHILA • EQUIPAMENTO • CRAFT":
			(child as Label).text = "MOCHILA • ARMAS • CRAFT • VESTUÁRIO"

	var title := Label.new()
	title.name = "BodyEquipmentTitle0533"
	title.text = "VESTUÁRIO"
	title.position = Vector2(875, 64)
	title.add_theme_font_size_override("font_size", 17)
	panel.add_child(title)

	equipment_scroll_0533 = ScrollContainer.new()
	equipment_scroll_0533.name = "BodyEquipmentScroll0533"
	equipment_scroll_0533.position = Vector2(870, 90)
	equipment_scroll_0533.size = Vector2(268, 392)
	equipment_scroll_0533.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(equipment_scroll_0533)

	equipment_box_0533 = VBoxContainer.new()
	equipment_box_0533.name = "BodyEquipmentBox0533"
	equipment_box_0533.custom_minimum_size = Vector2(248, 760)
	equipment_box_0533.add_theme_constant_override("separation", 5)
	equipment_scroll_0533.add_child(equipment_box_0533)

	equipment_stats_0533 = Label.new()
	equipment_stats_0533.name = "BodyEquipmentStats0533"
	equipment_stats_0533.position = Vector2(872, 490)
	equipment_stats_0533.size = Vector2(266, 78)
	equipment_stats_0533.add_theme_font_size_override("font_size", 10)
	equipment_stats_0533.modulate = Color(0.88, 0.78, 0.48, 0.97)
	panel.add_child(equipment_stats_0533)
	_refresh_equipment_0533()

func _refresh_contents() -> void:
	super._refresh_contents()
	_refresh_equipment_0533()

func _clear_equipment_box_0533() -> void:
	if equipment_box_0533 == null:
		return
	for child: Node in equipment_box_0533.get_children():
		equipment_box_0533.remove_child(child)
		child.queue_free()

func _refresh_equipment_0533() -> void:
	if equipment_box_0533 == null or equipment_stats_0533 == null:
		return
	_clear_equipment_box_0533()
	if player == null or not player.has_method("get_equipment_snapshot_0533"):
		equipment_stats_0533.text = "Sistema corporal indisponível"
		return
	var equipped := player.call("get_equipment_snapshot_0533") as Dictionary
	var defs := player.call("get_clothing_defs_0533") as Dictionary
	var slots := player.call("get_slot_names_0533") as Dictionary
	var snapshot := player.call("get_inventory_snapshot") as Dictionary

	var worn_title := Label.new()
	worn_title.text = "NO CORPO"
	worn_title.add_theme_font_size_override("font_size", 11)
	worn_title.modulate = Color(0.92, 0.72, 0.34, 1.0)
	equipment_box_0533.add_child(worn_title)
	for slot in ["head", "torso", "hands", "legs", "feet", "back"]:
		_add_equipped_slot_0533(slot, str(slots.get(slot, slot)), str(equipped.get(slot, "")), defs)

	var bag_title := Label.new()
	bag_title.text = "NA MOCHILA"
	bag_title.add_theme_font_size_override("font_size", 11)
	bag_title.modulate = Color(0.77, 0.85, 0.65, 0.95)
	equipment_box_0533.add_child(bag_title)
	var available := 0
	for item_id in CLOTHING_ORDER_0533:
		var amount := int(snapshot.get(item_id, 0))
		if amount <= 0 or not defs.has(item_id):
			continue
		available += 1
		_add_clothing_item_0533(item_id, amount, defs[item_id] as Dictionary)
	if available == 0:
		var empty := Label.new()
		empty.text = "Nenhuma roupa solta. Procure quartos e guarda-roupas."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.custom_minimum_size = Vector2(238, 42)
		empty.add_theme_font_size_override("font_size", 9)
		empty.modulate = Color(0.72, 0.74, 0.70, 0.82)
		equipment_box_0533.add_child(empty)

	var stats := player.call("get_equipment_stats_0533") as Dictionary
	equipment_stats_0533.text = "PROTEÇÃO  Mordida %d%% • Corte %d%%\nCLIMA  Frio %d%% • Chuva %d%%\nPESO %.1f kg • Carga extra %.0f kg" % [int(round(float(stats.get("bite", 0.0)))), int(round(float(stats.get("cut", 0.0)))), int(round(float(stats.get("cold", 0.0)))), int(round(float(stats.get("rain", 0.0)))), float(stats.get("weight", 0.0)), float(stats.get("carry_bonus", 0.0))]

func _add_equipped_slot_0533(slot: String, slot_name: String, item_id: String, defs: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(242, 30)
	var label := Label.new()
	var item_name := "VAZIO"
	if item_id != "" and defs.has(item_id):
		item_name = str((defs[item_id] as Dictionary).get("name", item_id))
	label.text = "%s: %s" % [slot_name, item_name]
	label.custom_minimum_size = Vector2(168, 28)
	label.add_theme_font_size_override("font_size", 9)
	row.add_child(label)
	if item_id != "":
		var remove := Button.new()
		remove.text = "TIRAR"
		remove.custom_minimum_size = Vector2(62, 28)
		remove.add_theme_font_size_override("font_size", 8)
		remove.button_down.connect(_unequip_0533.bind(slot))
		row.add_child(remove)
	equipment_box_0533.add_child(row)

func _add_clothing_item_0533(item_id: String, amount: int, data: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(242, 56)
	var row := HBoxContainer.new()
	box.add_child(row)
	var label := Label.new()
	label.text = "%s x%d" % [str(data.get("name", item_id)), amount]
	label.custom_minimum_size = Vector2(164, 28)
	label.add_theme_font_size_override("font_size", 10)
	row.add_child(label)
	var equip := Button.new()
	equip.text = "EQUIP."
	equip.custom_minimum_size = Vector2(66, 28)
	equip.add_theme_font_size_override("font_size", 8)
	equip.button_down.connect(_equip_0533.bind(item_id))
	row.add_child(equip)
	var detail := Label.new()
	detail.text = "M%d C%d • F%d Ch%d • %.1fkg" % [int(data.get("bite", 0)), int(data.get("cut", 0)), int(data.get("cold", 0)), int(data.get("rain", 0)), float(data.get("weight", 0.0))]
	detail.add_theme_font_size_override("font_size", 8)
	detail.modulate = Color(0.72, 0.75, 0.68, 0.88)
	box.add_child(detail)
	equipment_box_0533.add_child(box)

func _equip_0533(item_id: String) -> void:
	if player != null and player.has_method("equip_clothing_0533"):
		player.call("equip_clothing_0533", item_id)
	_refresh_contents()

func _unequip_0533(slot: String) -> void:
	if player != null and player.has_method("unequip_slot_0533"):
		player.call("unequip_slot_0533", slot)
	_refresh_contents()

func get_inventory_ui_debug_0533() -> Dictionary:
	return {
		"group": is_in_group("inventory_ui_0533"),
		"equipment_scroll": equipment_scroll_0533 != null,
		"equipment_box": equipment_box_0533 != null,
		"stats": equipment_stats_0533.text if equipment_stats_0533 != null else "",
		"panel_size": panel.size if panel != null else Vector2.ZERO,
		"panel_scale": panel.scale if panel != null else Vector2.ONE
	}
