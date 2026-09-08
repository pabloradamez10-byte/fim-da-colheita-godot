extends SceneTree

const SAVE_PATH_0530 := "user://fim_da_colheita_alpha_0_5_2.save.json"
const VEHICLE_KEY_0530 := "smoke0530:pickup"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.30 FAIL: %s" % message)
	quit(code)

func _find_vehicle(uid: String) -> Node3D:
	for raw: Node in get_nodes_in_group("vehicle_0530"):
		if raw is Node3D and str((raw as Node3D).get_meta("vehicle_key_0530", "")) == uid:
			return raw as Node3D
	return null

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0530):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0530))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(80):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_vehicle_player_debug_0530"):
		_fail(2, "PlayerV0530 não foi instanciado")
		return
	if not scene.has_method("get_vehicle_debug_0530"):
		_fail(3, "WorldV0530 ausente")
		return
	if get_nodes_in_group("vehicle_ui_0530").is_empty():
		_fail(4, "painel mobile do veículo ausente")
		return
	if get_nodes_in_group("inventory_ui_0530").is_empty():
		_fail(5, "inventário 0.5.30 ausente")
		return
	var controls := get_first_node_in_group("mobile_controls")
	if controls == null or not controls.has_method("set_vehicle_mode_0530"):
		_fail(6, "controles mobile não suportam modo veículo")
		return
	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("_build_vehicle_sprite_0517"):
		_fail(7, "streamer 0.5.30 não preservou fábrica de veículos")
		return

	# Cria um veículo conhecido em área isolada para testar todo o ciclo sem depender do seed urbano.
	var probe_parent := Node3D.new()
	probe_parent.name = "VehicleProbe0530"
	scene.add_child(probe_parent)
	streamer.call("_build_vehicle_sprite_0517", probe_parent, Vector3(420.0, 0.28, 420.0), 0.0, 3, VEHICLE_KEY_0530)
	for _i in range(4):
		await process_frame
	var vehicle := _find_vehicle(VEHICLE_KEY_0530)
	if vehicle == null:
		_fail(8, "veículo de teste não foi criado")
		return
	if vehicle.get_node_or_null("VehicleSprite0517") == null:
		_fail(9, "sprite legado 0.5.17 não foi preservado")
		return
	if vehicle.get_node_or_null("VehicleCollider0517") == null:
		_fail(10, "marcador de colisão legado não foi preservado")
		return
	if vehicle.get_node_or_null("VehicleDriveShape0530") == null:
		_fail(11, "colisão dirigível 0.5.30 ausente")
		return

	player.call("add_item", "wood", 8)
	player.call("add_item", "gasoline", 3)
	player.call("add_item", "repair_kit", 2)
	player.global_position = vehicle.global_position + Vector3(0.8, -0.08, 0.0)
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(12, "INTERAGIR não reconheceu veículo")
		return
	for _i in range(3):
		await process_frame
	var vehicle_ui := get_nodes_in_group("vehicle_ui_0530")[0]
	var ui_debug := vehicle_ui.call("get_vehicle_ui_debug_0530") as Dictionary
	if not bool(ui_debug.get("open", false)):
		_fail(13, "painel do veículo não abriu")
		return
	vehicle = _find_vehicle(VEHICLE_KEY_0530)
	if vehicle == null or not vehicle.is_in_group("vehicle_persistent_0530"):
		_fail(14, "veículo não saiu do chunk para persistência")
		return
	var activation_debug := scene.call("get_vehicle_debug_0530") as Dictionary
	if int(activation_debug.get("records", 0)) < 1:
		_fail(15, "ativação não criou registro persistente")
		return

	# Porta-malas transfere recursos nos dois sentidos.
	var backpack_before := player.call("get_inventory_snapshot") as Dictionary
	var wood_before := int(backpack_before.get("wood", 0))
	if not bool(scene.call("vehicle_trunk_deposit_0530", VEHICLE_KEY_0530, "wood", 1, player)):
		_fail(16, "depósito no porta-malas falhou")
		return
	var stored_status := scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary
	var stored_trunk := stored_status.get("trunk", {}) as Dictionary
	if int(stored_trunk.get("wood", 0)) < 1:
		_fail(17, "madeira não chegou ao porta-malas")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0)) != wood_before - 1:
		_fail(18, "depósito não descontou mochila")
		return
	if not bool(scene.call("vehicle_trunk_withdraw_0530", VEHICLE_KEY_0530, "wood", 1, player)):
		_fail(19, "retirada do porta-malas falhou")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0)) != wood_before:
		_fail(20, "retirada não devolveu item à mochila")
		return

	# Abastecimento e reparo usam recursos reais da mochila.
	vehicle.set("fuel_0530", 2.0)
	var gas_before := int((player.call("get_inventory_snapshot") as Dictionary).get("gasoline", 0))
	if not bool(scene.call("vehicle_refuel_0530", VEHICLE_KEY_0530, player)):
		_fail(21, "abastecimento falhou")
		return
	var fuel_after_refuel := float((scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary).get("fuel", 0.0))
	if absf(fuel_after_refuel - 3.0) > 0.05:
		_fail(22, "1L da mochila não virou 1L no tanque")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("gasoline", 0)) != gas_before - 1:
		_fail(23, "gasolina não foi consumida da mochila")
		return

	var status_before_repair := scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary
	var max_health := float(status_before_repair.get("max_health", 100.0))
	vehicle.set("health_0530", max_health * 0.40)
	var kit_before := int((player.call("get_inventory_snapshot") as Dictionary).get("repair_kit", 0))
	if not bool(scene.call("vehicle_repair_0530", VEHICLE_KEY_0530, player)):
		_fail(24, "reparo do veículo falhou")
		return
	var repaired_health := float((scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary).get("health", 0.0))
	if repaired_health < max_health * 0.68:
		_fail(25, "kit não restaurou aproximadamente 30% da integridade")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("repair_kit", 0)) != kit_before - 1:
		_fail(26, "kit de reparo não foi consumido")
		return

	# Condução: controles mudam, veículo anda, combustível cai e jogador/câmera acompanham.
	vehicle_ui.call("close_vehicle_0530")
	if not bool(scene.call("enter_vehicle_by_uid_0530", VEHICLE_KEY_0530, player)):
		_fail(27, "não foi possível entrar no veículo")
		return
	if not bool(player.call("is_in_vehicle_0530")) or player.visible:
		_fail(28, "estado visual do motorista incorreto")
		return
	if not bool(controls.call("is_vehicle_mode_0530")):
		_fail(29, "controles não entraram em modo veículo")
		return
	# Isola a prova de deslocamento de obstáculos procedurais; a colisão é testada separadamente por dano.
	vehicle.collision_mask = 0
	var drive_start := vehicle.global_position
	var fuel_before_drive := float((scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary).get("fuel", 0.0))
	controls.set("move_vector", Vector2(0.0, -1.0))
	for _i in range(120):
		await process_frame
	controls.set("move_vector", Vector2.ZERO)
	for _i in range(8):
		await process_frame
	var drive_end := vehicle.global_position
	var driven_distance := Vector2(drive_end.x - drive_start.x, drive_end.z - drive_start.z).length()
	var fuel_after_drive := float((scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary).get("fuel", 0.0))
	if driven_distance < 2.0:
		_fail(30, "joystick não movimentou o veículo")
		return
	if fuel_after_drive >= fuel_before_drive:
		_fail(31, "condução não consumiu combustível")
		return
	if Vector2(player.global_position.x - vehicle.global_position.x, player.global_position.z - vehicle.global_position.z).length() > 0.2:
		_fail(32, "jogador/câmera não acompanharam o veículo")
		return
	var vehicle_env := scene.call("get_environment_state_0521", player.global_position) as Dictionary
	if not bool(vehicle_env.get("vehicle_shelter_0530", false)):
		_fail(33, "ocupante não recebeu abrigo climático do veículo")
		return

	# Integridade reage a dano e pode imobilizar; aqui validamos o dano sem destruir o veículo de persistência.
	var health_before_damage := float((scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary).get("health", 0.0))
	vehicle.call("take_vehicle_damage_0530", 5.0)
	var health_after_damage := float((scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary).get("health", 0.0))
	if health_after_damage >= health_before_damage:
		_fail(34, "dano não reduziu integridade")
		return

	if not bool(scene.call("exit_vehicle_for_player_0530", player)):
		_fail(35, "não foi possível sair do veículo")
		return
	if bool(player.call("is_in_vehicle_0530")) or not player.visible:
		_fail(36, "player não voltou ao estado a pé")
		return
	if bool(controls.call("is_vehicle_mode_0530")):
		_fail(37, "controles mobile permaneceram em modo veículo")
		return

	# Persistência: posição, combustível, integridade e porta-malas devem sobreviver ao reload.
	player.global_position = vehicle.global_position + Vector3(1.8, -0.08, 0.0)
	player.call("add_item", "food", 2)
	if not bool(scene.call("vehicle_trunk_deposit_0530", VEHICLE_KEY_0530, "food", 1, player)):
		_fail(38, "não foi possível preparar porta-malas para persistência")
		return
	var saved_status := scene.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary
	var saved_position := vehicle.global_position
	var saved_fuel := float(saved_status.get("fuel", 0.0))
	var saved_health := float(saved_status.get("health", 0.0))
	var saved_trunk := saved_status.get("trunk", {}) as Dictionary
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0530, FileAccess.READ)
	if file == null:
		_fail(39, "save 0.5.30 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(40, "save 0.5.30 inválido")
		return
	var world_state := (parsed as Dictionary).get("world", {}) as Dictionary
	var vehicle_records := world_state.get("vehicle_records_0530", {}) as Dictionary
	if not vehicle_records.has(VEHICLE_KEY_0530):
		_fail(41, "registro do veículo não foi serializado")
		return

	scene.queue_free()
	for _i in range(12):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(96):
		await process_frame
	var restored_vehicle := _find_vehicle(VEHICLE_KEY_0530)
	if restored_vehicle == null:
		_fail(42, "veículo persistente não reapareceu")
		return
	var restored_status := restored.call("get_vehicle_status_0530", VEHICLE_KEY_0530) as Dictionary
	if Vector2(restored_vehicle.global_position.x - saved_position.x, restored_vehicle.global_position.z - saved_position.z).length() > 0.35:
		_fail(43, "posição do veículo não persistiu")
		return
	if absf(float(restored_status.get("fuel", 0.0)) - saved_fuel) > 0.15:
		_fail(44, "combustível não persistiu")
		return
	if absf(float(restored_status.get("health", 0.0)) - saved_health) > 0.15:
		_fail(45, "integridade não persistiu")
		return
	var restored_trunk := restored_status.get("trunk", {}) as Dictionary
	if int(restored_trunk.get("food", 0)) != int(saved_trunk.get("food", 0)):
		_fail(46, "porta-malas não persistiu")
		return
	if bool(restored.call("should_spawn_streamed_vehicle_0530", VEHICLE_KEY_0530)):
		_fail(47, "registro persistente permitiria duplicar veículo procedural")
		return

	# Tentar gerar novamente a mesma chave deve ser ignorado pelo streamer 0.5.30.
	var restored_streamer := restored.get_node_or_null("ChunkStreamer")
	var duplicate_parent := Node3D.new()
	restored.add_child(duplicate_parent)
	restored_streamer.call("_build_vehicle_sprite_0517", duplicate_parent, Vector3(420.0, 0.28, 420.0), 0.0, 3, VEHICLE_KEY_0530)
	await process_frame
	if duplicate_parent.get_child_count() != 0:
		_fail(48, "veículo procedural duplicou após reload")
		return

	# Sobrevivência hídrica anterior continua disponível na mesma árvore de herança.
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_water_survival_debug_0529"):
		_fail(49, "sobrevivência hídrica 0.5.29 regrediu")
		return
	if not restored.has_method("get_water_debug_0529"):
		_fail(50, "runtime hídrico 0.5.29 regrediu")
		return

	print("SMOKE 0.5.30 OK: drove=%.1f fuel=%.2f health=%.1f trunk_food=%d persistent=true duplicate=false" % [driven_distance, saved_fuel, saved_health, int(restored_trunk.get("food", 0))])
	quit(0)
