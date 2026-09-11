extends "res://scripts/ui/hud_3d.gd"

const HUD_VERSION_05401 := "0.5.40.1"
const COLOR_BG := Color(0.035, 0.040, 0.036, 0.93)
const COLOR_PANEL := Color(0.075, 0.082, 0.072, 0.94)
const COLOR_BORDER := Color(0.31, 0.34, 0.29, 0.70)
const COLOR_TEXT := Color(0.94, 0.95, 0.91, 1.0)
const COLOR_MUTED := Color(0.65, 0.69, 0.63, 1.0)
const COLOR_ACCENT := Color(0.78, 0.61, 0.28, 1.0)

var ui_root_05401: Control
var top_margin_05401: MarginContainer
var top_shell_05401: PanelContainer
var top_row_05401: HBoxContainer
var world_card_05401: PanelContainer
var world_primary_05401: Label
var world_secondary_05401: Label
var stat_cards_05401: Dictionary = {}
var info_panel_05401: PanelContainer
var equipment_label_05401: Label
var inventory_label_05401: Label
var location_label_05401: Label
var alert_panel_05401: PanelContainer
var alert_label_05401: Label
var refresh_05401 := 0.0

func _ready() -> void:
	if top_panel != null:
		top_panel.visible = false
	if hint != null:
		hint.visible = false
	add_to_group("hud_rework_05401")
	_build_hud_05401()
	get_viewport().size_changed.connect(_refresh_layout_05401)
	_refresh_layout_05401()

func _build_hud_05401() -> void:
	ui_root_05401 = Control.new()
	ui_root_05401.name = "HUDRework05401"
	ui_root_05401.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root_05401.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ui_root_05401)

	top_margin_05401 = MarginContainer.new()
	top_margin_05401.name = "TopMargin05401"
	top_margin_05401.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin_05401.add_theme_constant_override("margin_left", 14)
	top_margin_05401.add_theme_constant_override("margin_right", 14)
	top_margin_05401.add_theme_constant_override("margin_top", 10)
	ui_root_05401.add_child(top_margin_05401)

	top_shell_05401 = PanelContainer.new()
	top_shell_05401.name = "TopShell05401"
	top_shell_05401.add_theme_stylebox_override("panel", _panel_style_05401(COLOR_BG, 10, 1, COLOR_BORDER))
	top_margin_05401.add_child(top_shell_05401)

	top_row_05401 = HBoxContainer.new()
	top_row_05401.name = "TopRow05401"
	top_row_05401.add_theme_constant_override("separation", 6)
	top_shell_05401.add_child(top_row_05401)

	world_card_05401 = _make_world_card_05401()
	top_row_05401.add_child(world_card_05401)
	_make_stat_card_05401("health", "VIDA", Color(0.78, 0.22, 0.20, 1.0))
	_make_stat_card_05401("hunger", "FOME", Color(0.88, 0.51, 0.18, 1.0))
	_make_stat_card_05401("thirst", "SEDE", Color(0.25, 0.58, 0.82, 1.0))
	_make_stat_card_05401("stamina", "FÔLEGO", Color(0.77, 0.71, 0.25, 1.0))
	_make_stat_card_05401("fatigue", "CANSAÇO", Color(0.52, 0.55, 0.48, 1.0), true)

	info_panel_05401 = PanelContainer.new()
	info_panel_05401.name = "InfoStrip05401"
	info_panel_05401.add_theme_stylebox_override("panel", _panel_style_05401(Color(0.028, 0.032, 0.029, 0.88), 7, 1, Color(0.22, 0.24, 0.21, 0.65)))
	ui_root_05401.add_child(info_panel_05401)
	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 14)
	info_panel_05401.add_child(info_row)
	equipment_label_05401 = _small_info_label_05401("EQUIPADO —")
	inventory_label_05401 = _small_info_label_05401("MOCHILA —")
	location_label_05401 = _small_info_label_05401("LOCAL —")
	info_row.add_child(equipment_label_05401)
	info_row.add_child(inventory_label_05401)
	info_row.add_child(location_label_05401)

	alert_panel_05401 = PanelContainer.new()
	alert_panel_05401.name = "AlertPanel05401"
	alert_panel_05401.visible = false
	alert_panel_05401.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alert_panel_05401.add_theme_stylebox_override("panel", _panel_style_05401(Color(0.15, 0.055, 0.045, 0.94), 9, 1, Color(0.65, 0.20, 0.16, 0.90)))
	ui_root_05401.add_child(alert_panel_05401)
	alert_label_05401 = Label.new()
	alert_label_05401.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert_label_05401.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	alert_label_05401.add_theme_color_override("font_color", Color(1.0, 0.80, 0.72, 1.0))
	alert_label_05401.add_theme_font_size_override("font_size", 12)
	alert_panel_05401.add_child(alert_label_05401)

