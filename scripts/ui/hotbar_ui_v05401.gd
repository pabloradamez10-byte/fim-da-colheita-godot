extends "res://scripts/ui/hotbar_ui_v0523.gd"

func _ready() -> void:
	super._ready()
	add_to_group("hotbar_rework_05401")
	_apply_hotbar_polish_05401()

func _apply_hotbar_polish_05401() -> void:
	if panel != null:
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.030, 0.035, 0.031, 0.86)
		panel_style.border_color = Color(0.28, 0.30, 0.27, 0.68)
		panel_style.border_width_left = 1
		panel_style.border_width_top = 1
		panel_style.border_width_right = 1
		panel_style.border_width_bottom = 1
		panel_style.corner_radius_top_left = 10
		panel_style.corner_radius_top_right = 10
		panel_style.corner_radius_bottom_left = 10
		panel_style.corner_radius_bottom_right = 10
		panel_style.content_margin_left = 7.0
		panel_style.content_margin_right = 7.0
		panel_style.content_margin_top = 6.0
		panel_style.content_margin_bottom = 6.0
		panel.add_theme_stylebox_override("panel", panel_style)
	for button in buttons:
		_style_hotbar_button_05401(button)

func _style_hotbar_button_05401(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _slot_style_05401(Color(0.075, 0.082, 0.072, 0.94), Color(0.29, 0.31, 0.28, 0.60)))
	button.add_theme_stylebox_override("hover", _slot_style_05401(Color(0.10, 0.11, 0.095, 0.96), Color(0.48, 0.43, 0.30, 0.78)))
	button.add_theme_stylebox_override("pressed", _slot_style_05401(Color(0.20, 0.16, 0.085, 0.98), Color(0.78, 0.61, 0.28, 0.92)))
	button.add_theme_stylebox_override("focus", _slot_style_05401(Color(0.10, 0.095, 0.065, 0.96), Color(0.72, 0.57, 0.27, 0.88)))
	button.add_theme_color_override("font_color", Color(0.93, 0.94, 0.90, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.57, 0.53, 0.64))
	button.add_theme_font_size_override("font_size", 10)

func _slot_style_05401(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.content_margin_left = 5.0
	style.content_margin_right = 5.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style

func _refresh_layout_0523() -> void:
	super._refresh_layout_0523()
	if panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var max_width := minf(viewport_size.x * 0.54, panel.size.x)
	if viewport_size.x < 1040.0:
		var scale_factor := clampf(max_width / maxf(panel.size.x, 1.0), 0.82, 1.0)
		panel.scale = Vector2(scale_factor, scale_factor)
		panel.position.x = (viewport_size.x - panel.size.x * scale_factor) * 0.5
	else:
		panel.scale = Vector2.ONE

func get_hotbar_rework_debug_05401() -> Dictionary:
	return {
		"version": "0.5.40.1",
		"slots": buttons.size(),
		"panel": panel != null,
		"scale": panel.scale if panel != null else Vector2.ONE
	}
