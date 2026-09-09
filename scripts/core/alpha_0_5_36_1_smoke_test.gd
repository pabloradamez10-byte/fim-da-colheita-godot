extends SceneTree

const SAVE_PATH_05361 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.36.1 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_05361):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_05361))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(90):
		await process_frame

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("get_vehicle_catalog_05361"):
		_fail(2, "streamer 0.5.36.1 não está ativo")
		return
	var catalog := streamer.call("get_vehicle_catalog_05361") as Dictionary
	if int(catalog.get("variant_count", 0)) != 27:
		_fail(3, "catálogo não possui 27 variantes")
		return
	if int(catalog.get("directions", 0)) != 8:
		_fail(4, "catálogo não possui 8 direções")
		return
	if int(catalog.get("drivable_variants", 0)) < 25:
		_fail(5, "quantidade de veículos dirigíveis ficou abaixo do esperado")
		return

	var combined: Dictionary = {}
	for raw_variant: Variant in catalog.get("city_variants", []):
		combined[int(raw_variant)] = true
	for raw_variant: Variant in catalog.get("rural_variants", []):
		combined[int(raw_variant)] = true
	if combined.size() < 20:
		_fail(6, "pools procedural urbano+rural não usam variedade suficiente")
		return

	var probe := Node3D.new()
	probe.name = "VehicleArtProbe05361"
	streamer.add_child(probe)
	for variant in range(27):
		var before_count := probe.get_child_count()
		streamer.call(
			"_build_vehicle_sprite_0517",
			probe,
			Vector3(float(variant) * 7.0, 0.28, 700.0),
			0.0,
			variant,
			"smoke05361:variant:%d" % variant
		)
		await process_frame
		if probe.get_child_count() <= before_count:
			_fail(7, "variante %d não foi criada" % variant)
			return
		var vehicle := probe.get_child(probe.get_child_count() - 1) as Node3D
		if vehicle == null or not vehicle.has_method("get_vehicle_art_debug_05361"):
			_fail(8, "variante %d não usa VehicleV05361" % variant)
			return
		var debug := vehicle.call("get_vehicle_art_debug_05361") as Dictionary
		if int(debug.get("variant_count", 0)) != 27 or int(debug.get("direction_count", 0)) != 8:
			_fail(9, "metadados de arte inválidos na variante %d" % variant)
			return
		if str(debug.get("name", "")) == "":
			_fail(10, "variante %d sem nome")
			return
		var sprite := vehicle.get_node_or_null("VehicleSprite0517") as Sprite3D
		if sprite == null or sprite.texture == null:
			_fail(11, "variante %d sem textura")
			return
		var region := sprite.region_rect
		if region.size.x <= 0.0 or region.size.y <= 0.0:
			_fail(12, "recorte vazio na variante %d" % variant)
			return
		if region.position.x < 0.0 or region.position.y < 0.0 or region.end.x > float(sprite.texture.get_width()) + 0.1 or region.end.y > float(sprite.texture.get_height()) + 0.1:
			_fail(13, "recorte fora da textura na variante %d" % variant)
			return

		if variant != 8:
			var seen_directions: Dictionary = {}
			var seen_regions: Dictionary = {}
			for direction_step in range(8):
				vehicle.rotation.y = float(direction_step) * PI * 0.25
				vehicle.call("_refresh_sprite_orientation_0530")
				var dir_debug := vehicle.call("get_vehicle_art_debug_05361") as Dictionary
				seen_directions[int(dir_debug.get("direction", -1))] = true
				seen_regions[str((vehicle.get_node("VehicleSprite0517") as Sprite3D).region_rect)] = true
			if seen_directions.size() != 8:
				_fail(14, "variante %d não percorre as 8 direções" % variant)
				return
			if seen_regions.size() != 8:
				_fail(15, "variante %d não possui 8 recortes visuais distintos" % variant)
				return

		var should_drive := variant not in [8, 21]
		if bool(debug.get("drivable", false)) != should_drive:
			_fail(16, "estado dirigível incorreto na variante %d" % variant)
			return
		vehicle.queue_free()
		await process_frame

	var metrics := streamer.call("get_city_debug_metrics") as Dictionary
	if int(metrics.get("vehicle_variant_count_05361", 0)) != 27 or int(metrics.get("vehicle_direction_count_05361", 0)) != 8:
		_fail(17, "métricas do streamer 0.5.36.1 incorretas")
		return
	if not scene.has_method("get_mission_snapshot_0536"):
		_fail(18, "missões 0.5.36 regrediram")
		return
	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_progression_snapshot_0535"):
		_fail(19, "progressão 0.5.35 regrediu")
		return
	if not scene.has_method("get_vehicle_debug_0530"):
		_fail(20, "sistema funcional de veículos 0.5.30 regrediu")
		return

	print("SMOKE 0.5.36.1 OK: 27 variantes, 25 dirigíveis, 8 direções reais, pools contextualizados e regressões preservadas")
	if FileAccess.file_exists(SAVE_PATH_05361):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_05361))
	quit(0)
