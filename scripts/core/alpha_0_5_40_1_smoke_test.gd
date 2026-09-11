extends SceneTree

const SAVE_PATH := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.40.1 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(150):
		await process_frame

	if not scene.has_method("get_decision_engine_debug_0540"):
		_fail(2, "Atlas Decision Engine 0.5.40 regrediu")
		return
	var engine := scene.call("get_decision_engine_debug_0540") as Dictionary
	if int((engine.get("engine", {}) as Dictionary).get("action_count", 0)) != 7:
		_fail(3, "motor de decisão não mantém sete ações")
		return

	var hud := scene.get_node_or_null("HUD")
	if hud == null or not hud.has_method("get_hud_rework_debug_05401"):
		_fail(4, "HUD rework 0.5.40.1 ausente")
		return
	var hud_debug := hud.call("get_hud_rework_debug_05401") as Dictionary
	if int(hud_debug.get("stat_cards", 0)) != 5:
		_fail(5, "HUD não possui cinco cartões de status")
		return
	if not bool(hud_debug.get("top_shell", false)) or not bool(hud_debug.get("info_strip", false)):
		_fail(6, "barra superior ou faixa de informação não foi criada")
		return
	if not bool(hud_debug.get("legacy_hidden", false)):
		_fail(7, "HUD legado permaneceu visível")
		return
	if get_nodes_in_group("hud_rework_05401").size() != 1 or get_nodes_in_group("hud_stat_card_05401").size() != 5:
		_fail(8, "grupos de diagnóstico do HUD estão inconsistentes")
		return

	var mobile := scene.get_node_or_null("MobileLayer/MobileControls")
	if mobile == null or not mobile.has_method("get_mobile_rework_debug_05401"):
		_fail(9, "controles mobile rework ausentes")
		return
	var mobile_debug := mobile.call("get_mobile_rework_debug_05401") as Dictionary
	if str(mobile_debug.get("interact_text", "")) != "AÇÃO":
		_fail(10, "botão contextual não usa apresentação compacta")
		return
	if float(mobile_debug.get("joystick_radius", 0.0)) < 70.0:
		_fail(11, "joystick ficou pequeno demais para toque")
		return
	if get_nodes_in_group("mobile_rework_05401").size() != 1:
		_fail(12, "controles mobile não registraram o rework")
		return

	var hotbar: Node = get_first_node_in_group("hotbar_rework_05401")
	if hotbar == null or not hotbar.has_method("get_hotbar_rework_debug_05401"):
		_fail(13, "hotbar rework ausente")
		return
	var hotbar_debug := hotbar.call("get_hotbar_rework_debug_05401") as Dictionary
	if int(hotbar_debug.get("slots", 0)) != 6 or not bool(hotbar_debug.get("panel", false)):
		_fail(14, "hotbar perdeu os seis slots")
		return

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("take_damage"):
		_fail(15, "jogador não disponível para teste do alerta")
		return
	player.call("take_damage", 72.0)
	for _i in range(8):
		await process_frame
	var alert := scene.get_node_or_null("HUD/HUDRework05401/AlertPanel05401") as Control
	if alert == null or not alert.visible:
		_fail(16, "alerta contextual de vida crítica não apareceu")
		return

	if not scene.has_method("get_visual_rework_debug_05401"):
		_fail(17, "runtime 0.5.40.1 ausente")
		return
	var visual_debug := scene.call("get_visual_rework_debug_05401") as Dictionary
	if int(visual_debug.get("animal_species", 0)) != 4 or int(visual_debug.get("vehicle_variants", 0)) != 40:
		_fail(18, "catálogos de fauna/frota regrediram")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_fail(19, "save 0.5.40.1 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(20, "save 0.5.40.1 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.40.1-alpha":
		_fail(21, "versionamento do save não é 0.5.40.1-alpha")
		return
	var world_state := payload.get("world", {}) as Dictionary
	if not bool(world_state.get("visual_rework_05401", false)):
		_fail(22, "marcador 0.5.40.1 não foi persistido")
		return

	print("SMOKE 0.5.40.1 OK | hud=compact stats=5 alerts=true mobile=polished hotbar=6 decision_engine=preserved save=true")
	quit(0)
