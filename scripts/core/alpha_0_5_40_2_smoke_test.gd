extends SceneTree

const SAVE_PATH := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.40.2 FAIL: %s" % message)
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
	for _i in range(170):
		await process_frame

	if not scene.has_method("get_asset_rework_debug_05402"):
		_fail(2, "runtime Asset Rework 0.5.40.2 ausente")
		return
	var dbg := scene.call("get_asset_rework_debug_05402") as Dictionary
	if str(dbg.get("version", "")) != "0.5.40.2-alpha" or not bool(dbg.get("high_detail", false)):
		_fail(3, "versão/debug do Asset Rework inválido")
		return

	var player_dbg := dbg.get("player", {}) as Dictionary
	if not bool(player_dbg.get("sprite", false)) or int(player_dbg.get("directions", 0)) != 4:
		_fail(4, "jogador não recebeu sprite detalhado em quatro direções")
		return
	if not bool(player_dbg.get("procedural_body_hidden", false)):
		_fail(5, "corpo procedural antigo do jogador continua visível")
		return
	if get_nodes_in_group("player_high_detail_05402").size() != 1:
		_fail(6, "grupo visual do jogador 0.5.40.2 inválido")
		return

	var zombies := get_nodes_in_group("zombie_high_detail_05402")
	if zombies.size() < 10:
		_fail(7, "zumbis não receberam o novo atlas")
		return
	if int(dbg.get("zombie_profiles", 0)) != 5 or int(dbg.get("zombie_frames", 0)) != 8:
		_fail(8, "perfis/frames dos Zumbis 2.0 regrediram")
		return
	if str(dbg.get("zombie_tile", "")) != "96x128":
		_fail(9, "resolução do novo sprite de zumbi não corresponde ao pacote")
		return
	var zombie_parent := zombies[0]
	if not zombie_parent.has_method("get_asset_rework_debug_05402"):
		_fail(10, "script visual 0.5.40.2 do zumbi ausente")
		return
	var zdbg := zombie_parent.call("get_asset_rework_debug_05402") as Dictionary
	if int(zdbg.get("tile_width", 0)) != 96 or int(zdbg.get("tile_height", 0)) != 128:
		_fail(11, "atlas de zumbis não está em 96x128")
		return
	if int(zdbg.get("profiles", 0)) != 5 or int(zdbg.get("animation_frames", 0)) != 8:
		_fail(12, "semântica 5 perfis x 8 frames foi perdida")
		return

	var item_dbg := dbg.get("items", {}) as Dictionary
	if int(item_dbg.get("registered_items", 0)) != 16 or int(item_dbg.get("slots", 0)) != 6:
		_fail(13, "atlas de itens/hotbar 0.5.40.2 não foi integrado")
		return
	if str(item_dbg.get("tile", "")) != "64x64":
		_fail(14, "resolução dos itens não corresponde a 64x64")
		return

	# A melhoria não pode remover o pacote visual e de gameplay anterior.
	if int(dbg.get("vehicle_variants", 0)) != 40 or int(dbg.get("vehicle_directions", 0)) != 8:
		_fail(15, "frota 40x8 da 0.5.40.1 regrediu")
		return
	if int(dbg.get("animal_species", 0)) != 4 or int(dbg.get("animal_directions", 0)) != 8:
		_fail(16, "fauna 4x8 da 0.5.40.1 regrediu")
		return
	if not bool(dbg.get("decision_engine_0540", false)):
		_fail(17, "Atlas Decision Engine 0.5.40 regrediu")
		return
	if not scene.has_method("get_survivor_society_debug_0539") or not scene.has_method("get_mission_snapshot_0536"):
		_fail(18, "sociedade ou missões anteriores foram perdidas")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_fail(19, "save 0.5.40.2 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(20, "save 0.5.40.2 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.40.2-alpha":
		_fail(21, "versão do save não é 0.5.40.2-alpha")
		return
	var world_state := payload.get("world", {}) as Dictionary
	if not bool(world_state.get("asset_rework_05402", false)):
		_fail(22, "flag persistente do Asset Rework ausente")
		return

	print("SMOKE 0.5.40.2 OK | player=4dir-HD zombies=5x8@96x128 items=16@64x64 vehicles=40x8 animals=4x8 decision_engine=true")
	quit(0)
