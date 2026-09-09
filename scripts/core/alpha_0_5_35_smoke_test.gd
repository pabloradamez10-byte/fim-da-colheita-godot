extends SceneTree

const SAVE_PATH_0535 := "user://fim_da_colheita_alpha_0_5_2.save.json"
const VEHICLE_KEY_0535 := "smoke0535:mechanics"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.35 FAIL: %s" % message)
	quit(code)

func _find_vehicle(uid: String) -> Node3D:
	for raw: Node in get_nodes_in_group("vehicle_0530"):
		if raw is Node3D and str((raw as Node3D).get_meta("vehicle_key_0530", "")) == uid:
			return raw as Node3D
	return null

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0535):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0535))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(100):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_progression_snapshot_0535"):
		_fail(2, "PlayerV0535 não foi instanciado")
		return
	if not scene.has_method("get_progression_world_debug_0535"):
		_fail(3, "World 0.5.35 ausente")
		return
	var world_debug := scene.call("get_progression_world_debug_0535") as Dictionary
	if not bool(world_debug.get("player_0535", false)):
		_fail(4, "runtime não usa PlayerV0535")
		return

	var progression_uis := get_nodes_in_group("inventory_ui_0535")
	if progression_uis.is_empty():
		_fail(5, "progressão não foi integrada à mochila")
		return
	var ui_debug := progression_uis[0].call("get_inventory_ui_debug_0535") as Dictionary
	if not bool(ui_debug.get("progression_available", false)) or float(ui_debug.get("equipment_min_height", 0.0)) < 1000.0:
		_fail(6, "área de progressão da mochila não foi construída")
		return

	var initial := player.call("get_progression_snapshot_0535") as Dictionary
	if int(initial.get("survivor_level", 0)) != 1 or int(initial.get("total_xp", -1)) != 0:
		_fail(7, "nova seed não começa no nível/XP base")
		return
	var initial_attributes := initial.get("attributes", {}) as Dictionary
	if int(initial_attributes.get("strength", 0)) != 5 or int(initial_attributes.get("conditioning", 0)) != 5 or int(initial_attributes.get("perception", 0)) != 5:
		_fail(8, "atributos iniciais incorretos")
		return

	# Combate: um acerto real precisa conceder XP; evolução melhora o dano.
	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty():
		_fail(9, "não há zumbi para validar XP de combate")
		return
	var zombie := zombies[0] as Node3D
	player.global_position = zombie.global_position + Vector3(0.8, 0.0, 0.0)
	var combat_before := int(player.call("get_skill_xp_0535", "combat"))
	player.call("_damage_nearest", 3.0, 10.0)
	var combat_after_hit := int(player.call("get_skill_xp_0535", "combat"))
	if combat_after_hit <= combat_before:
		_fail(10, "acerto em zumbi não concedeu XP de combate")
		return
	var damage_base := float(player.call("get_combat_damage_multiplier_0535"))
	player.call("award_skill_xp_0535", "combat", 145, "smoke_training")
	if int(player.call("get_skill_level_0535", "combat")) < 2:
		_fail(11, "XP de combate não elevou a perícia")
		return
	var damage_trained := float(player.call("get_combat_damage_multiplier_0535"))
	if damage_trained <= damage_base + 0.08:
		_fail(12, "nível de combate não aumentou multiplicador de dano")
		return

	# Medicina: uso real de bandagem gera XP e nível melhora o tratamento.
	player.call("add_item", "bandage", 7)
	for _i in range(5):
		player.set("health", 50.0)
		player.set("bleeding_0519", 5.0)
		player.set("pain_0519", 40.0)
		if not bool(player.call("use_inventory_item", "bandage")):
			_fail(13, "bandagem falhou durante treino médico")
			return
	if int(player.call("get_skill_level_0535", "medicine")) < 1:
		_fail(14, "tratamentos não elevaram Medicina")
		return
	player.set("health", 50.0)
	player.set("bleeding_0519", 5.0)
	player.set("pain_0519", 40.0)
	if not bool(player.call("use_inventory_item", "bandage")):
		_fail(15, "bandagem treinada falhou")
		return
	if float(player.get("health")) <= 80.0 or float(player.get("bleeding_0519")) >= 0.5:
		_fail(16, "Medicina treinada não melhorou cura/controle de sangramento")
		return

	# Agricultura: preparar e plantar dão XP; nível 3 concede produção extra na colheita.
	var plots := get_nodes_in_group("farm_plot_0531")
	if plots.is_empty():
		_fail(17, "canteiros 0.5.31 desapareceram")
		return
	var plot := plots[0] as Node3D
	var plot_id := str(plot.get_meta("farm_plot_id_0531", ""))
	player.global_position = plot.global_position
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(18, "preparar solo falhou")
		return
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(19, "plantio falhou")
		return
	if int(player.call("get_skill_xp_0535", "farming")) < 8:
		_fail(20, "preparo/plantio não concederam XP agrícola")
		return
	player.call("award_skill_xp_0535", "farming", 292, "smoke_training")
	if int(player.call("get_skill_level_0535", "farming")) < 3 or int(player.call("get_farming_bonus_yield_0535")) < 1:
		_fail(21, "Agricultura Nv.3 não liberou bônus de rendimento")
		return
	var records: Dictionary = scene.get("farm_plot_records_0531") as Dictionary
	var ready_record: Dictionary = records[plot_id] as Dictionary
	ready_record["state"] = 4
	ready_record["crop_id"] = "potato"
	ready_record["growth"] = 9999.0
	ready_record["moisture"] = 1.0
	records[plot_id] = ready_record
	scene.set("farm_plot_records_0531", records)
	var potato_before := int((player.call("get_inventory_snapshot") as Dictionary).get("potato", 0))
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(22, "colheita treinada falhou")
		return
	var potato_after := int((player.call("get_inventory_snapshot") as Dictionary).get("potato", 0))
	if potato_after - potato_before < 4:
		_fail(23, "bônus agrícola não adicionou produção extra")
		return

	# Vasculhamento: caixa de POI real gera XP e a chance de bônus cresce com nível/percepção.
	var chunker := scene.get_node_or_null("ChunkStreamer")
	if chunker == null or not chunker.has_method("_decorate_location_0534"):
		_fail(24, "POIs 0.5.34 não foram preservados")
		return
	var fake_poi := Node3D.new()
	fake_poi.name = "SmokeMarket0535"
	fake_poi.position = Vector3(520.0, 0.0, 520.0)
	scene.add_child(fake_poi)
	chunker.set("world", scene)
	chunker.call("_decorate_location_0534", fake_poi, "market", "smoke:progression:market")
	var local_crates: Array[Node] = []
	for raw: Node in get_nodes_in_group("poi_loot_0534"):
		if fake_poi.is_ancestor_of(raw):
			local_crates.append(raw)
	if local_crates.is_empty():
		_fail(25, "POI de teste não criou caixa")
		return
	var crate := local_crates[0] as Node3D
	var scavenging_before := int(player.call("get_skill_xp_0535", "scavenging"))
	player.global_position = crate.global_position
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(26, "saque de POI falhou")
		return
	if int(player.call("get_skill_xp_0535", "scavenging")) <= scavenging_before:
		_fail(27, "vasculhar POI não concedeu XP")
		return
	var scavenging_chance_before := float(player.call("get_scavenging_bonus_chance_0535"))
	player.call("award_skill_xp_0535", "scavenging", 142, "smoke_training")
	var scavenging_chance_after := float(player.call("get_scavenging_bonus_chance_0535"))
	if int(player.call("get_skill_level_0535", "scavenging")) < 2 or scavenging_chance_after <= scavenging_chance_before:
		_fail(28, "Vasculhamento não melhorou a chance de recurso extra")
		return

	# Mecânica: reparo real dá XP; nível 2 aumenta o percentual restaurado.
	if not chunker.has_method("_build_vehicle_sprite_0517"):
		_fail(29, "fábrica de veículos 0.5.30 ausente")
		return
	var vehicle_parent := Node3D.new()
	vehicle_parent.name = "VehicleProbe0535"
	scene.add_child(vehicle_parent)
	chunker.call("_build_vehicle_sprite_0517", vehicle_parent, Vector3(440.0, 0.28, 440.0), 0.0, 3, VEHICLE_KEY_0535)
	for _i in range(4):
		await process_frame
	var vehicle := _find_vehicle(VEHICLE_KEY_0535)
	if vehicle == null:
		_fail(30, "veículo de teste não foi criado")
		return
	player.call("add_item", "repair_kit", 3)
	player.global_position = vehicle.global_position + Vector3(0.8, -0.08, 0.0)
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(31, "veículo não foi ativado")
		return
	vehicle = _find_vehicle(VEHICLE_KEY_0535)
	var status := scene.call("get_vehicle_status_0530", VEHICLE_KEY_0535) as Dictionary
	var max_health := float(status.get("max_health", 100.0))
	vehicle.set("health_0530", max_health * 0.40)
	if not bool(scene.call("vehicle_repair_0530", VEHICLE_KEY_0535, player)):
		_fail(32, "reparo de veículo falhou")
		return
	if int(player.call("get_skill_xp_0535", "mechanics")) < 18:
		_fail(33, "reparo não concedeu XP de Mecânica")
		return
	player.call("award_skill_xp_0535", "mechanics", 132, "smoke_training")
	if int(player.call("get_skill_level_0535", "mechanics")) < 2:
		_fail(34, "Mecânica não atingiu nível 2")
		return
	var repair_fraction := float(player.call("get_mechanics_repair_fraction_0535"))
	if repair_fraction < 0.349:
		_fail(35, "Mecânica Nv.2 não aumentou eficiência de reparo")
		return
	vehicle.set("health_0530", max_health * 0.40)
	if not bool(scene.call("vehicle_repair_0530", VEHICLE_KEY_0535, player)):
		_fail(36, "reparo treinado falhou")
		return
	var repaired_health := float((scene.call("get_vehicle_status_0530", VEHICLE_KEY_0535) as Dictionary).get("health", 0.0))
	if repaired_health < max_health * 0.74:
		_fail(37, "eficiência mecânica não foi aplicada ao veículo")
		return

	# Progressão geral e atributos precisam reagir ao conjunto das perícias.
	var progressed := player.call("get_progression_snapshot_0535") as Dictionary
	var progressed_attributes := progressed.get("attributes", {}) as Dictionary
	if int(progressed.get("survivor_level", 1)) < 3:
		_fail(38, "XP acumulado não elevou nível geral do sobrevivente")
		return
	if int(progressed_attributes.get("strength", 5)) <= 5 or int(progressed_attributes.get("perception", 5)) <= 5:
		_fail(39, "perícias não evoluíram atributos derivados")
		return

	# Save/load preserva XP, níveis e sistemas anteriores.
	var saved_skills := (progressed.get("skills", {}) as Dictionary).duplicate(true)
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0535, FileAccess.READ)
	if file == null:
		_fail(40, "save 0.5.35 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(41, "save 0.5.35 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.35-alpha":
		_fail(42, "save não recebeu versão 0.5.35")
		return
	var player_state := payload.get("player", {}) as Dictionary
	if not (player_state.get("skill_xp_0535", {}) is Dictionary):
		_fail(43, "XP das perícias não foi serializado")
		return
	var world_state := payload.get("world", {}) as Dictionary
	if int(world_state.get("progression_harvest_bonus_0535", 0)) < 1 or int(world_state.get("progression_mechanic_repairs_0535", 0)) < 2:
		_fail(44, "contadores de integração não foram serializados")
		return

	scene.queue_free()
	for _i in range(14):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(100):
		await process_frame
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_progression_snapshot_0535"):
		_fail(45, "reload perdeu progressão")
		return
	var restored_progress := restored_player.call("get_progression_snapshot_0535") as Dictionary
	var restored_skills := restored_progress.get("skills", {}) as Dictionary
	for skill_id in ["combat", "farming", "medicine", "mechanics", "scavenging"]:
		var before_skill := saved_skills.get(skill_id, {}) as Dictionary
		var after_skill := restored_skills.get(skill_id, {}) as Dictionary
		if int(after_skill.get("xp", -1)) != int(before_skill.get("xp", -2)):
			_fail(46, "XP de %s não persistiu" % skill_id)
			return
	if not restored.has_method("get_location_loot_debug_0534") or not restored.has_method("get_vehicle_debug_0530") or not restored.has_method("get_food_farming_debug_0532"):
		_fail(47, "reload perdeu POIs, veículos ou agricultura")
		return
	if not restored_player.has_method("get_equipment_snapshot_0533"):
		_fail(48, "reload perdeu vestuário 0.5.33")
		return

	print("SMOKE 0.5.35 OK: XP por ações reais, 5 perícias, 3 atributos, bônus de combate/agricultura/medicina/mecânica/loot e persistência")
	if FileAccess.file_exists(SAVE_PATH_0535):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0535))
	quit(0)
