extends "res://scripts/ui/build_ui_v0528.gd"

const PIECE_NAME_0529 := "COLETOR"

func _ready() -> void:
	super._ready()
	add_to_group("build_ui_0529")
	var collector := Button.new()
	collector.position = Vector2(14.0, 130.0)
	collector.size = Vector2(105, 43)
	collector.add_theme_font_size_override("font_size", 9)
	collector.pressed.connect(_select_piece_0528.bind("rain_collector"))
	panel.add_child(collector)
	piece_buttons["rain_collector"] = collector
	_refresh_layout_0528()
	_refresh_ui_0528()

func _refresh_layout_0528() -> void:
	if toggle_button == null or panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	toggle_button.size = Vector2(124, 48)
	toggle_button.position = Vector2(viewport_size.x - 278.0, viewport_size.y - 330.0)
	panel.size = Vector2(910, 244)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, viewport_size.y - 348.0)
	if repair_button != null:
		repair_button.position.y = 190.0
	if dismantle_button != null:
		dismantle_button.position.y = 190.0
	if maintenance_label != null:
		maintenance_label.position.y = 190.0

func _refresh_ui_0528() -> void:
	super._refresh_ui_0528()
	if panel == null or not panel.visible or world == null:
		return
	var collector_button: Button = piece_buttons.get("rain_collector") as Button
	var debug: Dictionary = {}
	if world.has_method("get_build_debug_0526"):
		debug = world.call("get_build_debug_0526") as Dictionary
	var selected := str(debug.get("piece", "floor"))
	if collector_button != null:
		collector_button.text = "%s%s\n%s" % ["▶" if selected == "rain_collector" else "", PIECE_NAME_0529, _cost_text_0528("rain_collector")]
	if selected == "rain_collector":
		var valid := bool(debug.get("valid", false))
		var yaw := int(round(float(debug.get("yaw", 0.0))))
		status_label.text = "%s • %d° • %s • capta chuva automaticamente" % [PIECE_NAME_0529, yaw, "posição válida" if valid else "posição/material insuficiente ou área ocupada"]

	if player == null or not world.has_method("get_nearest_structure_status_0527"):
		return
	var nearby := world.call("get_nearest_structure_status_0527", player.global_position) as Dictionary
	if str(nearby.get("type", "")) != "rain_collector":
		return
	var health := float(nearby.get("health", 0.0))
	var max_health := float(nearby.get("max_health", 1.0))
	var stored := float(nearby.get("water_units_0529", 0.0))
	dismantle_button.disabled = stored > 0.01
	var repair_cost := ""
	if player.has_method("get_repair_cost_0527"):
		repair_cost = _format_cost_0528(player.call("get_repair_cost_0527", "rain_collector", health, max_health) as Dictionary)
	maintenance_label.text = "COLETOR • integridade %d/%d • água %.1f/18%s%s" % [int(round(health)), int(round(max_health)), stored, " • reparo: " + repair_cost if repair_cost != "" else "", " • esvazie antes de desmontar" if stored > 0.01 else ""]

func get_build_ui_debug_0529() -> Dictionary:
	return {
		"group": is_in_group("build_ui_0529"),
		"piece_buttons": piece_buttons.size(),
		"collector_button": piece_buttons.has("rain_collector")
	}
