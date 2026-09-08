extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.19 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(42):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null:
		_fail(2, "player 0.5.19 ausente")
		return
	if not player.has_method("get_survival_debug_0519"):
		_fail(3, "player não usa camada de sobrevivência 0.5.19")
		return
	if not scene.has_method("emit_noise_0519") or not scene.has_method("get_loudest_noise_for_0519"):
		_fail(4, "barramento de ruído 0.5.19 ausente")
		return

	var zombies := get_nodes_in_group("zombies")
	if zombies.is_empty():
		_fail(5, "nenhum zumbi disponível")
		return
	var zombie := zombies[0] as Node3D
	if zombie == null or not zombie.has_method("get_ai_debug_0519"):
		_fail(6, "zumbi não usa IA sensorial 0.5.19")
		return

	# Audição: um ruído forte perto do zumbi deve tirá-lo do estado idle.
	zombie.global_position = player.global_position + Vector3(11.0, 0.0, 0.0)
	scene.call("emit_noise_0519", player.global_position, 24.0, "smoke_noise", player)
	for _i in range(16):
		await process_frame
	var ai := zombie.call("get_ai_debug_0519") as Dictionary
	if str(ai.get("state", "idle")) == "idle":
		_fail(7, "zumbi não reagiu ao ruído")
		return
	if str(ai.get("last_heard", "")) != "smoke_noise" and not bool(ai.get("can_see_player", false)):
		_fail(8, "zumbi não registrou ruído nem visão")
		return

	# Ferimento: dano deve gerar dor/sangramento e consumir fôlego.
	var vitals_before := player.call("get_vitals") as Dictionary
	player.call("take_damage", 12.0)
	var condition := player.call("get_survival_debug_0519") as Dictionary
	if float(condition.get("pain", 0.0)) <= 0.0:
		_fail(9, "dano não gerou dor")
		return
	if float(condition.get("bleeding", 0.0)) <= 0.0:
		_fail(10, "dano não gerou sangramento")
		return
	if float(condition.get("stamina", 100.0)) >= float(vitals_before.get("stamina", 100.0)):
		_fail(11, "dano não afetou fôlego")
		return

	# Combate/ruído: ataque corpo a corpo bem sucedido precisa produzir evento audível.
	zombie.global_position = player.global_position + Vector3(1.7, 0.0, 0.0)
	player.set("attack_cooldown", 0.0)
	player.call("_attack")
	for _i in range(3):
		await process_frame
	var noise_debug := scene.call("get_noise_debug_0519") as Dictionary
	if int(noise_debug.get("count", 0)) <= 0:
		_fail(12, "combate não gerou eventos de ruído")
		return
	var survival := player.call("get_survival_debug_0519") as Dictionary
	if str(survival.get("last_noise", "")) == "":
		_fail(13, "player não registrou o ruído do ataque")
		return

	# Regressões críticas das versões anteriores.
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(14, "bloqueio de água regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(15, "portas internas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(16, "veículos novos regrediram")
		return

	print("SMOKE 0.5.19 OK: state=%s pain=%.1f bleeding=%.2f noises=%d" % [str(ai.get("state", "?")), float(condition.get("pain", 0.0)), float(condition.get("bleeding", 0.0)), int(noise_debug.get("count", 0))])
	quit(0)
