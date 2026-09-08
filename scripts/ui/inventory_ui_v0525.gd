extends "res://scripts/ui/inventory_ui_v0524.gd"

const TOOL_NAMES_0525 := {
	"machete": "Facão",
	"axe": "Machadinha",
	"spear": "Lança",
	"pistol": "Pistola",
	"shotgun": "Espingarda"
}

var queue_label_0525: Label

func _ready() -> void:
	super._ready()
	add_to_group("inventory_ui_0525")
	_build_queue_ui_0525()

func _build_queue_ui_0525() -> void:
	queue_label_0525 = Label.new()
	queue_label_0525.name = "ProductionQueue0525"
	queue_label_0525.position = Vector2(300, 474)
	queue_label_0525.size = Vector2(540, 24)
	queue_label_0525.add_theme_font_size_override("font_size", 11)
	queue_label_0525.modulate = Color(0.86, 0.84, 0.73, 0.96)
	panel.add_child(queue_label_0525)
	for child in panel.get_children():
		if child is Label:
			var label := child as Label
			if label.text.begins_with("Itens zerados"):
				label.position.y = 501.0
	_update_queue_label_0525()

func _refresh_contents() -> void:
	super._refresh_contents()
	_update_queue_label_0525()

func _update_station_label_0524() -> void:
	super._update_station_label_0524()
	_update_queue_label_0525()

func _add_craft_row(recipe: Dictionary) -> void:
	var recipe_id := str(recipe.get("id", ""))
	var station := str(recipe.get("station", "field"))
	var duration := float(recipe.get("duration_0525", 5.0))
	var tool_required := str(recipe.get("tool_required_0525", ""))
	var tool_ok := bool(recipe.get("tool_ok_0525", true))

	var container := VBoxContainer.new()
	container.custom_minimum_size = Vector2(245, 92)

	var title_row := HBoxContainer.new()
	container.add_child(title_row)
	var name_label := Label.new()
	name_label.text = str(recipe.get("name", recipe_id))
	name_label.custom_minimum_size = Vector2(142, 22)
	name_label.add_theme_font_size_override("font_size", 12)
	title_row.add_child(name_label)
	var station_label := Label.new()
	station_label.text = "BANCADA" if station == "workbench" else "CAMPO"
	station_label.modulate = Color(0.95, 0.73, 0.30, 0.95) if station == "workbench" else Color(0.70, 0.80, 0.66, 0.85)
	station_label.add_theme_font_size_override("font_size", 9)
	title_row.add_child(station_label)

	var req := recipe.get("requirements", {}) as Dictionary
	var parts: Array[String] = []
	for raw_id in req.keys():
		var item_id := str(raw_id)
		parts.append("%s x%d" % [ITEM_NAMES_0524.get(item_id, item_id), int(req[raw_id])])
	var req_label := Label.new()
	req_label.text = " + ".join(parts)
	req_label.modulate = Color(0.82, 0.78, 0.67, 0.9)
	req_label.add_theme_font_size_override("font_size", 9)
	container.add_child(req_label)

	var detail_label := Label.new()
	var tool_text := ""
	if tool_required != "":
		tool_text = " • Ferramenta: %s%s" % [TOOL_NAMES_0525.get(tool_required, tool_required), "" if tool_ok else " (falta/quebrada)"]
	detail_label.text = "Tempo: %.0fs%s" % [duration, tool_text]
	detail_label.modulate = Color(0.73, 0.76, 0.70, 0.88) if tool_ok else Color(0.94, 0.58, 0.46, 0.95)
	detail_label.add_theme_font_size_override("font_size", 9)
	container.add_child(detail_label)

	var craft := Button.new()
	craft.text = "ADICIONAR À FILA"
	craft.custom_minimum_size = Vector2(140, 28)
	craft.add_theme_font_size_override("font_size", 9)
	var queue_ok := bool(recipe.get("queue_ok_0525", false))
	if player != null and player.has_method("can_queue_craft_0525"):
		queue_ok = bool(player.call("can_queue_craft_0525", recipe_id))
	craft.disabled = not queue_ok
	craft.pressed.connect(_on_craft.bind(recipe_id))
	container.add_child(craft)
	crafts_box.add_child(container)

func _update_queue_label_0525() -> void:
	if queue_label_0525 == null:
		return
	if player == null or not player.has_method("get_production_status_0525"):
		queue_label_0525.text = "FILA DE PRODUÇÃO: —"
		return
	var status := player.call("get_production_status_0525") as Dictionary
	var queue_size := int(status.get("queue_size", 0))
	var capacity := int(status.get("capacity", 4))
	var current := status.get("current", {}) as Dictionary
	if queue_size <= 0 or current.is_empty():
		queue_label_0525.text = "FILA DE PRODUÇÃO: vazia (%d espaços)" % capacity
		return
	var state := str(current.get("state", "queued"))
	var state_text := "na fila"
	if state == "running":
		state_text = "produzindo"
	elif state in ["waiting_station", "paused_station"]:
		state_text = "pausada: volte à bancada"
	elif state in ["waiting_tool", "paused_tool"]:
		state_text = "pausada: ferramenta necessária"
	elif state == "waiting_resources":
		state_text = "aguardando materiais"
	var remaining := maxf(0.0, float(current.get("remaining", 0.0)))
	queue_label_0525.text = "FILA %d/%d • %s • %s • %.1fs" % [queue_size, capacity, str(current.get("name", "Produção")), state_text, remaining]

func get_queue_ui_debug_0525() -> Dictionary:
	return {
		"label": queue_label_0525 != null,
		"text": queue_label_0525.text if queue_label_0525 != null else "",
		"group": is_in_group("inventory_ui_0525")
	}
