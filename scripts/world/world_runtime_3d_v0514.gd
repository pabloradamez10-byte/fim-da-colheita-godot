extends "res://scripts/world/world_runtime_3d_v0513.gd"

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var special_index := _pick_special_interactable_0513(pos, target_player)
	if special_index < 0:
		return super.try_interact_near(pos, target_player)

	var data := interactables[special_index] as Dictionary
	var kind := str(data.get("type", ""))
	var key := str(data.get("key", ""))
	var node_value: Variant = data.get("node")

	if kind == "door" or kind == "window":
		if node_value is Node3D and is_instance_valid(node_value as Node3D) and (node_value as Node3D).has_method("toggle_interaction"):
			(node_value as Node3D).call("toggle_interaction")
			return true
		return false

	if kind.begins_with("loot_"):
		_grant_contextual_loot_0514(kind, key, node_value as Node3D if node_value is Node3D else null, target_player)
		harvested_keys.append(key)
		interactables.remove_at(special_index)
		save_game()
		return true

	return super.try_interact_near(pos, target_player)

func _grant_contextual_loot_0514(kind: String, key: String, source: Node3D, target_player: Node) -> void:
	if target_player == null or not target_player.has_method("add_item"):
		return
	var marker := int(abs(hash("roomloot0514:%s:%d:%s" % [key, world_seed, source.name if source != null else kind])))
	match kind:
		"loot_fridge":
			# Geladeira: prioridade absoluta para comida e água.
			target_player.call("add_item", "food", 2 + marker % 3)
			target_player.call("add_item", "water", 1 + int(marker / 5) % 2)
		"loot_pantry":
			# Despensa: mantimentos secos; às vezes panos/embalagens úteis no craft.
			target_player.call("add_item", "food", 1 + marker % 3)
			if marker % 3 == 0:
				target_player.call("add_item", "fiber", 1)
		"loot_wardrobe":
			# Guarda-roupa/cômoda: tecido e pequena chance de bandagem pronta.
			target_player.call("add_item", "fiber", 2 + marker % 3)
			if marker % 3 != 1:
				target_player.call("add_item", "bandage", 1)
		"loot_medicine":
			# Armário do banheiro é a fonte doméstica mais confiável de curativos.
			target_player.call("add_item", "bandage", 2 + marker % 2)
			if marker % 4 == 0:
				target_player.call("add_item", "water", 1)
		"loot_bathroom":
			target_player.call("add_item", "bandage", 1 + marker % 2)
			if marker % 5 == 0:
				target_player.call("add_item", "water", 1)
		"loot_living":
			# Sala: poucos recursos, mas tecidos e comida esquecida ainda podem aparecer.
			target_player.call("add_item", "fiber", 1 + marker % 2)
			if marker % 4 == 0:
				target_player.call("add_item", "food", 1)
		"loot_kitchen":
			target_player.call("add_item", "food", 1 + marker % 3)
			if marker % 2 == 0:
				target_player.call("add_item", "water", 1)
		"loot_bedroom":
			target_player.call("add_item", "fiber", 1 + marker % 3)
			if marker % 3 == 0:
				target_player.call("add_item", "bandage", 1)
		_:
			target_player.call("add_item", "fiber", 1)

func get_debug_0514() -> Dictionary:
	var counts := {
		"fridge": 0,
		"pantry": 0,
		"wardrobe": 0,
		"medicine": 0,
		"bathroom": 0,
		"living": 0
	}
	for raw in interactables:
		var data := raw as Dictionary
		var kind := str(data.get("type", ""))
		match kind:
			"loot_fridge": counts["fridge"] = int(counts["fridge"]) + 1
			"loot_pantry": counts["pantry"] = int(counts["pantry"]) + 1
			"loot_wardrobe": counts["wardrobe"] = int(counts["wardrobe"]) + 1
			"loot_medicine": counts["medicine"] = int(counts["medicine"]) + 1
			"loot_bathroom": counts["bathroom"] = int(counts["bathroom"]) + 1
			"loot_living": counts["living"] = int(counts["living"]) + 1
	return {"contextual_loot": counts, "internal_doors": get_tree().get_nodes_in_group("internal_door_0514").size()}
