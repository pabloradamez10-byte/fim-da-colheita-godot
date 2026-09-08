class_name CampfireUIV0528
extends CanvasLayer

var world: Node = null
var player: Node = null
var panel: Panel
var status_label: Label
var toggle_button: Button
var fuel_button: Button
var current_uid := ""
var refresh_timer := 0.0

func _ready() -> void:
	layer = 18
	add_to_group("campfire_ui_0528")
	_build_ui_0528()
	get_viewport().size_changed.connect(_refresh_layout_0528)
	_refresh_layout_0528()

func _process(delta: float) -> void:
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if panel == null or not panel.visible:
		return
	refresh_timer += delta
	if refresh_timer >= 0.18:
		refresh_timer = 0.0
		_refresh_status_0528()

func _build_ui_0528() -> void:
	panel = Panel.new()
	panel.name = "CampfirePanel0528"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := Label.new()
	title.text = "FOGUEIRA"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 18)
	panel.add_child(title)

	status_label = Label.new()
	status_label.position = Vector2(16, 44)
	status_label.size = Vector2(390, 48)
	status_label.add_theme_font_size_override("font_size", 12)
	panel.add_child(status_label)

	toggle_button = Button.new()
	toggle_button.position = Vector2(16, 100)
	toggle_button.size = Vector2(120, 46)
	toggle_button.add_theme_font_size_override("font_size", 11)
	toggle_button.pressed.connect(_toggle_fire_0528)
	panel.add_child(toggle_button)

	fuel_button = Button.new()
	fuel_button.text = "+1 LENHA"
	fuel_button.position = Vector2(146, 100)
	fuel_button.size = Vector2(120, 46)
	fuel_button.add_theme_font_size_override("font_size", 11)
	fuel_button.pressed.connect(_add_fuel_0528)
	panel.add_child(fuel_button)

	var close := Button.new()
	close.text = "FECHAR"
	close.position = Vector2(276, 100)
	close.size = Vector2(110, 46)
	close.add_theme_font_size_override("font_size", 11)
	close.pressed.connect(close_campfire_0528)
	panel.add_child(close)

func _refresh_layout_0528() -> void:
	if panel == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	panel.size = Vector2(405, 162)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, (viewport_size.y - panel.size.y) * 0.5)

func open_campfire_0528(uid: String) -> void:
	current_uid = uid
	panel.visible = true
	_refresh_status_0528()

func close_campfire_0528() -> void:
	panel.visible = false
	current_uid = ""

func _toggle_fire_0528() -> void:
	if world != null and world.has_method("campfire_toggle_0528") and current_uid != "":
		world.call("campfire_toggle_0528", current_uid)
	_refresh_status_0528()

func _add_fuel_0528() -> void:
	if world != null and world.has_method("campfire_add_fuel_0528") and current_uid != "":
		world.call("campfire_add_fuel_0528", current_uid, player)
	_refresh_status_0528()

func _refresh_status_0528() -> void:
	if world == null or current_uid == "" or not world.has_method("get_campfire_status_0528"):
		return
	var status: Dictionary = world.call("get_campfire_status_0528", current_uid) as Dictionary
	if status.is_empty() or not bool(status.get("near", false)):
		close_campfire_0528()
		return
	var fuel: float = float(status.get("fuel_minutes", 0.0))
	var max_fuel: float = float(status.get("max_fuel", 360.0))
	var burning: bool = bool(status.get("burning", false))
	status_label.text = "%s\nCombustível: %d / %d min" % ["ACESA" if burning else "APAGADA", int(round(fuel)), int(round(max_fuel))]
	toggle_button.text = "APAGAR" if burning else "ACENDER"
	toggle_button.disabled = not burning and fuel <= 0.01
	fuel_button.disabled = fuel > max_fuel - 60.0 + 0.01

func get_campfire_ui_debug_0528() -> Dictionary:
	return {
		"panel": panel != null,
		"visible": panel != null and panel.visible,
		"uid": current_uid,
		"toggle": toggle_button != null,
		"fuel": fuel_button != null
	}
