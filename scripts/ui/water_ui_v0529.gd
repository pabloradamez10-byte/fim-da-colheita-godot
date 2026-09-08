class_name WaterUIV0529
extends CanvasLayer

var world: Node = null
var player: Node = null
var panel: Panel
var status_label: Label
var take_button: Button
var drink_button: Button
var current_uid := ""
var refresh_timer := 0.0

func _ready() -> void:
	layer = 18
	add_to_group("water_ui_0529")
	_build_ui_0529()
	get_viewport().size_changed.connect(_refresh_layout_0529)
	_refresh_layout_0529()

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
		_refresh_status_0529()

func _build_ui_0529() -> void:
	panel = Panel.new()
	panel.name = "WaterCollectorPanel0529"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var title := Label.new()
	title.text = "COLETOR DE CHUVA"
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 18)
	panel.add_child(title)

	status_label = Label.new()
	status_label.position = Vector2(16, 44)
	status_label.size = Vector2(430, 74)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(status_label)

	take_button = Button.new()
	take_button.text = "COLETAR 1"
	take_button.position = Vector2(16, 124)
	take_button.size = Vector2(126, 46)
	take_button.add_theme_font_size_override("font_size", 11)
	take_button.pressed.connect(_take_water_0529)
	panel.add_child(take_button)

	drink_button = Button.new()
	drink_button.text = "BEBER CRUA"
	drink_button.position = Vector2(152, 124)
	drink_button.size = Vector2(126, 46)
	drink_button.add_theme_font_size_override("font_size", 11)
	drink_button.pressed.connect(_drink_raw_0529)
	panel.add_child(drink_button)

	var close := Button.new()
	close.text = "FECHAR"
	close.position = Vector2(288, 124)
	close.size = Vector2(118, 46)
	close.add_theme_font_size_override("font_size", 11)
	close.pressed.connect(close_water_collector_0529)
	panel.add_child(close)

func _refresh_layout_0529() -> void:
	if panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	panel.size = Vector2(425, 188)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, (viewport_size.y - panel.size.y) * 0.5)

func open_water_collector_0529(uid: String) -> void:
	current_uid = uid
	panel.visible = true
	_refresh_status_0529()

func close_water_collector_0529() -> void:
	panel.visible = false
	current_uid = ""

func _take_water_0529() -> void:
	if world != null and world.has_method("collector_take_water_0529") and current_uid != "":
		world.call("collector_take_water_0529", current_uid, player)
	_refresh_status_0529()

func _drink_raw_0529() -> void:
	if world != null and world.has_method("collector_drink_raw_0529") and current_uid != "":
		world.call("collector_drink_raw_0529", current_uid, player)
	_refresh_status_0529()

func _refresh_status_0529() -> void:
	if world == null or current_uid == "" or not world.has_method("get_rain_collector_status_0529"):
		return
	var status := world.call("get_rain_collector_status_0529", current_uid) as Dictionary
	if status.is_empty() or not bool(status.get("near", false)):
		close_water_collector_0529()
		return
	var stored := float(status.get("water", 0.0))
	var capacity := float(status.get("capacity", 18.0))
	var raining := bool(status.get("raining", false))
	var sheltered := bool(status.get("sheltered", false))
	var dirty := 0
	var safe := 0
	var sickness := 0
	if player != null and player.has_method("get_water_survival_debug_0529"):
		var p := player.call("get_water_survival_debug_0529") as Dictionary
		dirty = int(p.get("dirty_water", 0))
		safe = int(p.get("safe_water", 0))
		sickness = int(round(float(p.get("sickness", 0.0))))
	var rain_text := "COLETANDO" if raining and not sheltered and stored < capacity - 0.01 else ("CHEIO" if stored >= capacity - 0.01 else "AGUARDANDO CHUVA")
	status_label.text = "Reservatório: %.1f / %.0f • %s\nMochila: água bruta %d • água segura %d • contaminação hídrica %d" % [stored, capacity, rain_text, dirty, safe, sickness]
	take_button.disabled = stored < 1.0
	drink_button.disabled = stored < 1.0

func get_water_ui_debug_0529() -> Dictionary:
	return {
		"panel": panel != null,
		"visible": panel != null and panel.visible,
		"uid": current_uid,
		"take_button": take_button != null,
		"drink_button": drink_button != null
	}
