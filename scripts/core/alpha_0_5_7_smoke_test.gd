extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.7 FAIL: main_3d.tscn não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(18):
		await process_frame

	var camera := root.get_camera_3d()
	if camera == null or not camera.current:
		printerr("SMOKE 0.5.7 FAIL: câmera 3D inativa")
		quit(2)
		return
	var player := get_first_node_in_group("player")
	if player == null:
		printerr("SMOKE 0.5.7 FAIL: player ausente")
		quit(3)
		return
	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		printerr("SMOKE 0.5.7 FAIL: city streamer ausente")
		quit(4)
		return

	var metrics := streamer.call("debug_force_city_sample") as Dictionary
	if int(metrics.get("city_buildings", 0)) < 18:
		printerr("SMOKE 0.5.7 FAIL: cidade pouco densa: %s" % str(metrics))
		quit(5)
		return
	if int(metrics.get("road_buildings", -1)) != 0:
		printerr("SMOKE 0.5.7 FAIL: prédio invadiu rua/calçada: %s" % str(metrics))
		quit(6)
		return
	if int(metrics.get("street_grid", 0)) < 50 or int(metrics.get("asphalt", 0)) < 50:
		printerr("SMOKE 0.5.7 FAIL: malha viária descontínua: %s" % str(metrics))
		quit(7)
		return
	if int(metrics.get("sidewalks", 0)) < 70 or int(metrics.get("curbs", 0)) < 45:
		printerr("SMOKE 0.5.7 FAIL: calçadas/guias incompletas: %s" % str(metrics))
		quit(8)
		return
	if int(metrics.get("crosswalks", 0)) < 150:
		printerr("SMOKE 0.5.7 FAIL: cruzamentos sem leitura urbana: %s" % str(metrics))
		quit(9)
		return
	if int(metrics.get("driveways", 0)) < 22:
		printerr("SMOKE 0.5.7 FAIL: lotes sem acesso à rua: %s" % str(metrics))
		quit(10)
		return
	if int(metrics.get("vehicles", 0)) < 12:
		printerr("SMOKE 0.5.7 FAIL: poucos veículos urbanos: %s" % str(metrics))
		quit(11)
		return
	if int(metrics.get("roofs", 0)) < 18 or int(metrics.get("roof_triggers", 0)) < 18:
		printerr("SMOKE 0.5.7 FAIL: telhados/interiores incompletos: %s" % str(metrics))
		quit(12)
		return
	if int(metrics.get("organic_patches", 0)) < 90:
		printerr("SMOKE 0.5.7 FAIL: terreno urbano ainda chapado: %s" % str(metrics))
		quit(13)
		return
	if int(metrics.get("loot", 0)) < 30:
		printerr("SMOKE 0.5.7 FAIL: pouco loot urbano: %s" % str(metrics))
		quit(14)
		return

	var roofs := get_nodes_in_group("building_roof")
	if roofs.is_empty():
		printerr("SMOKE 0.5.7 FAIL: nenhum telhado encontrado")
		quit(15)
		return
	var roof := roofs[0] as Node3D
	if roof == null or not roof.visible:
		printerr("SMOKE 0.5.7 FAIL: telhado não inicia visível")
		quit(16)
		return
	streamer.call("_on_building_body_entered", player, roof)
	if roof.visible:
		printerr("SMOKE 0.5.7 FAIL: telhado não ocultou ao entrar")
		quit(17)
		return
	streamer.call("_on_building_body_exited", player, roof)
	if not roof.visible:
		printerr("SMOKE 0.5.7 FAIL: telhado não voltou ao sair")
		quit(18)
		return

	var inventory_ui := scene.find_child("InventoryUI", true, false)
	if inventory_ui == null or not inventory_ui.has_method("toggle_inventory"):
		printerr("SMOKE 0.5.7 FAIL: inventário regrediu")
		quit(19)
		return
	inventory_ui.call("toggle_inventory")
	for _i in range(2):
		await process_frame
	var texts: Array[String] = []
	_collect_label_texts(inventory_ui, texts)
	for text in texts:
		if "x0" in text:
			printerr("SMOKE 0.5.7 FAIL: item zerado voltou à mochila: %s" % text)
			quit(20)
			return

	print("SMOKE 0.5.7 OK: prédios=%s conflitos=%s ruas=%s calçadas=%s guias=%s veículos=%s telhados=%s loot=%s" % [str(metrics.get("city_buildings", 0)), str(metrics.get("road_buildings", 0)), str(metrics.get("street_grid", 0)), str(metrics.get("sidewalks", 0)), str(metrics.get("curbs", 0)), str(metrics.get("vehicles", 0)), str(metrics.get("roofs", 0)), str(metrics.get("loot", 0))])
	quit(0)

func _collect_label_texts(node: Node, out: Array[String]) -> void:
	if node is Label:
		out.append((node as Label).text)
	for child in node.get_children():
		_collect_label_texts(child, out)
