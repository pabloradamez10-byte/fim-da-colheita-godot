class_name HUD3D
extends CanvasLayer

var player: Node = null
var world: Node = null
var refresh := 0.0

@onready var world_status: Label = $TopPanel/WorldStatus
@onready var vitals: Label = $TopPanel/Vitals
@onready var inventory: Label = $TopPanel/Inventory
@onready var weapon: Label = $TopPanel/Weapon

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
		vitals.text = "VIDA %d   FOME %d   SEDE %d   FÔLEGO %d" % [int(data.get("health", 0)),int(data.get("hunger", 0)),int(data.get("thirst", 0)),int(data.get("stamina", 0))]
	if player.has_method("get_inventory_summary"):
		inventory.text = "MOCHILA  " + str(player.call("get_inventory_summary"))
	if player.has_method("get_weapon_summary"):
		weapon.text = "EQUIPADO  " + str(player.call("get_weapon_summary"))
	if world != null and world.has_method("get_world_summary"):
		var summary: Dictionary = world.call("get_world_summary")
		var city_distance := int(summary.get("city_distance", -1))
		var city_text := "Cidade --"
		if city_distance >= 0:
			city_text = "Cidade %dm" % city_distance
		world_status.text = "Seed %s  |  Zumbis %s  |  Chunks %s  |  Prédios %s  |  %s" % [str(summary.get("seed", "?")), str(summary.get("zombies", 0)), str(summary.get("chunks", 0)), str(summary.get("city_buildings", 0)), city_text]
