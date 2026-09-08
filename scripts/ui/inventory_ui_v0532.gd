extends "res://scripts/ui/inventory_ui_v0530.gd"

const CROP_LABELS_0532 := {
	"potato": "Batata",
	"corn": "Milho",
	"carrot": "Cenoura"
}
const SEED_IDS_0532 := {
	"potato": "potato_seed",
	"corn": "corn_seed",
	"carrot": "carrot_seed"
}
const FOOD_LABELS_0532 := {
	"potato": "Batata crua",
	"corn": "Milho cru",
	"carrot": "Cenoura crua",
	"cooked_potato": "Batata assada",
	"roasted_corn": "Milho assado",
	"vegetable_stew": "Ensopado",
	"spoiled_food": "Comida estragada"
}

var items_scroll_0532: ScrollContainer
var crop_status_0532: Label

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0532")
	_upgrade_items_scroll_0532()
	_build_crop_status_0532()

func _upgrade_items_scroll_0532() -> void:
	if items_box == null or panel == null or items_box.get_parent() != panel:
		return
	panel.remove_child(items_box)
	items_scroll_0532 = ScrollContainer.new()
	items_scroll_0532.name = "ItemsScroll0532"
	items_scroll_0532.position = Vector2(24, 92)
	items_scroll_0532.size = Vector2(255, 350)
	items_scroll_0532.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(items_scroll_0532)
	items_box.position = Vector2.ZERO
	items_box.size = Vector2(245, 720)
	items_box.custom_minimum_size = Vector2(245, 720)
	items_scroll_0532.add_child(items_box)

func _build_crop_status_0532() -> void:
	crop_status_0532 = Label.new()
	crop_status_0532.name = "CropStatus0532"
	crop_status_0532.position = Vector2(24, 448)
	crop_status_0532.size = Vector2(255, 46)
	crop_status_0532.add_theme_font_size_override("font_size", 11)
	crop_status_0532.modulate = Color(0.82, 0.88, 0.66, 0.95)
	panel.add_child(crop_status_0532)
	_update_crop_status_0532()

func _refresh_contents() -> void:
	super._refresh_contents()
	if player == null or items_box == null or not player.has_method("get_inventory_snapshot"):
		return
	var snapshot := player.call("get_inventory_snapshot") as Dictionary
	for crop_id in ["potato", "corn", "carrot"]:
		var seed_id := str(SEED_IDS_0532[crop_id])
		var seed_amount := int(snapshot.get(seed_id, 0))
		if seed_amount > 0:
			_add_seed_row_0532(crop_id, seed_amount)
	for item_id in ["potato", "corn", "carrot", "cooked_potato", "roasted_corn", "vegetable_stew", "spoiled_food"]:
		var amount := int(snapshot.get(item_id, 0))
		if amount > 0:
			_add_food_row_0532(item_id, amount)
	_update_crop_status_0532()

func _get_world_0532() -> Node:
	if player == null:
		return null
	var raw_world: Variant = player.get("world")
	return raw_world as Node if raw_world is Node else null

func _selected_crop_0532() -> String:
	var world_node := _get_world_0532()
	if world_node != null and world_node.has_method("get_selected_crop_0532"):
		return str(world_node.call("get_selected_crop_0532"))
	return "potato"

func _add_seed_row_0532(crop_id: String, amount: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(235, 34)
	var selected := _selected_crop_0532() == crop_id
	var label := Label.new()
	label.text = "%s semente x%d%s" % [CROP_LABELS_0532.get(crop_id, crop_id), amount, " ✓" if selected else ""]
	label.custom_minimum_size = Vector2(154, 32)
	label.add_theme_font_size_override("font_size", 10)
	row.add_child(label)
	var button := Button.new()
	button.text = "ATIVA" if selected else "PLANTAR"
	button.disabled = selected
	button.custom_minimum_size = Vector2(72, 30)
	button.add_theme_font_size_override("font_size", 9)
	button.pressed.connect(_select_crop_0532.bind(crop_id))
	row.add_child(button)
	items_box.add_child(row)

func _add_food_row_0532(item_id: String, amount: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(235, 38)
	var freshness := 0.0
	if player != null and player.has_method("get_food_freshness_0532"):
		freshness = float(player.call("get_food_freshness_0532", item_id))
	var label := Label.new()
	if item_id == "spoiled_food":
		label.text = "%s x%d • RISCO" % [FOOD_LABELS_0532.get(item_id, item_id), amount]
	else:
		label.text = "%s x%d • %.0f%%" % [FOOD_LABELS_0532.get(item_id, item_id), amount, freshness]
	label.custom_minimum_size = Vector2(154, 34)
	label.add_theme_font_size_override("font_size", 10)
	row.add_child(label)
	var use := Button.new()
	use.text = "COMER"
	use.custom_minimum_size = Vector2(72, 30)
	use.add_theme_font_size_override("font_size", 9)
	use.pressed.connect(_eat_food_0532.bind(item_id))
	row.add_child(use)
	items_box.add_child(row)

func _select_crop_0532(crop_id: String) -> void:
	var world_node := _get_world_0532()
	if world_node != null and world_node.has_method("select_crop_0532"):
		world_node.call("select_crop_0532", crop_id)
	_refresh_contents()

func _eat_food_0532(item_id: String) -> void:
	if player != null and player.has_method("use_inventory_item"):
		player.call("use_inventory_item", item_id)
	_refresh_contents()

func _update_crop_status_0532() -> void:
	if crop_status_0532 == null:
		return
	var crop_id := _selected_crop_0532()
	crop_status_0532.text = "CULTIVO ATIVO: %s\nNo canteiro preparado, INTERAGIR planta essa semente." % CROP_LABELS_0532.get(crop_id, crop_id)

func get_inventory_ui_debug_0532() -> Dictionary:
	return {
		"group": is_in_group("inventory_ui_0532"),
		"scroll": items_scroll_0532 != null,
		"selected_crop": _selected_crop_0532(),
		"crop_status": crop_status_0532 != null
	}
