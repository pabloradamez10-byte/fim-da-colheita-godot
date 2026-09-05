extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.13 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(32):
		await process_frame

	var player := get_first_node_in_group("player") as Node3D
	if player == null:
		_fail(2, "player ausente")
		return
	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		_fail(3, "streamer urbano ausente")
		return
	streamer.call("debug_force_city_sample")
	for _i in range(8):
		await process_frame

	# 1) Porta deve vencer uma janela mais próxima dentro de seus respectivos alcances.
	var fake_door := Node3D.new()
	fake_door.position = player.global_position + Vector3(1.75, 0, 0)
	scene.add_child(fake_door)
	var fake_window := Node3D.new()
	fake_window.position = player.global_position + Vector3(0.85, 0, 0)
	scene.add_child(fake_window)
	scene.call("register_streamed_interaction", fake_window.global_position, "window", "smoke0513:window", fake_window, false)
	scene.call("register_streamed_interaction", fake_door.global_position, "door", "smoke0513:door", fake_door, false)
	player.set("last_move_dir", Vector3(1, 0, 0))
	var picked := int(scene.call("_pick_special_interactable_0513", player.global_position, player))
	var interactions := scene.get("interactables") as Array
	if picked < 0 or str((interactions[picked] as Dictionary).get("type", "")) != "door":
		_fail(4, "prioridade PORTA > LOOT > JANELA não foi respeitada")
		return

	# 2) Door collider precisa ser estreito e liberar/rearmar sem prender o player.
	var doors := get_nodes_in_group("interactive_door_0512")
	if doors.is_empty():
		_fail(5, "nenhuma porta interativa")
		return
	var door := doors[0] as Node3D
	var collision := door.get_node_or_null("Panel/CollisionShape3D") as CollisionShape3D
	if collision == null or not (collision.shape is BoxShape3D):
		_fail(6, "collider da porta ausente")
		return
	var shape := collision.shape as BoxShape3D
	if shape.size.x > 0.86 or shape.size.z > 0.10:
		_fail(7, "collider da porta ainda largo: %s" % str(shape.size))
		return
	door.call("toggle_interaction")
	await create_timer(0.24).timeout
	if not bool((door.call("get_interaction_state") as Dictionary).get("collision_disabled", false)):
		_fail(8, "porta aberta ainda bloqueia passagem")
		return
	player.global_position = door.global_position + Vector3(4.0, 0.2, 4.0)
	door.call("toggle_interaction")
	await create_timer(0.30).timeout
	if bool((door.call("get_interaction_state") as Dictionary).get("collision_disabled", true)):
		_fail(9, "porta fechada não rearmou collider")
		return

	# 3) Água deve possuir bloqueio físico e save antigo dentro d'água deve ser recuperado.
	var water_blockers := get_nodes_in_group("water_blocker_0513")
	if water_blockers.is_empty():
		_fail(10, "nenhum bloqueador de água foi criado")
		return
	var water_pos := Vector3.ZERO
	var found_water := false
	for gz in range(-17, 18):
		for gx in range(-17, 18):
			var candidate := Vector3(float(gx) * 4.0, 0.2, float(gz) * 4.0)
			if bool(scene.call("is_water_at_0513", candidate)):
				water_pos = candidate
				found_water = true
				break
		if found_water:
			break
	if not found_water:
		_fail(11, "seed de teste não encontrou água")
		return
	player.global_position = water_pos
	scene.call("_recover_player_from_water_0513")
	if bool(scene.call("is_water_at_0513", player.global_position)):
		_fail(12, "recuperação de save ainda deixou player na água")
		return

	print("SMOKE 0.5.13 OK: prioridade=door collider=%s water_blockers=%d recovered=%s" % [str(shape.size), water_blockers.size(), str(player.global_position)])
	quit(0)
