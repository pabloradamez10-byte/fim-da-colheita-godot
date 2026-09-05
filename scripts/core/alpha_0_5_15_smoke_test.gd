extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.15 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(38):
		await process_frame

	if get_first_node_in_group("player") == null:
		_fail(2, "player ausente")
		return
	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		_fail(3, "streamer urbano ausente")
		return
	streamer.call("debug_force_city_sample")
	for _i in range(14):
		await process_frame

	var visual := scene.call("get_debug_0515") as Dictionary
	if int(visual.get("macro_ground_patches", 0)) < 8:
		_fail(4, "terreno ainda sem breakup orgânico suficiente")
		return
	if int(visual.get("visual_materials", 0)) < 7:
		_fail(5, "materiais visuais 0.5.15 ausentes")
		return

	var city := streamer.call("get_city_debug_metrics") as Dictionary
	if int(city.get("house_weathering_0515", 0)) < 4:
		_fail(6, "fachadas sem envelhecimento")
		return
	if int(city.get("roof_details_0515", 0)) < 4:
		_fail(7, "telhados sem detalhes")
		return
	if int(city.get("yard_breakup_0515", 0)) < 4:
		_fail(8, "quintais continuam uniformes")
		return
	if int(city.get("environment_story_0515", 0)) < 1:
		_fail(9, "micro-histórias ambientais ausentes")
		return
	if int(city.get("road_cracks_0515", 0)) < 1:
		_fail(10, "asfalto sem desgaste estrutural")
		return

	# Regressões críticas das versões anteriores.
	if get_nodes_in_group("internal_door_0514").size() < 3:
		_fail(11, "portas internas regrediram")
		return
	if get_nodes_in_group("contextual_loot_furniture_0514").size() < 6:
		_fail(12, "loot contextual regrediu")
		return
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(13, "água voltou a ser atravessável")
		return

	print("SMOKE 0.5.15 OK: macro=%d weather=%d roof=%d story=%d cracks=%d" % [
		int(visual.get("macro_ground_patches", 0)),
		int(city.get("house_weathering_0515", 0)),
		int(city.get("roof_details_0515", 0)),
		int(city.get("environment_story_0515", 0)),
		int(city.get("road_cracks_0515", 0))
	])
	quit(0)
