class_name BuildUIV0527
extends CanvasLayer

const PIECES_0527 := ["floor", "wall", "door", "fence", "gate", "crate"]
const PIECE_NAMES_0527 := {
	"floor": "PISO",
	"wall": "PAREDE",
	"door": "PORTA",
	"fence": "CERCA",
	"gate": "PORTÃO",
	"crate": "CAIXA"
}
const ITEM_NAMES_0527 := {
	"wood": "Mad.",
	"plank": "Táb.",
	"cordage": "Corda"
}

var world: Node = null
var player: Node = null
var toggle_button: Button
var panel: Panel
var status_label: Label
var maintenance_label: Label
var place_button: Button
var repair_button: Button
var dismantle_button: Button
var piece_buttons: Dictionary = {}
var refresh_timer := 0.0

func _ready() -> void:
	layer = 16
	add_to_group("build_ui_0526")
	add_to_group("build_ui_0527")
	_build_ui()
	get_viewport().size_changed.connect(_refresh_layout)
	_refresh_layout()

func _process(delta: float) -> void:
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	refresh_timer += delta
	if refresh_timer >= 0.14:
		refresh_timer = 0.0
		_refresh_ui()

func _build_ui() -> void:
	toggle_button = Button.new()
	toggle_button.text = "CONSTRUIR"
	toggle_button.add_theme_font_size_override("font_size", 12)
	toggle_button.pressed.connect(_toggle)
	add_child(toggle_button)

	panel = Panel.new()
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := Label.new()
	title.text = "CONSTRUÇÃO E MANUTENÇÃO"
	title.position = Vector2(14, 7)
	title.add_theme_font_size_override("font_size", 15)
	panel.add_child(title)

	var x := 14.0
	for piece_id: String in PIECES_0527:
		var button := Button.new()
		button.position = Vector2(x, 32)
		button.size = Vector2(94, 47)
		button.add_theme_font_size_override("font_size", 9)
		button.pressed.connect(_select_piece.bind(piece_id))
		panel.add_child(button)
		piece_buttons[piece_id] = button
		x += 100.0

	var rotate := Button.new()
	rotate.text = "GIRAR 90°"
	rotate.position = Vector2(616, 32)
	rotate.size = Vector2(94, 47)
	rotate.add_theme_font_size_override("font_size", 9)
	rotate.pressed.connect(_rotate)
	panel.add_child(rotate)

	place_button = Button.new()
	place_button.text = "COLOCAR"
	place_button.position = Vector2(716, 32)
	place_button.size = Vector2(92, 47)
	place_button.add_theme_font_size_override("font_size", 10)
	place_button.pressed.connect(_place)
	panel.add_child(place_button)

	var close := Button.new()
	close.text = "SAIR"
	close.position = Vector2(814, 32)
	close.size = Vector2(72, 47)
	close.add_theme_font_size_override("font_size", 9)
	close.pressed.connect(_close)
	panel.add_child(close)

	status_label = Label.new()
	status_label.position = Vector2(14, 85)
	status_label.size = Vector2(875, 25)
	status_label.add_theme_font_size_override("font_size", 10)
	panel.add_child(status_label)

	repair_button = Button.new()
	repair_button.text = "REPARAR PRÓXIMA"
	repair_button.position = Vector2(14, 116)
	repair_button.size = Vector2(155, 40)
	repair_button.add_theme_font_size_override("font_size", 9)
	repair_button.pressed.connect(_repair)
	panel.add_child(repair_button)

	dismantle_button = Button.new()
	dismantle_button.text = "DESMONTAR PRÓXIMA"
	dismantle_button.position = Vector2(176, 116)
	dismantle_button.size = Vector2(170, 40)
	dismantle_button.add_theme_font_size_override("font_size", 9)
	dismantle_button.pressed.connect(_dismantle)
	panel.add_child(dismantle_button)

	maintenance_label = Label.new()
	maintenance_label.position = Vector2(360, 119)
	maintenance_label.size = Vector2(525, 36)
	maintenance_label.add_theme_font_size_override("font_size", 10)
	panel.add_child(maintenance_label)

func _refresh_layout() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	toggle_button.size = Vector2(124, 48)
	toggle_button.position = Vector2(viewport_size.x - 278.0, viewport_size.y - 330.0)
	panel.size = Vector2(900, 166)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, viewport_size.y - 272.0)

