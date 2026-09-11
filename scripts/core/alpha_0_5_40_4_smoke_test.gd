extends SceneTree

const SAVE_PATH := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.40.4 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(180):
		await process_frame

	if not scene.has_method("get_feedback_audio_debug_05404"):
		_fail(2, "runtime Feedback & Audio 0.5.40.4 ausente")
		return
	var dbg := scene.call("get_feedback_audio_debug_05404") as Dictionary
	if str(dbg.get("version", "")) != "0.5.40.4-alpha":
		_fail(3, "versão do runtime não é 0.5.40.4-alpha")
		return

	var audio := dbg.get("audio", {}) as Dictionary
	if int(audio.get("registered_cues", 0)) != 7 or int(audio.get("pool_size", 0)) != 4:
		_fail(4, "banco procedural de áudio 0.5.40.4 inválido")
		return
	if int(audio.get("mix_rate", 0)) != 22050 or not bool(audio.get("procedural", false)):
		_fail(5, "áudio local procedural não foi configurado corretamente")
		return

	var ui := dbg.get("ui", {}) as Dictionary
	if not bool(ui.get("flash", false)) or not bool(ui.get("label", false)):
		_fail(6, "camada visual de feedback não foi criada")
		return

	var mobile := dbg.get("mobile", {}) as Dictionary
	if not bool(mobile.get("feedback_connected", false)):
		_fail(7, "controles mobile não foram conectados ao feedback")
		return
	if get_nodes_in_group("mobile_feedback_05404").size() != 1:
		_fail(8, "grupo mobile 0.5.40.4 inválido")
		return

	# Exercita quatro famílias de feedback sem depender de backend de áudio real no CI.
	for event in [
		["attack", "", 1.0],
		["action", "AÇÃO CONCLUÍDA", 0.9],
		["pickup", "ITENS +1", 1.0],
		["alert", "PERIGO", 1.1]
	]:
		scene.call("emit_feedback_05404", str(event[0]), str(event[1]), float(event[2]))
		for _frame in range(4):
			await process_frame

	var after := scene.call("get_feedback_audio_debug_05404") as Dictionary
	var audio_after := after.get("audio", {}) as Dictionary
	var ui_after := after.get("ui", {}) as Dictionary
	if int(after.get("events", 0)) < 4 or int(audio_after.get("emitted", 0)) < 4:
		_fail(9, "eventos não chegaram ao mixer de feedback")
		return
	if int(ui_after.get("pulses", 0)) < 4 or str(ui_after.get("last_kind", "")) != "alert":
		_fail(10, "pulsos visuais não acompanharam os eventos")
		return

	# A 0.5.40.4 não pode remover o World Rework nem os pacotes anteriores.
	if not bool(after.get("world_rework_05403", false)):
		_fail(11, "World Rework 0.5.40.3 regrediu")
		return
	if not bool(after.get("player_high_detail", false)):
		_fail(12, "jogador HD 0.5.40.2 regrediu")
		return
	if int(after.get("zombie_profiles", 0)) != 5 or int(after.get("zombie_frames", 0)) != 8:
		_fail(13, "zumbis 5x8 regrediram")
		return
	if int(after.get("items", 0)) != 16:
		_fail(14, "atlas de 16 itens regrediu")
		return
	if int(after.get("vehicle_variants", 0)) != 40 or int(after.get("vehicle_directions", 0)) != 8:
		_fail(15, "frota 40x8 regrediu")
		return
	if int(after.get("animal_species", 0)) != 4 or int(after.get("animal_directions", 0)) != 8:
		_fail(16, "fauna 4x8 regrediu")
		return
	if not bool(after.get("decision_engine_0540", false)):
		_fail(17, "Atlas Decision Engine regrediu")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_fail(18, "save 0.5.40.4 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(19, "save 0.5.40.4 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.40.4-alpha":
		_fail(20, "save não foi versionado como 0.5.40.4-alpha")
		return
	var world_state := payload.get("world", {}) as Dictionary
	if not bool(world_state.get("feedback_audio_05404", false)):
		_fail(21, "flag persistente de Feedback & Audio ausente")
		return

	print("SMOKE 0.5.40.4 OK | cues=7 pool=4 pulses=%d emitted=%d world=0.5.40.3 playerHD=true zombies=5x8 items=16 vehicles=40x8 animals=4x8" % [
		int(ui_after.get("pulses", 0)),
		int(audio_after.get("emitted", 0))
	])
	quit(0)
