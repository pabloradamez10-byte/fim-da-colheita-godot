extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.12 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(30):
		await process_frame

	var player := get_first_node_in_group("player") as Node3D
	var streamer := get_first_node_in_group("chunk_streamer")
	if player == null or streamer == null:
		_fail(2, "player/streamer ausente")
		return
	var metrics := streamer.call("debug_force_city_sample") as Dictionary
	for _i in range(5):
		await process_frame
	metrics = streamer.call("get_city_debug_metrics") as Dictionary
	if int(metrics.get("road_buildings", -1)) != 0:
		_fail(3, "prédio invadiu via: %s" % str(metrics))
		return
	if int(metrics.get("interactive_doors_0512", 0)) < 10:
		_fail(4, "portas interativas insuficientes: %s" % str(metrics))
		return
	if int(metrics.get("interactive_windows_0512", 0)) < 20:
		_fail(5, "janelas interativas insuficientes: %s" % str(metrics))
		return
	if int(metrics.get("contextual_loot_0512", 0)) < 35:
		_fail(6, "loot contextual insuficiente: %s" % str(metrics))
		return

	var doors := get_nodes_in_group("interactive_door_0512")
	var windows := get_nodes_in_group("interactive_window_0512")
	if doors.is_empty() or windows.is_empty():
		_fail(7, "grupos de porta/janela ausentes")
		return
	var door := doors[0] as Node3D
	var window := windows[0] as Node3D
	door.call("toggle_interaction")
	window.call("toggle_interaction")
	for _i in range(18):
		await process_frame
	if not bool(door.get("is_open")) or not bool(window.get("is_open")):
		_fail(8, "porta ou janela não abriu")
		return

	var room_items := get_nodes_in_group("contextual_loot_furniture_0512")
	if room_items.is_empty():
		_fail(9, "mobília vasculhável ausente")
		return
	var loot_node := room_items[0] as Node3D
	player.global_position = loot_node.global_position + Vector3(0.4, 0.20, 0.4)
	var before := scene.call("get_interaction_debug_0512") as Dictionary
	var interacted := bool(scene.call("try_interact_near", player.global_position, player))
	var after := scene.call("get_interaction_debug_0512") as Dictionary
	if not interacted or int(after.get("room_loot", 0)) >= int(before.get("room_loot", 0)):
		_fail(10, "vasculhar cômodo não consumiu o ponto de loot: before=%s after=%s" % [str(before), str(after)])
		return

	print("SMOKE 0.5.12 OK: doors=%d windows=%d contextual=%d roomloot_after=%d" % [int(metrics.get("interactive_doors_0512")), int(metrics.get("interactive_windows_0512")), int(metrics.get("contextual_loot_0512")), int(after.get("room_loot", 0))])
	quit(0)
