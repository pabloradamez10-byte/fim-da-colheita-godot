extends SceneTree

const SAVE_PATH_0520 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.20 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	# O teste começa limpo para que cadáveres de execuções anteriores não alterem a contagem.
	if FileAccess.file_exists(SAVE_PATH_0520):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0520))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(48):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_survival_debug_0520"):
		_fail(2, "player não usa sobrevivência 0.5.20")
		return
	if not scene.has_method("get_survival_loop_debug_0520"):
		_fail(3, "runtime do loop 0.5.20 ausente")
		return
	var initial_loop := scene.call("get_survival_loop_debug_0520") as Dictionary
	if not bool(initial_loop.get("player_0520", false)):
		_fail(4, "runtime não instanciou PlayerV0520")
		return

	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty():
		_fail(5, "nenhum zumbi disponível")
		return
	var zombie := zombies[0] as Node3D
	if zombie == null or not zombie.has_method("get_ai_debug_0520"):
		_fail(6, "zumbi não usa arquétipos 0.5.20")
		return
	var archetype := zombie.call("get_ai_debug_0520") as Dictionary
	if str(archetype.get("archetype_0520", "")) == "":
		_fail(7, "arquétipo de zumbi não definido")
		return

	# Ferida de zumbi: precisa criar infecção além de dor/sangramento da 0.5.19.
	player.call("take_zombie_damage_0520", 9.0, 2)
	var infected := player.call("get_survival_debug_0520") as Dictionary
	var infection_before := float(infected.get("infection", 0.0))
	if infection_before <= 0.0:
		_fail(8, "ataque de zumbi não gerou infecção")
		return
	player.call("add_item", "antiseptic", 1)
	if not bool(player.call("use_inventory_item", "antiseptic")):
		_fail(9, "antisséptico não pôde ser usado")
		return
	var treated := player.call("get_survival_debug_0520") as Dictionary
	if float(treated.get("infection", 100.0)) >= infection_before:
		_fail(10, "antisséptico não reduziu infecção")
		return

	# Recompensa: um zumbi eliminado vira cadáver saqueável persistente.
	var corpse_pos := Vector3(46.0, 0.20, 46.0)
	zombie.global_position = corpse_pos
	zombie.call("take_damage", 999.0)
	for _i in range(5):
		await process_frame
	var after_kill := scene.call("get_survival_loop_debug_0520") as Dictionary
	if int(after_kill.get("kills", 0)) < 1 or int(after_kill.get("corpses", 0)) < 1:
		_fail(11, "morte do zumbi não criou cadáver/abate")
		return
	if int(after_kill.get("dead_zombies", 0)) < 1:
		_fail(12, "zumbi morto não foi marcado para persistência")
		return
	if get_nodes_in_group("corpse_loot_0520").is_empty():
		_fail(13, "marcador visual do cadáver ausente")
		return

	var inventory_before := player.call("get_inventory_snapshot") as Dictionary
	var fiber_before := int(inventory_before.get("fiber", 0))
	player.global_position = corpse_pos
	if not bool(scene.call("try_interact_near", corpse_pos, player)):
		_fail(14, "INTERAGIR não saqueou cadáver")
		return
	for _i in range(3):
		await process_frame
	var inventory_after := player.call("get_inventory_snapshot") as Dictionary
	if int(inventory_after.get("fiber", 0)) <= fiber_before:
		_fail(15, "loot do cadáver não chegou à mochila")
		return
	var after_loot := scene.call("get_survival_loop_debug_0520") as Dictionary
	if int(after_loot.get("corpses", 0)) != 0:
		_fail(16, "cadáver saqueado permaneceu registrado")
		return

	# Consequência da morte: parte de uma pilha relevante precisa ficar recuperável.
	player.call("add_item", "wood", 12)
	player.call("add_item", "ammo_9mm", 10)
	var death_pos := Vector3(52.0, 0.20, 42.0)
	player.global_position = death_pos
	player.set("health", 1.0)
	player.call("take_damage", 50.0)
	for _i in range(8):
		await process_frame
	var after_death := scene.call("get_survival_loop_debug_0520") as Dictionary
	if int(after_death.get("deaths", 0)) < 1:
		_fail(17, "morte não incrementou continuidade")
		return
	if int(after_death.get("death_bags", 0)) < 1 or get_nodes_in_group("death_bag_0520").is_empty():
		_fail(18, "morte não criou mochila recuperável")
		return
	var respawn_target := scene.call("get_respawn_position_0520") as Vector3
	if player.global_position.distance_to(respawn_target) > 1.0:
		_fail(19, "player não retornou ao ponto seguro")
		return
	var vitals := player.call("get_vitals") as Dictionary
	if int(vitals.get("health", 0)) <= 0:
		_fail(20, "player continuou morto após continuidade")
		return

	# Persistência: os novos campos precisam estar realmente serializados no save compatível.
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0520, FileAccess.READ)
	if file == null:
		_fail(21, "save 0.5.20 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(22, "save 0.5.20 inválido")
		return
	var world_state := (parsed as Dictionary).get("world", {}) as Dictionary
	if (world_state.get("dead_zombies_0520", []) as Array).is_empty():
		_fail(23, "zumbi morto não foi persistido no save")
		return
	if (world_state.get("death_bags_0520", {}) as Dictionary).is_empty():
		_fail(24, "mochila perdida não foi persistida no save")
		return

	# Regressões que não podem ser sacrificadas pelo novo loop.
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(25, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(26, "portas/casas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(27, "veículos regrediram")
		return

	print("SMOKE 0.5.20 OK: archetype=%s infection=%.1f kills=%d deaths=%d bags=%d" % [str(archetype.get("archetype_0520", "?")), infection_before, int(after_death.get("kills", 0)), int(after_death.get("deaths", 0)), int(after_death.get("death_bags", 0))])
	quit(0)
