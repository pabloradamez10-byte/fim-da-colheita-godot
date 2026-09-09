extends SceneTree

const SAVE_PATH_0534 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.34 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0534):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0534))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(96):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_equipment_debug_0533"):
		_fail(2, "player 0.5.33 não foi preservado")
		return
	if not scene.has_method("get_location_loot_debug_0534"):
		_fail(3, "World 0.5.34 ausente")
		return
	var chunker := scene.get_node_or_null("ChunkStreamer")
	if chunker == null or not chunker.has_method("get_location_catalog_0534"):
		_fail(4, "streamer de POIs 0.5.34 ausente")
		return
	var catalog := chunker.call("get_location_catalog_0534") as Dictionary
	var city_roles := catalog.get("city_roles", []) as Array
	for role in ["hospital", "market", "workshop", "police"]:
		if role not in city_roles:
			_fail(5, "catálogo não contém POI urbano %s" % role)
			return
	if str(catalog.get("rural_role", "")) != "farm":
		_fail(6, "fazenda não foi definida como POI rural")
		return

	# As tabelas precisam ser semanticamente diferentes e garantir seus recursos centrais.
	var hospital := scene.call("preview_location_loot_0534", "hospital", "smoke_hospital") as Dictionary
	var hospital_items := hospital.get("items", {}) as Dictionary
	if int(hospital_items.get("bandage", 0)) < 2 or int(hospital_items.get("antiseptic", 0)) < 1:
		_fail(7, "hospital não prioriza curativos/antisséptico")
		return
	var market := scene.call("preview_location_loot_0534", "market", "smoke_market") as Dictionary
	var market_food := market.get("foods", {}) as Dictionary
	if int(market_food.get("potato", 0)) < 1 or int(market_food.get("corn", 0)) < 1 or int(market_food.get("carrot", 0)) < 1:
		_fail(8, "mercado não entrega variedade de alimentos")
		return
	var workshop := scene.call("preview_location_loot_0534", "workshop", "smoke_workshop") as Dictionary
	var workshop_items := workshop.get("items", {}) as Dictionary
	if int(workshop_items.get("repair_kit", 0)) < 1 or int(workshop_items.get("gasoline", 0)) < 2:
		_fail(9, "oficina não prioriza reparo/combustível")
		return
	var police := scene.call("preview_location_loot_0534", "police", "smoke_police") as Dictionary
	var police_items := police.get("items", {}) as Dictionary
	if int(police_items.get("ammo_9mm", 0)) < 8 or int(police_items.get("shells", 0)) < 2:
		_fail(10, "delegacia não prioriza munição")
		return
	var farm := scene.call("preview_location_loot_0534", "farm", "smoke_farm") as Dictionary
	var farm_items := farm.get("items", {}) as Dictionary
	for seed_id in ["potato_seed", "corn_seed", "carrot_seed"]:
		if int(farm_items.get(seed_id, 0)) < 2:
			_fail(11, "fazenda não entrega sementes de %s" % seed_id)
			return

	# Aplicação real das cinco tabelas no inventário existente.
	var before := player.call("get_inventory_snapshot") as Dictionary
	for role in ["hospital", "market", "workshop", "police", "farm"]:
		if not bool(scene.call("debug_grant_location_loot_0534", role, player, "grant_%s" % role)):
			_fail(12, "concessão de loot falhou para %s" % role)
			return
	var after := player.call("get_inventory_snapshot") as Dictionary
	if int(after.get("bandage", 0)) <= int(before.get("bandage", 0)):
		_fail(13, "hospital não alterou bandagens do inventário")
		return
	if int(after.get("repair_kit", 0)) <= int(before.get("repair_kit", 0)) or int(after.get("gasoline", 0)) <= int(before.get("gasoline", 0)):
		_fail(14, "oficina não alterou reparo/combustível")
		return
	if int(after.get("ammo_9mm", 0)) <= int(before.get("ammo_9mm", 0)) or int(after.get("shells", 0)) <= int(before.get("shells", 0)):
		_fail(15, "delegacia não alterou munições")
		return
	if int(after.get("corn_seed", 0)) <= int(before.get("corn_seed", 0)) or int(after.get("carrot_seed", 0)) <= int(before.get("carrot_seed", 0)):
		_fail(16, "fazenda não alterou sementes")
		return

	# Valida decoração/registro e a interação de uma caixa especializada no mundo.
	var fake_poi := Node3D.new()
	fake_poi.name = "SmokeHospital0534"
	fake_poi.position = Vector3(500.0, 0.0, 500.0)
	scene.add_child(fake_poi)
	chunker.set("world", scene)
	chunker.call("_decorate_location_0534", fake_poi, "hospital", "smoke:world:hospital")
	if not fake_poi.is_in_group("poi_hospital_0534"):
		_fail(17, "POI hospital não recebeu grupo contextual")
		return
	var local_crates: Array[Node] = []
	for raw in get_nodes_in_group("poi_loot_0534"):
		if raw is Node and fake_poi.is_ancestor_of(raw as Node):
			local_crates.append(raw as Node)
	if local_crates.size() != 2:
		_fail(18, "POI não criou duas fontes de loot especializado")
		return
	var crate := local_crates[0] as Node3D
	var debug_before := scene.call("get_location_loot_debug_0534") as Dictionary
	player.global_position = crate.global_position
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(19, "INTERAGIR não abriu/coletou caixa especializada")
		return
	var debug_after := scene.call("get_location_loot_debug_0534") as Dictionary
	if int(debug_after.get("total", 0)) != int(debug_before.get("total", 0)) + 1:
		_fail(20, "interação especializada não contabilizou loot")
		return

	# Save 0.5.34 deve carregar contadores sem remover equipamento/agricultura/veículos.
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0534, FileAccess.READ)
	if file == null:
		_fail(21, "save 0.5.34 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(22, "save 0.5.34 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.34-alpha":
		_fail(23, "save não recebeu versão 0.5.34")
		return
	var world_state := payload.get("world", {}) as Dictionary
	var saved_counts := world_state.get("specialized_loot_found_0534", {}) as Dictionary
	if int(saved_counts.get("hospital", 0)) < 2 or int(saved_counts.get("farm", 0)) < 1:
		_fail(24, "contadores por localização não foram serializados")
		return

	scene.queue_free()
	for _i in range(14):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(96):
		await process_frame
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_equipment_snapshot_0533"):
		_fail(25, "reload perdeu sistema corporal 0.5.33")
		return
	if not restored.has_method("get_vehicle_debug_0530") or not restored.has_method("get_food_farming_debug_0532"):
		_fail(26, "reload perdeu veículos ou agricultura/alimentação")
		return
	var restored_debug := restored.call("get_location_loot_debug_0534") as Dictionary
	if int(restored_debug.get("total", 0)) < 6 or str(restored_debug.get("last", "")) != "hospital":
		_fail(27, "contadores/último POI não persistiram")
		return

	print("SMOKE 0.5.34 OK: hospital/mercado/oficina/delegacia/fazenda, POI interativo, raridade determinística e persistência preservando 0.5.33")
	if FileAccess.file_exists(SAVE_PATH_0534):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0534))
	quit(0)
