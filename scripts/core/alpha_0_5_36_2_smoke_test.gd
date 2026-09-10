extends SceneTree

const VehicleV05362 = preload("res://scripts/entities/vehicle_3d_v05362.gd")

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.36.2 FAIL: %s" % message)
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
	if streamer == null or not streamer.has_method("get_vehicle_catalog_05362"):
		_fail(2, "streamer 0.5.36.2 não está ativo")
		return
	var catalog := streamer.call("get_vehicle_catalog_05362") as Dictionary
	if int(catalog.get("variant_count", 0)) != 40:
		_fail(3, "catálogo não possui 40 veículos")
		return
	if int(catalog.get("directions", 0)) != 8:
		_fail(4, "catálogo não possui 8 direções")
		return

	var probe := Node3D.new()
	probe.name = "FleetProbe05362"
	root.add_child(probe)
	var names := {}
	for variant in range(40):
		var vehicle: CharacterBody3D = VehicleV05362.new()
		probe.add_child(vehicle)
		vehicle.call("configure_parked_0530", null, "smoke05362:%d" % variant, variant, 0.0, 5362)
		var debug := vehicle.call("get_vehicle_art_debug_05362") as Dictionary
		if int(debug.get("variant", -1)) != variant:
			_fail(10 + variant, "variante %d não foi preservada" % variant)
			return
		if int(debug.get("variant_count", 0)) != 40 or int(debug.get("direction_count", 0)) != 8:
			_fail(60 + variant, "metadados de frota inválidos na variante %d" % variant)
			return
		if int(debug.get("texture_width", 0)) != 512 or int(debug.get("texture_height", 0)) != 1920:
			_fail(110 + variant, "atlas inválido na variante %d: %sx%s" % [variant, debug.get("texture_width", 0), debug.get("texture_height", 0)])
			return
		if int(debug.get("row", -1)) != variant:
			_fail(160 + variant, "linha visual incorreta na variante %d" % variant)
			return
		var vehicle_name := str(debug.get("name", ""))
		if vehicle_name.is_empty() or names.has(vehicle_name):
			_fail(210 + variant, "nome vazio/duplicado na variante %d" % variant)
			return
		names[vehicle_name] = true

	if names.size() != 40:
		_fail(260, "não há 40 identidades visuais distintas")
		return

	var direction_vehicle := probe.get_child(0) as CharacterBody3D
	var directions := {}
	for direction_step in range(8):
		direction_vehicle.rotation.y = float(direction_step) * PI * 0.25
		direction_vehicle.call("_refresh_sprite_orientation_0530")
		var d := int(direction_vehicle.get_meta("vehicle_direction_05362", -1))
		directions[d] = true
	if directions.size() != 8:
		_fail(261, "um veículo não percorreu as 8 vistas reais")
		return

	var normal := probe.get_child(31) as CharacterBody3D
	if not bool(normal.call("is_drivable_0530")):
		_fail(262, "picape 4x4 deveria ser dirigível")
		return
	var before_total := int(normal.call("trunk_total_0530"))
	if not bool(normal.call("trunk_deposit_0530", "water", 1)):
		_fail(263, "porta-malas não aceitou item")
		return
	if int(normal.call("trunk_total_0530")) != before_total + 1:
		_fail(264, "porta-malas não contabilizou depósito")
		return
	if not bool(normal.call("trunk_withdraw_0530", "water", 1)):
		_fail(265, "porta-malas não permitiu retirada")
		return

	var wreck := probe.get_child(8) as CharacterBody3D
	var bicycle := probe.get_child(21) as CharacterBody3D
	if bool(wreck.call("is_drivable_0530")) or bool(bicycle.call("is_drivable_0530")):
		_fail(266, "variantes decorativas ficaram dirigíveis")
		return

	var metrics := streamer.call("get_city_debug_metrics") as Dictionary
	if int(metrics.get("vehicle_variant_count_05362", 0)) != 40 or int(metrics.get("vehicle_direction_count_05362", 0)) != 8:
		_fail(267, "métricas do streamer não registraram frota 40x8")
		return

	print("SMOKE 0.5.36.2 OK: 40 veículos x 8 direções; atlas 512x1920; porta-malas e dirigibilidade preservados")
	quit(0)
