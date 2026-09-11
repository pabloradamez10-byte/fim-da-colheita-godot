extends "res://scripts/ui/campfire_ui_v0532.gd"

var game_meat_button_0538: Button = null

func _ready() -> void:
	super._ready()
	add_to_group("campfire_ui_0538")
	_add_game_meat_button_0538()
	_refresh_layout_0528()
	_refresh_status_0528()

func _add_game_meat_button_0538() -> void:
	if panel == null or game_meat_button_0538 != null:
		return
	game_meat_button_0538 = Button.new()
	game_meat_button_0538.name = "Cook_cooked_game_meat_0538"
	game_meat_button_0538.text = "CARNE DE CAÇA ASSADA"
	game_meat_button_0538.position = Vector2(16.0, 302.0)
	game_meat_button_0538.size = Vector2(474.0, 44.0)
	game_meat_button_0538.add_theme_font_size_override("font_size", 10)
	game_meat_button_0538.pressed.connect(_cook_recipe_0532.bind("cooked_game_meat"))
	panel.add_child(game_meat_button_0538)

func _refresh_layout_0528() -> void:
	if panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	panel.size = Vector2(506, 366)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, (viewport_size.y - panel.size.y) * 0.5)

func _refresh_status_0528() -> void:
	super._refresh_status_0528()
	if game_meat_button_0538 == null or panel == null or not panel.visible:
		return
	var burning := false
	var fuel := 0.0
	if world != null and current_uid != "" and world.has_method("get_campfire_status_0528"):
		var fire_status := world.call("get_campfire_status_0528", current_uid) as Dictionary
		burning = bool(fire_status.get("burning", false))
		fuel = float(fire_status.get("fuel_minutes", 0.0))
	var fuel_cost := 10.0
	var can_cook := false
	if player != null and player.has_method("get_food_recipe_0532"):
		var recipe := player.call("get_food_recipe_0532", "cooked_game_meat") as Dictionary
		fuel_cost = float(recipe.get("fuel_cost", 10.0))
	if player != null and player.has_method("can_cook_recipe_0532"):
		can_cook = bool(player.call("can_cook_recipe_0532", "cooked_game_meat"))
	game_meat_button_0538.disabled = not burning or fuel < fuel_cost or not can_cook
	game_meat_button_0538.text = "CARNE DE CAÇA ASSADA • %.0fmin" % fuel_cost

func get_campfire_ui_debug_0538() -> Dictionary:
	return {
		"group": is_in_group("campfire_ui_0538"),
		"game_meat_button": game_meat_button_0538 != null,
		"parent_recipes": recipe_buttons_0532.size(),
		"total_recipes": recipe_buttons_0532.size() + (1 if game_meat_button_0538 != null else 0)
	}
