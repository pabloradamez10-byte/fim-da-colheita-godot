class_name BuildUIV0528
extends CanvasLayer

const PIECES_0528 := ["floor", "wall", "door", "fence", "gate", "crate", "barricade", "campfire"]
const PIECE_NAMES_0528 := {
	"floor": "PISO",
	"wall": "PAREDE",
	"door": "PORTA",
	"fence": "CERCA",
	"gate": "PORTÃO",
	"crate": "CAIXA",
	"barricade": "BARRIC.",
	"campfire": "FOGUEIRA"
}
const ITEM_NAMES_0528 := {
	"wood": "Mad.",
	"plank": "Táb.",
	"cordage": "Corda",
	"stone": "Pedra"
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
	add_to_group("build_ui_0528")
	_build_ui_0528()
	get_viewport().size_changed.connect(_refresh_layout_0528)
	_refresh_layout_0528()

func _process(delta: float) -> void:
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	refresh_timer += delta
	if refresh_timer >= 0.14:
		refresh_timer = 0.0
		_refresh_ui_0528()

func _build_ui_0528() -> void:
	toggle_button = Button.new()
	toggle_button.text = "CONSTRUIR"
	toggle_button.add_theme_font_size_override("font_size", 12)
	toggle_button.pressed.connect(_toggle_0528)
	add_child(toggle_button)

	panel = Panel.new()
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := Label.new()
	title.text = "CONSTRUÇÃO, DEFESA E MANUTENÇÃO"
	title.position = Vector2(14, 7)
	title.add_theme_font_size_override("font_size", 15)
	panel.add_child(title)

	for i in range(PIECES_0528.size()):
		var piece_id: String = PIECES_0528[i]
		var col: int = i % 4
		var row: int = int(i / 4)
		var button := Button.new()
		button.position = Vector2(14.0 + float(col) * 112.0, 32.0 + float(row) * 49.0)
		button.size = Vector2(105, 43)
		button.add_theme_font_size_override("font_size", 9)
		button.pressed.connect(_select_piece_0528.bind(piece_id))
		panel.add_child(button)
		piece_buttons[piece_id] = button

	var rotate := Button.new()
	rotate.text = "GIRAR 90°"
	rotate.position = Vector2(472, 32)
	rotate.size = Vector2(104, 43)
	rotate.add_theme_font_size_override("font_size", 9)
	rotate.pressed.connect(_rotate_0528)
	panel.add_child(rotate)

	place_button = Button.new()
	place_button.text = "COLOCAR"
	place_button.position = Vector2(584, 32)
	place_button.size = Vector2(100, 43)
	place_button.add_theme_font_size_override("font_size", 10)
	place_button.pressed.connect(_place_0528)
	panel.add_child(place_button)

	var close := Button.new()
	close.text = "SAIR"
	close.position = Vector2(692, 32)
	close.size = Vector2(78, 43)
	close.add_theme_font_size_override("font_size", 9)
	close.pressed.connect(_close_0528)
	panel.add_child(close)

	status_label = Label.new()
	status_label.position = Vector2(472, 82)
	status_label.size = Vector2(420, 47)
	status_label.add_theme_font_size_override("font_size", 10)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(status_label)

	repair_button = Button.new()
	repair_button.text = "REPARAR PRÓXIMA"
	repair_button.position = Vector2(14, 140)
	repair_button.size = Vector2(155, 40)
	repair_button.add_theme_font_size_override("font_size", 9)
	repair_button.pressed.connect(_repair_0528)
	panel.add_child(repair_button)

	dismantle_button = Button.new()
	dismantle_button.text = "DESMONTAR PRÓXIMA"
	dismantle_button.position = Vector2(176, 140)
	dismantle_button.size = Vector2(170, 40)
	dismantle_button.add_theme_font_size_override("font_size", 9)
	dismantle_button.pressed.connect(_dismantle_0528)
	panel.add_child(dismantle_button)

	maintenance_label = Label.new()
	maintenance_label.position = Vector2(360, 140)
	maintenance_label.size = Vector2(530, 42)
	maintenance_label.add_theme_font_size_override("font_size", 10)
	maintenance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(maintenance_label)

func _refresh_layout_0528() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	toggle_button.size = Vector2(124, 48)
	toggle_button.position = Vector2(viewport_size.x - 278.0, viewport_size.y - 330.0)
	panel.size = Vector2(910, 194)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, viewport_size.y - 298.0)

