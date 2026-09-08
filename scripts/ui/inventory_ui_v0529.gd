extends "res://scripts/ui/inventory_ui_v0525.gd"

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0529")

func _refresh_contents() -> void:
	super._refresh_contents()
	if player == null or items_box == null or not player.has_method("get_inventory_snapshot"):
		return
	var snapshot := player.call("get_inventory_snapshot") as Dictionary
	var dirty := int(snapshot.get("dirty_water", 0))
	if dirty <= 0:
		return
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(245, 34)
	var label := Label.new()
	label.text = "Água bruta  x%d" % dirty
	label.custom_minimum_size = Vector2(155, 32)
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)
	var use := Button.new()
	use.text = "BEBER"
	use.custom_minimum_size = Vector2(72, 32)
	use.add_theme_font_size_override("font_size", 10)
	use.pressed.connect(_drink_dirty_water_0529)
	row.add_child(use)
	items_box.add_child(row)

func _drink_dirty_water_0529() -> void:
	if player != null and player.has_method("drink_unsafe_water_0529"):
		player.call("drink_unsafe_water_0529", 1)
	_refresh_contents()

func get_inventory_ui_debug_0529() -> Dictionary:
	return {"group": is_in_group("inventory_ui_0529")}
