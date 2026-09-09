extends SceneTree

const SAVE_PATH_0536 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.36 FAIL: %s" % message)
	quit(code)

func _mission_by_id(snapshot: Dictionary, mission_id: String) -> Dictionary:
	var missions: Array = snapshot.get("missions", []) as Array
	for raw: Variant in missions:
		if raw is Dictionary and str((raw as Dictionary).get("id", "")) == mission_id:
			return (raw as Dictionary).duplicate(true)
	return {}

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0536):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0536))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(100):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_mission_bridge_debug_0536"):
		_fail(2, "PlayerV0536 não foi instanciado")
		return
	if not scene.has_method("get_mission_snapshot_0536") or not scene.has_method("get_progression_world_debug_0535"):
		_fail(3, "World 0.5.36 ou progressão 0.5.35 ausente")
		return
	var mission_debug := scene.call("get_mission_debug_0536") as Dictionary
	if not bool(mission_debug.get("player_0536", false)):
		_fail(4, "runtime não está usando PlayerV0536")
		return
	if not player.has_method("get_progression_snapshot_0535") or not scene.has_method("get_location_loot_debug_0534"):
		_fail(5, "progressão ou POIs anteriores desapareceram")
		return

	var mission_uis := get_nodes_in_group("inventory_ui_0536")
	if mission_uis.is_empty():
		_fail(6, "objetivos não foram integrados à mochila")
		return
	var ui_debug := mission_uis[0].call("get_inventory_ui_debug_0536") as Dictionary
	if not bool(ui_debug.get("missions_available", false)) or float(ui_debug.get("equipment_min_height_0536", 0.0)) < 1450.0:
		_fail(7, "diário de objetivos não foi construído corretamente")
		return

	var initial := scene.call("get_mission_snapshot_0536") as Dictionary
	if int(initial.get("total", 0)) != 5 or int(initial.get("completed", -1)) != 0:
		_fail(8, "nova partida não inicia com 5 objetivos abertos")
		return
	for mission_id in ["scavenge_route", "first_harvest", "field_medic", "road_ready", "clear_path"]:
		var mission := _mission_by_id(initial, mission_id)
		if mission.is_empty() or bool(mission.get("completed", true)):
			_fail(9, "objetivo inicial inválido: %s" % mission_id)
			return

	# Vasculhamento: dois POIs completam a rota e recompensa entra uma única vez.
	var inventory_before := player.call("get_inventory_snapshot") as Dictionary
	var water_before := int(inventory_before.get("water", 0))
	var bandage_before := int(inventory_before.get("bandage", 0))
	player.call("award_skill_xp_0535", "scavenging", 8, "loot_poi_market")
	player.call("award_skill_xp_0535", "scavenging", 8, "loot_poi_hospital")
	var after_scavenge := scene.call("get_mission_snapshot_0536") as Dictionary
	var scavenge := _mission_by_id(after_scavenge, "scavenge_route")
	if not bool(scavenge.get("completed", false)) or int(scavenge.get("progress", 0)) != 2:
		_fail(10, "rota de suprimentos não completou após 2 POIs")
		return
	var inventory_after := player.call("get_inventory_snapshot") as Dictionary
	if int(inventory_after.get("water", 0)) < water_before + 2 or int(inventory_after.get("bandage", 0)) < bandage_before + 1:
		_fail(11, "recompensa da rota não chegou à mochila")
		return
	var water_rewarded := int(inventory_after.get("water", 0))
	player.call("award_skill_xp_0535", "scavenging", 8, "loot_poi_police")
	if int((player.call("get_inventory_snapshot") as Dictionary).get("water", 0)) != water_rewarded:
		_fail(12, "missão concluída recompensou novamente")
		return

	# Agricultura, medicina e mecânica respondem aos mesmos reasons usados pela 0.5.35.
	player.call("award_skill_xp_0535", "farming", 14, "harvest")
	if not bool(_mission_by_id(scene.call("get_mission_snapshot_0536") as Dictionary, "first_harvest").get("completed", false)):
		_fail(13, "colheita não concluiu objetivo agrícola")
		return
	var seeds_after := player.call("get_inventory_snapshot") as Dictionary
	if int(seeds_after.get("potato_seed", 0)) < 2 or int(seeds_after.get("corn_seed", 0)) < 2 or int(seeds_after.get("carrot_seed", 0)) < 2:
		_fail(14, "pacote de sementes não foi recompensado")
		return

	player.call("award_skill_xp_0535", "medicine", 10, "bandage")
	player.call("award_skill_xp_0535", "medicine", 12, "antiseptic")
	if not bool(_mission_by_id(scene.call("get_mission_snapshot_0536") as Dictionary, "field_medic").get("completed", false)):
		_fail(15, "tratamentos não concluíram primeiros socorros")
		return

	player.call("award_skill_xp_0535", "mechanics", 18, "repair_vehicle")
	if not bool(_mission_by_id(scene.call("get_mission_snapshot_0536") as Dictionary, "road_ready").get("completed", false)):
		_fail(16, "reparo não concluiu objetivo mecânico")
		return
	var mechanics_reward := player.call("get_inventory_snapshot") as Dictionary
	if int(mechanics_reward.get("gasoline", 0)) < 3 or int(mechanics_reward.get("repair_kit", 0)) < 1:
		_fail(17, "recompensa mecânica não foi entregue")
		return

	# Combate exige repetição e só fecha no oitavo acerto.
	for i in range(7):
		player.call("award_skill_xp_0535", "combat", 5, "hit")
	var combat_before_final := _mission_by_id(scene.call("get_mission_snapshot_0536") as Dictionary, "clear_path")
	if bool(combat_before_final.get("completed", false)) or int(combat_before_final.get("progress", 0)) != 7:
		_fail(18, "objetivo de combate encerrou antes de 8 acertos")
		return
	player.call("award_skill_xp_0535", "combat", 5, "hit")
	var final_snapshot := scene.call("get_mission_snapshot_0536") as Dictionary
	if int(final_snapshot.get("completed", 0)) != 5:
		_fail(19, "os cinco objetivos não foram concluídos")
		return
	var combat_reward := player.call("get_inventory_snapshot") as Dictionary
	if int(combat_reward.get("ammo_9mm", 0)) < 12 or int(combat_reward.get("shells", 0)) < 3:
		_fail(20, "recompensa de combate não foi entregue")
		return
	if str(scene.call("get_active_mission_summary_0536")) != "TODOS OS OBJETIVOS CONCLUÍDOS":
		_fail(21, "resumo ativo não reconheceu conclusão total")
		return

	# Missões também alimentam a progressão antiga, mas recompensa não cria evento recursivo.
	var progression := player.call("get_progression_snapshot_0535") as Dictionary
	if int(progression.get("total_xp", 0)) <= 0 or int(final_snapshot.get("events", 0)) != 14:
		_fail(22, "integração missão/progressão gerou contagem inesperada")
		return

	# Save/load preserva estado, recompensas e sistemas anteriores.
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0536, FileAccess.READ)
	if file == null:
		_fail(23, "save 0.5.36 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(24, "save 0.5.36 inválido")
		return
	var payload: Dictionary = parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.36-alpha":
		_fail(25, "save não recebeu versão 0.5.36")
		return
	var world_state: Dictionary = payload.get("world", {}) as Dictionary
	if not (world_state.get("mission_state_0536", {}) is Dictionary) or int(world_state.get("mission_completions_0536", 0)) != 5:
		_fail(26, "estado das missões não foi serializado")
		return
	var player_state: Dictionary = payload.get("player", {}) as Dictionary
	if not (player_state.get("skill_xp_0535", {}) is Dictionary):
		_fail(27, "save 0.5.36 perdeu progressão 0.5.35")
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
		_fail(28, "reload perdeu player/progressão")
		return
	var restored_snapshot := restored.call("get_mission_snapshot_0536") as Dictionary
	if int(restored_snapshot.get("completed", 0)) != 5 or int(restored_snapshot.get("events", 0)) != 14:
		_fail(29, "progresso das missões não persistiu")
		return
	if not restored.has_method("get_vehicle_debug_0530") or not restored.has_method("get_food_farming_debug_0532") or not restored.has_method("get_location_loot_debug_0534"):
		_fail(30, "reload perdeu veículos, agricultura ou POIs")
		return
	if not restored_player.has_method("get_equipment_snapshot_0533"):
		_fail(31, "reload perdeu vestuário 0.5.33")
		return

	print("SMOKE 0.5.36 OK: 5 objetivos, progressão por ações, recompensas únicas, UI mobile e persistência preservando 0.5.35")
	if FileAccess.file_exists(SAVE_PATH_0536):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0536))
	quit(0)