func _make_world_card_05401() -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "WorldCard05401"
	card.custom_minimum_size = Vector2(230.0, 66.0)
	card.add_theme_stylebox_override("panel", _panel_style_05401(COLOR_PANEL, 8, 0, Color.TRANSPARENT))
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 1)
	card.add_child(box)
	world_primary_05401 = Label.new()
	world_primary_05401.text = "DIA 1   08:00"
	world_primary_05401.add_theme_color_override("font_color", COLOR_TEXT)
	world_primary_05401.add_theme_font_size_override("font_size", 17)
	world_secondary_05401 = Label.new()
	world_secondary_05401.text = "ABERTO   18°C"
	world_secondary_05401.add_theme_color_override("font_color", COLOR_MUTED)
	world_secondary_05401.add_theme_font_size_override("font_size", 11)
	box.add_child(world_primary_05401)
	box.add_child(world_secondary_05401)
	return card

func _make_stat_card_05401(id: String, title_text: String, color: Color, inverse: bool = false) -> void:
	var card := PanelContainer.new()
	card.name = "%sCard05401" % id.capitalize()
	card.custom_minimum_size = Vector2(112.0, 66.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style_05401(COLOR_PANEL, 8, 0, Color.TRANSPARENT))
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	card.add_child(box)
	var title_label := Label.new()
	title_label.text = title_text
	title_label.add_theme_color_override("font_color", COLOR_MUTED)
	title_label.add_theme_font_size_override("font_size", 9)
	var value_label := Label.new()
	value_label.text = "100"
	value_label.add_theme_color_override("font_color", COLOR_TEXT)
	value_label.add_theme_font_size_override("font_size", 16)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(82.0, 5.0)
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _bar_style_05401(Color(0.16, 0.17, 0.15, 0.90)))
	bar.add_theme_stylebox_override("fill", _bar_style_05401(color))
	box.add_child(title_label)
	box.add_child(value_label)
	box.add_child(bar)
	card.add_to_group("hud_stat_card_05401")
	top_row_05401.add_child(card)
	stat_cards_05401[id] = {"value": value_label, "bar": bar, "inverse": inverse}

