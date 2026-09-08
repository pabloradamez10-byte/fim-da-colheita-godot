extends "res://scripts/ui/campfire_ui_v0529.gd"

const RECIPE_ORDER_0532 := ["baked_potato", "roasted_corn", "vegetable_stew"]
const RECIPE_SHORT_NAMES_0532 := {
	"baked_potato": "BATATA ASSADA",
	"roasted_corn": "MILHO ASSADO",
	"vegetable_stew": "ENSOPADO"
}

var cooking_label_0532: Label
var recipe_buttons_0532: Dictionary = {}

func _ready() -> void:
	super._ready()
	add_to_group("campfire_ui_0532")
	_build_cooking_controls_0532()
	_refresh_layout_0528()

func _build_cooking_controls_0532() -> void:
	cooking_label_0532 = Label.new()
	cooking_label_0532.name = "CookingStatus0532"
	cooking_label_0532.position = Vector2(16, 204)
	cooking_label_0532.size = Vector2(470, 42)
	cooking_label_0532.add_theme_font_size_override("font_size", 11)
	cooking_label_0532.modulate = Color(0.92, 0.80, 0.52, 0.96)
	panel.add_child(cooking_label_0532)

	for i in range(RECIPE_ORDER_0532.size()):
		var recipe_id := str(RECIPE_ORDER_0532[i])
		var button := Button.new()
		button.name = "Cook_%s_0532" % recipe_id
		button.text = str(RECIPE_SHORT_NAMES_0532.get(recipe_id, recipe_id))
		button.position = Vector2(16.0 + float(i) * 158.0, 250.0)
		button.size = Vector2(148, 44)
		button.add_theme_font_size_override("font_size", 9)
		button.pressed.connect(_cook_recipe_0532.bind(recipe_id))
		panel.add_child(button)
		recipe_buttons_0532[recipe_id] = button

func _refresh_layout_0528() -> void:
	if panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	panel.size = Vector2(506, 312)
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, (viewport_size.y - panel.size.y) * 0.5)

func _cook_recipe_0532(recipe_id: String) -> void:
	if world != null and world.has_method("campfire_cook_food_0532") and current_uid != "":
		world.call("campfire_cook_food_0532", current_uid, player, recipe_id)
	_refresh_status_0528()

func _refresh_status_0528() -> void:
	super._refresh_status_0528()
	if cooking_label_0532 == null or panel == null or not panel.visible:
		return
	var burning := false
	var fuel := 0.0
	if world != null and current_uid != "" and world.has_method("get_campfire_status_0528"):
		var fire_status := world.call("get_campfire_status_0528", current_uid) as Dictionary
		burning = bool(fire_status.get("burning", false))
		fuel = float(fire_status.get("fuel_minutes", 0.0))
	var recipe_texts: Array[String] = []
	for recipe_id in RECIPE_ORDER_0532:
		var can_cook := false
		var fuel_cost := 0.0
		var recipe_name := str(RECIPE_SHORT_NAMES_0532.get(recipe_id, recipe_id))
		if player != null and player.has_method("get_food_recipe_0532"):
			var recipe := player.call("get_food_recipe_0532", recipe_id) as Dictionary
			fuel_cost = float(recipe.get("fuel_cost", 0.0))
			recipe_name = str(recipe.get("name", recipe_name))
		if player != null and player.has_method("can_cook_recipe_0532"):
			can_cook = bool(player.call("can_cook_recipe_0532", recipe_id))
		if recipe_buttons_0532.has(recipe_id):
			var button := recipe_buttons_0532[recipe_id] as Button
			button.disabled = not burning or fuel < fuel_cost or not can_cook
		recipe_texts.append("%s %.0fmin" % [recipe_name, fuel_cost])
	cooking_label_0532.text = "COZINHA • fogo aceso + ingredientes\n" + " • ".join(recipe_texts)

func get_campfire_ui_debug_0532() -> Dictionary:
	return {
		"group": is_in_group("campfire_ui_0532"),
		"recipes": recipe_buttons_0532.size(),
		"cooking_label": cooking_label_0532 != null,
		"visible": panel != null and panel.visible
	}
