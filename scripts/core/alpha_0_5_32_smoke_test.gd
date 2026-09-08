extends SceneTree

const SAVE_PATH_0532 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.32 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0532):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0532))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(96):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_food_debug_0532"):
		_fail(2, "PlayerV0532 não foi instanciado")
		return
	if not scene.has_method("get_food_farming_debug_0532"):
		_fail(3, "WorldV0532 ausente")
		return
	if not scene.has_method("get_agriculture_debug_0531") or not scene.has_method("get_vehicle_debug_0530"):
		_fail(4, "regressão: agricultura 0.5.31 ou veículos 0.5.30 desapareceram")
		return
	if get_nodes_in_group("inventory_ui_0532").is_empty():
		_fail(5, "inventário 0.5.32 ausente")
		return
	if get_nodes_in_group("campfire_ui_0532").is_empty():
		_fail(6, "cozinha da fogueira 0.5.32 ausente")
		return

	var food_debug := player.call("get_food_debug_0532") as Dictionary
	if int(food_debug.get("corn_seed", 0)) < 3 or int(food_debug.get("carrot_seed", 0)) < 3:
		_fail(7, "sementes iniciais de milho/cenoura não foram criadas")
		return

	# Milho: seleção explícita, plantio, chuva, crescimento e colheita.
	if not bool(scene.call("select_crop_0532", "corn")):
		_fail(8, "seleção de milho falhou")
		return
	var plot0 := scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	player.global_position = plot0.get("position", Vector3.ZERO) as Vector3
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(9, "preparo do canteiro de milho falhou")
		return
	var seeds_before := int((player.call("get_inventory_snapshot") as Dictionary).get("corn_seed", 0))
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(10, "plantio de milho falhou")
		return
	plot0 = scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	if str(plot0.get("crop_id", "")) != "corn" or int(plot0.get("state", -1)) != 2:
		_fail(11, "canteiro não registrou cultura milho")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("corn_seed", 0)) != seeds_before - 1:
		_fail(12, "milho não consumiu semente")
		return
	scene.call("set_weather_override_0522", 2)
	scene.call("advance_time_0521", 950.0, false)
	scene.call("refresh_farming_0531")
	plot0 = scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	if int(plot0.get("state", -1)) != 4:
		_fail(13, "milho não amadureceu no tempo específico")
		return
	player.global_position = plot0.get("position", Vector3.ZERO) as Vector3
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(14, "colheita do milho falhou")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("corn", 0)) < 3:
		_fail(15, "colheita não entregou milho")
		return

	# Cenoura: tempo menor e rendimento próprio.
	if not bool(scene.call("select_crop_0532", "carrot")):
		_fail(16, "seleção de cenoura falhou")
		return
	var plot1 := scene.call("get_farm_plot_state_0531", "plot_01") as Dictionary
	player.global_position = plot1.get("position", Vector3.ZERO) as Vector3
	scene.call("try_interact_near", player.global_position, player)
	scene.call("try_interact_near", player.global_position, player)
	plot1 = scene.call("get_farm_plot_state_0531", "plot_01") as Dictionary
	if str(plot1.get("crop_id", "")) != "carrot":
		_fail(17, "canteiro não registrou cultura cenoura")
		return
	scene.call("advance_time_0521", 650.0, false)
	scene.call("refresh_farming_0531")
	plot1 = scene.call("get_farm_plot_state_0531", "plot_01") as Dictionary
	if int(plot1.get("state", -1)) != 4:
		_fail(18, "cenoura não amadureceu no tempo específico")
		return
	player.global_position = plot1.get("position", Vector3.ZERO) as Vector3
	scene.call("try_interact_near", player.global_position, player)
	if int((player.call("get_inventory_snapshot") as Dictionary).get("carrot", 0)) < 4:
		_fail(19, "colheita não entregou cenouras")
		return

	# Comida crua alimenta e é consumida.
	player.set("hunger", 30.0)
	var carrot_before := int((player.call("get_inventory_snapshot") as Dictionary).get("carrot", 0))
	if not bool(player.call("use_inventory_item", "carrot")):
		_fail(20, "cenoura crua não pôde ser comida")
		return
	if float(player.get("hunger")) <= 30.0:
		_fail(21, "comida crua não recuperou fome")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("carrot", 0)) != carrot_before - 1:
		_fail(22, "comer não consumiu a cenoura")
		return

	# Fogueira existente vira estação de cozinha e consome combustível.
	player.call("add_item", "wood", 20)
	player.call("add_item", "stone", 12)
	player.global_position = Vector3(116.0, 0.20, 86.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	if not bool(scene.call("select_build_piece_0526", "campfire")):
		_fail(23, "seleção da fogueira falhou")
		return
	await process_frame
	if not bool((scene.call("get_build_debug_0526") as Dictionary).get("valid", false)):
		_fail(24, "preview da fogueira inválido")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(25, "fogueira não foi construída")
		return
	for _i in range(3):
		await process_frame
	var fires := get_nodes_in_group("campfire_0528")
	if fires.is_empty():
		_fail(26, "fogueira construída não foi encontrada")
		return
	var fire := fires[0] as Node3D
	var fire_uid := str(fire.get_meta("campfire_uid_0528", ""))
	player.global_position = fire.global_position + Vector3(0.7, 0.0, 0.0)
	if not bool(scene.call("campfire_add_fuel_0528", fire_uid, player)):
		_fail(27, "não foi possível adicionar lenha")
		return
	if not bool(scene.call("campfire_toggle_0528", fire_uid)):
		_fail(28, "fogueira não acendeu")
		return
	player.call("receive_food_item_0532", "potato", 1, 100.0)
	var fuel_before := float((scene.call("get_campfire_status_0528", fire_uid) as Dictionary).get("fuel_minutes", 0.0))
	if not bool(scene.call("campfire_cook_food_0532", fire_uid, player, "baked_potato")):
		_fail(29, "cozinhar batata na fogueira falhou")
		return
	var snapshot := player.call("get_inventory_snapshot") as Dictionary
	if int(snapshot.get("cooked_potato", 0)) < 1:
		_fail(30, "receita não entregou batata assada")
		return
	var fuel_after := float((scene.call("get_campfire_status_0528", fire_uid) as Dictionary).get("fuel_minutes", 0.0))
	if absf((fuel_before - fuel_after) - 8.0) > 0.6:
		_fail(31, "cozinha não consumiu combustível da fogueira")
		return

	# Frescor decai e comida vencida vira pilha estragada.
	player.call("receive_food_item_0532", "corn", 2, 100.0)
	player.call("advance_food_decay_0532", 3000.0)
	food_debug = player.call("get_food_debug_0532") as Dictionary
	if int(food_debug.get("spoiled_food", 0)) <= 0 or int(food_debug.get("spoiled", 0)) <= 0:
		_fail(32, "validade não converteu comida vencida em estragada")
		return

	# Save/load preserva culturas, seleção, alimentos e contadores.
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0532, FileAccess.READ)
	if file == null:
		_fail(33, "save 0.5.32 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(34, "save 0.5.32 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.32-alpha":
		_fail(35, "save não recebeu versão 0.5.32")
		return
	var world_state := payload.get("world", {}) as Dictionary
	if str(world_state.get("selected_crop_0532", "")) != "carrot":
		_fail(36, "cultura selecionada não foi serializada")
		return
	var totals := world_state.get("crop_harvest_totals_0532", {}) as Dictionary
	if int(totals.get("corn", 0)) < 3 or int(totals.get("carrot", 0)) < 4:
		_fail(37, "totais de colheita não foram persistidos")
		return

	scene.queue_free()
	for _i in range(14):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(100):
		await process_frame
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_food_debug_0532"):
		_fail(38, "PlayerV0532 não voltou após reload")
		return
	var restored_debug := restored_player.call("get_food_debug_0532") as Dictionary
	if int(restored_debug.get("cooked", 0)) < 1:
		_fail(39, "contador de cozinha não persistiu")
		return
	if int(restored_debug.get("spoiled_food", 0)) <= 0:
		_fail(40, "comida estragada não persistiu")
		return
	var restored_world := restored.call("get_food_farming_debug_0532") as Dictionary
	if str(restored_world.get("selected_crop", "")) != "carrot":
		_fail(41, "seleção de cultura não voltou no reload")
		return
	if not restored.has_method("get_vehicle_debug_0530"):
		_fail(42, "regressão final: veículos 0.5.30 desapareceram")
		return

	print("SMOKE 0.5.32 OK: milho/cenoura, comida crua, cozinha, validade e persistência preservando 0.5.30/0.5.31")
	if FileAccess.file_exists(SAVE_PATH_0532):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0532))
	quit(0)
