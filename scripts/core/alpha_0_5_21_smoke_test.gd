extends SceneTree

const SAVE_PATH_0521 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.21 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0521):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0521))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(54):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_survival_debug_0521"):
		_fail(2, "player não usa fisiologia 0.5.21")
		return
	if not scene.has_method("get_time_state_0521") or not scene.has_method("get_environment_state_0521"):
		_fail(3, "runtime de tempo/ambiente 0.5.21 ausente")
		return
	var debug := scene.call("get_survival_loop_debug_0521") as Dictionary
	if not bool(debug.get("player_0521", false)):
		_fail(4, "runtime não instanciou PlayerV0521")
		return

	var beds := get_nodes_in_group("sleep_surface_0521")
	var shelters := get_nodes_in_group("shelter_structure_0521")
	if beds.is_empty():
		_fail(5, "nenhuma cama funcional 0.5.21 registrada")
		return
	if shelters.is_empty():
		_fail(6, "nenhum abrigo 0.5.21 registrado")
		return

	# Abrigo precisa alterar a exposição térmica sem teletransportar o jogador.
	var bed := beds[0] as Node3D
	if bed == null:
		_fail(7, "cama funcional inválida")
		return
	scene.call("set_time_0521", 1, 120.0) # 02:00, período frio.
	var indoor := scene.call("get_environment_state_0521", bed.global_position) as Dictionary
	var outdoor := scene.call("get_environment_state_0521", Vector3(10000.0, 0.20, 10000.0)) as Dictionary
	if not bool(indoor.get("sheltered", false)):
		_fail(8, "posição da cama não foi reconhecida como abrigo")
		return
	if bool(outdoor.get("sheltered", true)):
		_fail(9, "posição externa foi marcada como abrigo")
		return
	if float(indoor.get("effective_temperature", 0.0)) <= float(outdoor.get("effective_temperature", 0.0)):
		_fail(10, "abrigo não protegeu do frio noturno")
		return

	# Dormir à noite precisa avançar para a manhã e reduzir cansaço.
	scene.call("set_time_0521", 1, 22.0 * 60.0)
	player.set("fatigue_0521", 82.0)
	player.global_position = bed.global_position
	var fatigue_before := float((player.call("get_survival_debug_0521") as Dictionary).get("fatigue", 0.0))
	if not bool(scene.call("try_interact_near", bed.global_position, player)):
		_fail(11, "INTERAGIR na cama não iniciou sono")
		return
	for _i in range(5):
		await process_frame
	var slept := player.call("get_survival_debug_0521") as Dictionary
	var fatigue_after := float(slept.get("fatigue", 100.0))
	if fatigue_after >= fatigue_before:
		_fail(12, "sono não reduziu cansaço")
		return
	if int(slept.get("last_sleep_minutes", 0)) < 400:
		_fail(13, "sono noturno não registrou avanço suficiente")
		return
	var morning := scene.call("get_time_state_0521") as Dictionary
	if int(morning.get("day", 1)) != 2:
		_fail(14, "sono atravessando meia-noite não incrementou o dia")
		return
	if int(morning.get("hour", 0)) != 6:
		_fail(15, "sono noturno não terminou pela manhã")
		return

	# Relógio também precisa cruzar a meia-noite sem depender do sono.
	scene.call("set_time_0521", 4, 1439.0)
	scene.call("advance_time_0521", 2.0, true)
	var rollover := scene.call("get_time_state_0521") as Dictionary
	if int(rollover.get("day", 0)) != 5 or int(rollover.get("hour", -1)) != 0:
		_fail(16, "relógio não virou o dia corretamente")
		return

	# A noite deve alterar o perfil sensorial dos zumbis.
	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty():
		_fail(17, "nenhum zumbi disponível")
		return
	var zombie := zombies[0] as Node3D
	if zombie == null or not zombie.has_method("get_ai_debug_0521"):
		_fail(18, "zumbi não usa sentidos 0.5.21")
		return
	scene.call("set_time_0521", 5, 22.0 * 60.0)
	var night_ai := zombie.call("get_ai_debug_0521") as Dictionary
	if not bool(night_ai.get("night_0521", false)):
		_fail(19, "zumbi não reconheceu período noturno")
		return
	if float(night_ai.get("hearing_multiplier_0521", 1.0)) <= 1.0:
		_fail(20, "audição noturna não foi ampliada")
		return
	if float(night_ai.get("vision_range_0521", 99.0)) >= 16.0:
		_fail(21, "visão noturna não foi reduzida")
		return

	# Save precisa preservar relógio e fisiologia nova junto ao loop 0.5.20.
	player.set("fatigue_0521", 61.0)
	scene.call("set_time_0521", 7, 735.0)
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0521, FileAccess.READ)
	if file == null:
		_fail(22, "save 0.5.21 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(23, "save 0.5.21 inválido")
		return
	var payload := parsed as Dictionary
	var world_state := payload.get("world", {}) as Dictionary
	var player_state := payload.get("player", {}) as Dictionary
	if int(world_state.get("world_day_0521", 0)) != 7:
		_fail(24, "dia não foi persistido")
		return
	if absf(float(world_state.get("world_minutes_0521", 0.0)) - 735.0) > 1.0:
		_fail(25, "hora não foi persistida")
		return
	if absf(float(player_state.get("fatigue_0521", 0.0)) - 61.0) > 1.0:
		_fail(26, "cansaço não foi persistido")
		return
	if not player_state.has("body_temperature_0521"):
		_fail(27, "temperatura corporal não foi persistida")
		return

	# Regressões obrigatórias da Bíblia.
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(28, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(29, "portas/casas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(30, "veículos regrediram")
		return
	if not player.has_method("get_survival_debug_0520"):
		_fail(31, "loop de infecção/morte 0.5.20 regrediu")
		return

	print("SMOKE 0.5.21 OK: beds=%d shelters=%d fatigue=%.1f day=%d time=%s night_hearing=%.2f" % [beds.size(), shelters.size(), fatigue_after, int(rollover.get("day", 0)), str(morning.get("formatted", "?")), float(night_ai.get("hearing_multiplier_0521", 1.0))])
	quit(0)
