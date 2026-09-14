extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.1 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.1-alpha":
		_fail(1, "versão do projeto incorreta")
		return
	if int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 0)) != 60:
		_fail(2, "tick de física não está em 60 Hz")
		return
	if not bool(ProjectSettings.get_setting("physics/common/physics_interpolation", false)):
		_fail(3, "interpolação de física não está ativa")
		return

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(4, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(40):
		await process_frame

	if not scene.has_method("get_fluidity_debug_0601"):
		_fail(5, "runtime fluido não está ativo")
		return
	var runtime := scene.call("get_fluidity_debug_0601") as Dictionary
	if str(runtime.get("version", "")) != "0.6.1-alpha":
		_fail(6, "runtime fluido reportou versão incorreta")
		return

	var controls := scene.get_node_or_null("MobileLayer/MobileControls")
	if controls == null or not controls.has_method("get_mobile_fluidity_debug_0601"):
		_fail(7, "controles suavizados não estão ativos")
		return
	controls.set("move_vector", Vector2.RIGHT)
	controls.call("_process", 1.0 / 60.0)
	var rising := (controls.call("get_move_vector") as Vector2).length()
	if rising <= 0.0 or rising >= 1.0:
		_fail(8, "entrada analógica não foi interpolada")
		return
	controls.set("move_vector", Vector2.ZERO)
	controls.call("_process", 1.0 / 60.0)
	var releasing := (controls.call("get_move_vector") as Vector2).length()
	if releasing >= rising:
		_fail(9, "soltura do analógico não desacelerou a entrada")
		return

	var camera := scene.get_node_or_null("CameraRig")
	if camera == null or not camera.has_method("get_camera_fluidity_debug_0601"):
		_fail(10, "câmera suavizada não está ativa")
		return

	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("get_streaming_fluidity_debug_0601"):
		_fail(11, "streaming parcelado não está ativo")
		return
	streamer.call("_queue_missing_chunks_0601", Vector2i(80, 80))
	var before := streamer.call("get_streaming_fluidity_debug_0601") as Dictionary
	streamer.call("_load_pending_chunks_0601")
	var after := streamer.call("get_streaming_fluidity_debug_0601") as Dictionary
	if int(before.get("pending_chunks", 0)) - int(after.get("pending_chunks", 0)) != 1:
		_fail(12, "streaming não respeitou o limite de um chunk")
		return
	if int(after.get("generated_last_frame", 0)) > 1:
		_fail(13, "mais de um chunk foi gerado no frame")
		return

	var player := scene.get_node_or_null("Actors/Player")
	if player == null or not player.has_method("get_player_stabilization_debug_0600"):
		_fail(14, "regressão no player estabilizado")
		return
	player.call("unlock_weapon", "pistol")
	player.call("_damage_nearest", 0.0, 0.0)
	var combat := player.call("get_player_stabilization_debug_0600") as Dictionary
	if str(combat.get("last_combat_animation", "")) != "firearm_1h":
		_fail(15, "regressão na animação da pistola")
		return

	scene.call("save_game")
	var save_debug := scene.call("get_save_stabilization_debug_0600") as Dictionary
	if not bool(save_debug.get("last_save_valid", false)) or int(save_debug.get("saved_schema", 0)) != 600:
		_fail(16, "regressão no save compatível")
		return

	print("SMOKE 0.6.1 OK | input=smoothed camera=smoothed chunks=1/frame physics=60Hz save=compatible")
	quit(0)
