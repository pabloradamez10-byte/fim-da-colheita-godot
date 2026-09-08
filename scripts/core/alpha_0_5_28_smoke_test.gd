extends SceneTree

const SAVE_PATH_0528 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.28 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0528):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0528))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(66):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_base_utility_debug_0528"):
		_fail(2, "PlayerV0528 não foi instanciado")
		return
	if not scene.has_method("get_base_utility_debug_0528"):
		_fail(3, "WorldV0528 ausente")
		return
	var build_uis := get_nodes_in_group("build_ui_0528")
	if build_uis.is_empty():
		_fail(4, "UI de construção 0.5.28 ausente")
		return
	var ui_debug := build_uis[0].call("get_build_ui_debug_0528") as Dictionary
	if int(ui_debug.get("piece_buttons", 0)) != 8 or not bool(ui_debug.get("barricade_button", false)) or not bool(ui_debug.get("campfire_button", false)):
		_fail(5, "painel não possui oito peças com barricada/fogueira")
		return
	if get_nodes_in_group("campfire_ui_0528").is_empty():
		_fail(6, "painel dedicado da fogueira ausente")
		return

	player.call("add_item", "wood", 120)
	player.call("add_item", "cordage", 30)
	player.call("add_item", "stone", 40)
	player.call("add_item", "plank", 50)

	# Barricada: peça física, resistente e compatível com manutenção da 0.5.27.
	player.global_position = Vector3(104.0, 0.20, 86.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	if not bool(scene.call("enter_build_mode_0526", "barricade")):
		_fail(7, "modo barricada não abriu")
		return
	await process_frame
	var barricade_preview := scene.call("get_build_debug_0526") as Dictionary
	if not bool(barricade_preview.get("valid", false)):
		_fail(8, "preview da barricada inválido em área livre")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(9, "barricada não foi construída")
		return
	for _i in range(3):
		await process_frame
	var barricades := get_nodes_in_group("spike_barricade_0528")
	if barricades.size() != 1:
		_fail(10, "barricada construída não foi registrada")
		return
	var barricade := barricades[0] as Node3D
	if not _has_static_body(barricade):
		_fail(11, "barricada não possui colisão física")
		return
	var barricade_uid: String = str(barricade.get_meta("build_uid_0526", ""))
	var barricade_status := scene.call("get_nearest_structure_status_0527", barricade.global_position) as Dictionary
	if int(round(float(barricade_status.get("max_health", 0.0)))) != 220:
		_fail(12, "integridade máxima da barricada não é 220")
		return
	if not bool(scene.call("damage_structure_0527", barricade_uid, 55.0, "smoke")):
		_fail(13, "barricada não recebeu dano")
		return
	player.global_position = barricade.global_position + Vector3(0.8, 0.0, 0.0)
	if not bool(scene.call("repair_nearest_structure_0527")):
		_fail(14, "reparo da barricada falhou")
		return
	var repaired_status := scene.call("get_nearest_structure_status_0527", player.global_position) as Dictionary
	if int(round(float(repaired_status.get("health", 0.0)))) != 220:
		_fail(15, "reparo não restaurou a barricada")
		return

	# Zumbis novos precisam carregar a regra de dano de retorno dos espigões.
	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty():
		_fail(16, "nenhum zumbi disponível")
		return
	var zombie := zombies[0] as Node
	if not zombie.has_method("get_ai_debug_0528"):
		_fail(17, "ZombieV0528 não foi instanciado")
		return
	var zombie_debug := zombie.call("get_ai_debug_0528") as Dictionary
	if float(zombie_debug.get("barricade_retaliation_0528", 0.0)) <= 0.0:
		_fail(18, "retaliação da barricada não foi registrada na IA")
		return

	# Fogueira: construção sem collider alto, painel próprio, combustível e luz.
	player.global_position = Vector3(116.0, 0.20, 86.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "campfire")
	await process_frame
	var fire_preview := scene.call("get_build_debug_0526") as Dictionary
	if not bool(fire_preview.get("valid", false)):
		_fail(19, "preview da fogueira inválido em área livre")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(20, "fogueira não foi construída")
		return
	for _i in range(3):
		await process_frame
	var campfires := get_nodes_in_group("campfire_0528")
	if campfires.size() != 1:
		_fail(21, "fogueira construída não foi registrada")
		return
	var campfire := campfires[0] as Node3D
	if _has_static_body(campfire):
		_fail(22, "fogueira criou collider alto/bloqueante")
		return
	var fire_uid: String = str(campfire.get_meta("campfire_uid_0528", ""))
	var fire_light := campfire.get_node_or_null("CampfireLight0528") as OmniLight3D
	if fire_light == null or fire_light.visible:
		_fail(23, "luz da fogueira deveria iniciar apagada")
		return

	player.global_position = campfire.global_position + Vector3(0.7, 0.0, 0.0)
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(24, "INTERAGIR não reconheceu fogueira")
		return
	await process_frame
	var fire_ui := get_nodes_in_group("campfire_ui_0528")[0]
	var fire_ui_debug := fire_ui.call("get_campfire_ui_debug_0528") as Dictionary
	if not bool(fire_ui_debug.get("visible", false)):
		_fail(25, "painel da fogueira não abriu")
		return

	var wood_before: int = int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0))
	if not bool(scene.call("campfire_add_fuel_0528", fire_uid, player)):
		_fail(26, "não foi possível adicionar lenha")
		return
	var wood_after: int = int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0))
	if wood_after != wood_before - 1:
		_fail(27, "lenha não foi descontada corretamente")
		return
	var fuelled := scene.call("get_campfire_status_0528", fire_uid) as Dictionary
	if absf(float(fuelled.get("fuel_minutes", 0.0)) - 60.0) > 0.5:
		_fail(28, "1 lenha não adicionou 60 minutos")
		return
	if not bool(scene.call("campfire_toggle_0528", fire_uid)):
		_fail(29, "fogueira com combustível não acendeu")
		return
	await process_frame
	var burning := scene.call("get_campfire_status_0528", fire_uid) as Dictionary
	if not bool(burning.get("burning", false)) or not fire_light.visible:
		_fail(30, "chama/luz não ficaram ativas")
		return

	# Calor precisa entrar no mesmo ambiente usado pela temperatura corporal.
	scene.call("set_weather_override_0522", 0)
	var warm_env := scene.call("get_environment_state_0521", campfire.global_position + Vector3(0.8, 0.0, 0.0)) as Dictionary
	var far_env := scene.call("get_environment_state_0521", campfire.global_position + Vector3(30.0, 0.0, 0.0)) as Dictionary
	if float(warm_env.get("campfire_warmth_0528", 0.0)) < 4.0:
		_fail(31, "fogueira não adicionou calor local suficiente")
		return
	if float(warm_env.get("effective_temperature", 0.0)) <= float(far_env.get("effective_temperature", 0.0)):
		_fail(32, "temperatura efetiva perto do fogo não aumentou")
		return

	# Tempo consome combustível; chuva exposta precisa consumir mais rápido.
	var clear_before: float = float((scene.call("get_campfire_status_0528", fire_uid) as Dictionary).get("fuel_minutes", 0.0))
	scene.call("advance_time_0521", 10.0, true)
	var clear_after: float = float((scene.call("get_campfire_status_0528", fire_uid) as Dictionary).get("fuel_minutes", 0.0))
	var clear_burn: float = clear_before - clear_after
	if clear_burn < 9.5 or clear_burn > 10.5:
		_fail(33, "consumo em clima aberto não corresponde ao tempo")
		return
	scene.call("set_weather_override_0522", 2)
	var rain_before: float = clear_after
	scene.call("advance_time_0521", 10.0, true)
	var rain_after: float = float((scene.call("get_campfire_status_0528", fire_uid) as Dictionary).get("fuel_minutes", 0.0))
	var rain_burn: float = rain_before - rain_after
	if rain_burn < clear_burn + 2.5:
		_fail(34, "chuva não acelerou o consumo da fogueira exposta")
		return

	# O fogo deve usar o sistema de ruído existente e poder chamar atenção.
	scene.call("_emit_campfire_noise_0528")
	var noise_debug := scene.call("get_noise_debug_0519") as Dictionary
	var kinds := noise_debug.get("kinds", []) as Array
	if not kinds.has("campfire"):
		_fail(35, "fogueira não gerou evento de ruído")
		return

	# Save precisa carregar combustível, fogo ativo e as duas novas estruturas.
	fire_ui.call("close_campfire_0528")
	scene.call("save_game")
	var saved_status := scene.call("get_campfire_status_0528", fire_uid) as Dictionary
	var saved_fuel: float = float(saved_status.get("fuel_minutes", 0.0))
	if saved_fuel <= 0.0 or not bool(saved_status.get("burning", false)):
		_fail(36, "estado da fogueira inválido antes do reload")
		return

	scene.queue_free()
	for _i in range(10):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(66):
		await process_frame
	var restored_fires := get_nodes_in_group("campfire_0528")
	var restored_barricades := get_nodes_in_group("spike_barricade_0528")
	if restored_fires.size() != 1 or restored_barricades.size() != 1:
		_fail(37, "novas estruturas não reapareceram no reload")
		return
	var restored_fire := restored_fires[0] as Node3D
	var restored_uid: String = str(restored_fire.get_meta("campfire_uid_0528", ""))
	var restored_status := restored.call("get_campfire_status_0528", restored_uid) as Dictionary
	if absf(float(restored_status.get("fuel_minutes", 0.0)) - saved_fuel) > 1.0:
		_fail(38, "combustível não persistiu")
		return
	if not bool(restored_status.get("burning", false)):
		_fail(39, "estado aceso não persistiu")
		return
	var restored_light := restored_fire.get_node_or_null("CampfireLight0528") as OmniLight3D
	if restored_light == null or not restored_light.visible:
		_fail(40, "luz não foi restaurada com fogueira acesa")
		return

	# Regressões consolidadas.
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_structure_maintenance_debug_0527"):
		_fail(41, "manutenção 0.5.27 regrediu")
		return
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(42, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(43, "portas/casas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(44, "veículos regrediram")
		return

	print("SMOKE 0.5.28 OK: barricade_hp=220 campfire_fuel=%.1f clear_burn=%.1f rain_burn=%.1f warmth=%.1f persistence=true" % [saved_fuel, clear_burn, rain_burn, float(warm_env.get("campfire_warmth_0528", 0.0))])
	quit(0)

func _has_static_body(root_node: Node) -> bool:
	if root_node is StaticBody3D:
		return true
	for child: Node in root_node.get_children():
		if _has_static_body(child):
			return true
	return false
