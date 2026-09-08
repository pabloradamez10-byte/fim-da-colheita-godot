extends "res://scripts/ui/inventory_ui_v0520.gd"

const WEAPON_NAMES_0523 := {
	"machete":"Facão", "pistol":"Pistola 9mm", "shotgun":"Espingarda",
	"axe":"Machadinha", "spear":"Lança"
}
const MATERIAL_NAMES_0523 := {
	"wood":"Madeira", "stone":"Pedra", "fiber":"Fibra"
}

func _add_weapon_row(id: String, equipped: bool) -> void:
	var container := VBoxContainer.new()
	container.custom_minimum_size = Vector2(255, 58)

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(255, 38)
	container.add_child(row)

	var durability := 100
	var broken := false
	if player != null and player.has_method("get_weapon_durability_percent_0523"):
		durability = int(player.call("get_weapon_durability_percent_0523", id))
	if player != null and player.has_method("is_weapon_broken_0523"):
		broken = bool(player.call("is_weapon_broken_0523", id))

	var label := Label.new()
	label.text = "%s%s\n%s" % [WEAPON_NAMES_0523.get(id, id), " ✓" if equipped else "", "QUEBRADA" if broken else "DUR %d%%" % durability]
	label.custom_minimum_size = Vector2(112, 38)
	label.add_theme_font_size_override("font_size", 12)
	row.add_child(label)

	var equip := Button.new()
	equip.text = "ATIVO" if equipped else "EQUIP."
	equip.disabled = equipped
	equip.custom_minimum_size = Vector2(66, 36)
	equip.add_theme_font_size_override("font_size", 10)
	equip.pressed.connect(_on_equip_weapon.bind(id))
	row.add_child(equip)

	var repair := Button.new()
	repair.text = "REPARAR"
	repair.custom_minimum_size = Vector2(70, 36)
	repair.add_theme_font_size_override("font_size", 9)
	if player == null or not player.has_method("can_repair_weapon_0523"):
		repair.disabled = true
	else:
		repair.disabled = not bool(player.call("can_repair_weapon_0523", id))
	repair.pressed.connect(_on_repair_weapon_0523.bind(id))
	row.add_child(repair)

	var cost_label := Label.new()
	cost_label.modulate = Color(0.78, 0.75, 0.66, 0.82)
	cost_label.add_theme_font_size_override("font_size", 10)
	cost_label.text = "Reparo: " + _repair_cost_text_0523(id)
	container.add_child(cost_label)
	weapons_box.add_child(container)

func _repair_cost_text_0523(id: String) -> String:
	if player == null or not player.has_method("get_repair_cost_0523"):
		return "—"
	var raw: Variant = player.call("get_repair_cost_0523", id)
	if not (raw is Dictionary):
		return "—"
	var cost := raw as Dictionary
	var parts: Array[String] = []
	for raw_id in cost.keys():
		var item_id := str(raw_id)
		parts.append("%s %d" % [MATERIAL_NAMES_0523.get(item_id, item_id), int(cost[raw_id])])
	return " + ".join(parts) if not parts.is_empty() else "—"

func _on_repair_weapon_0523(id: String) -> void:
	if player != null and player.has_method("repair_weapon_0523"):
		player.call("repair_weapon_0523", id)
		_refresh_contents()
