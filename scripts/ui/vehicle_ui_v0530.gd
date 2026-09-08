class_name VehicleUIV0530
extends CanvasLayer

const TRUNK_ITEMS_0530 := [
	"wood", "stone", "fiber", "plank", "cordage", "stone_blade", "repair_kit",
	"food", "water", "dirty_water", "bandage", "antiseptic", "ammo_9mm", "shells", "gasoline"
]
const ITEM_NAMES_0530 := {
	"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra", "plank":"Tábuas", "cordage":"Corda",
	"stone_blade":"Lâmina pedra", "repair_kit":"Kit reparo", "food":"Comida", "water":"Água segura",
	"dirty_water":"Água bruta", "bandage":"Bandagem", "antiseptic":"Antisséptico",
	"ammo_9mm":"Munição 9mm", "shells":"Cartuchos", "gasoline":"Gasolina"
}

var world: Node = null
var player: Node = null
var overlay_0530: ColorRect
var panel_0530: Panel
var title_0530: Label
var status_0530: Label
var drive_button_0530: Button
var refuel_button_0530: Button
var repair_button_0530: Button
var rows_0530: VBoxContainer
var active_uid_0530 := ""
var refresh_timer_0530 := 0.0
var trunk_signature_05321 := ""

func _ready() -> void:
	layer = 27
	add_to_group("vehicle_ui_0530")
	_build_ui_0530()
	get_viewport().size_changed.connect(_refresh_layout_0530)
	_refresh_layout_0530()

func _process(delta: float) -> void:
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if panel_0530 != null and panel_0530.visible:
		refresh_timer_0530 += delta
		if refresh_timer_0530 >= 0.18:
			refresh_timer_0530 = 0.0
			_refresh_0530()

