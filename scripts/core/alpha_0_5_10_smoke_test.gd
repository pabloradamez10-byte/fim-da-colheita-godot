extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.10 FAIL: cena principal não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(24):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_motion_debug"):
		printerr("SMOKE 0.5.10 FAIL: player ausente")
		quit(2)
		return
	var sprite := player.get_node_or_null("CharacterVisual2D/SurvivorPixelSprite") as AnimatedSprite3D
	if sprite == null:
		printerr("SMOKE 0.5.10 FAIL: survivor sprite ausente")
		quit(3)
		return
	if sprite.pixel_size < 0.049:
		printerr("SMOKE 0.5.10 FAIL: survivor ainda pequeno: %s" % sprite.pixel_size)
		quit(4)
		return

	player.set("movement_amount", 0.7)
	player.set("last_move_dir", Vector3(1, 0, -1).normalized())
	player.call("_update_character_animation", 0.1, false)
	var right_motion := player.call("get_motion_debug") as Dictionary
	if str(right_motion.get("sprite_direction", "")) != "right" or not bool(right_motion.get("sprite_flip_h", false)):
		printerr("SMOKE 0.5.10 FAIL: direita não está espelhada corretamente: %s" % str(right_motion))
		quit(5)
		return

	player.set("last_move_dir", Vector3(-1, 0, 1).normalized())
	player.call("_update_character_animation", 0.1, false)
	var left_motion := player.call("get_motion_debug") as Dictionary
	if str(left_motion.get("sprite_direction", "")) != "left" or bool(left_motion.get("sprite_flip_h", true)):
		printerr("SMOKE 0.5.10 FAIL: esquerda ficou invertida: %s" % str(left_motion))
		quit(6)
		return

	player.call("_physics_process", 0.016)
	if absf(float(player.global_position.y) - 0.20) > 0.03:
		printerr("SMOKE 0.5.10 FAIL: grounding regrediu: %s" % player.global_position.y)
		quit(7)
		return

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		printerr("SMOKE 0.5.10 FAIL: city streamer ausente")
		quit(8)
		return
	var metrics := streamer.call("debug_force_city_sample") as Dictionary
	if int(metrics.get("garage_door_colliders", 0)) <= 0:
		printerr("SMOKE 0.5.10 FAIL: colisão de garagem regrediu: %s" % str(metrics))
		quit(9)
		return

	print("SMOKE 0.5.10 OK: pixel_size=%.3f right_flip=%s left_flip=%s garage_colliders=%d" % [sprite.pixel_size, str(right_motion.get("sprite_flip_h")), str(left_motion.get("sprite_flip_h")), int(metrics.get("garage_door_colliders", 0))])
	quit(0)
