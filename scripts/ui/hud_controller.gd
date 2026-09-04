class_name HUDController
extends CanvasLayer

var refresh_accumulator := 0.0
var player: Node = null

@onready var world_status: Label = $TopPanel/WorldStatus
@onready var vitals: Label = $TopPanel/Vitals
@onready var inventory: Label = $TopPanel/Inventory

func _process(delta: float) -> void:
	refresh_accumulator += delta
	if refresh_accumulator < 0.15:
		return
	refresh_accumulator = 0.0

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	if player.has_method("get_vitals"):
		var data: Dictionary = player.call("get_vitals")
		vitals.text = "VIDA %d | FOME %d | SEDE %d | FÔLEGO %d" % [
			int(data.get("health", 0)),
			int(data.get("hunger", 0)),
			int(data.get("thirst", 0)),
			int(data.get("stamina", 0))
		]

	if player.has_method("get_inventory_summary"):
		inventory.text = "MOCHILA  " + str(player.call("get_inventory_summary"))

	var world := get_parent()
	var zombie_count := get_tree().get_nodes_in_group("zombies").size()
	world_status.text = "ALPHA 0.3.0 | Seed %s | Zumbis %d | Auto-save ativo" % [str(world.get("world_seed")), zombie_count]
