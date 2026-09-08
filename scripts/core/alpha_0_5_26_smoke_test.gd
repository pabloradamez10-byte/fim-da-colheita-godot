extends SceneTree

const SAVE_PATH_0526 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.26 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0526):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0526))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(60):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_build_inventory_debug_0526"):
		_fail(2, "PlayerV0526 não foi instanciado")
		return
	if not scene.has_method("get_build_debug_0526"):
		_fail(3, "WorldV0526 ausente")
		return
	if get_nodes_in_group("build_ui_0526").is_empty() or get_nodes_in_group("storage_ui_0526").is_empty():
		_fail(4, "interfaces mobile de construção/armazenamento ausentes")
		return

	# Recursos suficientes para todas as peças e para testar armazenamento.
	player.call("add_item", "plank", 30)
	player.call("add_item", "cordage", 12)
	player.call("add_item", "wood", 80)

	# Piso: deve consumir 2 tábuas e não criar collider elevado.
	player.global_position = Vector3(70.0, 0.20, 70.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	if not bool(scene.call("enter_build_mode_0526", "floor")):
		_fail(5, "não entrou no modo de construção")
		return
	await process_frame
	var floor_debug := scene.call("get_build_debug_0526") as Dictionary
	if not bool(floor_debug.get("valid", false)):
		_fail(6, "preview do piso em área livre não ficou válido")
		return
	var inv_before_floor := player.call("get_inventory_snapshot") as Dictionary
	var plank_before := int(inv_before_floor.get("plank", 0))
	if not bool(scene.call("place_build_preview_0526")):
		_fail(7, "piso não foi colocado")
		return
	await process_frame
	var inv_after_floor := player.call("get_inventory_snapshot") as Dictionary
	if int(inv_after_floor.get("plank", 0)) != plank_before - 2:
		_fail(8, "custo do piso incorreto")
		return
	if get_nodes_in_group("build_floor_0526").size() != 1:
		_fail(9, "piso construído não foi registrado")
		return

	# Parede: rotação 90° e colisão física.
	player.global_position = Vector3(78.0, 0.20, 70.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "wall")
	scene.call("rotate_build_preview_0526")
	await process_frame
	var wall_preview := scene.call("get_build_debug_0526") as Dictionary
	if int(round(float(wall_preview.get("yaw", 0.0)))) != 90:
		_fail(10, "rotação de 90 graus não foi aplicada")
		return
	if not bool(wall_preview.get("valid", false)) or not bool(scene.call("place_build_preview_0526")):
		_fail(11, "parede não foi colocada")
		return
	await process_frame
	var walls := get_nodes_in_group("build_wall_0526")
	if walls.size() != 1 or not _has_static_body(walls[0] as Node):
		_fail(12, "parede não possui colisão física")
		return

	# Cerca: outra peça física independente.
	player.global_position = Vector3(86.0, 0.20, 70.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "fence")
	await process_frame
	if not bool((scene.call("get_build_debug_0526") as Dictionary).get("valid", false)):
		_fail(13, "preview da cerca inválido em área livre")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(14, "cerca não foi colocada")
		return
	await process_frame
	var fences := get_nodes_in_group("build_fence_0526")
	if fences.size() != 1 or not _has_static_body(fences[0] as Node):
		_fail(15, "cerca não possui colisão")
		return

	# Caixa: deve ser física e abrir inventário próprio.
	player.global_position = Vector3(94.0, 0.20, 70.0)
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	scene.call("select_build_piece_0526", "crate")
	await process_frame
	if not bool((scene.call("get_build_debug_0526") as Dictionary).get("valid", false)):
		_fail(16, "preview da caixa inválido em área livre")
		return
	if not bool(scene.call("place_build_preview_0526")):
		_fail(17, "caixa não foi colocada")
		return
	for _i in range(3):
		await process_frame
	var crates := get_nodes_in_group("storage_crate_0526")
	if crates.size() != 1 or not _has_static_body(crates[0] as Node):
		_fail(18, "caixa não possui colisão")
		return
	var crate := crates[0] as Node3D
	var uid := str(crate.get_meta("storage_uid_0526", ""))
	if uid == "":
		_fail(19, "caixa sem UID persistente")
		return

	# Transferências e limite real de 60 unidades.
	var wood_before := int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0))
	if not bool(scene.call("storage_deposit_0526", uid, "wood", 60, player)):
		_fail(20, "depósito de 60 unidades falhou")
		return
	if int(scene.call("get_storage_total_0526", uid)) != 60:
		_fail(21, "capacidade da caixa não chegou a 60")
		return
	if bool(scene.call("storage_deposit_0526", uid, "wood", 1, player)):
		_fail(22, "caixa aceitou item acima da capacidade")
		return
	if not bool(scene.call("storage_withdraw_0526", uid, "wood", 1, player)):
		_fail(23, "retirada da caixa falhou")
		return
	var wood_after := int((player.call("get_inventory_snapshot") as Dictionary).get("wood", 0))
	if wood_after != wood_before - 59:
		_fail(24, "transferência mochila/caixa inconsistente")
		return

	# INTERAGIR precisa abrir a UI da caixa construída.
	player.global_position = crate.global_position + Vector3(0.9, 0.0, 0.0)
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(25, "INTERAGIR não reconheceu caixa construída")
		return
	await process_frame
	var storage_ui := get_nodes_in_group("storage_ui_0526")[0]
	if not bool(storage_ui.call("is_storage_open_0526")):
		_fail(26, "interface de armazenamento não abriu")
		return
	storage_ui.call("close_storage_0526")

	# Quatro estruturas e conteúdo precisam ir para o save.
	scene.call("cancel_build_mode_0526")
	scene.call("save_game")
	var save_file := FileAccess.open(SAVE_PATH_0526, FileAccess.READ)
	if save_file == null:
		_fail(27, "save 0.5.26 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(save_file.get_as_text())
	if not (parsed is Dictionary):
		_fail(28, "save 0.5.26 inválido")
		return
	var world_state := (parsed as Dictionary).get("world", {}) as Dictionary
	var saved_structures := world_state.get("structure_records_0526", []) as Array
	var saved_storage := world_state.get("storage_records_0526", {}) as Dictionary
	if saved_structures.size() != 4:
		_fail(29, "quantidade de estruturas não persistiu")
		return
	if not saved_storage.has(uid) or int((saved_storage[uid] as Dictionary).get("wood", 0)) != 59:
		_fail(30, "conteúdo da caixa não persistiu")
		return

	# Recarrega a cena para validar restauração real, não só o JSON.
	scene.queue_free()
	for _i in range(8):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(60):
		await process_frame
	var restored_debug := restored.call("get_build_debug_0526") as Dictionary
	if int(restored_debug.get("structures", 0)) != 4:
		_fail(31, "estruturas não reapareceram após carregar")
		return
	var restored_crates := get_nodes_in_group("storage_crate_0526")
	if restored_crates.size() != 1:
		_fail(32, "caixa não reapareceu após carregar")
		return
	var restored_uid := str((restored_crates[0] as Node3D).get_meta("storage_uid_0526", ""))
	if int(restored.call("get_storage_total_0526", restored_uid)) != 59:
		_fail(33, "inventário da caixa não reapareceu")
		return

	# Regressões de sistemas estabilizados.
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_production_status_0525"):
		_fail(34, "fila de produção 0.5.25 regrediu")
		return
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(35, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(36, "portas/casas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(37, "veículos regrediram")
		return

	print("SMOKE 0.5.26 OK: structures=4 wall_collision=true fence_collision=true crate_storage=59 capacity=60 restored=true")
	quit(0)

func _has_static_body(root_node: Node) -> bool:
	if root_node is StaticBody3D:
		return true
	for child in root_node.get_children():
		if _has_static_body(child):
			return true
	return false
