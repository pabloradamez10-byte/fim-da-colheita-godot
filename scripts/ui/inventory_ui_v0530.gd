extends "res://scripts/ui/inventory_ui_v0529.gd"

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0530")

func _refresh_contents() -> void:
	super._refresh_contents()
	if player == null or items_box == null or not player.has_method("get_inventory_snapshot"):
		return
	var snapshot := player.call("get_inventory_snapshot") as Dictionary
	var gasoline := int(snapshot.get("gasoline", 0))
	if gasoline <= 0:
		return
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(245, 34)
	var label := Label.new()
	label.text = "Gasolina  x%d L" % gasoline
	label.custom_minimum_size = Vector2(230, 32)
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)
	items_box.add_child(row)

func get_inventory_ui_debug_0530() -> Dictionary:
	return {"group": is_in_group("inventory_ui_0530")}
