extends SceneTree

const SAVE_PATH_0529 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.29 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0529):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0529))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(68):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_water_survival_debug_0529"):
		_fail(2, "PlayerV0529 não foi instanciado")
		return
	if not scene.has_method("get_water_debug_0529"):
		_fail(3, "WorldV0529 ausente")
		return
	var world_debug := scene.call("get_water_debug_0529") as Dictionary
	if not bool(world_debug.get("player_0529", false)):
		_fail(4, "runtime não usa PlayerV0529")
		return

	var build_uis := get_nodes_in_group("build_ui_0529")
	if build_uis.is_empty():
		_fail(5, "BuildUIV0529 ausente")
		return
	var build_debug := build_uis[0].call("get_build_ui_debug_0529") as Dictionary
	if int(build_debug.get("piece_buttons", 0)) != 9 or not bool(build_debug.get("collector_button", false)):
		_fail(6, "painel não possui nove peças com coletor")
		return
	if get_nodes_in_group("water_ui_0529").is_empty():
		_fail(7, "painel do coletor ausente")
		return
	if get_nodes_in_group("campfire_ui_0529").is_empty():
		_fail(8, "fogueira não recebeu controle de fervura")
		return
	if get_nodes_in_group("inventory_ui_0529").is_empty():
		_fail(9, "inventário 0.5.29 ausente")
		return

	player.call("add_item", "wood", 100)
	player.call("add_item", "stone", 40)
	player.call("add_item", "plank", 50)
	player.call("add_item", "cordage", 30)
	player.call("add_item", "fiber", 60)

	# Coletor: construção física e reservatório inicialmente vazio.
	player.global_position = Vector3(104.0, 0.20, 86.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	if not bool(scene.call("enter_build_mode_0526", "rain_collector")):
		_fail(10, "modo coletor não abriu")
		return
	await process_frame
	if not bool((scene.call("get_build_debug_0526") as Dictionary).get("valid", false)):
		_fail(11, "preview do coletor inválido em área livre")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(12, "coletor não foi construído")
		return
	for _i in range(4):
		await process_frame
	var collectors := get_nodes_in_group("rain_collector_0529")
	if collectors.size() != 1:
		_fail(13, "coletor construído não foi registrado")
		return
	var collector := collectors[0] as Node3D
	if not _has_static_body(collector):
		_fail(14, "coletor não possui colisão")
		return
	var collector_uid := str(collector.get_meta("collector_uid_0529", ""))
	var empty_status := scene.call("get_rain_collector_status_0529", collector_uid) as Dictionary
	if absf(float(empty_status.get("water", -1.0))) > 0.01:
		_fail(15, "coletor não iniciou vazio")
		return

	# Chuva enche; clima aberto não altera o volume.
	scene.call("set_weather_override_0522", 2)
	scene.call("advance_time_0521", 120.0, true)
	var rainy_status := scene.call("get_rain_collector_status_0529", collector_uid) as Dictionary
	var rain_water := float(rainy_status.get("water", 0.0))
	if rain_water < 6.0 or rain_water > 7.2:
		_fail(16, "captação de 120 min de chuva fora do esperado")
		return
	scene.call("set_weather_override_0522", 0)
	scene.call("advance_time_0521", 40.0, true)
	var clear_status := scene.call("get_rain_collector_status_0529", collector_uid) as Dictionary
	if absf(float(clear_status.get("water", 0.0)) - rain_water) > 0.05:
		_fail(17, "coletor aumentou sem chuva")
		return

	# INTERAGIR abre painel; retirar água cria água bruta na mochila.
	player.global_position = collector.global_position + Vector3(0.65, 0.0, 0.0)
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(18, "INTERAGIR não reconheceu coletor")
		return
	await process_frame
	var water_ui := get_nodes_in_group("water_ui_0529")[0]
	var ui_debug := water_ui.call("get_water_ui_debug_0529") as Dictionary
	if not bool(ui_debug.get("visible", false)):
		_fail(19, "painel do coletor não abriu")
		return
	if not bool(scene.call("collector_take_water_0529", collector_uid, player)):
		_fail(20, "não foi possível retirar água bruta")
		return
	var after_take := player.call("get_water_survival_debug_0529") as Dictionary
	if int(after_take.get("dirty_water", 0)) != 1:
		_fail(21, "água bruta não chegou à mochila")
		return

	# Água crua sacia, mas precisa criar risco sanitário.
	var thirst_before := float((player.call("get_vitals") as Dictionary).get("thirst", 0.0))
	player.set("thirst", minf(thirst_before, 40.0))
	if not bool(player.call("drink_unsafe_water_0529", 1)):
		_fail(22, "água bruta da mochila não pôde ser bebida")
		return
	var contaminated := player.call("get_water_survival_debug_0529") as Dictionary
	if float(contaminated.get("sickness", 0.0)) < 17.0:
		_fail(23, "água bruta não gerou contaminação hídrica")
		return
	if float((player.call("get_vitals") as Dictionary).get("thirst", 0.0)) <= 40.0:
		_fail(24, "água bruta não recuperou sede")
		return

	# Pegar outra unidade para tratamento.
	if not bool(scene.call("collector_take_water_0529", collector_uid, player)):
		_fail(25, "segunda água bruta não pôde ser retirada")
		return

	# Fogueira acesa transforma água bruta em água segura e consome combustível.
	water_ui.call("close_water_collector_0529")
	player.global_position = Vector3(116.0, 0.20, 86.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "campfire")
	await process_frame
	if not bool((scene.call("get_build_debug_0526") as Dictionary).get("valid", false)):
		_fail(26, "preview da fogueira inválido")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(27, "fogueira não foi construída")
		return
	for _i in range(3):
		await process_frame
	var fires := get_nodes_in_group("campfire_0528")
	if fires.size() != 1:
		_fail(28, "fogueira ausente")
		return
	var fire := fires[0] as Node3D
	var fire_uid := str(fire.get_meta("campfire_uid_0528", ""))
	player.global_position = fire.global_position + Vector3(0.6, 0.0, 0.0)
	if not bool(scene.call("campfire_add_fuel_0528", fire_uid, player)):
		_fail(29, "lenha não foi adicionada")
		return
	if not bool(scene.call("campfire_toggle_0528", fire_uid)):
		_fail(30, "fogueira não acendeu")
		return
	var safe_before := int((player.call("get_water_survival_debug_0529") as Dictionary).get("safe_water", 0))
	var dirty_before := int((player.call("get_water_survival_debug_0529") as Dictionary).get("dirty_water", 0))
	var fuel_before := float((scene.call("get_campfire_status_0528", fire_uid) as Dictionary).get("fuel_minutes", 0.0))
	if not bool(scene.call("campfire_purify_water_0529", fire_uid, player)):
		_fail(31, "fogueira não ferveu água bruta")
		return
	var after_boil := player.call("get_water_survival_debug_0529") as Dictionary
	var fuel_after := float((scene.call("get_campfire_status_0528", fire_uid) as Dictionary).get("fuel_minutes", 0.0))
	if int(after_boil.get("dirty_water", 0)) != dirty_before - 1:
		_fail(32, "fervura não consumiu água bruta")
		return
	if int(after_boil.get("safe_water", 0)) != safe_before + 1:
		_fail(33, "fervura não produziu água segura")
		return
	if absf((fuel_before - fuel_after) - 10.0) > 0.2:
		_fail(34, "fervura não consumiu 10 min de combustível")
		return

	# Coletor com água não pode ser desmontado.
	player.global_position = collector.global_position + Vector3(0.5, 0.0, 0.0)
	if bool(scene.call("dismantle_nearest_structure_0527")):
		_fail(35, "coletor cheio pôde ser desmontado")
		return

	# Guardar uma unidade bruta para validar persistência completa.
	if not bool(scene.call("collector_take_water_0529", collector_uid, player)):
		_fail(36, "não foi possível preparar água bruta para persistência")
		return
	var saved_player_water := player.call("get_water_survival_debug_0529") as Dictionary
	var saved_dirty := int(saved_player_water.get("dirty_water", 0))
	var saved_sickness := float(saved_player_water.get("sickness", 0.0))
	var saved_collector := scene.call("get_rain_collector_status_0529", collector_uid) as Dictionary
	var saved_stored := float(saved_collector.get("water", 0.0))
	scene.call("save_game")

	scene.queue_free()
	for _i in range(10):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(68):
		await process_frame
	var restored_collectors := get_nodes_in_group("rain_collector_0529")
	if restored_collectors.size() != 1:
		_fail(37, "coletor não reapareceu no reload")
		return
	var restored_collector := restored_collectors[0] as Node3D
	var restored_uid := str(restored_collector.get_meta("collector_uid_0529", ""))
	var restored_status := restored.call("get_rain_collector_status_0529", restored_uid) as Dictionary
	if absf(float(restored_status.get("water", 0.0)) - saved_stored) > 0.15:
		_fail(38, "volume do coletor não persistiu")
		return
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_water_survival_debug_0529"):
		_fail(39, "PlayerV0529 não foi restaurado")
		return
	var restored_water := restored_player.call("get_water_survival_debug_0529") as Dictionary
	if int(restored_water.get("dirty_water", 0)) != saved_dirty:
		_fail(40, "água bruta da mochila não persistiu")
		return
	if absf(float(restored_water.get("sickness", 0.0)) - saved_sickness) > 1.0:
		_fail(41, "contaminação hídrica não persistiu")
		return

	# Regressões consolidadas do mundo e da base.
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(42, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(43, "portas/casas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(44, "veículos regrediram")
		return
	if get_nodes_in_group("spike_barricade_0528").size() > 0 and not restored_player.has_method("get_base_utility_debug_0528"):
		_fail(45, "base 0.5.28 regrediu")
		return

	print("SMOKE 0.5.29 OK: rain=%.1f stored=%.1f dirty=%d safe=%d sickness=%.1f boil_fuel=10 persistence=true" % [rain_water, saved_stored, saved_dirty, int(restored_water.get("safe_water", 0)), saved_sickness])
	quit(0)

func _has_static_body(root_node: Node) -> bool:
	if root_node is StaticBody3D:
		return true
	for child: Node in root_node.get_children():
		if _has_static_body(child):
			return true
	return false