func _small_info_label_05401(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_color_override("font_color", Color(0.82, 0.84, 0.79, 1.0))
	label.add_theme_font_size_override("font_size", 10)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _panel_style_05401(bg: Color, radius: int, border: int, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = border
	style.border_width_top = border
	style.border_width_right = border
	style.border_width_bottom = border
	style.border_color = border_color
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style

func _bar_style_05401(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style

func _refresh_layout_05401() -> void:
	if ui_root_05401 == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var compact := viewport_size.x < 1080.0
	top_margin_05401.offset_left = 0.0
	top_margin_05401.offset_top = 0.0
	top_margin_05401.offset_right = 0.0
	top_margin_05401.offset_bottom = 82.0 if not compact else 76.0
	world_card_05401.custom_minimum_size.x = 230.0 if not compact else 180.0
	for raw in stat_cards_05401.values():
		var data := raw as Dictionary
		var value_label := data.get("value") as Label
		if value_label != null:
			value_label.add_theme_font_size_override("font_size", 16 if not compact else 14)
	info_panel_05401.position = Vector2(14.0, 88.0 if not compact else 82.0)
	info_panel_05401.size = Vector2(minf(viewport_size.x - 28.0, 900.0), 34.0)
	alert_panel_05401.size = Vector2(minf(720.0, viewport_size.x * 0.62), 34.0)
	alert_panel_05401.position = Vector2((viewport_size.x - alert_panel_05401.size.x) * 0.5, 128.0 if not compact else 122.0)

func _process(delta: float) -> void:
	refresh_05401 += delta
	if refresh_05401 < 0.14:
		return
	refresh_05401 = 0.0
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	_update_player_05401()
	_update_world_05401()

func _update_player_05401() -> void:
	if not player.has_method("get_vitals"):
		return
	var data: Dictionary = player.call("get_vitals")
	_set_stat_05401("health", float(data.get("health", 0.0)))
	_set_stat_05401("hunger", float(data.get("hunger", 0.0)))
	_set_stat_05401("thirst", float(data.get("thirst", 0.0)))
	_set_stat_05401("stamina", float(data.get("stamina", 0.0)))
	_set_stat_05401("fatigue", float(data.get("fatigue", 0.0)))

	if player.has_method("get_weapon_summary"):
		equipment_label_05401.text = "EQUIPADO  •  " + _clip_05401(str(player.call("get_weapon_summary")), 42)
	if player.has_method("get_equipment_summary_0533"):
		equipment_label_05401.text += "  •  " + _clip_05401(str(player.call("get_equipment_summary_0533")), 30)
	if player.has_method("get_inventory_summary"):
		inventory_label_05401.text = "MOCHILA  •  " + _clip_05401(str(player.call("get_inventory_summary")), 54)
	_update_alerts_05401(data)

func _update_world_05401() -> void:
	if world == null or not world.has_method("get_world_summary"):
		return
	var summary: Dictionary = world.call("get_world_summary")
	var day := int(summary.get("day_0521", 0))
	var time_text := str(summary.get("time_0521", "--:--"))
	var weather := str(summary.get("weather_0522", "ABERTO"))
	var ambient := int(round(float(summary.get("ambient_temperature_0521", 18.0))))
	var period := "NOITE" if bool(summary.get("night_0521", false)) else "DIA"
	if day > 0:
		world_primary_05401.text = "DIA %d   %s" % [day, time_text]
		world_secondary_05401.text = "%s  •  %s  •  %d°C" % [period, weather, ambient]
	else:
		world_primary_05401.text = "SEED %s" % str(summary.get("seed", "?"))
		world_secondary_05401.text = "%s  •  %d°C" % [weather, ambient]
	var city_distance := int(summary.get("city_distance", -1))
	var zombies := int(summary.get("zombies", 0))
	var location_text := "ZUMBIS %d" % zombies
	if city_distance >= 0:
		location_text += "  •  CIDADE %dm" % city_distance
	var driving_name := str(summary.get("driving_vehicle_0530", ""))
	if driving_name != "":
		location_text = "%s  •  %.1fL  •  INT %d" % [driving_name, float(summary.get("driving_fuel_0530", 0.0)), int(round(float(summary.get("driving_health_0530", 0.0))))]
	location_label_05401.text = "MUNDO  •  " + location_text

func _set_stat_05401(id: String, raw_value: float) -> void:
	if not stat_cards_05401.has(id):
		return
	var data := stat_cards_05401[id] as Dictionary
	var value_label := data.get("value") as Label
	var bar := data.get("bar") as ProgressBar
	var inverse := bool(data.get("inverse", false))
	var value := clampf(raw_value, 0.0, 100.0)
	if value_label != null:
		value_label.text = "%d" % int(round(value))
	if bar != null:
		bar.value = 100.0 - value if inverse else value

func _update_alerts_05401(data: Dictionary) -> void:
	var alerts: Array[String] = []
	var health := float(data.get("health", 100.0))
	var hunger := float(data.get("hunger", 100.0))
	var thirst := float(data.get("thirst", 100.0))
	var fatigue := float(data.get("fatigue", 0.0))
	var pain := int(data.get("pain", 0))
	var bleeding := float(data.get("bleeding", 0.0))
	var infection := int(data.get("infection", 0))
	var wetness := int(data.get("wetness", 0))
	var water_sickness := int(round(float(data.get("water_sickness", 0.0))))
	if health <= 35.0: alerts.append("VIDA CRÍTICA")
	if hunger <= 25.0: alerts.append("FOME")
	if thirst <= 25.0: alerts.append("SEDE")
	if fatigue >= 70.0: alerts.append("EXAUSTO")
	if pain >= 15: alerts.append("DOR")
	if bleeding >= 0.25: alerts.append("SANGRANDO")
	if infection >= 10: alerts.append("INFECÇÃO")
	if wetness >= 15: alerts.append("MOLHADO")
	if water_sickness >= 10: alerts.append("ÁGUA CONTAMINADA")
	alert_panel_05401.visible = not alerts.is_empty()
	if not alerts.is_empty():
		alert_label_05401.text = "  •  ".join(alerts)

func _clip_05401(value: String, limit: int) -> String:
	if value.length() <= limit:
		return value
	return value.substr(0, maxi(0, limit - 1)) + "…"

func get_hud_rework_debug_05401() -> Dictionary:
	return {
		"version": HUD_VERSION_05401,
		"stat_cards": stat_cards_05401.size(),
		"top_shell": top_shell_05401 != null,
		"info_strip": info_panel_05401 != null,
		"alerts": alert_panel_05401 != null,
		"legacy_hidden": top_panel == null or not top_panel.visible
	}
