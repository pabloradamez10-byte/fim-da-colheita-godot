extends "res://scripts/player/player_3d_v0530.gd"

const STARTING_POTATO_SEEDS_0531 := 4

func _ready() -> void:
	super._ready()
	_ensure_farming_inventory_0531()

func _ensure_farming_inventory_0531() -> void:
	if not inventory.has("potato_seed"):
		inventory["potato_seed"] = STARTING_POTATO_SEEDS_0531
	if not inventory.has("potato"):
		inventory["potato"] = 0

func get_inventory_summary() -> String:
	var result := super.get_inventory_summary()
	var seeds := int(inventory.get("potato_seed", 0))
	var potatoes := int(inventory.get("potato", 0))
	if seeds > 0:
		result += " | Sementes %d" % seeds
	if potatoes > 0:
		result += " | Batatas %d" % potatoes
	return result

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	_ensure_farming_inventory_0531()

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	inventory["potato_seed"] = STARTING_POTATO_SEEDS_0531
	inventory["potato"] = 0

func get_agriculture_player_debug_0531() -> Dictionary:
	return {
		"potato_seed": int(inventory.get("potato_seed", 0)),
		"potato": int(inventory.get("potato", 0))
	}
