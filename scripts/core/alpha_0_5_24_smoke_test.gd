extends SceneTree

const SAVE_PATH_0524 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.24 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0524):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0524))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(64):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_crafting_debug_0524"):
		_fail(2, "PlayerV0524 não está ativo")
		return
	if not scene.has_method("get_crafting_debug_0524") or not scene.has_method("is_near_workbench_0524"):
		_fail(3, "runtime de crafting 0.5.24 ausente")
		return

	var benches := get_nodes_in_group("workbench_0524")
	if benches.is_empty():
		_fail(4, "nenhuma bancada funcional encontrada")
		return
	var bench := benches[0] as Node3D
	if bench == null:
		_fail(5, "bancada inválida")
		return

	var inventory_uis := get_nodes_in_group("inventory_ui_0524")
	if inventory_uis.is_empty():
		_fail(6, "Inventory UI 0.5.24 não registrada")
		return
	var inventory_ui := inventory_uis[0]
	if inventory_ui == null or not inventory_ui.has_method("open_workbench_0524"):
		_fail(7, "UI não suporta modo bancada")
		return

	# Fora da estação: receitas de bancada ficam bloqueadas; craft de campo continua válido.
	player.global_position = Vector3(5000.0, 0.20, 5000.0)
	player.call("add_item", "wood", 4)
	player.call("add_item", "stone", 4)
	player.call("add_item", "fiber", 8)
	if bool(player.call("can_craft", "plank_bundle")):
		_fail(8, "receita de bancada ficou disponível longe da estação")
		return
	if not bool(player.call("can_craft", "cordage")):
		_fail(9, "receita de campo cordage não ficou disponível")
		return
	if not bool(player.call("craft_recipe", "cordage")):
		_fail(10, "craft de campo falhou")
		return
	var after_field := player.call("get_inventory_snapshot") as Dictionary
	if int(after_field.get("cordage", 0)) != 1:
		_fail(11, "corda improvisada não foi produzida")
		return

	# Interagir na bancada precisa ativar a estação e abrir a interface.
	player.global_position = bench.global_position
	if not bool(scene.call("try_interact_near", bench.global_position, player)):
		_fail(12, "INTERAGIR não ativou bancada")
		return
	for _i in range(3):
		await process_frame
	if not bool(player.call("is_at_workbench_0524")):
		_fail(13, "player não reconheceu proximidade da bancada")
		return
	if inventory_ui.has_method("is_inventory_open") and not bool(inventory_ui.call("is_inventory_open")):
		_fail(14, "interação com bancada não abriu a mochila/crafting")
		return

	# Cadeia de produção: madeira -> tábuas; pedra -> lâmina; intermediários -> kit.
	if not bool(player.call("craft_recipe", "plank_bundle")):
		_fail(15, "bancada não processou madeira em tábuas")
		return
	if not bool(player.call("craft_recipe", "stone_blade")):
		_fail(16, "bancada não produziu lâmina de pedra")
		return
	if not bool(player.call("can_craft", "repair_kit")):
		_fail(17, "cadeia processada não habilitou kit de reparo")
		return
	if not bool(player.call("craft_recipe", "repair_kit")):
		_fail(18, "kit de reparo não foi produzido")
		return
	var processed := player.call("get_inventory_snapshot") as Dictionary
	if int(processed.get("plank", 0)) < 1:
		_fail(19, "saldo de tábuas processadas inesperado")
		return
	if int(processed.get("repair_kit", 0)) < 1:
		_fail(20, "kit de reparo não entrou no inventário")
		return

	# Reparo de campo da 0.5.23 continua existindo e a bancada oferece revisão completa.
	var durability: Variant = player.get("weapon_durability_0523")
	if not (durability is Dictionary):
		_fail(21, "dicionário de durabilidade da 0.5.23 regrediu")
		return
	(durability as Dictionary)["machete"] = 10.0
	player.global_position = Vector3(5000.0, 0.20, 5000.0)
	player.call("add_item", "stone", 2)
	player.call("add_item", "fiber", 2)
	if not bool(player.call("repair_weapon_0523", "machete")):
		_fail(22, "reparo de campo da 0.5.23 deixou de funcionar")
		return
	var after_field_repair := float(player.call("get_weapon_durability_0523", "machete"))
	if after_field_repair <= 10.0 or after_field_repair >= float(player.call("get_weapon_max_durability_0523", "machete")):
		_fail(23, "reparo de campo deveria ser parcial")
		return

	player.call("add_item", "repair_kit", 1)
	player.global_position = bench.global_position
	if not bool(player.call("can_workbench_repair_0524", "machete")):
		_fail(24, "revisão completa não ficou disponível na bancada")
		return
	if not bool(player.call("workbench_repair_weapon_0524", "machete")):
		_fail(25, "revisão de bancada falhou")
		return
	var full_durability := float(player.call("get_weapon_durability_0523", "machete"))
	var max_durability := float(player.call("get_weapon_max_durability_0523", "machete"))
	if absf(full_durability - max_durability) > 0.01:
		_fail(26, "revisão de bancada não restaurou 100%")
		return

	# Persistência dos materiais e metadados novos.
	player.call("add_item", "plank", 2)
	player.call("add_item", "repair_kit", 1)
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0524, FileAccess.READ)
	if file == null:
		_fail(27, "save 0.5.24 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(28, "save 0.5.24 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.24-alpha":
		_fail(29, "versão do save não foi atualizada")
		return
	var player_state := payload.get("player", {}) as Dictionary
	var saved_inventory := player_state.get("inventory", {}) as Dictionary
	if int(saved_inventory.get("plank", 0)) < 2 or int(saved_inventory.get("repair_kit", 0)) < 1:
		_fail(30, "materiais processados não persistiram")
		return
	if int(player_state.get("craft_count_0524", 0)) < 4:
		_fail(31, "contador de produção 0.5.24 não persistiu")
		return
	if int(player_state.get("workbench_repair_count_0524", 0)) < 1:
		_fail(32, "contador de revisão de bancada não persistiu")
		return

	# Regressões obrigatórias de versões estabilizadas.
	if get_nodes_in_group("hotbar_slot_0523").size() != 6:
		_fail(33, "hotbar 0.5.23 regrediu")
		return
	if get_nodes_in_group("weather_rain_0522").is_empty():
		_fail(34, "clima 0.5.22 regrediu")
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

	var debug := scene.call("get_crafting_debug_0524") as Dictionary
	print("SMOKE 0.5.24 OK: workbenches=%d crafts=%d repairs=%d plank=%d" % [int(debug.get("workbenches", 0)), int((debug.get("player", {}) as Dictionary).get("craft_count", 0)), int((debug.get("player", {}) as Dictionary).get("workbench_repairs", 0)), int(saved_inventory.get("plank", 0))])
	quit(0)
