extends CanvasLayer

var flash_05404: ColorRect
var label_05404: Label
var feedback_timer_05404 := 0.0
var feedback_duration_05404 := 0.16
var pulse_count_05404 := 0
var haptic_count_05404 := 0
var last_kind_05404 := ""
var last_text_05404 := ""

func _ready() -> void:
	add_to_group("feedback_ui_05404")
	layer = 18
	_build_overlay_05404()
	set_process(true)

func _build_overlay_05404() -> void:
	flash_05404 = ColorRect.new()
	flash_05404.name = "FeedbackFlash05404"
	flash_05404.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_05404.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_05404.color = Color(1, 1, 1, 0)
	add_child(flash_05404)

	label_05404 = Label.new()
	label_05404.name = "FeedbackLabel05404"
	label_05404.anchor_left = 0.5
	label_05404.anchor_top = 0.78
	label_05404.anchor_right = 0.5
	label_05404.anchor_bottom = 0.78
	label_05404.offset_left = -170.0
	label_05404.offset_top = -20.0
	label_05404.offset_right = 170.0
	label_05404.offset_bottom = 22.0
	label_05404.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_05404.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_05404.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_05404.add_theme_font_size_override("font_size", 15)
	label_05404.add_theme_color_override("font_color", Color(0.98, 0.95, 0.86, 0.0))
	label_05404.text = ""
	add_child(label_05404)

func pulse_05404(kind: String, text: String = "", strength: float = 1.0) -> void:
	last_kind_05404 = kind
	last_text_05404 = text
	pulse_count_05404 += 1
	feedback_duration_05404 = 0.18 if kind in ["alert", "denied"] else 0.14
	feedback_timer_05404 = feedback_duration_05404
	var alpha := 0.075 * clampf(strength, 0.4, 1.5)
	var tint := Color(0.82, 0.64, 0.28, alpha)
	match kind:
		"attack": tint = Color(0.86, 0.30, 0.18, alpha * 1.25)
		"pickup": tint = Color(0.38, 0.72, 0.38, alpha)
		"alert": tint = Color(0.90, 0.16, 0.12, alpha * 1.55)
		"denied": tint = Color(0.72, 0.15, 0.12, alpha * 1.15)
		"weapon": tint = Color(0.42, 0.60, 0.82, alpha)
		"sprint": tint = Color(0.80, 0.74, 0.54, alpha * 0.72)
	flash_05404.color = tint
	label_05404.text = text
	label_05404.add_theme_color_override("font_color", Color(0.98, 0.95, 0.86, 0.94 if text != "" else 0.0))
	_try_haptic_05404(kind, strength)

func _try_haptic_05404(kind: String, strength: float) -> void:
	if not OS.has_feature("mobile"):
		return
	var duration_ms := 18
	var amplitude := 0.22
	match kind:
		"attack":
			duration_ms = 34
			amplitude = 0.42
		"alert":
			duration_ms = 48
			amplitude = 0.58
		"denied":
			duration_ms = 26
			amplitude = 0.32
		"pickup":
			duration_ms = 16
			amplitude = 0.20
	Input.vibrate_handheld(duration_ms, clampf(amplitude * strength, 0.05, 1.0))
	haptic_count_05404 += 1

func _process(delta: float) -> void:
	if feedback_timer_05404 <= 0.0:
		return
	feedback_timer_05404 = maxf(0.0, feedback_timer_05404 - delta)
	var ratio := feedback_timer_05404 / maxf(0.001, feedback_duration_05404)
	var c := flash_05404.color
	c.a *= clampf(ratio, 0.0, 1.0)
	flash_05404.color = c
	var text_color := label_05404.get_theme_color("font_color")
	text_color.a = clampf(ratio * 1.25, 0.0, 0.94) if label_05404.text != "" else 0.0
	label_05404.add_theme_color_override("font_color", text_color)
	if feedback_timer_05404 <= 0.0:
		flash_05404.color.a = 0.0
		label_05404.text = ""

func get_feedback_ui_debug_05404() -> Dictionary:
	return {
		"version": "0.5.40.4",
		"pulses": pulse_count_05404,
		"haptics": haptic_count_05404,
		"last_kind": last_kind_05404,
		"last_text": last_text_05404,
		"flash": flash_05404 != null,
		"label": label_05404 != null,
		"mobile_haptics": OS.has_feature("mobile")
	}
