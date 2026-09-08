extends SceneTree

const SAVE_PATH_0527 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.27 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0527):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0527))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(64):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_structure_maintenance_debug_0527"):
		_fail(2, "PlayerV0527 não foi instanciado")
		return
	if not scene.has_method("get_structure_debug_0527"):
		_fail(3, "WorldV0527 ausente")
		return
	var build_uis := get_nodes_in_group("build_ui_0527")
	if build_uis.is_empty():
		_fail(4, "UI de construção 0.5.27 ausente")
		return
	var ui_debug := build_uis[0].call("get_build_ui_debug_0527") as Dictionary
	if int(ui_debug.get("piece_buttons", 0)) != 6:
		_fail(5, "painel não possui seis peças")
		return

	player.call("add_item", "plank", 50)
	player.call("add_item", "cordage", 30)
	player.call("add_item", "wood", 100)

	# Porta construída, com collider fechado e interação de abrir.
	player.global_position = Vector3(120.0, 0.20, 120.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	if not bool(scene.call("enter_build_mode_0526", "door")):
		_fail(6, "modo porta não abriu")
		return
	await process_frame
	var door_preview := scene.call("get_build_debug_0526") as Dictionary
	if not bool(door_preview.get("valid", false)):
		_fail(7, "preview de porta inválido em área livre")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(8, "porta não foi construída")
		return
	for _i in range(4):
		await process_frame
	var doors := get_nodes_in_group("build_door_0527")
	if doors.size() != 1 or not _has_static_body(doors[0] as Node):
		_fail(9, "porta construída sem colisão")
		return
	var door := doors[0] as Node3D
	var door_uid: String = str(door.get_meta("build_uid_0526", ""))
	var hinges := get_nodes_in_group("built_door_0527")
	if hinges.size() != 1:
		_fail(10, "hinge da porta ausente")
		return
	var door_hinge := hinges[0] as Node3D
	player.global_position = door_hinge.global_position + Vector3(0.7, 0.0, 0.0)
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(11, "INTERAGIR não abriu porta construída")
		return
	await process_frame
	if not bool(door_hinge.get("is_open")):
		_fail(12, "porta não mudou para aberta")
		return

	# Portão separado e físico.
	player.global_position = Vector3(130.0, 0.20, 120.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "gate")
	await process_frame
	if not bool((scene.call("get_build_debug_0526") as Dictionary).get("valid", false)):
		_fail(13, "preview de portão inválido")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(14, "portão não foi construído")
		return
	for _i in range(3):
		await process_frame
	var gates := get_nodes_in_group("build_gate_0527")
	if gates.size() != 1 or not _has_static_body(gates[0] as Node):
		_fail(15, "portão sem colisão física")
		return

	# Parede recebe dano e reparo restaura integridade consumindo recurso.
	player.global_position = Vector3(140.0, 0.20, 120.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "wall")
	await process_frame
	if not bool(scene.call("place_build_preview_0526")):
		_fail(16, "parede de teste não foi construída")
		return
	await process_frame
	var walls := get_nodes_in_group("build_wall_0526")
	if walls.size() != 1:
		_fail(17, "parede de manutenção ausente")
		return
	var wall := walls[0] as Node3D
	var wall_uid: String = str(wall.get_meta("build_uid_0526", ""))
	if not bool(scene.call("damage_structure_0527", wall_uid, 72.0, "smoke")):
		_fail(18, "dano estrutural falhou")
		return
	var damaged := scene.call("get_nearest_structure_status_0527", wall.global_position) as Dictionary
	if float(damaged.get("health", 999.0)) >= float(damaged.get("max_health", 1.0)):
		_fail(19, "integridade não caiu após dano")
		return
	player.global_position = wall.global_position + Vector3(0.9, 0.0, 0.0)
	var plank_before_repair: int = int((player.call("get_inventory_snapshot") as Dictionary).get("plank", 0))
	if not bool(scene.call("repair_nearest_structure_0527")):
		_fail(20, "reparo da parede falhou")
		return
	var repaired := scene.call("get_nearest_structure_status_0527", player.global_position) as Dictionary
	if absf(float(repaired.get("health", 0.0)) - float(repaired.get("max_health", 1.0))) > 0.01:
		_fail(21, "reparo não restaurou integridade")
		return
	var plank_after_repair: int = int((player.call("get_inventory_snapshot") as Dictionary).get("plank", 0))
	if plank_after_repair >= plank_before_repair:
		_fail(22, "reparo não consumiu material")
		return

	# Desmontagem devolve material parcial e remove a estrutura.
	var plank_before_dismantle: int = plank_after_repair
	if not bool(scene.call("dismantle_nearest_structure_0527")):
		_fail(23, "desmontagem falhou")
		return
	for _i in range(3):
		await process_frame
	if not get_nodes_in_group("build_wall_0526").is_empty():
		_fail(24, "parede desmontada permaneceu no mundo")
		return
	var plank_after_dismantle: int = int((player.call("get_inventory_snapshot") as Dictionary).get("plank", 0))
	if plank_after_dismantle <= plank_before_dismantle:
		_fail(25, "desmontagem não devolveu material")
		return

	# Caixa ocupada não pode ser desmontada.
	player.global_position = Vector3(150.0, 0.20, 120.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "crate")
	await process_frame
	if not bool(scene.call("place_build_preview_0526")):
		_fail(26, "caixa de teste não foi construída")
		return
	for _i in range(3):
		await process_frame
	var crates := get_nodes_in_group("storage_crate_0526")
	if crates.size() != 1:
		_fail(27, "caixa construída ausente")
		return
	var crate := crates[0] as Node3D
	var crate_uid: String = str(crate.get_meta("storage_uid_0526", ""))
	if not bool(scene.call("storage_deposit_0526", crate_uid, "wood", 2, player)):
		_fail(28, "depósito na caixa falhou")
		return
	player.global_position = crate.global_position + Vector3(0.8, 0.0, 0.0)
	if bool(scene.call("dismantle_nearest_structure_0527")):
		_fail(29, "caixa ocupada foi desmontada")
		return

	# Destruição por dano remove estrutura sem reembolso.
	var gate := gates[0] as Node3D
	var gate_uid: String = str(gate.get_meta("build_uid_0526", ""))
	if not bool(scene.call("damage_structure_0527", gate_uid, 999.0, "zombie_test")):
		_fail(30, "dano letal no portão falhou")
		return
	for _i in range(3):
		await process_frame
	if not get_nodes_in_group("build_gate_0527").is_empty():
		_fail(31, "portão destruído permaneceu no mundo")
		return

	# Runtime realmente usa zumbi 0.5.27.
	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty() or not zombies[0].has_method("get_ai_debug_0527"):
		_fail(32, "ZombieV0527 não foi instanciado")
		return

	# Porta aberta e integridades remanescentes devem persistir.
	scene.call("cancel_build_mode_0526")
	scene.call("save_game")
	var save_file := FileAccess.open(SAVE_PATH_0527, FileAccess.READ)
	if save_file == null:
		_fail(33, "save 0.5.27 ausente")
		return
	var parsed: Variant = JSON.parse_string(save_file.get_as_text())
	if not (parsed is Dictionary):
		_fail(34, "save 0.5.27 inválido")
		return
	var world_state := (parsed as Dictionary).get("world", {}) as Dictionary
	var saved_structures := world_state.get("structure_records_0526", []) as Array
	var saved_door_open := false
	for raw: Variant in saved_structures:
		if raw is Dictionary:
			var record := raw as Dictionary
			if str(record.get("uid", "")) == door_uid:
				saved_door_open = bool(record.get("open_0527", false))
				if not record.has("health_0527"):
					_fail(35, "integridade da porta não persistiu")
					return
	if not saved_door_open:
		_fail(36, "estado aberto da porta não persistiu")
		return

	scene.queue_free()
	for _i in range(8):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(64):
		await process_frame
	var restored_doors := get_nodes_in_group("build_door_0527")
	if restored_doors.size() != 1:
		_fail(37, "porta não reapareceu após carregar")
		return
	var restored_hinges := get_nodes_in_group("built_door_0527")
	if restored_hinges.size() != 1 or not bool((restored_hinges[0] as Node3D).get("is_open")):
		_fail(38, "porta não restaurou aberta")
		return
	if get_nodes_in_group("storage_crate_0526").size() != 1:
		_fail(39, "caixa persistente regrediu")
		return
	var restored_debug := restored.call("get_structure_debug_0527") as Dictionary
	if int(restored_debug.get("repaired", 0)) < 1 or int(restored_debug.get("dismantled", 0)) < 1 or int(restored_debug.get("destroyed", 0)) < 1:
		_fail(40, "contadores de manutenção não persistiram")
		return

	# Regressões estabilizadas.
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_production_status_0525"):
		_fail(41, "crafting 0.5.25 regrediu")
		return
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(42, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(43, "casas/portas antigas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(44, "veículos regrediram")
		return

	print("SMOKE 0.5.27 OK: door=open gate=destroyed repair=true dismantle=true crate_guard=true zombie_structure_damage=true persisted=true")
	quit(0)

func _has_static_body(root_node: Node) -> bool:
	if root_node is StaticBody3D:
		return true
	for child: Node in root_node.get_children():
		if _has_static_body(child):
			return true
	return false
