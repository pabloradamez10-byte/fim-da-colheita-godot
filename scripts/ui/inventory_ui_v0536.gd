extends "res://scripts/ui/inventory_ui_v0535.gd"

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0536")
	if equipment_box_0533 != null:
		equipment_box_0533.custom_minimum_size = Vector2(248, 1540)
	if panel != null:
		for child: Node in panel.get_children():
			if child is Label and (child as Label).text == "MOCHILA • ARMAS • CRAFT • VESTUÁRIO • PROGRESSÃO":
				(child as Label).text = "MOCHILA • ARMAS • CRAFT • VESTUÁRIO • PROGRESSÃO • OBJETIVOS"
	_refresh_equipment_0533()

func _refresh_equipment_0533() -> void:
	super._refresh_equipment_0533()
	if equipment_box_0533 == null or player == null:
		return
	var world_node: Node = player.get("world") as Node
	if world_node == null or not world_node.has_method("get_mission_snapshot_0536"):
		return
	var snapshot: Dictionary = world_node.call("get_mission_snapshot_0536") as Dictionary
	var missions: Array = snapshot.get("missions", []) as Array

	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(236, 10)
	equipment_box_0533.add_child(separator)

	var title := Label.new()
	title.text = "OBJETIVOS DE SOBREVIVÊNCIA  %d/%d" % [int(snapshot.get("completed", 0)), int(snapshot.get("total", 0))]
	title.add_theme_font_size_override("font_size", 11)
	title.modulate = Color(0.92, 0.72, 0.34, 1.0)
	equipment_box_0533.add_child(title)

	for raw: Variant in missions:
		if raw is Dictionary:
			_add_mission_row_0536(raw as Dictionary)

	var last_completed := str(snapshot.get("last_completed", ""))
	if last_completed != "":
		var done := Label.new()
		done.text = "ÚLTIMA MISSÃO CONCLUÍDA: %s" % last_completed.replace("_", " ").to_upper()
		done.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		done.custom_minimum_size = Vector2(238, 34)
		done.add_theme_font_size_override("font_size", 9)
		done.modulate = Color(0.72, 0.88, 0.55, 1.0)
		equipment_box_0533.add_child(done)

func _add_mission_row_0536(mission: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(240, 82)
	var completed := bool(mission.get("completed", false))
	var progress := int(mission.get("progress", 0))
	var target := maxi(1, int(mission.get("target", 1)))

	var title := Label.new()
	title.text = "%s  %s" % ["✓" if completed else "•", str(mission.get("title", "OBJETIVO"))]
	title.add_theme_font_size_override("font_size", 9)
	title.modulate = Color(0.65, 0.86, 0.52, 1.0) if completed else Color(0.92, 0.90, 0.82, 1.0)
	box.add_child(title)

	var description := Label.new()
	description.text = str(mission.get("description", ""))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(236, 26)
	description.add_theme_font_size_override("font_size", 8)
	description.modulate = Color(0.73, 0.76, 0.70, 0.92)
	box.add_child(description)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(232, 14)
	bar.min_value = 0.0
	bar.max_value = float(target)
	bar.value = float(progress)
	bar.show_percentage = false
	box.add_child(bar)

	var reward_items: Dictionary = mission.get("reward_items", {}) as Dictionary
	var reward_parts: Array[String] = []
	for raw_id: Variant in reward_items.keys():
		reward_parts.append("%s x%d" % [str(raw_id).replace("_", " "), int(reward_items[raw_id])])
	var reward := Label.new()
	reward.text = "%d/%d  •  RECOMPENSA: %s + %d XP" % [progress, target, ", ".join(reward_parts), int(mission.get("reward_xp", 0))]
	reward.add_theme_font_size_override("font_size", 8)
	reward.modulate = Color(0.82, 0.69, 0.42, 0.92)
	box.add_child(reward)
	equipment_box_0533.add_child(box)

func get_inventory_ui_debug_0536() -> Dictionary:
	var base: Dictionary = get_inventory_ui_debug_0535()
	var world_node: Node = player.get("world") as Node if player != null else null
	base["group_0536"] = is_in_group("inventory_ui_0536")
	base["missions_available"] = world_node != null and world_node.has_method("get_mission_snapshot_0536")
	base["equipment_min_height_0536"] = equipment_box_0533.custom_minimum_size.y if equipment_box_0533 != null else 0.0
	return base
