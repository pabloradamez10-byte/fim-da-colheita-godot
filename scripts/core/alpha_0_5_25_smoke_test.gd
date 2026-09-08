extends SceneTree

const SAVE_PATH_0525 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.25 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0525):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0525))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(58):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_production_status_0525"):
		_fail(2, "player não usa produção 0.5.25")
		return
	if not scene.has_method("get_production_debug_0525"):
		_fail(3, "runtime 0.5.25 ausente")
		return
	var world_debug := scene.call("get_production_debug_0525") as Dictionary
	if not bool(world_debug.get("player_0525", false)):
		_fail(4, "runtime não instanciou PlayerV0525")
		return
	if not bool(world_debug.get("label", false)):
		_fail(5, "indicador 3D da bancada ausente")
		return

	var benches := get_nodes_in_group("workbench_0524")
	if benches.is_empty():
		_fail(6, "bancada da 0.5.24 regrediu")
		return
	var bench := benches[0] as Node3D
	if bench == null:
		_fail(7, "bancada inválida")
		return

	# 1) Enfileirar não consome; iniciar consome; concluir só ocorre depois do tempo.
	player.call("add_item", "fiber", 9)
	var before_queue := player.call("get_inventory_snapshot") as Dictionary
	var fiber_before := int(before_queue.get("fiber", 0))
	if not bool(player.call("queue_craft_0525", "cordage")):
		_fail(8, "corda não entrou na fila")
		return
	var after_queue := player.call("get_inventory_snapshot") as Dictionary
	if int(after_queue.get("fiber", 0)) != fiber_before:
		_fail(9, "materiais foram consumidos ao enfileirar")
		return
	var queued := player.call("get_production_status_0525") as Dictionary
	if int(queued.get("queue_size", 0)) != 1:
		_fail(10, "fila não registrou primeiro trabalho")
		return

	var machete_before := int(player.call("get_weapon_durability_percent_0523", "machete"))
	player.call("_update_production_queue_0525", 0.25)
	var started_inv := player.call("get_inventory_snapshot") as Dictionary
	if int(started_inv.get("fiber", 0)) != fiber_before - 3:
		_fail(11, "materiais não foram consumidos quando trabalho iniciou")
		return
	if int(started_inv.get("cordage", 0)) != 0:
		_fail(12, "resultado apareceu antes de terminar o tempo")
		return
	player.call("_update_production_queue_0525", 5.0)
	var finished_inv := player.call("get_inventory_snapshot") as Dictionary
	if int(finished_inv.get("cordage", 0)) < 1:
		_fail(13, "trabalho cronometrado não entregou resultado")
		return
	if int(player.call("get_weapon_durability_percent_0523", "machete")) >= machete_before:
		_fail(14, "ferramenta não sofreu desgaste de produção")
		return

	# 2) Reservas impedem prometer os mesmos materiais duas vezes além do disponível.
	var inv_for_reserve := player.call("get_inventory_snapshot") as Dictionary
	var current_fiber := int(inv_for_reserve.get("fiber", 0))
	if current_fiber < 6:
		player.call("add_item", "fiber", 6 - current_fiber)
	if not bool(player.call("queue_craft_0525", "bandage")):
		_fail(15, "primeira bandagem não entrou na fila")
		return
	if not bool(player.call("queue_craft_0525", "bandage")):
		_fail(16, "segunda bandagem não entrou na fila")
		return
	if bool(player.call("queue_craft_0525", "bandage")):
		_fail(17, "reserva permitiu sobrealocar fibra")
		return
	player.call("_update_production_queue_0525", 4.0)
	player.call("_update_production_queue_0525", 4.0)
	var post_reserve := player.call("get_production_status_0525") as Dictionary
	if int(post_reserve.get("queue_size", 0)) != 0:
		_fail(18, "fila FIFO não drenou trabalhos concluídos")
		return

	# 3) Tábuas exigem machadinha funcional.
	player.global_position = bench.global_position
	if bool(player.call("can_queue_craft_0525", "plank_bundle")):
		_fail(19, "tábuas foram liberadas sem machadinha")
		return
	player.call("add_item", "wood", 8)
	player.call("add_item", "stone", 4)
	player.call("add_item", "fiber", 4)
	if not bool(player.call("queue_craft_0525", "axe")):
		_fail(20, "machadinha não entrou na fila de campo")
		return
	player.call("_update_production_queue_0525", 9.0)
	if not (player.call("get_owned_weapons") as Array).has("axe"):
		_fail(21, "machadinha não foi criada ao fim da produção")
		return
	if not bool(player.call("can_queue_craft_0525", "plank_bundle")):
		_fail(22, "tábuas continuaram bloqueadas com machadinha e bancada")
		return

	# 4) Produção de bancada pausa ao se afastar e retoma ao voltar.
	var wood_before_plank := int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0))
	if not bool(player.call("queue_craft_0525", "plank_bundle")):
		_fail(23, "tábuas não entraram na fila")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0)) != wood_before_plank:
		_fail(24, "tábuas consumiram madeira ao enfileirar")
		return
	player.call("_update_production_queue_0525", 1.0)
	var active := player.call("get_production_status_0525") as Dictionary
	var active_job := active.get("current", {}) as Dictionary
	var remaining_before_pause := float(active_job.get("remaining", 99.0))
	if remaining_before_pause >= 8.0:
		_fail(25, "produção de bancada não iniciou")
		return
	player.global_position = bench.global_position + Vector3(30.0, 0.0, 30.0)
	player.call("_update_production_queue_0525", 4.0)
	var paused := player.call("get_production_status_0525") as Dictionary
	var paused_job := paused.get("current", {}) as Dictionary
	if absf(float(paused_job.get("remaining", 0.0)) - remaining_before_pause) > 0.05:
		_fail(26, "produção continuou longe da bancada")
		return
	if str(paused_job.get("state", "")) != "paused_station":
		_fail(27, "estado de pausa da bancada não foi registrado")
		return
	player.global_position = bench.global_position
	player.call("_update_production_queue_0525", 20.0)
	var after_plank := player.call("get_inventory_snapshot") as Dictionary
	if int(after_plank.get("plank", 0)) < 3:
		_fail(28, "produção não retomou ao voltar à bancada")
		return

	# 5) Revisão total também é um trabalho cronometrado.
	var durability := player.get("weapon_durability_0523") as Dictionary
	durability["axe"] = 20.0
	player.set("weapon_durability_0523", durability)
	player.call("add_item", "repair_kit", 1)
	if not bool(player.call("workbench_repair_weapon_0524", "axe")):
		_fail(29, "revisão não entrou na fila")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("repair_kit", 0)) != 1:
		_fail(30, "kit foi consumido antes da revisão iniciar")
		return
	player.call("_update_production_queue_0525", 0.5)
	if int((player.call("get_inventory_snapshot") as Dictionary).get("repair_kit", 0)) != 0:
		_fail(31, "kit não foi consumido ao iniciar revisão")
		return
	if int(player.call("get_weapon_durability_percent_0523", "axe")) >= 100:
		_fail(32, "revisão restaurou antes do tempo")
		return
	player.call("_update_production_queue_0525", 11.0)
	if int(player.call("get_weapon_durability_percent_0523", "axe")) != 100:
		_fail(33, "revisão cronometrada não restaurou 100%")
		return

	# 6) Uma fila iniciada precisa persistir com o tempo restante.
	player.call("add_item", "stone", 2)
	player.call("add_item", "fiber", 1)
	if not bool(player.call("queue_craft_0525", "stone_blade")):
		_fail(34, "lâmina de pedra não entrou na fila")
		return
	player.call("_update_production_queue_0525", 1.0)
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0525, FileAccess.READ)
	if file == null:
		_fail(35, "save 0.5.25 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(36, "save 0.5.25 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.25-alpha":
		_fail(37, "save não foi versionado como 0.5.25")
		return
	var player_state := payload.get("player", {}) as Dictionary
	var saved_queue := player_state.get("production_queue_0525", []) as Array
	if saved_queue.is_empty():
		_fail(38, "fila não foi persistida")
		return
	var saved_job := saved_queue[0] as Dictionary
	if not bool(saved_job.get("started", false)):
		_fail(39, "estado iniciado da produção não foi persistido")
		return
	var saved_remaining := float(saved_job.get("remaining", 0.0))
	if saved_remaining <= 0.0 or saved_remaining >= 6.0:
		_fail(40, "tempo restante persistido é inválido")
		return

	# Interface e regressões estruturais acumuladas.
	var queue_uis := get_nodes_in_group("inventory_ui_0525")
	if queue_uis.is_empty() or not (queue_uis[0] as Node).has_method("get_queue_ui_debug_0525"):
		_fail(41, "UI de fila 0.5.25 ausente")
		return
	var ui_debug := (queue_uis[0] as Node).call("get_queue_ui_debug_0525") as Dictionary
	if not bool(ui_debug.get("label", false)):
		_fail(42, "status visual da fila não foi criado")
		return
	if get_nodes_in_group("hotbar_slot_0523").size() != 6:
		_fail(43, "hotbar 0.5.23 regrediu")
		return
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(44, "água 0.5.16 regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(45, "casas/portas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(46, "veículos regrediram")
		return
	if not scene.has_method("get_weather_state_0522"):
		_fail(47, "clima 0.5.22 regrediu")
		return

	print("SMOKE 0.5.25 OK: queue persisted remaining=%.1fs completed=%d axe=100%% planks=%d" % [saved_remaining, int(player_state.get("completed_jobs_0525", 0)), int(after_plank.get("plank", 0))])
	quit(0)
