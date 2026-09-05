extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.17 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(36):
		await process_frame

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null:
		_fail(2, "streamer ausente")
		return

	# Cria veículos diretamente para validar atlas, regiões e colliders independentemente da seed.
	for i in range(9):
		streamer.call("_build_vehicle_sprite_0517", streamer, Vector3(float(i) * 5.0, 0.28, 0.0), 0.0 if i % 2 == 0 else PI * 0.5, i, "smoke0517:%d" % i)
	for _i in range(4):
		await process_frame

	var sprites := get_nodes_in_group("vehicle_sprite_0517")
	var colliders := get_nodes_in_group("vehicle_collider_0517")
	if sprites.size() < 9:
		_fail(3, "nem todos os 9 veículos do atlas foram renderizados: %d" % sprites.size())
		return
	if colliders.size() < 9:
		_fail(4, "colliders dos veículos insuficientes: %d" % colliders.size())
		return

	var first := sprites[0] as Sprite3D
	if first == null or first.texture == null:
		_fail(5, "sprite sem textura")
		return
	if first.texture.get_width() != 480 or first.texture.get_height() != 360:
		_fail(6, "atlas importado com dimensão inesperada: %dx%d" % [first.texture.get_width(), first.texture.get_height()])
		return
	if not first.region_enabled or int(first.region_rect.size.x) != 160 or int(first.region_rect.size.y) != 120:
		_fail(7, "recorte do atlas não está ativo")
		return

	# Confirma que a geração urbana usa o override novo.
	if streamer.has_method("debug_force_city_sample"):
		streamer.call("debug_force_city_sample")
		for _i in range(12):
			await process_frame
	var metrics := streamer.call("get_city_debug_metrics") as Dictionary
	if int(metrics.get("vehicle_sprites_0517", 0)) < 9:
		_fail(8, "métrica de veículos novos não foi registrada")
		return

	# Regressões essenciais da 0.5.16.
	if get_nodes_in_group("large_house_0511").is_empty():
		_fail(9, "casas grandes regrediram")
		return
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(10, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(11, "portas internas regrediram")
		return

	print("SMOKE 0.5.17 OK: sprites=%d colliders=%d atlas=%dx%d" % [sprites.size(), colliders.size(), first.texture.get_width(), first.texture.get_height()])
	quit(0)
