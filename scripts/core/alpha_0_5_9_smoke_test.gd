extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.9 FAIL: cena principal não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(24):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_motion_debug"):
		printerr("SMOKE 0.5.9 FAIL: player 0.5.9 ausente")
		quit(2)
		return
	var motion := player.call("get_motion_debug") as Dictionary
	if not bool(motion.get("sprite_character", false)) or not bool(motion.get("sprite_ready", false)):
		printerr("SMOKE 0.5.9 FAIL: sprite sheet não decodificou: %s" % str(motion))
		quit(3)
		return
	var sprite := player.get_node_or_null("CharacterVisual2D/SurvivorPixelSprite") as AnimatedSprite3D
	if sprite == null or sprite.sprite_frames == null:
		printerr("SMOKE 0.5.9 FAIL: AnimatedSprite3D ausente")
		quit(4)
		return
	for anim in ["idle_down", "walk_down", "run_down", "attack_down", "walk_left", "walk_right", "walk_up"]:
		if not sprite.sprite_frames.has_animation(anim):
			printerr("SMOKE 0.5.9 FAIL: animação ausente: %s" % anim)
			quit(5)
			return

	player.set("movement_amount", 0.7)
	player.set("last_move_dir", Vector3(1, 0, 1).normalized())
	player.call("_update_character_animation", 0.1, false)
	if not str(sprite.animation).begins_with("walk_"):
		printerr("SMOKE 0.5.9 FAIL: walk direcional não ativou: %s" % sprite.animation)
		quit(6)
		return

	player.call("_physics_process", 0.016)
	if absf(float(player.global_position.y) - 0.20) > 0.03:
		printerr("SMOKE 0.5.9 FAIL: player ainda flutua y=%s" % player.global_position.y)
		quit(7)
		return

	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty():
		printerr("SMOKE 0.5.9 FAIL: sem zumbis")
		quit(8)
		return
	var zombie := zombies[0] as CharacterBody3D
	zombie.call("_physics_process", 0.016)
	if absf(zombie.global_position.y - 0.20) > 0.03:
		printerr("SMOKE 0.5.9 FAIL: zumbi ainda flutua y=%s" % zombie.global_position.y)
		quit(9)
		return

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		printerr("SMOKE 0.5.9 FAIL: streamer urbano ausente")
		quit(10)
		return
	var metrics := streamer.call("debug_force_city_sample") as Dictionary
	if int(metrics.get("road_buildings", -1)) != 0:
		printerr("SMOKE 0.5.9 FAIL: prédio na rua: %s" % str(metrics))
		quit(11)
		return
	if int(metrics.get("garage_door_colliders", 0)) <= 0:
		printerr("SMOKE 0.5.9 FAIL: portas de garagem sem colisão: %s" % str(metrics))
		quit(12)
		return
	if int(metrics.get("four_side_sidewalks", 0)) < 30:
		printerr("SMOKE 0.5.9 FAIL: calçadas regrediram: %s" % str(metrics))
		quit(13)
		return

	print("SMOKE 0.5.9 OK: sprite=%s anim=%s ground=%.2f garage_colliders=%d" % [str(motion.get("sprite_ready")), sprite.animation, player.global_position.y, int(metrics.get("garage_door_colliders", 0))])
	quit(0)
