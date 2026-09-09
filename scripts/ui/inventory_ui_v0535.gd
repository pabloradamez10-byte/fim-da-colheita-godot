extends "res://scripts/ui/inventory_ui_v0533.gd"

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0535")
	if equipment_box_0533 != null:
		equipment_box_0533.custom_minimum_size = Vector2(248, 1080)
	if panel != null:
		for child: Node in panel.get_children():
			if child is Label and (child as Label).text == "MOCHILA • ARMAS • CRAFT • VESTUÁRIO":
				(child as Label).text = "MOCHILA • ARMAS • CRAFT • VESTUÁRIO • PROGRESSÃO"
	_refresh_equipment_0533()

func _refresh_equipment_0533() -> void:
	super._refresh_equipment_0533()
	if equipment_box_0533 == null or player == null or not player.has_method("get_progression_snapshot_0535"):
		return
	var snapshot: Dictionary = player.call("get_progression_snapshot_0535") as Dictionary
	var attributes: Dictionary = snapshot.get("attributes", {}) as Dictionary
	var skills: Dictionary = snapshot.get("skills", {}) as Dictionary

	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(236, 10)
	equipment_box_0533.add_child(separator)

	var title := Label.new()
	title.text = "PROGRESSÃO DO SOBREVIVENTE"
	title.add_theme_font_size_override("font_size", 11)
	title.modulate = Color(0.92, 0.72, 0.34, 1.0)
	equipment_box_0533.add_child(title)

	var level_label := Label.new()
	level_label.text = "NÍVEL %d  •  XP TOTAL %d" % [int(snapshot.get("survivor_level", 1)), int(snapshot.get("total_xp", 0))]
	level_label.add_theme_font_size_override("font_size", 10)
	equipment_box_0533.add_child(level_label)

	var attributes_label := Label.new()
	attributes_label.text = "ATRIBUTOS  Força %d • Vigor %d • Percepção %d" % [int(attributes.get("strength", 5)), int(attributes.get("conditioning", 5)), int(attributes.get("perception", 5))]
	attributes_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	attributes_label.custom_minimum_size = Vector2(238, 34)
	attributes_label.add_theme_font_size_override("font_size", 9)
	attributes_label.modulate = Color(0.80, 0.84, 0.73, 0.95)
	equipment_box_0533.add_child(attributes_label)

	for skill_id in ["combat", "farming", "medicine", "mechanics", "scavenging"]:
		if not skills.has(skill_id):
			continue
		_add_skill_row_0535(skills[skill_id] as Dictionary)

	var last_level_up := str(snapshot.get("last_level_up", ""))
	if last_level_up != "":
		var level_up := Label.new()
		level_up.text = "ÚLTIMA EVOLUÇÃO: %s" % last_level_up
		level_up.add_theme_font_size_override("font_size", 9)
		level_up.modulate = Color(0.95, 0.70, 0.28, 1.0)
		equipment_box_0533.add_child(level_up)

	if equipment_stats_0533 != null:
		equipment_stats_0533.text += "\nNÍVEL %d • Força %d • Vigor %d • Percepção %d" % [int(snapshot.get("survivor_level", 1)), int(attributes.get("strength", 5)), int(attributes.get("conditioning", 5)), int(attributes.get("perception", 5))]

func _add_skill_row_0535(data: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(240, 46)
	var label := Label.new()
	var level := int(data.get("level", 0))
	var xp := int(data.get("xp", 0))
	var next_xp := int(data.get("next_threshold", xp))
	label.text = "%s  Nv.%d  •  %d/%d XP" % [str(data.get("name", "Perícia")), level, xp, next_xp]
	label.add_theme_font_size_override("font_size", 9)
	box.add_child(label)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(232, 14)
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = float(data.get("ratio", 0.0)) * 100.0
	bar.show_percentage = false
	box.add_child(bar)
	equipment_box_0533.add_child(box)

func get_inventory_ui_debug_0535() -> Dictionary:
	var base := get_inventory_ui_debug_0533()
	base["group_0535"] = is_in_group("inventory_ui_0535")
	base["progression_available"] = player != null and player.has_method("get_progression_snapshot_0535")
	base["equipment_min_height"] = equipment_box_0533.custom_minimum_size.y if equipment_box_0533 != null else 0.0
	return base