func _toggle() -> void:
	if panel.visible:
		_close()
		return
	panel.visible = true
	if world != null and world.has_method("enter_build_mode_0526"):
		world.call("enter_build_mode_0526", "floor")
	_refresh_ui()

func _close() -> void:
	panel.visible = false
	if world != null and world.has_method("cancel_build_mode_0526"):
		world.call("cancel_build_mode_0526")

func _select_piece(piece_id: String) -> void:
	if world != null and world.has_method("select_build_piece_0526"):
		world.call("select_build_piece_0526", piece_id)
	_refresh_ui()

func _rotate() -> void:
	if world != null and world.has_method("rotate_build_preview_0526"):
		world.call("rotate_build_preview_0526")

func _place() -> void:
	if world != null and world.has_method("place_build_preview_0526"):
		world.call("place_build_preview_0526")
	_refresh_ui()

func _repair() -> void:
	if world != null and world.has_method("repair_nearest_structure_0527"):
		world.call("repair_nearest_structure_0527")
	_refresh_ui()

func _dismantle() -> void:
	if world != null and world.has_method("dismantle_nearest_structure_0527"):
		world.call("dismantle_nearest_structure_0527")
	_refresh_ui()

func _refresh_ui() -> void:
	if not panel.visible or world == null:
		return
	var debug: Dictionary = {}
	if world.has_method("get_build_debug_0526"):
		debug = world.call("get_build_debug_0526") as Dictionary
	var selected: String = str(debug.get("piece", "floor"))
	var valid: bool = bool(debug.get("valid", false))
	var yaw: int = int(round(float(debug.get("yaw", 0.0))))
	for piece_id: String in PIECES_0527:
		var button: Button = piece_buttons.get(piece_id) as Button
		if button == null:
			continue
		button.text = "%s%s\n%s" % ["▶" if piece_id == selected else "", PIECE_NAMES_0527[piece_id], _cost_text(piece_id)]
	place_button.disabled = not valid
	place_button.text = "COLOCAR" if valid else "BLOQUEADO"
	status_label.modulate = Color(0.62, 0.93, 0.62, 0.96) if valid else Color(0.95, 0.54, 0.46, 0.96)
	status_label.text = "%s • %d° • %s • construções: %d" % [PIECE_NAMES_0527.get(selected, selected), yaw, "posição válida" if valid else "posição/material insuficiente ou área ocupada", int(debug.get("structures", 0))]

	var nearby: Dictionary = {}
	if world.has_method("get_nearest_structure_status_0527") and player != null:
		nearby = world.call("get_nearest_structure_status_0527", player.global_position) as Dictionary
	if nearby.is_empty():
		repair_button.disabled = true
		dismantle_button.disabled = true
		maintenance_label.text = "Aproxime-se de uma construção sua para reparar ou desmontar."
		return
	var piece_id_near: String = str(nearby.get("type", ""))
	var health: float = float(nearby.get("health", 0.0))
	var max_health: float = float(nearby.get("max_health", 1.0))
	var storage_total: int = int(nearby.get("storage_total", 0))
	repair_button.disabled = health >= max_health - 0.01
	dismantle_button.disabled = piece_id_near == "crate" and storage_total > 0
	var repair_cost := ""
	if player != null and player.has_method("get_repair_cost_0527"):
		var cost: Dictionary = player.call("get_repair_cost_0527", piece_id_near, health, max_health) as Dictionary
		repair_cost = _format_cost(cost)
	maintenance_label.text = "%s • integridade %d/%d%s%s" % [PIECE_NAMES_0527.get(piece_id_near, piece_id_near), int(round(health)), int(round(max_health)), " • reparo: " + repair_cost if repair_cost != "" else "", " • esvazie a caixa" if piece_id_near == "crate" and storage_total > 0 else ""]

func _cost_text(piece_id: String) -> String:
	if player == null or not player.has_method("get_build_cost_0526"):
		return "—"
	var cost: Dictionary = player.call("get_build_cost_0526", piece_id) as Dictionary
	return _format_cost(cost)

func _format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for raw_id: Variant in cost.keys():
		var item_id: String = str(raw_id)
		parts.append("%s%d" % [ITEM_NAMES_0527.get(item_id, item_id), int(cost[raw_id])])
	return "+".join(parts)

func get_build_ui_debug_0527() -> Dictionary:
	return {
		"panel": panel != null,
		"visible": panel != null and panel.visible,
		"piece_buttons": piece_buttons.size(),
		"repair_button": repair_button != null,
		"dismantle_button": dismantle_button != null
	}
