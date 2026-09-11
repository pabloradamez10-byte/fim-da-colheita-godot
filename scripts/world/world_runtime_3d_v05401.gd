extends "res://scripts/world/world_runtime_3d_v0540.gd"

const AnimalV05401Script = preload("res://scripts/entities/animal_3d_v05401.gd")
const SAVE_VERSION_05401 := "0.5.40.1-alpha"

func _spawn_animals_0538() -> void:
	if actors_root == null or not is_instance_valid(actors_root):
		return
	_ensure_animal_records_0538()
	animal_spawn_count_0538 = 0
	for raw_id: Variant in animal_records_0538.keys():
		var id := str(raw_id)
		var state: Dictionary = animal_records_0538[id] as Dictionary
		if bool(state.get("harvested", false)):
			continue
		var animal: CharacterBody3D = AnimalV05401Script.new()
		animal.name = "Animal_%s" % id
		var species := str(state.get("species", "rabbit"))
		animal.call("configure_animal_0538", id, species, state, self)
		animal.position = _dict_to_vec_0538(state.get("position", {}) as Dictionary)
		actors_root.add_child(animal)
		animal_spawn_count_0538 += 1

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_05401
	var world_state := payload.get("world", {}) as Dictionary
	world_state["visual_rework_05401"] = true
	world_state["vehicle_atlas_05401"] = "88x66x40x8"
	world_state["animal_atlas_05401"] = "128x128x4x8"
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func get_visual_rework_debug_05401() -> Dictionary:
	var animal_nodes := get_tree().get_nodes_in_group("animal_high_detail_05401")
	var vehicle_nodes := get_tree().get_nodes_in_group("vehicle_high_detail_05401")
	return {
		"save_version": SAVE_VERSION_05401,
		"animal_sprites": animal_nodes.size(),
		"vehicle_sprites": vehicle_nodes.size(),
		"animal_species": 4,
		"animal_directions": 8,
		"vehicle_variants": 40,
		"vehicle_directions": 8,
		"decision_engine_0540": has_method("get_decision_engine_debug_0540") or has_method("get_atlas_decision_debug_0540"),
		"high_detail": true
	}
