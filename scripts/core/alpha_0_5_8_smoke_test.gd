extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.8 FAIL: main_3d.tscn não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(18):
		await process_frame

	var camera := root.get_camera_3d()
	if camera == null or not camera.current:
		printerr("SMOKE 0.5.8 FAIL: câmera inativa")
		quit(2)
		return
	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_motion_debug"):
		printerr("SMOKE 0.5.8 FAIL: player fluido não carregou")
		quit(3)
		return
	var motion := player.call("get_motion_debug") as Dictionary
	if not bool(motion.get("articulated", false)):
		printerr("SMOKE 0.5.8 FAIL: personagem não articulado: %s" % str(motion))
		quit(4)
		return
	if str(motion.get("weapon_anchor_parent", "")) != "RightArmPivot":
		printerr("SMOKE 0.5.8 FAIL: arma não acompanha braço direito: %s" % str(motion))
		quit(5)
		return

	player.set("movement_amount", 0.65)
	player.call("_update_character_animation", 0.12, false)
	var left_leg := player.get_node_or_null("CharacterVisual/LeftLegPivot") as Node3D
	var right_leg := player.get_node_or_null("CharacterVisual/RightLegPivot") as Node3D
	if left_leg == null or right_leg == null:
		printerr("SMOKE 0.5.8 FAIL: pivots de caminhada ausentes")
		quit(6)
		return

	var controls := get_first_node_in_group("mobile_controls")
	if controls == null or not controls.has_method("is_attack_held"):
		printerr("SMOKE 0.5.8 FAIL: ataque contínuo mobile ausente")
		quit(7)
		return

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		printerr("SMOKE 0.5.8 FAIL: city streamer ausente")
		quit(8)
		return
	var metrics := streamer.call("debug_force_city_sample") as Dictionary
	if int(metrics.get("road_buildings", -1)) != 0:
		printerr("SMOKE 0.5.8 FAIL: prédio em via: %s" % str(metrics))
		quit(9)
		return
	if int(metrics.get("four_side_sidewalks", 0)) < 30:
		printerr("SMOKE 0.5.8 FAIL: quadras ainda sem calçada em quatro lados: %s" % str(metrics))
		quit(10)
		return
	if int(metrics.get("four_side_curbs", 0)) < 20:
		printerr("SMOKE 0.5.8 FAIL: meio-fio incompleto: %s" % str(metrics))
		quit(11)
		return
	if _open_lot_has_orphan_loot():
		printerr("SMOKE 0.5.8 FAIL: loot/móvel solto voltou a lote aberto")
		quit(12)
		return

	var roofs := get_nodes_in_group("building_roof")
	if roofs.is_empty():
		printerr("SMOKE 0.5.8 FAIL: telhados regrediram")
		quit(13)
		return
	var roof := roofs[0] as Node3D
	streamer.call("_on_building_body_entered", player, roof)
	if roof.visible:
		printerr("SMOKE 0.5.8 FAIL: telhado não oculta ao entrar")
		quit(14)
		return
	streamer.call("_on_building_body_exited", player, roof)
	if not roof.visible:
		printerr("SMOKE 0.5.8 FAIL: telhado não volta ao sair")
		quit(15)
		return

	print("SMOKE 0.5.8 OK: articulado=%s calçadas4=%s curbs4=%s open_lots=%s" % [str(motion.get("articulated", false)), str(metrics.get("four_side_sidewalks", 0)), str(metrics.get("four_side_curbs", 0)), str(metrics.get("open_lots", 0))])
	quit(0)

func _open_lot_has_orphan_loot() -> bool:
	for raw in get_nodes_in_group("open_lot"):
		if raw is Node:
			if _find_named_recursive(raw as Node, "LootContainer"):
				return true
	return false

func _find_named_recursive(node: Node, needle: String) -> bool:
	if node.name == needle:
		return true
	for child in node.get_children():
		if _find_named_recursive(child, needle):
			return true
	return false
