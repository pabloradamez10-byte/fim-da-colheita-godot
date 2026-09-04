extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.5 FAIL: main_3d.tscn não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(14):
		await process_frame

	var camera := root.get_camera_3d()
	if camera == null or not camera.current:
		printerr("SMOKE 0.5.5 FAIL: câmera 3D inativa")
		quit(2)
		return
	var player := get_first_node_in_group("player")
	if player == null:
		printerr("SMOKE 0.5.5 FAIL: player ausente")
		quit(3)
		return
	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		printerr("SMOKE 0.5.5 FAIL: city streamer ausente")
		quit(4)
		return

	var metrics := streamer.call("debug_force_city_sample") as Dictionary
	if int(metrics.get("city_buildings", 0)) < 9:
		printerr("SMOKE 0.5.5 FAIL: cidade incompleta: %s" % str(metrics))
		quit(5)
		return
	if int(metrics.get("asphalt", 0)) < 5:
		printerr("SMOKE 0.5.5 FAIL: asfalto urbano ausente: %s" % str(metrics))
		quit(6)
		return
	if int(metrics.get("vehicles", 0)) < 4:
		printerr("SMOKE 0.5.5 FAIL: poucos veículos: %s" % str(metrics))
		quit(7)
		return
	if int(metrics.get("roofs", 0)) < 9 or int(metrics.get("roof_triggers", 0)) < 9:
		printerr("SMOKE 0.5.5 FAIL: telhados/triggers incompletos: %s" % str(metrics))
		quit(8)
		return
	if int(metrics.get("loot", 0)) < 16:
		printerr("SMOKE 0.5.5 FAIL: pouco loot visível: %s" % str(metrics))
		quit(9)
		return
	if int(metrics.get("furniture", 0)) < 24:
		printerr("SMOKE 0.5.5 FAIL: interiores pouco mobiliados: %s" % str(metrics))
		quit(10)
		return

	var roofs := get_nodes_in_group("building_roof")
	if roofs.is_empty():
		printerr("SMOKE 0.5.5 FAIL: nenhum telhado encontrado")
		quit(11)
		return
	var roof := roofs[0] as Node3D
	if roof == null or not roof.visible:
		printerr("SMOKE 0.5.5 FAIL: telhado não inicia visível")
		quit(12)
		return
	streamer.call("_on_building_body_entered", player, roof)
	if roof.visible:
		printerr("SMOKE 0.5.5 FAIL: telhado não ocultou ao entrar")
		quit(13)
		return
	streamer.call("_on_building_body_exited", player, roof)
	if not roof.visible:
		printerr("SMOKE 0.5.5 FAIL: telhado não voltou ao sair")
		quit(14)
		return

	var inventory_ui := scene.find_child("InventoryUI", true, false)
	if inventory_ui == null or not inventory_ui.has_method("toggle_inventory"):
		printerr("SMOKE 0.5.5 FAIL: inventário regrediu")
		quit(15)
		return
	inventory_ui.call("toggle_inventory")
	for _i in range(2):
		await process_frame
	var texts: Array[String] = []
	_collect_label_texts(inventory_ui, texts)
	for text in texts:
		if "x0" in text:
			printerr("SMOKE 0.5.5 FAIL: item zerado voltou à mochila: %s" % text)
			quit(16)
			return

	print("SMOKE 0.5.5 OK: prédios=%s asfalto=%s veículos=%s telhados=%s loot=%s móveis=%s" % [str(metrics.get("city_buildings", 0)), str(metrics.get("asphalt", 0)), str(metrics.get("vehicles", 0)), str(metrics.get("roofs", 0)), str(metrics.get("loot", 0)), str(metrics.get("furniture", 0))])
	quit(0)

func _collect_label_texts(node: Node, out: Array[String]) -> void:
	if node is Label:
		out.append((node as Label).text)
	for child in node.get_children():
		_collect_label_texts(child, out)
