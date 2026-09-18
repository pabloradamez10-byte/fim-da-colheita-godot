extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.7 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.7-alpha":
		_fail(1, "versão do projeto incorreta")
		return

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(2, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(80):
		await process_frame

	if not scene.has_method("get_performance_debug_067"):
		_fail(3, "runtime performance 0.6.7 não está ativo")
		return
	if not scene.has_method("get_quality_debug_066"):
		_fail(4, "correções 0.6.6 foram perdidas")
		return

	var player := get_first_node_in_group("player") as CharacterBody3D
	if player == null or not bool(player.get_meta("grounding_066", false)):
		_fail(5, "grounding 0.6.6 regrediu")
		return
	if not player.has_method("_select_firearm_target_066"):
		_fail(6, "tiro 360 0.6.6 regrediu")
		return

	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("get_streaming_performance_debug_067"):
		_fail(7, "streamer 0.6.7 não está ativo")
		return
	var sdebug := streamer.call("get_streaming_performance_debug_067") as Dictionary
	if int(sdebug.get("load_radius", -1)) != 1 or int(sdebug.get("unload_radius", -1)) != 2:
		_fail(8, "raios mobile de streaming incorretos")
		return
	if bool(sdebug.get("terrain_shadows", true)):
		_fail(9, "sombras do terreno ainda estão ativas")
		return
	if int(sdebug.get("max_primary_chunks", 99)) != 9:
		_fail(10, "orçamento principal de chunks deveria ser 9")
		return

	var zombies: Array = scene.call("get_zombies") as Array
	if zombies.size() < 3:
		_fail(11, "zumbis insuficientes para validar tiers")
		return
	for raw in zombies:
		if raw is Node3D:
			(raw as Node3D).global_position = Vector3(1100.0, 0.20, 1100.0)
	player.global_position = Vector3(900.0, 0.20, 900.0)
	var near_z := zombies[0] as Node3D
	var mid_z := zombies[1] as Node3D
	var far_z := zombies[2] as Node3D
	near_z.global_position = player.global_position + Vector3(10.0, 0.0, 0.0)
	mid_z.global_position = player.global_position + Vector3(25.0, 0.0, 0.0)
	far_z.global_position = player.global_position + Vector3(52.0, 0.0, 0.0)
	for _i in range(18):
		await physics_frame

	for z in [near_z, mid_z, far_z]:
		if not z.has_method("get_performance_tier_067"):
			_fail(12, "zumbi sem scheduler 0.6.7")
			return
	if str(near_z.call("get_performance_tier_067")) != "full":
		_fail(13, "zumbi próximo não está em IA completa")
		return
	if str(mid_z.call("get_performance_tier_067")) != "reduced":
		_fail(14, "zumbi médio não está em IA reduzida")
		return
	if str(far_z.call("get_performance_tier_067")) != "sleep":
		_fail(15, "zumbi distante não entrou em sleep")
		return

	var perf := scene.call("get_performance_debug_067") as Dictionary
	if str(perf.get("version", "")) != "0.6.7-alpha":
		_fail(16, "debug de performance incorreto")
		return
	if float(perf.get("autosave_seconds", 0.0)) < 40.0:
		_fail(17, "autosave ainda agressivo demais")
		return

	print("SMOKE 0.6.7 OK | chunks=9 radius=1 terrain_shadow=off zombie_lod=full/reduced/sleep autosave=45s quality066=preserved")
	quit(0)
