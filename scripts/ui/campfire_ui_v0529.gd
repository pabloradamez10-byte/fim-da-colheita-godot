extends "res://scripts/ui/campfire_ui_v0528.gd"

var purify_button_0529: Button
var water_label_0529: Label

func _ready() -> void:
	super._ready()
	add_to_group("campfire_ui_0529")
	_build_water_controls_0529()
	_refresh_layout_0528()

func _build_water_controls_0529() -> void:
	water_label_0529 = Label.new()
	water_label_0529.position = Vector2(16, 154)
	water_label_0529.size = Vector2(245, 40)
	water_label_0529.add_theme_font_size_override("font_size", 11)
	panel.add_child(water_label_0529)

	purify_button_0529 = Button.new()
	purify_button_0529.text = "FERVER 1 ÁGUA"
	purify_button_0529.position = Vector2(266, 154)
	purify_button_0529.size = Vector2(120, 42)
	purify_button_0529.add_theme_font_size_override("font_size", 10)
	purify_button_0529.pressed.connect(_purify_water_0529)
	panel.add_child(purify_button_0529)

func _refresh_layout_0528() -> void:
	if panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	panel.size = Vector2(405, 212)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, (viewport_size.y - panel.size.y) * 0.5)

func _purify_water_0529() -> void:
	if world != null and world.has_method("campfire_purify_water_0529") and current_uid != "":
		world.call("campfire_purify_water_0529", current_uid, player)
	_refresh_status_0528()

func _refresh_status_0528() -> void:
	super._refresh_status_0528()
	if purify_button_0529 == null or water_label_0529 == null or panel == null or not panel.visible:
		return
	var dirty := 0
	var safe := 0
	if player != null and player.has_method("get_water_survival_debug_0529"):
		var water_state := player.call("get_water_survival_debug_0529") as Dictionary
		dirty = int(water_state.get("dirty_water", 0))
		safe = int(water_state.get("safe_water", 0))
	var fire_status: Dictionary = {}
	if world != null and current_uid != "" and world.has_method("get_campfire_status_0528"):
		fire_status = world.call("get_campfire_status_0528", current_uid) as Dictionary
	var burning := bool(fire_status.get("burning", false))
	var fuel := float(fire_status.get("fuel_minutes", 0.0))
	water_label_0529.text = "Água bruta: %d • segura: %d\nFerver consome 10 min de combustível" % [dirty, safe]
	purify_button_0529.disabled = dirty <= 0 or not burning or fuel < 10.0

func get_campfire_ui_debug_0529() -> Dictionary:
	return {
		"group": is_in_group("campfire_ui_0529"),
		"purify_button": purify_button_0529 != null,
		"water_label": water_label_0529 != null
	}
