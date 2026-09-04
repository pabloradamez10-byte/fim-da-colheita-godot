extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.3 FAIL: main_3d.tscn não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(18):
		await process_frame

	var camera := root.get_camera_3d()
	if camera == null or not camera.current:
		printerr("SMOKE 0.5.3 FAIL: câmera 3D não está ativa")
		quit(2)
		return

	var player := get_first_node_in_group("player")
	if player == null:
		printerr("SMOKE 0.5.3 FAIL: player ausente")
		quit(3)
		return
	if not player.has_method("get_inventory_snapshot") or not player.has_method("equip_weapon"):
		printerr("SMOKE 0.5.3 FAIL: API de inventário/equipamento ausente")
		quit(4)
		return

	var inventory_ui := scene.find_child("InventoryUI", true, false)
	if inventory_ui == null or not inventory_ui.has_method("toggle_inventory"):
		printerr("SMOKE 0.5.3 FAIL: InventoryUI ausente")
		quit(5)
		return
	inventory_ui.call("toggle_inventory")
	if not bool(inventory_ui.call("is_inventory_open")):
		printerr("SMOKE 0.5.3 FAIL: inventário não abriu")
		quit(6)
		return
	inventory_ui.call("toggle_inventory")

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_chunk"):
		printerr("SMOKE 0.5.3 FAIL: ChunkStreamer ausente")
		quit(7)
		return
	var before := int(streamer.call("get_loaded_chunk_count"))
	streamer.call("debug_force_chunk", Vector2i(5, 0))
	for _i in range(4):
		await process_frame
	var after := int(streamer.call("get_loaded_chunk_count"))
	if after <= before:
		printerr("SMOKE 0.5.3 FAIL: chunk distante não foi gerado: before=%d after=%d" % [before, after])
		quit(8)
		return
	var far_chunk := streamer.find_child("Chunk_5_0", false, false)
	if far_chunk == null:
		printerr("SMOKE 0.5.3 FAIL: nó Chunk_5_0 não existe")
		quit(9)
		return
	var far_visuals := _count_visuals(far_chunk)
	if far_visuals < 1:
		printerr("SMOKE 0.5.3 FAIL: chunk distante sem terreno/visuais")
		quit(10)
		return

	# Revalida regressões importantes da 0.5.2.
	if not scene.has_method("get_debug_metrics"):
		printerr("SMOKE 0.5.3 FAIL: métricas do runtime ausentes")
		quit(11)
		return
	var metrics: Dictionary = scene.call("get_debug_metrics")
	if int(metrics.get("colliders", 0)) < 80:
		printerr("SMOKE 0.5.3 FAIL: regressão de colisores: %s" % str(metrics.get("colliders", 0)))
		quit(12)
		return
	if not bool(metrics.get("roof", false)) or not bool(metrics.get("interior", false)):
		printerr("SMOKE 0.5.3 FAIL: regressão do interior/telhado")
		quit(13)
		return

	var weapon_anchor := player.find_child("RightHandWeaponAnchor", true, false)
	if weapon_anchor == null or weapon_anchor.get_child_count() < 1:
		printerr("SMOKE 0.5.3 FAIL: arma não está anexada à mão")
		quit(14)
		return

	print("SMOKE 0.5.3 OK: inventário abre, arma ancorada, chunk distante gerado, chunks=%d, far_visuals=%d" % [after, far_visuals])
	quit(0)

func _count_visuals(node: Node) -> int:
	var total := 1 if (node is MeshInstance3D or node is MultiMeshInstance3D) else 0
	for child in node.get_children():
		total += _count_visuals(child)
	return total
