class_name StorageUIV0526
extends CanvasLayer

const STORAGE_ITEMS_0526 := [
	"wood", "stone", "fiber", "plank", "cordage", "stone_blade", "repair_kit",
	"food", "water", "bandage", "antiseptic", "ammo_9mm", "shells"
]
const ITEM_NAMES_0526 := {
	"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra",
	"plank":"Tábuas", "cordage":"Corda", "stone_blade":"Lâmina pedra", "repair_kit":"Kit reparo",
	"food":"Comida", "water":"Água", "bandage":"Bandagem", "antiseptic":"Antisséptico",
	"ammo_9mm":"Munição 9mm", "shells":"Cartuchos"
}

var world: Node = null
var player: Node = null
var overlay_0526: ColorRect
var panel_0526: Panel
var title_0526: Label
var capacity_0526: Label
var rows_0526: VBoxContainer
var active_uid_0526 := ""
var refresh_timer_0526 := 0.0

func _ready() -> void:
	layer = 25
	add_to_group("storage_ui_0526")
	_build_ui_0526()
	get_viewport().size_changed.connect(_refresh_layout_0526)
	_refresh_layout_0526()

func _process(delta: float) -> void:
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if panel_0526.visible:
		refresh_timer_0526 += delta
		if refresh_timer_0526 >= 0.22:
			refresh_timer_0526 = 0.0
			_refresh_contents_0526()

func _build_ui_0526() -> void:
	overlay_0526 = ColorRect.new()
	overlay_0526.color = Color(0.012, 0.015, 0.012, 0.72)
	overlay_0526.visible = false
	overlay_0526.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay_0526)

	panel_0526 = Panel.new()
	panel_0526.visible = false
	panel_0526.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel_0526)

	title_0526 = Label.new()
	title_0526.text = "CAIXA DE ARMAZENAMENTO"
	title_0526.position = Vector2(20, 14)
	title_0526.add_theme_font_size_override("font_size", 20)
	panel_0526.add_child(title_0526)

	capacity_0526 = Label.new()
	capacity_0526.position = Vector2(20, 48)
	capacity_0526.size = Vector2(500, 24)
	capacity_0526.add_theme_font_size_override("font_size", 12)
	capacity_0526.modulate = Color(0.88, 0.78, 0.52, 0.95)
	panel_0526.add_child(capacity_0526)

	var close := Button.new()
	close.text = "FECHAR"
	close.position = Vector2(616, 12)
	close.size = Vector2(92, 42)
	close.pressed.connect(close_storage_0526)
	panel_0526.add_child(close)

	var header := Label.new()
	header.text = "ITEM                         MOCHILA     CAIXA           TRANSFERIR"
	header.position = Vector2(22, 77)
	header.add_theme_font_size_override("font_size", 11)
	header.modulate = Color(0.74, 0.77, 0.70, 0.85)
	panel_0526.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(18, 104)
	scroll.size = Vector2(690, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_0526.add_child(scroll)

	rows_0526 = VBoxContainer.new()
	rows_0526.custom_minimum_size = Vector2(670, 520)
	rows_0526.add_theme_constant_override("separation", 4)
	scroll.add_child(rows_0526)

func _refresh_layout_0526() -> void:
	var size := get_viewport().get_visible_rect().size
	overlay_0526.position = Vector2.ZERO
	overlay_0526.size = size
	panel_0526.size = Vector2(730, 485)
	panel_0526.position = (size - panel_0526.size) * 0.5

func open_storage_0526(uid: String) -> void:
	if uid == "":
		return
	active_uid_0526 = uid
	panel_0526.visible = true
	overlay_0526.visible = true
	_refresh_contents_0526()

func close_storage_0526() -> void:
	panel_0526.visible = false
	overlay_0526.visible = false
	active_uid_0526 = ""

func _refresh_contents_0526() -> void:
	if active_uid_0526 == "" or world == null or player == null:
		return
	for child in rows_0526.get_children():
		child.queue_free()
	var backpack: Dictionary = {}
	if player.has_method("get_inventory_snapshot"):
		backpack = player.call("get_inventory_snapshot") as Dictionary
	var storage: Dictionary = {}
	if world.has_method("get_storage_snapshot_0526"):
		storage = world.call("get_storage_snapshot_0526", active_uid_0526) as Dictionary
	var total := 0
	var capacity := 60
	if world.has_method("get_storage_total_0526"):
		total = int(world.call("get_storage_total_0526", active_uid_0526))
	if world.has_method("get_storage_capacity_0526"):
		capacity = int(world.call("get_storage_capacity_0526", active_uid_0526))
	capacity_0526.text = "CAPACIDADE  %d / %d unidades" % [total, capacity]

	for item_id in STORAGE_ITEMS_0526:
		var backpack_amount := int(backpack.get(item_id, 0))
		var storage_amount := int(storage.get(item_id, 0))
		if backpack_amount <= 0 and storage_amount <= 0:
			continue
		_add_row_0526(item_id, backpack_amount, storage_amount, total < capacity)
	if rows_0526.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "Caixa vazia e nenhum item transferível na mochila."
		empty.modulate = Color(0.75, 0.77, 0.72, 0.82)
		rows_0526.add_child(empty)

func _add_row_0526(item_id: String, backpack_amount: int, storage_amount: int, can_deposit: bool) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(665, 34)
	var name := Label.new()
	name.text = str(ITEM_NAMES_0526.get(item_id, item_id))
	name.custom_minimum_size = Vector2(250, 32)
	name.add_theme_font_size_override("font_size", 12)
	row.add_child(name)
	var backpack := Label.new()
	backpack.text = "x%d" % backpack_amount
	backpack.custom_minimum_size = Vector2(88, 32)
	row.add_child(backpack)
	var box := Label.new()
	box.text = "x%d" % storage_amount
	box.custom_minimum_size = Vector2(80, 32)
	row.add_child(box)
	var deposit := Button.new()
	deposit.text = "> 1"
	deposit.custom_minimum_size = Vector2(72, 30)
	deposit.disabled = backpack_amount <= 0 or not can_deposit
	deposit.pressed.connect(_deposit_0526.bind(item_id))
	row.add_child(deposit)
	var withdraw := Button.new()
	withdraw.text = "< 1"
	withdraw.custom_minimum_size = Vector2(72, 30)
	withdraw.disabled = storage_amount <= 0
	withdraw.pressed.connect(_withdraw_0526.bind(item_id))
	row.add_child(withdraw)
	rows_0526.add_child(row)

func _deposit_0526(item_id: String) -> void:
	if world != null and world.has_method("storage_deposit_0526"):
		world.call("storage_deposit_0526", active_uid_0526, item_id, 1, player)
	_refresh_contents_0526()

func _withdraw_0526(item_id: String) -> void:
	if world != null and world.has_method("storage_withdraw_0526"):
		world.call("storage_withdraw_0526", active_uid_0526, item_id, 1, player)
	_refresh_contents_0526()

func is_storage_open_0526() -> bool:
	return panel_0526 != null and panel_0526.visible

func get_storage_ui_debug_0526() -> Dictionary:
	return {
		"panel": panel_0526 != null,
		"open": panel_0526 != null and panel_0526.visible,
		"uid": active_uid_0526,
		"rows": rows_0526.get_child_count() if rows_0526 != null else 0
	}