func _build_ui_0530() -> void:
	overlay_0530 = ColorRect.new()
	overlay_0530.color = Color(0.01, 0.012, 0.01, 0.74)
	overlay_0530.visible = false
	overlay_0530.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay_0530)

	panel_0530 = Panel.new()
	panel_0530.visible = false
	panel_0530.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel_0530)

	title_0530 = Label.new()
	title_0530.position = Vector2(20, 14)
	title_0530.size = Vector2(520, 30)
	title_0530.add_theme_font_size_override("font_size", 20)
	panel_0530.add_child(title_0530)

	status_0530 = Label.new()
	status_0530.position = Vector2(20, 48)
	status_0530.size = Vector2(710, 58)
	status_0530.add_theme_font_size_override("font_size", 12)
	status_0530.modulate = Color(0.88, 0.82, 0.66, 0.98)
	panel_0530.add_child(status_0530)

	drive_button_0530 = Button.new()
	drive_button_0530.text = "DIRIGIR"
	drive_button_0530.position = Vector2(20, 112)
	drive_button_0530.size = Vector2(125, 44)
	drive_button_0530.pressed.connect(_drive_0530)
	panel_0530.add_child(drive_button_0530)

	refuel_button_0530 = Button.new()
	refuel_button_0530.text = "+1L GASOLINA"
	refuel_button_0530.position = Vector2(154, 112)
	refuel_button_0530.size = Vector2(145, 44)
	refuel_button_0530.add_theme_font_size_override("font_size", 10)
	refuel_button_0530.pressed.connect(_refuel_0530)
	panel_0530.add_child(refuel_button_0530)

	repair_button_0530 = Button.new()
	repair_button_0530.text = "REPARAR"
	repair_button_0530.position = Vector2(308, 112)
	repair_button_0530.size = Vector2(125, 44)
	repair_button_0530.pressed.connect(_repair_0530)
	panel_0530.add_child(repair_button_0530)

	var close := Button.new()
	close.text = "FECHAR"
	close.position = Vector2(624, 14)
	close.size = Vector2(96, 42)
	close.pressed.connect(close_vehicle_0530)
	panel_0530.add_child(close)

	var header := Label.new()
	header.text = "PORTA-MALAS                 MOCHILA     CARRO        TRANSFERIR"
	header.position = Vector2(22, 174)
	header.add_theme_font_size_override("font_size", 11)
	header.modulate = Color(0.74, 0.77, 0.70, 0.86)
	panel_0530.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(18, 198)
	scroll.size = Vector2(704, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_0530.add_child(scroll)

	rows_0530 = VBoxContainer.new()
	rows_0530.custom_minimum_size = Vector2(684, 520)
	rows_0530.add_theme_constant_override("separation", 4)
	scroll.add_child(rows_0530)

func _refresh_layout_0530() -> void:
	var size := get_viewport().get_visible_rect().size
	overlay_0530.position = Vector2.ZERO
	overlay_0530.size = size
	panel_0530.size = Vector2(744, 520)
	panel_0530.position = (size - panel_0530.size) * 0.5

func open_vehicle_0530(uid: String) -> void:
	if uid == "":
		return
	active_uid_0530 = uid
	trunk_signature_05321 = ""
	panel_0530.visible = true
	overlay_0530.visible = true
	_refresh_0530()

func close_vehicle_0530() -> void:
	panel_0530.visible = false
	overlay_0530.visible = false
	active_uid_0530 = ""
	trunk_signature_05321 = ""

func _refresh_0530() -> void:
	if active_uid_0530 == "" or world == null or player == null or not world.has_method("get_vehicle_status_0530"):
		return
	var data := world.call("get_vehicle_status_0530", active_uid_0530) as Dictionary
	if data.is_empty() or not bool(data.get("near", false)):
		close_vehicle_0530()
		return
	var fuel := float(data.get("fuel", 0.0))
	var max_fuel := float(data.get("max_fuel", 0.0))
	var health := float(data.get("health", 0.0))
	var max_health := float(data.get("max_health", 100.0))
	var trunk_total := int(data.get("trunk_total", 0))
	var trunk_capacity := int(data.get("trunk_capacity", 0))
	title_0530.text = str(data.get("name", "VEÍCULO")).to_upper()
	status_0530.text = "COMBUSTÍVEL %.1f / %.0f L   •   INTEGRIDADE %d / %d\nPORTA-MALAS %d / %d   •   Gasolina mochila %dL   •   Kits reparo %d" % [fuel, max_fuel, int(round(health)), int(round(max_health)), trunk_total, trunk_capacity, int(data.get("backpack_gasoline", 0)), int(data.get("backpack_repair_kits", 0))]
	drive_button_0530.disabled = not bool(data.get("drivable", false))
	drive_button_0530.text = "DIRIGIR" if bool(data.get("drivable", false)) else "IMOBILIZADO"
	refuel_button_0530.disabled = int(data.get("variant", 8)) == 8 or int(data.get("backpack_gasoline", 0)) <= 0 or fuel >= max_fuel - 0.99
	repair_button_0530.disabled = int(data.get("variant", 8)) == 8 or int(data.get("backpack_repair_kits", 0)) <= 0 or health >= max_health - 0.01
	_refresh_trunk_0530(data)

func _trunk_signature_for_05321(backpack: Dictionary, trunk: Dictionary, total: int, capacity: int) -> String:
	var parts: Array[String] = [str(total), str(capacity)]
	for item_id in TRUNK_ITEMS_0530:
		parts.append("%s:%d:%d" % [item_id, int(backpack.get(item_id, 0)), int(trunk.get(item_id, 0))])
	return "|".join(parts)

func _refresh_trunk_0530(data: Dictionary) -> void:
	var backpack: Dictionary = {}
	if player.has_method("get_inventory_snapshot"):
		backpack = player.call("get_inventory_snapshot") as Dictionary
	var trunk := data.get("trunk", {}) as Dictionary
	var total := int(data.get("trunk_total", 0))
	var capacity := int(data.get("trunk_capacity", 0))
	var next_signature := _trunk_signature_for_05321(backpack, trunk, total, capacity)
	if next_signature == trunk_signature_05321:
		return
	trunk_signature_05321 = next_signature

	for child in rows_0530.get_children():
		child.queue_free()
	for item_id in TRUNK_ITEMS_0530:
		var backpack_amount := int(backpack.get(item_id, 0))
		var trunk_amount := int(trunk.get(item_id, 0))
		if backpack_amount <= 0 and trunk_amount <= 0:
			continue
		_add_trunk_row_0530(item_id, backpack_amount, trunk_amount, total < capacity)
	if rows_0530.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "Porta-malas vazio e nenhum item transferível na mochila."
		empty.modulate = Color(0.75, 0.77, 0.72, 0.82)
		rows_0530.add_child(empty)

func _add_trunk_row_0530(item_id: String, backpack_amount: int, trunk_amount: int, can_deposit: bool) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(680, 34)
	var name_label := Label.new()
	name_label.text = str(ITEM_NAMES_0530.get(item_id, item_id))
	name_label.custom_minimum_size = Vector2(250, 32)
	name_label.add_theme_font_size_override("font_size", 12)
	row.add_child(name_label)
	var backpack_label := Label.new()
	backpack_label.text = "x%d" % backpack_amount
	backpack_label.custom_minimum_size = Vector2(88, 32)
	row.add_child(backpack_label)
	var trunk_label := Label.new()
	trunk_label.text = "x%d" % trunk_amount
	trunk_label.custom_minimum_size = Vector2(80, 32)
	row.add_child(trunk_label)
	var deposit := Button.new()
	deposit.text = "> 1"
	deposit.custom_minimum_size = Vector2(72, 30)
	deposit.disabled = backpack_amount <= 0 or not can_deposit
	deposit.button_down.connect(_deposit_0530.bind(item_id))
	row.add_child(deposit)
	var withdraw := Button.new()
	withdraw.text = "< 1"
	withdraw.custom_minimum_size = Vector2(72, 30)
	withdraw.disabled = trunk_amount <= 0
	withdraw.button_down.connect(_withdraw_0530.bind(item_id))
	row.add_child(withdraw)
	rows_0530.add_child(row)

func _drive_0530() -> void:
	if world != null and player != null and world.has_method("enter_vehicle_by_uid_0530"):
		if bool(world.call("enter_vehicle_by_uid_0530", active_uid_0530, player)):
			close_vehicle_0530()

func _refuel_0530() -> void:
	if world != null and player != null and world.has_method("vehicle_refuel_0530"):
		world.call("vehicle_refuel_0530", active_uid_0530, player)
	_refresh_0530()

func _repair_0530() -> void:
	if world != null and player != null and world.has_method("vehicle_repair_0530"):
		world.call("vehicle_repair_0530", active_uid_0530, player)
	_refresh_0530()

func _deposit_0530(item_id: String) -> void:
	if world != null and player != null and world.has_method("vehicle_trunk_deposit_0530"):
		if bool(world.call("vehicle_trunk_deposit_0530", active_uid_0530, item_id, 1, player)):
			trunk_signature_05321 = ""
	_refresh_0530()

func _withdraw_0530(item_id: String) -> void:
	if world != null and player != null and world.has_method("vehicle_trunk_withdraw_0530"):
		if bool(world.call("vehicle_trunk_withdraw_0530", active_uid_0530, item_id, 1, player)):
			trunk_signature_05321 = ""
	_refresh_0530()

func get_vehicle_ui_debug_0530() -> Dictionary:
	return {
		"panel": panel_0530 != null,
		"open": panel_0530 != null and panel_0530.visible,
		"uid": active_uid_0530,
		"drive": drive_button_0530 != null,
		"refuel": refuel_button_0530 != null,
		"repair": repair_button_0530 != null,
		"touch_transfer_05321": true,
		"signature_cache_05321": trunk_signature_05321
	}
