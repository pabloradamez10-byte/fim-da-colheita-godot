extends SceneTree

const SAVE_PATH := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.40.3 FAIL: %s" % message)
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
	for _i in range(180):
		await process_frame

	if not scene.has_method("get_world_rework_debug_05403"):
		_fail(2, "runtime World Rework 0.5.40.3 ausente")
		return
	var dbg := scene.call("get_world_rework_debug_05403") as Dictionary
	if str(dbg.get("version", "")) != "0.5.40.3-alpha":
		_fail(3, "versão do runtime não é 0.5.40.3-alpha")
		return

	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("get_environment_rework_debug_05403"):
		_fail(4, "streamer visual 0.5.40.3 ausente")
		return

	# Exercita o rework em uma quadra isolada para o teste não depender da posição inicial do jogador.
	var test_root := Node3D.new()
	test_root.name = "SmokeWorld05403"
	scene.add_child(test_root)
	var coord := Vector2i(999, 999)
	streamer.call("_build_large_house_0511", test_root, Vector3(0.0, 0.0, 0.0), coord, 0, 12345, 0.0)
	streamer.call("_build_city_sidewalks", test_root, Vector3(320.0, 0.0, 320.0), Vector2i.ZERO)
	streamer.call("_decorate_residential_yard_0511", test_root, Vector3(360.0, 0.0, 360.0), Vector2i.ZERO, 24680)
	for _i in range(12):
		await process_frame

	var env := streamer.call("get_environment_rework_debug_05403") as Dictionary
	if int(env.get("houses", 0)) < 1:
		_fail(5, "fachadas residenciais do World Rework não foram criadas")
		return
	if int(env.get("street", 0)) < 2 or int(env.get("roadwear", 0)) < 1:
		_fail(6, "drenagem/desgaste de rua 0.5.40.3 não foi criado")
		return
	if int(env.get("props", 0)) < 1:
		_fail(7, "props residenciais 0.5.40.3 não foram criados")
		return
	if int(env.get("meshes", 0)) < 20:
		_fail(8, "densidade visual do rework ficou abaixo do pacote mínimo")
		return

	var house := test_root.get_node_or_null("CityHouse0511_999_999_0") as Node3D
	if house == null or not house.has_meta("world_rework_05403"):
		_fail(9, "casa não recebeu marcador do rework")
		return
	if house.get_node_or_null("WindowGlass05403") == null or house.get_node_or_null("EntryAwning05403") == null:
		_fail(10, "janela detalhada ou marquise da casa não foi integrada")
		return
	if house.get_node_or_null("InteractiveFrontDoor0512") == null:
		_fail(11, "porta funcional anterior foi perdida pelo rework")
		return

	# Pacote 0.5.40.2 deve permanecer integral.
	if not bool(dbg.get("asset_rework_05402", false)) or not bool(dbg.get("player_high_detail", false)):
		_fail(12, "Asset Rework 0.5.40.2 ou jogador HD regrediu")
		return
	if int(dbg.get("zombie_profiles", 0)) != 5 or int(dbg.get("zombie_frames", 0)) != 8:
		_fail(13, "zumbis 5x8 regrediram")
		return
	if int(dbg.get("items", 0)) != 16:
		_fail(14, "atlas de 16 itens regrediu")
		return
	if int(dbg.get("vehicle_variants", 0)) != 40 or int(dbg.get("vehicle_directions", 0)) != 8:
		_fail(15, "frota 40x8 regrediu")
		return
	if int(dbg.get("animal_species", 0)) != 4 or int(dbg.get("animal_directions", 0)) != 8:
		_fail(16, "fauna 4x8 regrediu")
		return
	if not bool(dbg.get("decision_engine_0540", false)):
		_fail(17, "Atlas Decision Engine regrediu")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_fail(18, "save 0.5.40.3 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(19, "save 0.5.40.3 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.40.3-alpha":
		_fail(20, "save não foi versionado como 0.5.40.3-alpha")
		return
	var world_state := payload.get("world", {}) as Dictionary
	if not bool(world_state.get("world_rework_05403", false)):
		_fail(21, "flag persistente do World Rework ausente")
		return

	print("SMOKE 0.5.40.3 OK | houses=%d street=%d roadwear=%d props=%d meshes=%d playerHD=true zombies=5x8 items=16 vehicles=40x8 animals=4x8") % [
		int(env.get("houses", 0)),
		int(env.get("street", 0)),
		int(env.get("roadwear", 0)),
		int(env.get("props", 0)),
		int(env.get("meshes", 0))
	]
	quit(0)
