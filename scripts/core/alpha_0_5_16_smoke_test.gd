extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.16 FAIL: %s" % message)
	quit(code)

func _collision_disabled(body: StaticBody3D) -> bool:
	if body == null:
		return false
	if body.collision_layer != 0:
		return false
	for child in body.get_children():
		if child is CollisionShape3D and not (child as CollisionShape3D).disabled:
			return false
	return true

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(38):
		await process_frame

	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		_fail(2, "streamer urbano ausente")
		return
	streamer.call("debug_force_city_sample")
	for _i in range(16):
		await process_frame

	var houses := get_nodes_in_group("large_house_0511")
	if houses.size() < 3:
		_fail(3, "casas residenciais insuficientes para validar: %d" % houses.size())
		return

	var checked := 0
	for raw in houses:
		var house := raw as Node3D
		if house == null:
			continue
		var foundation := house.get_node_or_null("Foundation") as StaticBody3D
		var porch := house.get_node_or_null("FrontPorch") as StaticBody3D
		var step := house.get_node_or_null("PorchStep") as StaticBody3D
		if foundation == null or porch == null or step == null:
			_fail(4, "casa sem superfícies de entrada esperadas")
			return
		if not _collision_disabled(foundation) or not _collision_disabled(porch) or not _collision_disabled(step):
			_fail(5, "fundação/varanda/degrau ainda bloqueiam a entrada")
			return
		var door := house.get_node_or_null("InteractiveFrontDoor0512") as Node3D
		if door == null or not door.has_method("toggle_interaction"):
			_fail(6, "casa sem porta externa funcional")
			return
		checked += 1

	var first_house := houses[0] as Node3D
	var first_door := first_house.get_node_or_null("InteractiveFrontDoor0512") as Node3D
	first_door.call("toggle_interaction")
	await create_timer(0.22).timeout
	var state := first_door.call("get_interaction_state") as Dictionary
	if not bool(state.get("open", false)) or not bool(state.get("collision_disabled", false)):
		_fail(7, "porta abriu visualmente mas ainda bloqueia")
		return

	if not scene.has_method("get_debug_0516"):
		_fail(8, "runtime 0.5.16 não está ativo")
		return
	var debug := scene.call("get_debug_0516") as Dictionary
	if float(debug.get("door_range", 0.0)) < 3.0:
		_fail(9, "alcance de interação da porta não foi ampliado")
		return
	if int(debug.get("registered_doors", 0)) < checked:
		_fail(10, "nem todas as casas têm porta registrada")
		return
	if int(debug.get("walkable_thresholds", 0)) < checked * 3:
		_fail(11, "entradas caminháveis insuficientes")
		return

	# Regressões principais: água, portas internas e loot contextual continuam ativos.
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(12, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(13, "portas internas regrediram")
		return
	if get_nodes_in_group("contextual_loot_furniture_0514").is_empty():
		_fail(14, "loot contextual regrediu")
		return

	print("SMOKE 0.5.16 OK: houses=%d registered_doors=%d thresholds=%d" % [checked, int(debug.get("registered_doors", 0)), int(debug.get("walkable_thresholds", 0))])
	quit(0)
