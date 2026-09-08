extends SceneTree

const SAVE_PATH_0531 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.31 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0531):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0531))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(90):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_agriculture_player_debug_0531"):
		_fail(2, "PlayerV0531 não foi instanciado")
		return
	if not scene.has_method("get_agriculture_debug_0531"):
		_fail(3, "WorldV0531 ausente")
		return
	if not scene.has_method("get_vehicle_debug_0530"):
		_fail(4, "regressão: veículos 0.5.30 foram perdidos")
		return
	var farm_debug := scene.call("get_agriculture_debug_0531") as Dictionary
	if int(farm_debug.get("plots", 0)) != 6 or int(farm_debug.get("nodes", 0)) != 6:
		_fail(5, "seis canteiros não foram criados")
		return
	if not bool(farm_debug.get("player_0531", false)):
		_fail(6, "world não reconhece PlayerV0531")
		return

	var player_debug := player.call("get_agriculture_player_debug_0531") as Dictionary
	var starting_seeds := int(player_debug.get("potato_seed", 0))
	if starting_seeds < 4:
		_fail(7, "sementes iniciais não foram migradas")
		return

	# Canteiro 0: preparar solo, plantar, receber chuva e colher.
	var plot0 := scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	if not plot0.has("position"):
		_fail(8, "posição do primeiro canteiro ausente")
		return
	player.global_position = plot0.get("position", Vector3.ZERO) as Vector3
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(9, "não foi possível preparar o solo")
		return
	plot0 = scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	if int(plot0.get("state", -1)) != 1:
		_fail(10, "canteiro não ficou preparado")
		return
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(11, "não foi possível plantar")
		return
	plot0 = scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	if int(plot0.get("state", -1)) != 2:
		_fail(12, "semente não iniciou cultivo")
		return
	var after_plant := player.call("get_agriculture_player_debug_0531") as Dictionary
	if int(after_plant.get("potato_seed", 0)) != starting_seeds - 1:
		_fail(13, "plantio não consumiu uma semente")
		return

	scene.call("set_weather_override_0522", 2)
	scene.call("advance_time_0521", 800.0, false)
	scene.call("refresh_farming_0531")
	plot0 = scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	if int(plot0.get("state", -1)) != 4:
		_fail(14, "chuva + tempo não levaram cultura à colheita")
		return
	if float(plot0.get("moisture", 0.0)) < 0.8:
		_fail(15, "chuva não manteve umidade do canteiro")
		return

	player.global_position = plot0.get("position", Vector3.ZERO) as Vector3
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(16, "colheita falhou")
		return
	var after_harvest := player.call("get_agriculture_player_debug_0531") as Dictionary
	if int(after_harvest.get("potato", 0)) < 3:
		_fail(17, "colheita não entregou batatas")
		return
	if int(after_harvest.get("potato_seed", 0)) < starting_seeds + 1:
		_fail(18, "colheita não devolveu sementes suficientes")
		return
	plot0 = scene.call("get_farm_plot_state_0531", "plot_00") as Dictionary
	if int(plot0.get("state", -1)) != 1:
		_fail(19, "canteiro colhido deveria permanecer preparado")
		return

	# Canteiro 1: rega manual e persistência.
	scene.call("clear_weather_override_0522")
	player.call("add_item", "water", 2)
	var plot1 := scene.call("get_farm_plot_state_0531", "plot_01") as Dictionary
	player.global_position = plot1.get("position", Vector3.ZERO) as Vector3
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(20, "preparo do segundo canteiro falhou")
		return
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(21, "plantio do segundo canteiro falhou")
		return
	var water_before := int((player.call("get_inventory_snapshot") as Dictionary).get("water", 0))
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(22, "rega manual falhou")
		return
	plot1 = scene.call("get_farm_plot_state_0531", "plot_01") as Dictionary
	if float(plot1.get("moisture", 0.0)) < 0.99:
		_fail(23, "rega manual não saturou umidade")
		return
	if int((player.call("get_inventory_snapshot") as Dictionary).get("water", 0)) != water_before - 1:
		_fail(24, "rega não consumiu água")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0531, FileAccess.READ)
	if file == null:
		_fail(25, "save 0.5.31 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(26, "save 0.5.31 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.31-alpha":
		_fail(27, "save não recebeu versão 0.5.31")
		return
	var world_state := payload.get("world", {}) as Dictionary
	var farm_records := world_state.get("farm_plot_records_0531", {}) as Dictionary
	if not farm_records.has("plot_01"):
		_fail(28, "canteiro não foi serializado")
		return

	scene.queue_free()
	for _i in range(12):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(96):
		await process_frame
	var restored_plot := restored.call("get_farm_plot_state_0531", "plot_01") as Dictionary
	if int(restored_plot.get("state", -1)) < 2:
		_fail(29, "cultivo não persistiu após reload")
		return
	if float(restored_plot.get("moisture", 0.0)) <= 0.0:
		_fail(30, "umidade não persistiu após reload")
		return
	var restored_debug := restored.call("get_agriculture_debug_0531") as Dictionary
	if int(restored_debug.get("harvested", 0)) < 1:
		_fail(31, "contador de colheita não persistiu")
		return
	if not restored.has_method("get_vehicle_debug_0530"):
		_fail(32, "regressão final: suporte a veículos desapareceu após reload")
		return

	print("SMOKE 0.5.31 OK: agricultura, chuva/rega, colheita e persistência preservando 0.5.30")
	if FileAccess.file_exists(SAVE_PATH_0531):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0531))
	quit(0)
