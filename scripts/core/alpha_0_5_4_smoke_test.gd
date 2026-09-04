extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.4 FAIL: main_3d.tscn não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(14):
		await process_frame

	var camera := root.get_camera_3d()
	if camera == null or not camera.current:
		printerr("SMOKE 0.5.4 FAIL: câmera 3D inativa")
		quit(2)
		return
	var player := get_first_node_in_group("player")
	if player == null:
		printerr("SMOKE 0.5.4 FAIL: player ausente")
		quit(3)
		return
	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		printerr("SMOKE 0.5.4 FAIL: city streamer ausente")
		quit(4)
		return

	var city_metrics := streamer.call("debug_force_city_sample") as Dictionary
	for _i in range(4):
		await process_frame
	city_metrics = streamer.call("get_city_debug_metrics") as Dictionary
	if int(city_metrics.get("city_buildings", 0)) < 7:
		printerr("SMOKE 0.5.4 FAIL: cidade gerou poucos prédios: %s" % str(city_metrics))
		quit(5)
		return
	if int(city_metrics.get("furniture", 0)) < 12:
		printerr("SMOKE 0.5.4 FAIL: poucos móveis na cidade: %s" % str(city_metrics))
		quit(6)
		return
	if int(city_metrics.get("loot", 0)) < 7:
		printerr("SMOKE 0.5.4 FAIL: poucos pontos de loot: %s" % str(city_metrics))
		quit(7)
		return

	var inventory_ui := scene.find_child("InventoryUI", true, false)
	if inventory_ui == null or not inventory_ui.has_method("toggle_inventory"):
		printerr("SMOKE 0.5.4 FAIL: inventário ausente")
		quit(8)
		return
	inventory_ui.call("toggle_inventory")
	for _i in range(3):
		await process_frame
	var texts: Array[String] = []
	_collect_label_texts(inventory_ui, texts)
	for text in texts:
		if "x0" in text:
			printerr("SMOKE 0.5.4 FAIL: item zerado apareceu na mochila: %s" % text)
			quit(9)
			return
	var saw_craft := false
	for text in texts:
		if text == "CRAFT":
			saw_craft = true
	if not saw_craft:
		printerr("SMOKE 0.5.4 FAIL: seção CRAFT não apareceu")
		quit(10)
		return

	if not player.has_method("craft_recipe") or not player.has_method("can_craft"):
		printerr("SMOKE 0.5.4 FAIL: player sem crafting")
		quit(11)
		return
	player.call("add_item", "wood", 3)
	player.call("add_item", "stone", 2)
	player.call("add_item", "fiber", 1)
	if not bool(player.call("can_craft", "axe")):
		printerr("SMOKE 0.5.4 FAIL: receita da machadinha não ficou disponível")
		quit(12)
		return
	if not bool(player.call("craft_recipe", "axe")):
		printerr("SMOKE 0.5.4 FAIL: não fabricou machadinha")
		quit(13)
		return
	var weapons := player.call("get_owned_weapons") as Array
	if not weapons.has("axe"):
		printerr("SMOKE 0.5.4 FAIL: machadinha não entrou no equipamento")
		quit(14)
		return

	if not scene.has_method("get_debug_metrics"):
		printerr("SMOKE 0.5.4 FAIL: métricas do mundo ausentes")
		quit(15)
		return
	var world_metrics := scene.call("get_debug_metrics") as Dictionary
	if int(world_metrics.get("colliders", 0)) < 80 or not bool(world_metrics.get("interior", false)):
		printerr("SMOKE 0.5.4 FAIL: regressão de colisões/interior: %s" % str(world_metrics))
		quit(16)
		return

	print("SMOKE 0.5.4 OK: cidade=%s móveis=%s loot=%s mochila filtrada + crafting OK" % [str(city_metrics.get("city_buildings",0)), str(city_metrics.get("furniture",0)), str(city_metrics.get("loot",0))])
	quit(0)

func _collect_label_texts(node: Node, out: Array[String]) -> void:
	if node is Label:
		out.append((node as Label).text)
	for child in node.get_children():
		_collect_label_texts(child, out)
