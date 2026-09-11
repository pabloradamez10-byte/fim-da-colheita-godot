extends SceneTree

const SAVE_PATH_0540 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.40 FAIL: %s" % message)
	quit(code)

func _base_context() -> Dictionary:
	return {
		"survivor_id": "probe",
		"role": "scavenger",
		"health": 100.0,
		"hunger": 100.0,
		"thirst": 100.0,
		"trust": 0,
		"met_player": false,
		"dead": false,
		"player_distance": 9999.0,
		"zombie_distance": 9999.0,
		"night": false
	}

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0540):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0540))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(150):
		await process_frame

	if not scene.has_method("get_decision_engine_debug_0540") or not scene.has_method("evaluate_decision_debug_0540"):
		_fail(2, "Atlas Decision Engine 0.5.40 ausente")
		return
	var engine := scene.call("get_decision_engine_debug_0540") as Dictionary
	var core := engine.get("engine", {}) as Dictionary
	if str(core.get("version", "")) != "0.5.40-alpha" or int(core.get("action_count", 0)) != 7:
		_fail(3, "núcleo de decisão não expõe sete ações/versionamento")
		return
	if not bool(core.get("offline", false)) or not bool(core.get("deterministic_scores", false)):
		_fail(4, "motor inicial precisa ser local/offline e determinístico")
		return
	if int(engine.get("records", 0)) != 3 or int(engine.get("evaluations", 0)) < 3:
		_fail(5, "três sobreviventes não foram avaliados")
		return
	if get_nodes_in_group("decision_actor_0540").size() != 3:
		_fail(6, "sobreviventes 0.5.40 não foram instanciados como atores de decisão")
		return

	# Motor puro: ameaça deve interromper qualquer objetivo concorrente.
	var context := _base_context()
	context["zombie_distance"] = 2.5
	context["thirst"] = 10.0
	var decision := scene.call("evaluate_decision_debug_0540", context) as Dictionary
	if str(decision.get("action", "")) != "flee_threat":
		_fail(7, "ameaça próxima não venceu necessidade fisiológica")
		return

	# Sede, saúde e fome precisam criar metas distintas.
	context = _base_context()
	context["thirst"] = 12.0
	decision = scene.call("evaluate_decision_debug_0540", context) as Dictionary
	if str(decision.get("action", "")) != "seek_water":
		_fail(8, "sede crítica não gerou busca por água")
		return
	context = _base_context()
	context["health"] = 22.0
	decision = scene.call("evaluate_decision_debug_0540", context) as Dictionary
	if str(decision.get("action", "")) != "seek_medical":
		_fail(9, "saúde baixa não gerou busca médica")
		return
	context = _base_context()
	context["hunger"] = 12.0
	decision = scene.call("evaluate_decision_debug_0540", context) as Dictionary
	if str(decision.get("action", "")) != "seek_food":
		_fail(10, "fome crítica não gerou busca por comida")
		return

	# Contexto social e horário também participam da decisão.
	context = _base_context()
	context["night"] = true
	decision = scene.call("evaluate_decision_debug_0540", context) as Dictionary
	if str(decision.get("action", "")) != "return_home":
		_fail(11, "noite segura não priorizou retorno ao abrigo")
		return
	context = _base_context()
	context["met_player"] = true
	context["trust"] = 65
	context["player_distance"] = 10.0
	decision = scene.call("evaluate_decision_debug_0540", context) as Dictionary
	if str(decision.get("action", "")) != "regroup_player":
		_fail(12, "confiança alta não permitiu reagrupar com jogador")
		return
	context = _base_context()
	decision = scene.call("evaluate_decision_debug_0540", context) as Dictionary
	if str(decision.get("action", "")) != "role_patrol":
		_fail(13, "estado estável não caiu na rotina de papel")
		return

	var player := get_first_node_in_group("player")
	if player == null:
		_fail(14, "jogador ausente")
		return
	var helena_node: Node3D = null
	for raw: Node in get_nodes_in_group("survivor_0539"):
		if str(raw.get("survivor_id_0539")) == "helena" and raw is Node3D:
			helena_node = raw as Node3D
			break
	if helena_node == null:
		_fail(15, "Helena ausente")
		return

	# Limpa ameaças físicas só para tornar este teste de necessidade determinístico.
	for raw: Node in get_nodes_in_group("zombie_0537"):
		if is_instance_valid(raw):
			raw.queue_free()
	for _i in range(4):
		await process_frame

	# Depois de conhecer o jogador, necessidade baixa deve fazê-la procurar ajuda real.
	if not bool(scene.call("interact_survivor_debug_0539", "helena", player)):
		_fail(16, "primeiro contato 0.5.39 regrediu")
		return
	player.global_position = helena_node.global_position + Vector3(6.0, 0.0, 0.0)
	if not bool(scene.call("set_survivor_needs_debug_0539", "helena", 90.0, 8.0, 100.0)):
		_fail(17, "não foi possível preparar sede de Helena")
		return
	engine = scene.call("force_decision_cycle_debug_0540") as Dictionary
	var helena_decision := scene.call("get_survivor_decision_0540", "helena") as Dictionary
	if str(helena_decision.get("action", "")) != "seek_water":
		_fail(18, "Helena não escolheu buscar água")
		return
	if str(helena_decision.get("target_kind", "")) != "player_help":
		_fail(19, "Helena conhecida e próxima não procurou ajuda do jogador")
		return
	if int(engine.get("cycles", 0)) < 2 or int(engine.get("evaluations", 0)) < 6:
		_fail(20, "scheduler não executou novo ciclo completo")
		return

	# O motor deve manter todos os sistemas da sociedade e do mundo vivo disponíveis.
	var society := scene.call("get_survivor_society_debug_0539") as Dictionary
	if int(society.get("records", 0)) != 3 or int(society.get("role_count", 0)) != 3:
		_fail(21, "Sociedade Humana 0.5.39 regrediu")
		return
	var wildlife := scene.call("get_animal_ecology_debug_0538") as Dictionary
	if int(wildlife.get("records", 0)) != 18 or int(wildlife.get("species_count", 0)) != 4:
		_fail(22, "Animais & Caça 0.5.38 regrediu")
		return
	if not scene.has_method("get_zombie_ecology_debug_0537") or not scene.has_method("get_mission_snapshot_0536"):
		_fail(23, "zumbis ou missões anteriores foram perdidos")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0540, FileAccess.READ)
	if file == null:
		_fail(24, "save 0.5.40 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(25, "save 0.5.40 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.40-alpha":
		_fail(26, "versão do save não é 0.5.40-alpha")
		return
	var world_state := payload.get("world", {}) as Dictionary
	var saved_decisions := world_state.get("decision_records_0540", {}) as Dictionary
	if saved_decisions.size() != 3:
		_fail(27, "decisões dos três sobreviventes não foram persistidas")
		return
	var saved_survivors := world_state.get("survivor_records_0539", {}) as Dictionary
	var helena_saved := saved_survivors.get("helena", {}) as Dictionary
	if str(helena_saved.get("decision_action_0540", "")) == "" or int(helena_saved.get("decision_count_0540", 0)) <= 0:
		_fail(28, "estado de decisão individual não foi salvo")
		return

	scene.queue_free()
	for _i in range(18):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(150):
		await process_frame
	if not restored.has_method("get_decision_engine_debug_0540"):
		_fail(29, "reload perdeu Atlas Decision Engine")
		return
	var restored_engine := restored.call("get_decision_engine_debug_0540") as Dictionary
	if int(restored_engine.get("records", 0)) != 3 or int(restored_engine.get("cycles", 0)) < 2:
		_fail(30, "reload perdeu histórico do scheduler/decisões")
		return
	var restored_helena := restored.call("get_survivor_record_0539", "helena") as Dictionary
	if int(restored_helena.get("decision_count_0540", 0)) <= 0:
		_fail(31, "reload perdeu decisão persistente de Helena")
		return

	print("SMOKE 0.5.40 OK | engine=offline deterministic actions=7 survivors=3 cycles=%d evaluations=%d switches=%d persistent=true" % [
		int(restored_engine.get("cycles", 0)),
		int(restored_engine.get("evaluations", 0)),
		int(restored_engine.get("switches", 0))
	])
	quit(0)
