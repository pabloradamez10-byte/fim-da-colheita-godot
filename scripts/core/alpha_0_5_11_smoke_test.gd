extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.11 FAIL: cena principal não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(28):
		await process_frame

	var player := get_first_node_in_group("player") as Node3D
	if player == null:
		printerr("SMOKE 0.5.11 FAIL: player ausente")
		quit(2)
		return
	var sprite := player.get_node_or_null("CharacterVisual2D/SurvivorPixelSprite") as AnimatedSprite3D
	if sprite == null or sprite.pixel_size < 0.049:
		printerr("SMOKE 0.5.11 FAIL: personagem 0.5.10 regrediu")
		quit(3)
		return

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		printerr("SMOKE 0.5.11 FAIL: streamer urbano ausente")
		quit(4)
		return
	var metrics := streamer.call("debug_force_city_sample") as Dictionary
	if int(metrics.get("road_buildings", -1)) != 0:
		printerr("SMOKE 0.5.11 FAIL: prédio invadiu via: %s" % str(metrics))
		quit(5)
		return
	if int(metrics.get("residential_houses_0511", 0)) < 12:
		printerr("SMOKE 0.5.11 FAIL: densidade residencial insuficiente: %s" % str(metrics))
		quit(6)
		return
	if int(metrics.get("large_houses_0511", 0)) != int(metrics.get("residential_houses_0511", 0)):
		printerr("SMOKE 0.5.11 FAIL: casas grandes inconsistentes: %s" % str(metrics))
		quit(7)
		return
	if int(metrics.get("room_partitions_0511", 0)) < 45:
		printerr("SMOKE 0.5.11 FAIL: casas sem cômodos suficientes: %s" % str(metrics))
		quit(8)
		return
	if int(metrics.get("room_furniture_0511", 0)) < 100:
		printerr("SMOKE 0.5.11 FAIL: interiores pouco mobiliados: %s" % str(metrics))
		quit(9)
		return
	if int(metrics.get("roof_cutaway_0511", 0)) < 12:
		printerr("SMOKE 0.5.11 FAIL: telhados/cutaway ausentes: %s" % str(metrics))
		quit(10)
		return
	if int(metrics.get("block_sidewalks_0511", 0)) < 15:
		printerr("SMOKE 0.5.11 FAIL: perímetros de quadra incompletos: %s" % str(metrics))
		quit(11)
		return

	var houses := get_nodes_in_group("residential_house_0511")
	if houses.is_empty():
		printerr("SMOKE 0.5.11 FAIL: nenhuma casa residencial encontrada")
		quit(12)
		return
	var house := houses[0] as Node3D
	var roof := house.get_node_or_null("Roof") as Node3D
	if roof == null:
		printerr("SMOKE 0.5.11 FAIL: casa sem Roof")
		quit(13)
		return
	player.global_position = house.global_position + Vector3(0, 0.20, 0)
	for _i in range(3):
		await process_frame
	if roof.visible:
		printerr("SMOKE 0.5.11 FAIL: telhado não ocultou ao entrar")
		quit(14)
		return
	player.global_position = house.global_position + Vector3(20, 0.20, 20)
	for _i in range(3):
		await process_frame
	if not roof.visible:
		printerr("SMOKE 0.5.11 FAIL: telhado não voltou ao sair")
		quit(15)
		return

	print("SMOKE 0.5.11 OK: houses=%d rooms=%d furniture=%d roofs=%d sidewalks=%d" % [int(metrics.get("residential_houses_0511")), int(metrics.get("room_partitions_0511")), int(metrics.get("room_furniture_0511")), int(metrics.get("roof_cutaway_0511")), int(metrics.get("block_sidewalks_0511"))])
	quit(0)
