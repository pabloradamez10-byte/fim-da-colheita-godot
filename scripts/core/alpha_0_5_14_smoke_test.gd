extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.14 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(34):
		await process_frame

	var player := get_first_node_in_group("player") as Node
	if player == null:
		_fail(2, "player ausente")
		return
	var streamer := get_first_node_in_group("chunk_streamer")
	if streamer == null or not streamer.has_method("debug_force_city_sample"):
		_fail(3, "streamer urbano ausente")
		return
	streamer.call("debug_force_city_sample")
	for _i in range(12):
		await process_frame

	var internal_doors := get_nodes_in_group("internal_door_0514")
	if internal_doors.size() < 3:
		_fail(4, "portas internas insuficientes: %d" % internal_doors.size())
		return
	if get_nodes_in_group("room_living_0514").is_empty() or get_nodes_in_group("room_kitchen_0514").is_empty():
		_fail(5, "sala/cozinha não identificáveis")
		return
	if get_nodes_in_group("room_bedroom_0514").size() < 2 or get_nodes_in_group("room_bathroom_0514").is_empty():
		_fail(6, "quartos/banheiro não identificáveis")
		return
	if get_nodes_in_group("room_detail_0514").size() < 14:
		_fail(7, "interior ainda pouco detalhado")
		return
	if get_nodes_in_group("contextual_loot_furniture_0514").size() < 6:
		_fail(8, "móveis contextuais insuficientes")
		return

	var debug := scene.call("get_debug_0514") as Dictionary
	var loot_counts := debug.get("contextual_loot", {}) as Dictionary
	if int(loot_counts.get("fridge", 0)) < 1 or int(loot_counts.get("pantry", 0)) < 1:
		_fail(9, "loot de cozinha não foi especializado")
		return
	if int(loot_counts.get("wardrobe", 0)) < 2 or int(loot_counts.get("medicine", 0)) < 1:
		_fail(10, "loot de quarto/banheiro não foi especializado")
		return

	var inventory := player.get("inventory") as Dictionary
	var food_before := int(inventory.get("food", 0))
	var water_before := int(inventory.get("water", 0))
	scene.call("_grant_contextual_loot_0514", "loot_fridge", "smoke:fridge", null, player)
	inventory = player.get("inventory") as Dictionary
	if int(inventory.get("food", 0)) <= food_before or int(inventory.get("water", 0)) <= water_before:
		_fail(11, "geladeira não entregou comida e água")
		return
	var bandage_before := int(inventory.get("bandage", 0))
	scene.call("_grant_contextual_loot_0514", "loot_medicine", "smoke:medicine", null, player)
	inventory = player.get("inventory") as Dictionary
	if int(inventory.get("bandage", 0)) <= bandage_before:
		_fail(12, "armário de remédios não entregou bandagem")
		return

	var first_door := internal_doors[0] as Node3D
	if first_door == null or not first_door.has_method("toggle_interaction"):
		_fail(13, "porta interna não é interativa")
		return
	first_door.call("toggle_interaction")
	await create_timer(0.20).timeout
	var state := first_door.call("get_interaction_state") as Dictionary
	if not bool(state.get("open", false)) or not bool(state.get("collision_disabled", false)):
		_fail(14, "porta interna aberta ainda bloqueia passagem")
		return

	print("SMOKE 0.5.14 OK: internal_doors=%d room_details=%d contextual=%s" % [internal_doors.size(), get_nodes_in_group("room_detail_0514").size(), str(loot_counts)])
	quit(0)
