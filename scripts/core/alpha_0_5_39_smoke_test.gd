extends SceneTree

const SAVE_PATH_0539 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.39 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0539):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0539))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(130):
		await process_frame

	if not scene.has_method("get_survivor_society_debug_0539"):
		_fail(2, "runtime Sociedade Humana 0.5.39 ausente")
		return
	var society := scene.call("get_survivor_society_debug_0539") as Dictionary
	if int(society.get("records", 0)) != 3 or int(society.get("spawned", 0)) != 3:
		_fail(3, "três sobreviventes persistentes não foram criados")
		return
	if int(society.get("alive", 0)) != 3 or int(society.get("role_count", 0)) != 3:
		_fail(4, "papéis humanos iniciais não foram preservados")
		return
	var roles := society.get("roles", {}) as Dictionary
	for role_id in ["medic", "mechanic", "scavenger"]:
		if int(roles.get(role_id, 0)) != 1:
			_fail(5, "papel ausente ou duplicado: %s" % role_id)
			return

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_hunting_player_debug_0538"):
		_fail(6, "PlayerV0538 e sistemas anteriores não foram preservados")
		return
	if get_nodes_in_group("survivor_0539").size() != 3:
		_fail(7, "nós físicos dos sobreviventes não correspondem aos registros")
		return

	# Primeiro contato deve criar relação sem exigir recursos.
	if not bool(scene.call("interact_survivor_debug_0539", "helena", player)):
		_fail(8, "primeiro contato com Helena falhou")
		return
	var helena := scene.call("get_survivor_record_0539", "helena") as Dictionary
	if not bool(helena.get("met_player", false)) or int(helena.get("trust", 0)) < 12:
		_fail(9, "primeiro contato não gerou confiança")
		return

	# Necessidades reais: água do jogador é consumida para socorrer NPC com sede.
	player.call("add_item", "water", 2)
	var inv_before := player.call("get_inventory_snapshot") as Dictionary
	var water_before := int(inv_before.get("water", 0))
	if not bool(scene.call("set_survivor_needs_debug_0539", "helena", 82.0, 25.0, 100.0)):
		_fail(10, "não foi possível preparar necessidade de sede")
		return
	if not bool(scene.call("interact_survivor_debug_0539", "helena", player)):
		_fail(11, "ajuda com água falhou")
		return
	var inv_after_aid := player.call("get_inventory_snapshot") as Dictionary
	if int(inv_after_aid.get("water", 0)) != water_before - 1:
		_fail(12, "ajuda não consumiu uma água do jogador")
		return
	helena = scene.call("get_survivor_record_0539", "helena") as Dictionary
	if float(helena.get("thirst", 0.0)) <= 25.0 or int(helena.get("trust", 0)) <= 12:
		_fail(13, "ajuda não recuperou sede/confiança")
		return

	# Relação suficiente libera uma troca social única baseada no papel.
	if not bool(scene.call("set_survivor_needs_debug_0539", "helena", 90.0, 90.0, 100.0)):
		_fail(14, "não foi possível estabilizar necessidades")
		return
	if not bool(scene.call("set_survivor_trust_debug_0539", "helena", 28)):
		_fail(15, "não foi possível preparar confiança")
		return
	var bandage_before := int((player.call("get_inventory_snapshot") as Dictionary).get("bandage", 0))
	if not bool(scene.call("interact_survivor_debug_0539", "helena", player)):
		_fail(16, "compartilhamento de suprimento falhou")
		return
	var bandage_after := int((player.call("get_inventory_snapshot") as Dictionary).get("bandage", 0))
	if bandage_after != bandage_before + 1:
		_fail(17, "socorrista não compartilhou bandagem")
		return
	helena = scene.call("get_survivor_record_0539", "helena") as Dictionary
	if not bool(helena.get("gift_shared", false)):
		_fail(18, "presente social não foi marcado como único")
		return
	if not bool(scene.call("interact_survivor_debug_0539", "helena", player)):
		_fail(19, "conversa posterior falhou")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("bandage", 0)) != bandage_after:
		_fail(20, "presente social foi duplicado")
		return

	# Ruído de tiro deve afetar humanos e continuar afetando fauna/zumbis.
	var survivor_nodes := get_nodes_in_group("survivor_0539")
	var noise_target := survivor_nodes[0] as Node3D
	var noise_before := int((scene.call("get_survivor_society_debug_0539") as Dictionary).get("noise_flees", 0))
	scene.call("emit_noise_0519", noise_target.global_position, 34.0, "shotgun", null)
	for _i in range(8):
		await process_frame
	var after_noise := scene.call("get_survivor_society_debug_0539") as Dictionary
	if int(after_noise.get("noise_flees", 0)) <= noise_before:
		_fail(21, "tiro não assustou nenhum sobrevivente")
		return

	# Sobreviventes são vulneráveis; dano precisa persistir sem quebrar relação.
	var davi_before := scene.call("get_survivor_record_0539", "davi") as Dictionary
	if not bool(scene.call("damage_survivor_debug_0539", "davi", 18.0)):
		_fail(22, "sobrevivente não recebeu dano")
		return
	var davi_after := scene.call("get_survivor_record_0539", "davi") as Dictionary
	if float(davi_after.get("health", 100.0)) >= float(davi_before.get("health", 100.0)):
		_fail(23, "dano humano não reduziu saúde")
		return

	# Sistemas da Bíblia imediatamente anteriores continuam ativos.
	var wildlife := scene.call("get_animal_ecology_debug_0538") as Dictionary
	if int(wildlife.get("records", 0)) != 18 or int(wildlife.get("species_count", 0)) != 4:
		_fail(24, "Animais & Caça 0.5.38 regrediu")
		return
	var zombie_ecology := scene.call("get_zombie_ecology_debug_0537") as Dictionary
	if int(zombie_ecology.get("hordes", 0)) != 4 or int(zombie_ecology.get("visual_profiles", 0)) != 5:
		_fail(25, "Zumbis 2.0 0.5.37 regrediu")
		return
	if not scene.has_method("get_mission_snapshot_0536"):
		_fail(26, "missões 0.5.36 foram perdidas")
		return
	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("get_vehicle_catalog_05362"):
		_fail(27, "frota 0.5.36.2 foi perdida")
		return
	var fleet := streamer.call("get_vehicle_catalog_05362") as Dictionary
	if int(fleet.get("variant_count", 0)) != 40 or int(fleet.get("directions", 0)) != 8:
		_fail(28, "frota 40x8 regrediu")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0539, FileAccess.READ)
	if file == null:
		_fail(29, "save 0.5.39 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(30, "save 0.5.39 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.39-alpha":
		_fail(31, "versão do save não é 0.5.39-alpha")
		return
	var world_state := payload.get("world", {}) as Dictionary
	var saved_survivors := world_state.get("survivor_records_0539", {}) as Dictionary
	if saved_survivors.size() != 3:
		_fail(32, "três sobreviventes não foram serializados")
		return
	if not bool((saved_survivors.get("helena", {}) as Dictionary).get("gift_shared", false)):
		_fail(33, "relação/presente de Helena não persistiu")
		return

	scene.queue_free()
	for _i in range(18):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(130):
		await process_frame
	var restored_society := restored.call("get_survivor_society_debug_0539") as Dictionary
	if int(restored_society.get("records", 0)) != 3 or int(restored_society.get("met", 0)) < 1 or int(restored_society.get("gifted", 0)) < 1:
		_fail(34, "reload perdeu sociedade/relações")
		return
	var restored_helena := restored.call("get_survivor_record_0539", "helena") as Dictionary
	if not bool(restored_helena.get("met_player", false)) or not bool(restored_helena.get("gift_shared", false)):
		_fail(35, "reload perdeu estado social individual")
		return

	print("SMOKE 0.5.39 OK | survivors=3 roles=3 met=%d assists=%d gifts=%d noise_flees=%d wildlife=18 zombies=4-hordes vehicles=40x8" % [
		int(restored_society.get("met", 0)),
		int(restored_society.get("assists", 0)),
		int(restored_society.get("gifts", 0)),
		int(restored_society.get("noise_flees", 0))
	])
	quit(0)
