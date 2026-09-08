class_name BuildUIV0526
extends CanvasLayer

const PIECES_0526 := ["floor", "wall", "fence", "crate"]
const PIECE_NAMES_0526 := {
	"floor": "PISO",
	"wall": "PAREDE",
	"fence": "CERCA",
	"crate": "CAIXA"
}
const ITEM_NAMES_0526 := {
	"wood": "Madeira",
	"plank": "Tábuas",
	"cordage": "Corda"
}

var world: Node = null
var player: Node = null
var toggle_button_0526: Button
var panel_0526: Panel
var status_label_0526: Label
var place_button_0526: Button
var piece_buttons_0526: Dictionary = {}
var refresh_timer_0526 := 0.0

func _ready() -> void:
	layer = 16
	add_to_group("build_ui_0526")
	_build_ui_0526()
	get_viewport().size_changed.connect(_refresh_layout_0526)
	_refresh_layout_0526()

func _process(delta: float) -> void:
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	refresh_timer_0526 += delta
	if refresh_timer_0526 >= 0.14:
		refresh_timer_0526 = 0.0
		_refresh_ui_0526()

func _build_ui_0526() -> void:
	toggle_button_0526 = Button.new()
	toggle_button_0526.name = "BuildToggle0526"
	toggle_button_0526.text = "CONSTRUIR"
	toggle_button_0526.add_theme_font_size_override("font_size", 12)
	toggle_button_0526.pressed.connect(_toggle_build_0526)
	add_child(toggle_button_0526)

	panel_0526 = Panel.new()
	panel_0526.name = "BuildPanel0526"
	panel_0526.visible = false
	panel_0526.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel_0526)

	var title := Label.new()
	title.text = "CONSTRUÇÃO"
	title.position = Vector2(14, 8)
	title.add_theme_font_size_override("font_size", 16)
	panel_0526.add_child(title)

	var x := 14.0
	for piece_id in PIECES_0526:
		var button := Button.new()
		button.name = "Build_%s_0526" % piece_id
		button.position = Vector2(x, 34)
		button.size = Vector2(105, 48)
		button.add_theme_font_size_override("font_size", 10)
		button.pressed.connect(_select_piece_0526.bind(piece_id))
		panel_0526.add_child(button)
		piece_buttons_0526[piece_id] = button
		x += 112.0

	var rotate := Button.new()
	rotate.text = "GIRAR 90°"
	rotate.position = Vector2(468, 34)
	rotate.size = Vector2(96, 48)
	rotate.add_theme_font_size_override("font_size", 10)
	rotate.pressed.connect(_rotate_0526)
	panel_0526.add_child(rotate)

	place_button_0526 = Button.new()
	place_button_0526.text = "COLOCAR"
	place_button_0526.position = Vector2(572, 34)
	place_button_0526.size = Vector2(92, 48)
	place_button_0526.add_theme_font_size_override("font_size", 11)
	place_button_0526.pressed.connect(_place_0526)
	panel_0526.add_child(place_button_0526)

	var close := Button.new()
	close.text = "SAIR"
	close.position = Vector2(672, 34)
	close.size = Vector2(72, 48)
	close.add_theme_font_size_override("font_size", 10)
	close.pressed.connect(_close_build_0526)
	panel_0526.add_child(close)

	status_label_0526 = Label.new()
	status_label_0526.name = "BuildStatus0526"
	status_label_0526.position = Vector2(14, 91)
	status_label_0526.size = Vector2(730, 38)
	status_label_0526.add_theme_font_size_override("font_size", 11)
	status_label_0526.modulate = Color(0.86, 0.84, 0.75, 0.95)
	panel_0526.add_child(status_label_0526)

func _refresh_layout_0526() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	toggle_button_0526.size = Vector2(124, 48)
	toggle_button_0526.position = Vector2(viewport_size.x - 278.0, viewport_size.y - 330.0)
	panel_0526.size = Vector2(760, 138)
	panel_0526.position = Vector2((viewport_size.x - panel_0526.size.x) * 0.5, viewport_size.y - 244.0)

func _toggle_build_0526() -> void:
	if panel_0526.visible:
		_close_build_0526()
		return
	panel_0526.visible = true
	if world != null and world.has_method("enter_build_mode_0526"):
		world.call("enter_build_mode_0526", "floor")
	_refresh_ui_0526()

func _close_build_0526() -> void:
	panel_0526.visible = false
	if world != null and world.has_method("cancel_build_mode_0526"):
		world.call("cancel_build_mode_0526")

func _select_piece_0526(piece_id: String) -> void:
	if world != null and world.has_method("select_build_piece_0526"):
		world.call("select_build_piece_0526", piece_id)
	_refresh_ui_0526()

func _rotate_0526() -> void:
	if world != null and world.has_method("rotate_build_preview_0526"):
		world.call("rotate_build_preview_0526")
	_refresh_ui_0526()

func _place_0526() -> void:
	if world != null and world.has_method("place_build_preview_0526"):
		world.call("place_build_preview_0526")
	_refresh_ui_0526()

func _refresh_ui_0526() -> void:
	if not panel_0526.visible:
		return
	if world == null or not world.has_method("get_build_debug_0526"):
		return
	var debug := world.call("get_build_debug_0526") as Dictionary
	var selected := str(debug.get("piece", "floor"))
	var valid := bool(debug.get("valid", false))
	var yaw := int(round(float(debug.get("yaw", 0.0))))
	var structures := int(debug.get("structures", 0))
	for piece_id in PIECES_0526:
		var button := piece_buttons_0526.get(piece_id) as Button
		if button == null:
			continue
		var cost_text := _cost_text_0526(piece_id)
		button.text = "%s%s\n%s" % ["▶ " if piece_id == selected else "", PIECE_NAMES_0526[piece_id], cost_text]
	place_button_0526.disabled = not valid
	place_button_0526.text = "COLOCAR" if valid else "BLOQUEADO"
	status_label_0526.modulate = Color(0.62, 0.93, 0.62, 0.96) if valid else Color(0.95, 0.54, 0.46, 0.96)
	status_label_0526.text = "%s • rotação %d° • %s • estruturas construídas: %d" % [PIECE_NAMES_0526.get(selected, selected), yaw, "posição válida" if valid else "posição/material insuficiente ou área ocupada", structures]

func _cost_text_0526(piece_id: String) -> String:
	if player == null or not player.has_method("get_build_cost_0526"):
		return "—"
	var cost := player.call("get_build_cost_0526", piece_id) as Dictionary
	var parts: Array[String] = []
	for raw_id in cost.keys():
		var item_id := str(raw_id)
		parts.append("%s %d" % [ITEM_NAMES_0526.get(item_id, item_id), int(cost[raw_id])])
	return " + ".join(parts)

func get_build_ui_debug_0526() -> Dictionary:
	return {
		"panel": panel_0526 != null,
		"visible": panel_0526 != null and panel_0526.visible,
		"buttons": piece_buttons_0526.size(),
		"status": status_label_0526.text if status_label_0526 != null else ""
	}
