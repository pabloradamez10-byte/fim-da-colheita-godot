extends SceneTree

const SAVE_PATH_0538 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.38 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0538):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0538))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(120):
		await process_frame

	if not scene.has_method("get_animal_ecology_debug_0538"):
		_fail(2, "runtime Animais & Caça ausente")
		return
	var wildlife := scene.call("get_animal_ecology_debug_0538") as Dictionary
	if int(wildlife.get("records", 0)) != 18 or int(wildlife.get("alive", 0)) != 18:
		_fail(3, "fauna inicial não criou 18 animais vivos")
		return
	if int(wildlife.get("species_count", 0)) != 4:
		_fail(4, "quatro espécies não foram registradas")
		return
	var species := wildlife.get("species", {}) as Dictionary
	for species_id in ["rabbit", "deer", "boar", "chicken"]:
		if int(species.get(species_id, 0)) <= 0:
			_fail(5, "espécie ausente: %s" % species_id)
			return
	if not bool(wildlife.get("player_0538", false)):
		_fail(6, "PlayerV0538 não está ativo")
		return

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_hunting_player_debug_0538"):
		_fail(7, "ponte de caça do jogador ausente")
		return

	var animals := get_nodes_in_group("animal_0538")
	if animals.size() != 18 or not (animals[0] is Node3D):
		_fail(8, "nós físicos da fauna não correspondem aos registros")
		return
	var prey := animals[0] as Node3D
	var prey_id := str(prey.get("animal_id_0538"))
	var prey_species := str(prey.get("species_id_0538"))
	var noise_before := int(wildlife.get("noise_flees", 0))
	scene.call("emit_noise_0519", prey.global_position, 32.0, "shotgun", null)
	for _i in range(10):
		await process_frame
	var after_noise := scene.call("get_animal_ecology_debug_0538") as Dictionary
	if int(after_noise.get("noise_flees", 0)) <= noise_before:
		_fail(9, "ruído de tiro não assustou a fauna")
		return

	if not bool(scene.call("damage_animal_debug_0538", prey_id, 999.0)):
		_fail(10, "animal não recebeu dano de caça")
		return
	for _i in range(8):
		await process_frame
	var after_kill := scene.call("get_animal_ecology_debug_0538") as Dictionary
	if int(after_kill.get("kills", 0)) < 1 or int(after_kill.get("carcasses", 0)) < 1:
		_fail(11, "abate não gerou carcaça persistente")
		return
	var killed_record := scene.call("get_animal_record_0538", prey_id) as Dictionary
	if not bool(killed_record.get("dead", false)) or bool(killed_record.get("harvested", false)):
		_fail(12, "estado da carcaça está incorreto")
		return

	var inventory_before := player.call("get_inventory_snapshot") as Dictionary
	var meat_before := int(inventory_before.get("raw_game_meat", 0))
	if not bool(scene.call("butcher_animal_0538", prey_id, player)):
		_fail(13, "carcaça não pôde ser aproveitada")
		return
	for _i in range(5):
		await process_frame
	var inventory_after := player.call("get_inventory_snapshot") as Dictionary
	if int(inventory_after.get("raw_game_meat", 0)) <= meat_before:
		_fail(14, "aproveitamento da carcaça não entregou carne")
		return
	if prey_species == "chicken":
		if int(inventory_after.get("feathers", 0)) <= 0:
			_fail(15, "galinha não entregou penas")
			return
	else:
		if int(inventory_after.get("animal_hide", 0)) <= 0:
			_fail(15, "animal não entregou couro")
			return

	var cooked_before := int(inventory_after.get("cooked_game_meat", 0))
	if not bool(player.call("can_cook_recipe_0532", "cooked_game_meat")):
		_fail(16, "receita de carne de caça não ficou disponível")
		return
	if not bool(player.call("cook_food_recipe_0532", "cooked_game_meat")):
		_fail(17, "carne de caça não pôde ser assada")
		return
	var inventory_cooked := player.call("get_inventory_snapshot") as Dictionary
	if int(inventory_cooked.get("cooked_game_meat", 0)) <= cooked_before:
		_fail(18, "cozimento não produziu carne assada")
		return

	var hunger_before := float((player.call("get_vitals") as Dictionary).get("hunger", 100.0))
	player.set("hunger", 40.0)
	if not bool(player.call("use_inventory_item", "cooked_game_meat")):
		_fail(19, "carne assada não pôde ser consumida")
		return
	if float((player.call("get_vitals") as Dictionary).get("hunger", 0.0)) <= 40.0:
		_fail(20, "carne assada não recuperou fome")
		return
	player.set("hunger", hunger_before)

	# A ecologia zumbi anterior deve continuar íntegra.
	if not scene.has_method("get_zombie_ecology_debug_0537"):
		_fail(21, "Zumbis 2.0 foram perdidos")
		return
	var zombie_ecology := scene.call("get_zombie_ecology_debug_0537") as Dictionary
	if int(zombie_ecology.get("hordes", 0)) != 4 or int(zombie_ecology.get("visual_profiles", 0)) != 5:
		_fail(22, "ecologia zumbi 0.5.37 regrediu")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0538, FileAccess.READ)
	if file == null:
		_fail(23, "save 0.5.38 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(24, "save 0.5.38 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.38-alpha":
		_fail(25, "versão do save não é 0.5.38-alpha")
		return
	var world_state := payload.get("world", {}) as Dictionary
	var saved_animals := world_state.get("animal_records_0538", {}) as Dictionary
	if saved_animals.size() != 18:
		_fail(26, "18 registros de fauna não foram serializados")
		return
	if not saved_animals.has(prey_id) or not bool((saved_animals[prey_id] as Dictionary).get("harvested", false)):
		_fail(27, "carcaça aproveitada não persistiu")
		return

	scene.queue_free()
	for _i in range(18):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(120):
		await process_frame
	var restored_wildlife := restored.call("get_animal_ecology_debug_0538") as Dictionary
	if int(restored_wildlife.get("records", 0)) != 18 or int(restored_wildlife.get("harvested", 0)) < 1:
		_fail(28, "reload perdeu persistência da fauna")
		return
	if int(restored_wildlife.get("spawned", 0)) != 17:
		_fail(29, "animal já aproveitado reapareceu após reload")
		return
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_hunting_player_debug_0538"):
		_fail(30, "reload perdeu PlayerV0538")
		return

	print("SMOKE 0.5.38 OK | animals=18 species=4 noise_flees=%d kills=%d butchered=%d zombies=4-hordes meat_loop=true" % [
		int(restored_wildlife.get("noise_flees", 0)),
		int(restored_wildlife.get("kills", 0)),
		int(restored_wildlife.get("butchered", 0))
	])
	quit(0)
