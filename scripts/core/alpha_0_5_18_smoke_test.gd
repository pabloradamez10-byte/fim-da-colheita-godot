extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.18 FAIL: %s" % message)
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

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("_vehicle_flip_h_0518"):
		_fail(2, "correção de orientação 0.5.18 ausente")
		return

	# A regra corrigida é o inverso da 0.5.17: eixo Z espelha; eixo X mantém o atlas original.
	var flip_z := bool(streamer.call("_vehicle_flip_h_0518", 0.0))
	var flip_x := bool(streamer.call("_vehicle_flip_h_0518", PI * 0.5))
	if not flip_z:
		_fail(3, "veículo no eixo Z não foi espelhado")
		return
	if flip_x:
		_fail(4, "veículo no eixo X continua invertido")
		return

	var probe := Node3D.new()
	probe.name = "OrientationProbe0518"
	streamer.add_child(probe)
	streamer.call("_build_vehicle_sprite_0517", probe, Vector3.ZERO, 0.0, 3, "orientation0518:z")
	streamer.call("_build_vehicle_sprite_0517", probe, Vector3(6.0, 0.0, 0.0), PI * 0.5, 3, "orientation0518:x")
	await process_frame

	if probe.get_child_count() < 2:
		_fail(5, "veículos de prova não foram criados")
		return
	var root_z := probe.get_child(0) as Node3D
	var root_x := probe.get_child(1) as Node3D
	var sprite_z := root_z.get_node_or_null("VehicleSprite0517") as Sprite3D
	var sprite_x := root_x.get_node_or_null("VehicleSprite0517") as Sprite3D
	if sprite_z == null or sprite_x == null:
		_fail(6, "sprites de prova ausentes")
		return
	if not sprite_z.flip_h or sprite_x.flip_h:
		_fail(7, "flip visual não corresponde à orientação corrigida")
		return
	if root_z.get_node_or_null("VehicleCollider0517") == null or root_x.get_node_or_null("VehicleCollider0517") == null:
		_fail(8, "colisão dos veículos regrediu")
		return

	var metrics := streamer.call("get_city_debug_metrics") as Dictionary
	if int(metrics.get("vehicle_orientation_0518", 0)) < 2:
		_fail(9, "métrica da correção de orientação não foi registrada")
		return

	print("SMOKE 0.5.18 OK: yaw0_flip=%s yaw90_flip=%s" % [str(sprite_z.flip_h), str(sprite_x.flip_h)])
	quit(0)
