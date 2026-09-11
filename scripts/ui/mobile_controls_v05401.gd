extends "res://scripts/ui/mobile_controls.gd"

const CONTROL_BG_05401 := Color(0.045, 0.050, 0.045, 0.78)
const CONTROL_BORDER_05401 := Color(0.48, 0.50, 0.44, 0.62)
const CONTROL_TEXT_05401 := Color(0.95, 0.96, 0.92, 1.0)
const CONTROL_ACCENT_05401 := Color(0.72, 0.52, 0.22, 0.92)

func _ready() -> void:
	super._ready()
	add_to_group("mobile_rework_05401")
	_apply_button_polish_05401()
	_refresh_layout()

func _apply_button_polish_05401() -> void:
	_style_button_05401(attack_button, CONTROL_ACCENT_05401, Color(0.88, 0.65, 0.29, 1.0), 13)
	_style_button_05401(interact_button, CONTROL_BG_05401, Color(0.16, 0.18, 0.15, 0.94), 12)
	_style_button_05401(sprint_button, CONTROL_BG_05401, Color(0.18, 0.20, 0.17, 0.94), 11)
	_style_button_05401(weapon_button, CONTROL_BG_05401, Color(0.18, 0.20, 0.17, 0.94), 11)
	_style_button_05401(new_seed_button, Color(0.035, 0.040, 0.036, 0.62), Color(0.12, 0.13, 0.12, 0.82), 9)
	attack_button.text = "ATACAR"
	interact_button.text = "AÇÃO"
	sprint_button.text = "CORRER"
	weapon_button.text = "ARMA"
	new_seed_button.text = "NOVA SEED"

func _style_button_05401(button: Button, normal_color: Color, pressed_color: Color, font_size: int) -> void:
	button.add_theme_stylebox_override("normal", _button_box_05401(normal_color, CONTROL_BORDER_05401, 14))
	button.add_theme_stylebox_override("hover", _button_box_05401(normal_color.lightened(0.06), CONTROL_BORDER_05401.lightened(0.08), 14))
	button.add_theme_stylebox_override("pressed", _button_box_05401(pressed_color, Color(0.82, 0.70, 0.45, 0.88), 14))
	button.add_theme_stylebox_override("focus", _button_box_05401(normal_color, Color(0.80, 0.66, 0.39, 0.75), 14))
	button.add_theme_color_override("font_color", CONTROL_TEXT_05401)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", font_size)
	button.flat = false

func _button_box_05401(bg: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style

func _refresh_layout() -> void:
	super._refresh_layout()
	if attack_button == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var edge := clampf(viewport_size.y * 0.024, 12.0, 18.0)
	var attack_size := Vector2(104.0, 92.0)
	var action_size := Vector2(112.0, 56.0)
	var small_size := Vector2(96.0, 50.0)
	attack_button.size = attack_size
	interact_button.size = action_size
	sprint_button.size = small_size
	weapon_button.size = small_size
	new_seed_button.size = Vector2(96.0, 34.0)

	var attack_pos := Vector2(viewport_size.x - edge - attack_size.x, viewport_size.y - edge - attack_size.y)
	attack_button.position = attack_pos
	interact_button.position = Vector2(attack_pos.x - action_size.x - 10.0, viewport_size.y - edge - action_size.y)
	weapon_button.position = Vector2(attack_pos.x + 4.0, attack_pos.y - small_size.y - 10.0)
	sprint_button.position = Vector2(interact_button.position.x + 8.0, interact_button.position.y - small_size.y - 10.0)
	new_seed_button.position = Vector2(viewport_size.x - edge - new_seed_button.size.x, 96.0)
	queue_redraw()

func set_vehicle_mode_0530(enabled: bool) -> void:
	super.set_vehicle_mode_0530(enabled)
	interact_button.text = "SAIR" if enabled else "AÇÃO"

func _draw() -> void:
	var outer_color := Color(0.025, 0.030, 0.027, 0.46)
	var ring_color := Color(0.72, 0.73, 0.67, 0.28)
	var inner_color := Color(0.19, 0.20, 0.17, 0.54)
	var knob_color := Color(0.73, 0.57, 0.28, 0.74)
	draw_circle(joystick_center, joystick_radius + 5.0, outer_color)
	draw_circle(joystick_center, joystick_radius, inner_color)
	draw_arc(joystick_center, joystick_radius, 0.0, TAU, 64, ring_color, 2.0)
	draw_arc(joystick_center, joystick_radius * 0.52, 0.0, TAU, 48, Color(0.72, 0.73, 0.67, 0.13), 1.0)
	draw_circle(joystick_knob, minf(31.0, joystick_radius * 0.36), knob_color)
	draw_arc(joystick_knob, minf(31.0, joystick_radius * 0.36), 0.0, TAU, 40, Color(0.96, 0.88, 0.69, 0.40), 1.5)

func get_mobile_rework_debug_05401() -> Dictionary:
	return {
		"version": "0.5.40.1",
		"attack_size": attack_button.size,
		"interact_text": interact_button.text,
		"joystick_radius": joystick_radius,
		"vehicle_mode": vehicle_mode_0530
	}