func _toggle_0528() -> void:
	if panel.visible:
		_close_0528()
		return
	panel.visible = true
	if world != null and world.has_method("enter_build_mode_0526"):
		world.call("enter_build_mode_0526", "floor")
	_refresh_ui_0528()

func _close_0528() -> void:
	panel.visible = false
	if world != null and world.has_method("cancel_build_mode_0526"):
		world.call("cancel_build_mode_0526")

func _select_piece_0528(piece_id: String) -> void:
	if world != null and world.has_method("select_build_piece_0526"):
		world.call("select_build_piece_0526", piece_id)
	_refresh_ui_0528()

func _rotate_0528() -> void:
	if world != null and world.has_method("rotate_build_preview_0526"):
		world.call("rotate_build_preview_0526")

func _place_0528() -> void:
	if world != null and world.has_method("place_build_preview_0526"):
		world.call("place_build_preview_0526")
	_refresh_ui_0528()

func _repair_0528() -> void:
	if world != null and world.has_method("repair_nearest_structure_0527"):
		world.call("repair_nearest_structure_0527")
	_refresh_ui_0528()

func _dismantle_0528() -> void:
	if world != null and world.has_method("dismantle_nearest_structure_0527"):
		world.call("dismantle_nearest_structure_0527")
	_refresh_ui_0528()

func _refresh_ui_0528() -> void:
	if not panel.visible or world == null:
		return
	var debug: Dictionary = {}
	if world.has_method("get_build_debug_0526"):
		debug = world.call("get_build_debug_0526") as Dictionary
	var selected: String = str(debug.get("piece", "floor"))
	var valid: bool = bool(debug.get("valid", false))
	var yaw: int = int(round(float(debug.get("yaw", 0.0))))
	for piece_id: String in PIECES_0528:
		var button: Button = piece_buttons.get(piece_id) as Button
		if button == null:
			continue
		button.text = "%s%s\n%s" % ["▶" if piece_id == selected else "", PIECE_NAMES_0528[piece_id], _cost_text_0528(piece_id)]
	place_button.disabled = not valid
	place_button.text = "COLOCAR" if valid else "BLOQUEADO"
	status_label.modulate = Color(0.62, 0.93, 0.62, 0.96) if valid else Color(0.95, 0.54, 0.46, 0.96)
	status_label.text = "%s • %d° • %s • construções: %d" % [PIECE_NAMES_0528.get(selected, selected), yaw, "posição válida" if valid else "posição/material insuficiente ou área ocupada", int(debug.get("structures", 0))]

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
		repair_cost = _format_cost_0528(cost)
	maintenance_label.text = "%s • integridade %d/%d%s%s" % [PIECE_NAMES_0528.get(piece_id_near, piece_id_near), int(round(health)), int(round(max_health)), " • reparo: " + repair_cost if repair_cost != "" else "", " • esvazie a caixa" if piece_id_near == "crate" and storage_total > 0 else ""]

func _cost_text_0528(piece_id: String) -> String:
	if player == null or not player.has_method("get_build_cost_0526"):
		return "—"
	var cost: Dictionary = player.call("get_build_cost_0526", piece_id) as Dictionary
	return _format_cost_0528(cost)

func _format_cost_0528(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for raw_id: Variant in cost.keys():
		var item_id: String = str(raw_id)
		parts.append("%s%d" % [ITEM_NAMES_0528.get(item_id, item_id), int(cost[raw_id])])
	return "+".join(parts)

func get_build_ui_debug_0528() -> Dictionary:
	return {
		"panel": panel != null,
		"visible": panel != null and panel.visible,
		"piece_buttons": piece_buttons.size(),
		"repair_button": repair_button != null,
		"dismantle_button": dismantle_button != null,
		"barricade_button": piece_buttons.has("barricade"),
		"campfire_button": piece_buttons.has("campfire")
	}
