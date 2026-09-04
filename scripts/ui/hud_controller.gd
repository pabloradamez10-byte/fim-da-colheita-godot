class_name HUDController
extends CanvasLayer

var refresh_accumulator := 0.0
var player: Node = null
var hotbar_buttons: Dictionary = {}

@onready var world_status: Label = $TopPanel/WorldStatus
@onready var vitals: Label = $TopPanel/Vitals
@onready var inventory: Label = $TopPanel/Inventory

func _ready() -> void:
	_build_hotbar()

func _process(delta: float) -> void:
	refresh_accumulator += delta
	if refresh_accumulator < 0.15: return
	refresh_accumulator = 0.0
	if player == null or not is_instance_valid(player): player = get_tree().get_first_node_in_group("player")
	if player == null: return
	if player.has_method("get_vitals"):
		var data: Dictionary = player.call("get_vitals")
		vitals.text = "VIDA %d   FOME %d   SEDE %d   FÔLEGO %d" % [int(data.get("health", 0)), int(data.get("hunger", 0)), int(data.get("thirst", 0)), int(data.get("stamina", 0))]
	if player.has_method("get_inventory_summary"): inventory.text = "MOCHILA  " + str(player.call("get_inventory_summary"))
	var world := get_parent()
	var zombie_count := get_tree().get_nodes_in_group("zombies").size()
	var weapon := "machete"
	if player.has_method("get_equipped_weapon"): weapon = str(player.call("get_equipped_weapon"))
	world_status.text = "ALPHA 0.4.0 | Seed %s | Zumbis %d | Arma: %s | Auto-save" % [str(world.get("world_seed")), zombie_count, _weapon_label(weapon)]
	_refresh_hotbar_selection(weapon)

func _build_hotbar() -> void:
	var panel := PanelContainer.new()
	panel.name = "HotbarPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	panel.offset_left = -235.0
	panel.offset_top = -96.0
	panel.offset_right = 235.0
	panel.offset_bottom = -12.0
	add_child(panel)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	panel.add_child(bar)
	for weapon_id in ["machete", "axe", "pistol", "shotgun"]:
		var button := Button.new()
		button.custom_minimum_size = Vector2(108, 76)
		button.text = _weapon_label(weapon_id)
		button.icon = VisualAssets.texture(weapon_id)
		button.expand_icon = true
		button.icon_max_width = 46
		button.pressed.connect(_on_hotbar_pressed.bind(weapon_id))
		bar.add_child(button)
		hotbar_buttons[weapon_id] = button

func _on_hotbar_pressed(weapon_id: String) -> void:
	if player == null or not is_instance_valid(player): player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("set_equipped_weapon"): player.call("set_equipped_weapon", weapon_id)

func _refresh_hotbar_selection(weapon_id: String) -> void:
	for key in hotbar_buttons:
		var button := hotbar_buttons[key] as Button
		if button != null: button.modulate = Color(1.0, 0.84, 0.50, 1.0) if str(key) == weapon_id else Color.WHITE

func _weapon_label(weapon_id: String) -> String:
	match weapon_id:
		"machete": return "FACÃO"
		"axe": return "MACHADO"
		"pistol": return "PISTOLA"
		"shotgun": return "ESPING."
	return weapon_id.to_upper()
