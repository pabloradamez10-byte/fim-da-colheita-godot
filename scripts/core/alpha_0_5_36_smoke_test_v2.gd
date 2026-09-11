extends SceneTree

const SAVE_PATH_0536 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.36 FAIL: %s" % message)
	quit(code)

func _mission(snapshot: Dictionary, mission_id: String) -> Dictionary:
	var missions: Array = snapshot.get("missions", []) as Array
	for raw: Variant in missions:
		if raw is Dictionary and str((raw as Dictionary).get("id", "")) == mission_id:
			return raw as Dictionary
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
		_fail(2, "PlayerV0536 ausente")
		return
	if not scene.has_method("get_mission_snapshot_0536") or not scene.has_method("get_progression_world_debug_0535"):
		_fail(3, "World 0.5.36 ou progressão anterior ausente")
		return
	var debug := scene.call("get_mission_debug_0536") as Dictionary
	if not bool(debug.get("player_0536", false)):
		_fail(4, "runtime não preserva compatibilidade PlayerV0536")
		return
	if get_nodes_in_group("inventory_ui_0536").is_empty():
		_fail(5, "diário de objetivos não está na mochila")
		return
	var ui_debug := get_nodes_in_group("inventory_ui_0536")[0].call("get_inventory_ui_debug_0536") as Dictionary
	if not bool(ui_debug.get("missions_available", false)):
		_fail(6, "UI não encontrou sistema de missões")
		return

	var initial := scene.call("get_mission_snapshot_0536") as Dictionary
	if int(initial.get("total", 0)) != 5 or int(initial.get("completed", -1)) != 0:
		_fail(7, "partida não iniciou com cinco objetivos")
		return

	var before := player.call("get_inventory_snapshot") as Dictionary
	var water_before := int(before.get("water", 0))
	player.call("award_skill_xp_0535", "scavenging", 8, "loot_poi_market")
	player.call("award_skill_xp_0535", "scavenging", 8, "loot_poi_hospital")
	var snap := scene.call("get_mission_snapshot_0536") as Dictionary
	if not bool(_mission(snap, "scavenge_route").get("completed", false)):
		_fail(8, "rota de suprimentos não completou")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("water", 0)) < water_before + 2:
		_fail(9, "recompensa de suprimentos não foi entregue")
		return

	player.call("award_skill_xp_0535", "farming", 14, "harvest")
	if not bool(_mission(scene.call("get_mission_snapshot_0536") as Dictionary, "first_harvest").get("completed", false)):
		_fail(10, "objetivo agrícola não completou")
		return
	var seeds := player.call("get_inventory_snapshot") as Dictionary
	if int(seeds.get("potato_seed", 0)) < 2 or int(seeds.get("corn_seed", 0)) < 2 or int(seeds.get("carrot_seed", 0)) < 2:
		_fail(11, "recompensa agrícola não entregou sementes")
		return

	player.call("award_skill_xp_0535", "medicine", 10, "bandage")
	player.call("award_skill_xp_0535", "medicine", 12, "antiseptic")
	if not bool(_mission(scene.call("get_mission_snapshot_0536") as Dictionary, "field_medic").get("completed", false)):
		_fail(12, "objetivo médico não completou")
		return

	var gas_before := int((player.call("get_inventory_snapshot") as Dictionary).get("gasoline", 0))
	player.call("award_skill_xp_0535", "mechanics", 18, "repair_vehicle")
	if not bool(_mission(scene.call("get_mission_snapshot_0536") as Dictionary, "road_ready").get("completed", false)):
		_fail(13, "objetivo mecânico não completou")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("gasoline", 0)) < gas_before + 3:
		_fail(14, "recompensa mecânica não entregou gasolina")
		return

	for _i in range(8):
		player.call("award_skill_xp_0535", "combat", 5, "hit")
	var final_snapshot := scene.call("get_mission_snapshot_0536") as Dictionary
	if int(final_snapshot.get("completed", 0)) != 5 or int(final_snapshot.get("events", 0)) != 14:
		_fail(15, "ciclo completo das cinco missões falhou")
		return
	var combat_reward := player.call("get_inventory_snapshot") as Dictionary
	if int(combat_reward.get("ammo_9mm", 0)) < 12 or int(combat_reward.get("shells", 0)) < 3:
		_fail(16, "recompensa de combate não foi entregue")
		return

	var water_rewarded := int(combat_reward.get("water", 0))
	player.call("award_skill_xp_0535", "scavenging", 8, "loot_poi_police")
	if int((player.call("get_inventory_snapshot") as Dictionary).get("water", 0)) != water_rewarded:
		_fail(17, "missão concluída recompensou novamente")
		return

	var progression := player.call("get_progression_snapshot_0535") as Dictionary
	if int(progression.get("total_xp", 0)) <= 0:
		_fail(18, "missões não preservaram progressão 0.5.35")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0536, FileAccess.READ)
	if file == null:
		_fail(19, "save da linha 0.5.36+ não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(20, "save inválido")
		return
	var payload := parsed as Dictionary
	var saved_version := str(payload.get("version", ""))
	if saved_version not in ["0.5.36-alpha", "0.5.37-alpha", "0.5.38-alpha", "0.5.39-alpha", "0.5.40-alpha", "0.5.40.1-alpha"]:
		_fail(21, "versão do save não é compatível com 0.5.36+")
		return
	var world_state := payload.get("world", {}) as Dictionary
	if int(world_state.get("mission_completions_0536", 0)) != 5 or not (world_state.get("mission_state_0536", {}) is Dictionary):
		_fail(22, "missões não foram persistidas")
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
		_fail(23, "reload perdeu progressão")
		return
	var restored_snapshot := restored.call("get_mission_snapshot_0536") as Dictionary
	if int(restored_snapshot.get("completed", 0)) != 5 or int(restored_snapshot.get("events", 0)) != 14:
		_fail(24, "reload perdeu progresso das missões")
		return
	if not restored.has_method("get_vehicle_debug_0530") or not restored.has_method("get_food_farming_debug_0532") or not restored.has_method("get_location_loot_debug_0534"):
		_fail(25, "reload perdeu veículos, agricultura ou POIs")
		return
	if not restored_player.has_method("get_equipment_snapshot_0533"):
		_fail(26, "reload perdeu vestuário")
		return

	print("SMOKE 0.5.36 OK: cinco objetivos, recompensas únicas, integração com progressão, UI mobile e persistência")
	if FileAccess.file_exists(SAVE_PATH_0536):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0536))
	quit(0)
