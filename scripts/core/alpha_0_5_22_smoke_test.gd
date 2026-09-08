extends SceneTree

const SAVE_PATH_0522 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.22 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0522):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0522))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(56):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_survival_debug_0522"):
		_fail(2, "player não usa umidade 0.5.22")
		return
	if not scene.has_method("get_weather_state_0522") or not scene.has_method("set_weather_override_0522"):
		_fail(3, "runtime de clima 0.5.22 ausente")
		return
	var weather_debug := scene.call("get_weather_debug_0522") as Dictionary
	if not bool(weather_debug.get("player_0522", false)):
		_fail(4, "runtime não instanciou PlayerV0522")
		return
	if get_nodes_in_group("weather_rain_0522").is_empty():
		_fail(5, "sistema visual de chuva não foi criado")
		return

	# Regressão 0.5.21: cama continua funcional e sono ainda avança a noite.
	var beds := get_nodes_in_group("sleep_surface_0521")
	if beds.is_empty():
		_fail(6, "camas da 0.5.21 regrediram")
		return
	var bed := beds[0] as Node3D
	scene.call("set_time_0521", 1, 22.0 * 60.0)
	player.set("fatigue_0521", 82.0)
	player.global_position = bed.global_position
	if not bool(scene.call("try_interact_near", bed.global_position, player)):
		_fail(7, "sono funcional regrediu")
		return
	var after_sleep := player.call("get_survival_debug_0521") as Dictionary
	if float(after_sleep.get("fatigue", 100.0)) >= 82.0:
		_fail(8, "sono não reduziu cansaço")
		return
	var morning := scene.call("get_time_state_0521") as Dictionary
	if int(morning.get("day", 0)) != 2 or int(morning.get("hour", -1)) != 6:
		_fail(9, "sono não avançou para a manhã")
		return

	# Chuva: visual, redução térmica e acúmulo de umidade ao ar livre.
	scene.call("set_weather_override_0522", 2)
	var rain := scene.call("get_weather_state_0522") as Dictionary
	if str(rain.get("name", "")) != "CHUVA" or float(rain.get("precipitation", 0.0)) < 0.9:
		_fail(10, "estado CHUVA não foi aplicado")
		return
	var rain_mods := scene.call("get_zombie_weather_modifiers_0522") as Dictionary
	if float(rain_mods.get("vision", 1.0)) >= 0.9 or float(rain_mods.get("hearing", 1.0)) >= 0.8:
		_fail(11, "chuva não alterou percepção de zumbis")
		return
	player.global_position = Vector3(10000.0, 0.20, 10000.0)
	player.set("sheltered_0521", false)
	player.set("wetness_0522", 0.0)
	player.call("_update_weather_exposure_0522", 10.0)
	var wet := player.call("get_survival_debug_0522") as Dictionary
	var wetness_after_rain := float(wet.get("wetness", 0.0))
	if wetness_after_rain < 15.0:
		_fail(12, "chuva ao ar livre não molhou o personagem")
		return
	scene.call("_update_rain_follow_0522")
	var rain_visual := scene.call("get_weather_debug_0522") as Dictionary
	if not bool(rain_visual.get("rain_emitting", false)):
		_fail(13, "partículas de chuva não estão emitindo ao ar livre")
		return

	# Abrigo deve secar em vez de continuar acumulando água.
	player.set("sheltered_0521", true)
	player.call("_update_weather_exposure_0522", 8.0)
	var drying := player.call("get_survival_debug_0522") as Dictionary
	if float(drying.get("wetness", 100.0)) >= wetness_after_rain:
		_fail(14, "abrigo não secou o personagem")
		return

	# Neblina: perda visual forte, mas som menos mascarado que na chuva.
	scene.call("set_weather_override_0522", 3)
	var fog := scene.call("get_weather_state_0522") as Dictionary
	if str(fog.get("name", "")) != "NEBLINA":
		_fail(15, "estado NEBLINA não foi aplicado")
		return
	var fog_mods := scene.call("get_zombie_weather_modifiers_0522") as Dictionary
	if float(fog_mods.get("vision", 1.0)) > 0.60:
		_fail(16, "neblina não reduziu visão suficientemente")
		return
	if float(fog_mods.get("hearing", 0.0)) <= float(rain_mods.get("hearing", 1.0)):
		_fail(17, "neblina mascarou som mais que a chuva")
		return

	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty():
		_fail(18, "nenhum zumbi disponível")
		return
	var zombie := zombies[0] as Node3D
	if zombie == null or not zombie.has_method("get_ai_debug_0522"):
		_fail(19, "zumbi não usa percepção climática 0.5.22")
		return
	var zombie_weather := zombie.call("get_ai_debug_0522") as Dictionary
	if float(zombie_weather.get("weather_vision_0522", 1.0)) > 0.60:
		_fail(20, "IA não recebeu modificador da neblina")
		return

	# Persistência de umidade e relógio no save existente.
	player.set("wetness_0522", 43.0)
	scene.call("set_time_0521", 4, 615.0)
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0522, FileAccess.READ)
	if file == null:
		_fail(21, "save 0.5.22 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(22, "save 0.5.22 inválido")
		return
	var payload := parsed as Dictionary
	var player_state := payload.get("player", {}) as Dictionary
	var world_state := payload.get("world", {}) as Dictionary
	if absf(float(player_state.get("wetness_0522", 0.0)) - 43.0) > 0.5:
		_fail(23, "umidade não foi persistida")
		return
	if int(world_state.get("world_day_0521", 0)) != 4:
		_fail(24, "relógio da 0.5.21 regrediu no save")
		return

	# Regressões que já custaram correções anteriores.
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(25, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(26, "portas/casas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(27, "veículos regrediram")
		return
	if not player.has_method("get_survival_debug_0520"):
		_fail(28, "infecção/morte 0.5.20 regrediu")
		return

	print("SMOKE 0.5.22 OK: rain_wet=%.1f dry=%.1f fog_vision=%.2f rain_hearing=%.2f" % [wetness_after_rain, float(drying.get("wetness", 0.0)), float(fog_mods.get("vision", 1.0)), float(rain_mods.get("hearing", 1.0))])
	quit(0)
