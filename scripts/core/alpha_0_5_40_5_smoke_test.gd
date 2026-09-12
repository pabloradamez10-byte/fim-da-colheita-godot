extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.40.5 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(12):
		await process_frame
	var player := scene.get_node_or_null("Actors/Player")
	if player == null:
		_fail(2, "player não foi criado")
		return
	if not player.has_method("get_player_visual_debug_05405"):
		_fail(3, "debug visual 0.5.40.5 ausente")
		return
	var debug := player.call("get_player_visual_debug_05405") as Dictionary
	if str(debug.get("version", "")) != "0.5.40.5":
		_fail(4, "versão visual incorreta")
		return
	if int(debug.get("directions", 0)) != 8 or int(debug.get("walk_frames", 0)) != 6:
		_fail(5, "atlas direcional/caminhada inválido")
		return
	if int(debug.get("action_frames", 0)) != 5 or not bool(debug.get("sprite", false)):
		_fail(6, "atlas de ação/Sprite3D inválido")
		return
	if not scene.has_method("get_feedback_audio_debug_05404"):
		_fail(7, "Feedback & Audio 0.5.40.4 regrediu")
		return
	var old := scene.call("get_feedback_audio_debug_05404") as Dictionary
	if str(old.get("version", "")) != "0.5.40.4-alpha":
		_fail(8, "runtime anterior não foi preservado")
		return
	print("SMOKE 0.5.40.5 OK | player=8dir walk=6 frames actions=5 frames feedback=preserved")
	quit(0)
