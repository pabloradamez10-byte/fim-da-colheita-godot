class_name HotbarUIV0523
extends CanvasLayer

const SLOT_COUNT_0523 := 6
const SLOT_WIDTH_0523 := 90.0
const SLOT_HEIGHT_0523 := 66.0
const SLOT_GAP_0523 := 6.0
const NAMES_0523 := {
	"machete": "FACÃO",
	"axe": "MACHADO",
	"spear": "LANÇA",
	"pistol": "9MM",
	"shotgun": "12GA",
	"bandage": "BANDAGEM",
	"water": "ÁGUA",
	"food": "COMIDA",
	"antiseptic": "ANTISSÉP."
}

var player: Node = null
var panel: Panel
var row: HBoxContainer
var buttons: Array[Button] = []
var slots_0523: Array[Dictionary] = []
var refresh_timer_0523 := 0.0

func _ready() -> void:
	layer = 12
	_build_hotbar_0523()
	get_viewport().size_changed.connect(_refresh_layout_0523)
	_refresh_layout_0523()

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	refresh_timer_0523 += delta
	if refresh_timer_0523 >= 0.16:
		refresh_timer_0523 = 0.0
		_refresh_slots_0523()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var index := -1
	match key_event.keycode:
		KEY_1: index = 0
		KEY_2: index = 1
		KEY_3: index = 2
		KEY_4: index = 3
		KEY_5: index = 4
		KEY_6: index = 5
	if index >= 0:
		_activate_slot_0523(index)

func _build_hotbar_0523() -> void:
	panel = Panel.new()
	panel.name = "HotbarPanel0523"
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(panel)

	row = HBoxContainer.new()
	row.name = "HotbarRow0523"
	row.add_theme_constant_override("separation", int(SLOT_GAP_0523))
	panel.add_child(row)

	for i in range(SLOT_COUNT_0523):
		var button := Button.new()
		button.name = "HotbarSlot%d" % (i + 1)
		button.custom_minimum_size = Vector2(SLOT_WIDTH_0523, SLOT_HEIGHT_0523)
		button.add_theme_font_size_override("font_size", 11)
		button.text = "%d\n—" % (i + 1)
		button.disabled = true
		button.pressed.connect(_activate_slot_0523.bind(i))
		button.add_to_group("hotbar_slot_0523")
		row.add_child(button)
		buttons.append(button)

func _refresh_layout_0523() -> void:
	if panel == null or row == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var content_width := SLOT_WIDTH_0523 * SLOT_COUNT_0523 + SLOT_GAP_0523 * float(SLOT_COUNT_0523 - 1)
	panel.size = Vector2(content_width + 16.0, SLOT_HEIGHT_0523 + 14.0)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, viewport_size.y - panel.size.y - 8.0)
	row.position = Vector2(8.0, 7.0)
	row.size = Vector2(content_width, SLOT_HEIGHT_0523)

func _refresh_slots_0523() -> void:
	if player == null or not player.has_method("get_hotbar_slots_0523"):
		return
	var raw: Variant = player.call("get_hotbar_slots_0523")
	if not (raw is Array):
		return
	slots_0523.clear()
	for entry in raw as Array:
		if entry is Dictionary:
			slots_0523.append((entry as Dictionary).duplicate(true))

	for i in range(buttons.size()):
		var button := buttons[i]
		if i >= slots_0523.size():
			button.text = "%d\n—" % (i + 1)
			button.disabled = true
			button.modulate = Color(0.72, 0.72, 0.70, 0.55)
			continue
		var slot := slots_0523[i]
		var id := str(slot.get("id", ""))
		var kind := str(slot.get("kind", ""))
		var name_text := str(NAMES_0523.get(id, id.to_upper()))
		var detail := ""
		if kind == "weapon":
			var durability := int(slot.get("durability", 0))
			var broken := bool(slot.get("broken", false))
			var count := int(slot.get("count", -1))
			if broken:
				detail = "QUEBRADA"
			elif count >= 0:
				detail = "D%d%% • x%d" % [durability, count]
			else:
				detail = "DUR %d%%" % durability
			button.modulate = Color(1.0, 0.82, 0.70, 1.0) if broken else (Color(1.0, 0.91, 0.62, 1.0) if bool(slot.get("equipped", false)) else Color.WHITE)
		else:
			detail = "x%d" % int(slot.get("count", 0))
			button.modulate = Color.WHITE
		button.text = "%d  %s\n%s" % [i + 1, name_text, detail]
		button.disabled = false

func _activate_slot_0523(index: int) -> void:
	if player == null or not player.has_method("hotbar_activate_0523"):
		return
	if index < 0 or index >= slots_0523.size():
		return
	var id := str(slots_0523[index].get("id", ""))
	if id == "":
		return
	player.call("hotbar_activate_0523", id)
	_refresh_slots_0523()

func get_hotbar_debug_0523() -> Dictionary:
	return {
		"slots": slots_0523.duplicate(true),
		"buttons": buttons.size(),
		"visible_slots": slots_0523.size(),
		"panel": panel != null
	}
