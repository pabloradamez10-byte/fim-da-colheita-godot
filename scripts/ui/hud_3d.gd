class_name HUD3D
extends CanvasLayer

var player: Node = null
var world: Node = null
var refresh := 0.0

@onready var top_panel: ColorRect = $TopPanel
@onready var title: Label = $TopPanel/Title
@onready var world_status: Label = $TopPanel/WorldStatus
@onready var vitals: Label = $TopPanel/Vitals
@onready var inventory: Label = $TopPanel/Inventory
@onready var weapon: Label = $TopPanel/Weapon
@onready var hint: Label = $Hint

func _ready() -> void:
	get_viewport().size_changed.connect(_refresh_layout_05321)
	_refresh_layout_05321()

func _refresh_layout_05321() -> void:
	if top_panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_width := clampf(viewport_size.x - 190.0, 760.0, 1080.0)
	top_panel.position = Vector2(16.0, 12.0)
	top_panel.size = Vector2(panel_width, 106.0)

	var content_width := maxf(200.0, panel_width - 28.0)
	title.position = Vector2(14.0, 5.0)
	title.size = Vector2(content_width, 19.0)
	world_status.position = Vector2(14.0, 25.0)
	world_status.size = Vector2(content_width, 18.0)
	vitals.position = Vector2(14.0, 44.0)
	vitals.size = Vector2(content_width, 18.0)
	inventory.position = Vector2(14.0, 63.0)
	inventory.size = Vector2(content_width, 18.0)
	weapon.position = Vector2(14.0, 82.0)
	weapon.size = Vector2(content_width, 19.0)

	title.add_theme_font_size_override("font_size", 17)
	world_status.add_theme_font_size_override("font_size", 11)
	vitals.add_theme_font_size_override("font_size", 11)
	inventory.add_theme_font_size_override("font_size", 11)
	weapon.add_theme_font_size_override("font_size", 11)

	hint.position = Vector2(18.0, 121.0)
	hint.size = Vector2(maxf(320.0, viewport_size.x - 36.0), 20.0)
	hint.add_theme_font_size_override("font_size", 10)

func _process(delta: float) -> void:
	refresh += delta
	if refresh < 0.15:
		return
	refresh = 0.0
	if world == null:
		world = get_parent()
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if player.has_method("get_vitals"):
		var data: Dictionary = player.call("get_vitals")
		var pain := int(data.get("pain", 0))
		var bleeding := float(data.get("bleeding", 0.0))
		var infection := int(data.get("infection", 0))
		var fatigue := int(data.get("fatigue", 0))
		var wetness := int(data.get("wetness", 0))
		var water_sickness := int(round(float(data.get("water_sickness", 0.0))))
		var body_temp := float(data.get("body_temperature", 36.9))
		var sheltered := bool(data.get("sheltered", false))
		var condition := ""
		if pain >= 15 or bleeding >= 0.25 or infection >= 10:
			condition = "   DOR %d   SANG %.1f   INFEC %d" % [pain, bleeding, infection]
		if water_sickness >= 10:
			condition += "   CONTAM.ÁGUA %d" % water_sickness
		var shelter_text := " ABRIGO" if sheltered else ""
		var wet_text := ""
		if wetness >= 8:
			wet_text = "   MOLHADO %d" % wetness
		vitals.text = "VIDA %d   FOME %d   SEDE %d   FÔLEGO %d   CANSAÇO %d   TEMP %.1f°%s%s%s" % [int(data.get("health", 0)), int(data.get("hunger", 0)), int(data.get("thirst", 0)), int(data.get("stamina", 0)), fatigue, body_temp, shelter_text, wet_text, condition]
	if player.has_method("get_inventory_summary"):
		inventory.text = "MOCHILA  " + str(player.call("get_inventory_summary"))
	if player.has_method("get_weapon_summary"):
		weapon.text = "EQUIPADO  " + str(player.call("get_weapon_summary"))
		if player.has_method("get_equipment_summary_0533"):
			weapon.text += "  |  " + str(player.call("get_equipment_summary_0533"))
	if world != null and world.has_method("get_world_summary"):
		var summary: Dictionary = world.call("get_world_summary")
		var city_distance := int(summary.get("city_distance", -1))
		var city_text := "Cidade --"
		if city_distance >= 0:
			city_text = "Cidade %dm" % city_distance
		var kills := int(summary.get("kills_0520", -1))
		var deaths := int(summary.get("deaths_0520", -1))
		var day := int(summary.get("day_0521", 0))
		var time_text := str(summary.get("time_0521", "--:--"))
		var ambient := int(round(float(summary.get("ambient_temperature_0521", 18.0))))
		var weather := str(summary.get("weather_0522", "ABERTO"))
		var period := "NOITE" if bool(summary.get("night_0521", false)) else "DIA"
		var loop_text := ""
		if kills >= 0 and deaths >= 0:
			loop_text = "  |  Abates %d  Mortes %d" % [kills, deaths]
		var water_text := ""
		if summary.has("rain_water_stored_0529"):
			water_text = "  |  Chuva %.1f" % float(summary.get("rain_water_stored_0529", 0.0))
		var vehicle_text := ""
		var driving_name := str(summary.get("driving_vehicle_0530", ""))
		if driving_name != "":
			vehicle_text = "  |  %s  %.1fL  INT %d" % [driving_name, float(summary.get("driving_fuel_0530", 0.0)), int(round(float(summary.get("driving_health_0530", 0.0))))]
			weapon.text = "DIRIGINDO  •  joystick acelera/freia e esterça  •  INTERAGIR para sair"
		if day > 0:
			world_status.text = "Dia %d  %s  %s  %s  %d°C  |  Zumbis %s  |  %s%s%s%s" % [day, time_text, period, weather, ambient, str(summary.get("zombies", 0)), city_text, loop_text, water_text, vehicle_text]
		else:
			world_status.text = "Seed %s  |  Zumbis %s  |  Chunks %s  |  Prédios %s  |  %s%s%s%s" % [str(summary.get("seed", "?")), str(summary.get("zombies", 0)), str(summary.get("chunks", 0)), str(summary.get("city_buildings", 0)), city_text, loop_text, water_text, vehicle_text]

func get_hud_layout_debug_05321() -> Dictionary:
	return {
		"panel_position": top_panel.position if top_panel != null else Vector2.ZERO,
		"panel_size": top_panel.size if top_panel != null else Vector2.ZERO,
		"hint_position": hint.position if hint != null else Vector2.ZERO
	}
