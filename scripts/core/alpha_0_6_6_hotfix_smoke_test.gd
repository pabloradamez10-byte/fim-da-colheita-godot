extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.6 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.6-alpha":
		_fail(1, "versão incorreta")
		return
	for path in [
		"res://assets/visual_rework_066/fdc_vehicle_atlas_066.png",
		"res://assets/visual_rework_066/fdc_zombie_atlas_066.png"
	]:
		var tex := load(path) as Texture2D
		if tex == null:
			_fail(2, "asset ausente: %s" % path)
			return
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(3, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(50):
		await process_frame
	if not scene.has_method("get_hotfix_debug_066"):
		_fail(4, "runtime 0.6.6 não ativo")
		return
	var debug := scene.call("get_hotfix_debug_066") as Dictionary
	if int(debug.get("zombie_visuals", 0)) < 1:
		_fail(5, "zumbis 0.6.6 não ativos")
		return
	var player := get_first_node_in_group("player") as CharacterBody3D
	if player == null or not player.has_method("get_player_hotfix_debug_066"):
		_fail(6, "player 0.6.6 ausente")
		return
	var pd := player.call("get_player_hotfix_debug_066") as Dictionary
	if float(pd.get("floor_snap", 0.0)) < 0.5:
		_fail(7, "floor snap não ativo")
		return
	if not bool(pd.get("shadow", false)):
		_fail(8, "sombra de contato ausente")
		return
	var zombies: Array = scene.call("get_zombies") as Array
	if zombies.is_empty():
		_fail(9, "sem zumbi para teste de alvo")
		return
	for i in range(zombies.size()):
		if zombies[i] is Node3D:
			(zombies[i] as Node3D).set_physics_process(false)
			(zombies[i] as Node3D).global_position = Vector3(1200.0 + i * 4.0, 0.1, 1200.0)
	player.set_physics_process(false)
	player.global_position = Vector3(900,0.1,900)
	player.rotation.y = 0.0
	var target := zombies[0] as Node3D
	target.global_position = Vector3(900,0.1,904.5)
	await process_frame
	var picked := player.call("_select_target_065", 21.0, 180.0, false) as Node3D
	if picked != target:
		_fail(10, "autoalvo 360 não selecionou inimigo atrás")
		return
	player.call("_face_target_065", target)
	if int(player.get("direction_05405")) == 0:
		_fail(11, "direção visual não atualizou após mirar")
		return
	print("SMOKE 0.6.6 OK | grounded movement visual 360-aim zombie-8dir vehicle-HD")
	quit(0)
