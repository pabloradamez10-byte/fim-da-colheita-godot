extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.4 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.4-alpha":
		_fail(1, "versão do projeto incorreta")
		return

	for path in [
		"res://assets/characters/player/sprite_pack_064/idle_8dir.png",
		"res://assets/characters/player/sprite_pack_064/walk_8dir.png",
		"res://assets/characters/player/sprite_pack_064/run_8dir.png"
	]:
		var texture := load(path) as Texture2D
		if texture == null:
			_fail(2, "asset do protagonista não carregou: %s" % path)
			return
		if texture.get_size() != Vector2(384, 1024):
			_fail(3, "dimensão inválida no asset: %s" % path)
			return

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(4, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(35):
		await process_frame

	if not scene.has_method("get_protagonist_debug_064"):
		_fail(5, "runtime 0.6.4 do protagonista não está ativo")
		return
	var debug := scene.call("get_protagonist_debug_064") as Dictionary
	if str(debug.get("version", "")) != "0.6.4-alpha":
		_fail(6, "versão visual incorreta")
		return
	if not bool(debug.get("sprite", false)):
		_fail(7, "sprite 0.6.4 não foi instalado")
		return
	if int(debug.get("directions", 0)) != 8 or int(debug.get("movement_frames", 0)) != 4:
		_fail(8, "grade de movimento incorreta")
		return
	if not bool(debug.get("run_supported", false)):
		_fail(9, "corrida não está ativa")
		return

	var player := get_first_node_in_group("player") as CharacterBody3D
	if player == null:
		_fail(10, "player não foi criado")
		return
	player.set_physics_process(false)

	player.velocity = Vector3.ZERO
	player.call("_refresh_character_art_05402", 0.20)
	debug = player.call("get_player_visual_debug_064") as Dictionary
	if str(debug.get("state", "")) != "idle":
		_fail(11, "idle não selecionado")
		return

	player.velocity = Vector3(5.0, 0.0, 0.0)
	player.call("_refresh_character_art_05402", 0.20)
	debug = player.call("get_player_visual_debug_064") as Dictionary
	if str(debug.get("state", "")) != "walk":
		_fail(12, "caminhada não selecionada")
		return

	player.velocity = Vector3(7.4, 0.0, 0.0)
	player.call("_refresh_character_art_05402", 0.12)
	debug = player.call("get_player_visual_debug_064") as Dictionary
	if str(debug.get("state", "")) != "run":
		_fail(13, "corrida não selecionada")
		return

	if not player.has_method("play_melee_1h_05405") or not player.has_method("play_firearm_1h_05405"):
		_fail(14, "ações de combate legadas foram quebradas")
		return
	player.call("play_melee_1h_05405")
	player.call("_refresh_character_art_05402", 0.05)
	if str(player.get_meta("player_visual_state_05405", "")) != "action":
		_fail(15, "animação de combate não permanece funcional")
		return

	print("SMOKE 0.6.4 OK | protagonist=8dir idle=4 walk=4 run=4 legacy_actions=preserved")
	quit(0)
