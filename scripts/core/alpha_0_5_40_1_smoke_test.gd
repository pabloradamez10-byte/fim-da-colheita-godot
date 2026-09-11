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
		_fail(1,"cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(150): await process_frame
	if not scene.has_method("get_visual_rework_debug_05401"):
		_fail(2,"runtime visual 0.5.40.1 ausente")
		return
	var dbg := scene.call("get_visual_rework_debug_05401") as Dictionary
	if not bool(dbg.get("high_detail",false)) or not bool(dbg.get("vector_art",false)):
		_fail(3,"visual rework não está ativo")
		return
	if int(dbg.get("animal_species",0)) != 4 or int(dbg.get("animal_directions",0)) != 8:
		_fail(4,"fauna visual não está em 4 espécies x 8 direções")
		return
	if int(dbg.get("vehicle_variants",0)) != 40 or int(dbg.get("vehicle_directions",0)) != 8:
		_fail(5,"frota visual não está em 40 x 8")
		return
	if str(dbg.get("animal_tile","")) != "96x96" or str(dbg.get("vehicle_tile","")) != "96x72":
		_fail(6,"resolução dos novos sprites não corresponde ao pacote")
		return
	if int(dbg.get("animal_sprites",0)) < 18:
		_fail(7,"18 animais não receberam o novo sprite")
		return
	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("get_vehicle_catalog_05362"):
		_fail(8,"streamer/frota ausente")
		return
	var fleet := streamer.call("get_vehicle_catalog_05362") as Dictionary
	if int(fleet.get("variant_count",0)) != 40 or int(fleet.get("directions",0)) != 8:
		_fail(9,"catálogo 40x8 regrediu")
		return
	var vehicles := get_nodes_in_group("vehicle_high_detail_05401")
	if vehicles.is_empty():
		_fail(10,"nenhum veículo com arte nova foi instanciado")
		return
	var vehicle_parent := vehicles[0].get_parent()
	if vehicle_parent == null or not vehicle_parent.has_method("get_visual_rework_debug_05401"):
		_fail(11,"script visual do veículo ausente")
		return
	var vdbg := vehicle_parent.call("get_visual_rework_debug_05401") as Dictionary
	if int(vdbg.get("tile_width",0)) != 96 or int(vdbg.get("tile_height",0)) != 72:
		_fail(12,"atlas vetorial do veículo não está em alta definição")
		return
	var animals := get_nodes_in_group("animal_high_detail_05401")
	if animals.is_empty():
		_fail(13,"sprites novos dos animais ausentes")
		return
	var animal_parent := animals[0].get_parent()
	if animal_parent == null or not animal_parent.has_method("get_visual_rework_debug_05401"):
		_fail(14,"script visual da fauna ausente")
		return
	var adbg := animal_parent.call("get_visual_rework_debug_05401") as Dictionary
	if int(adbg.get("tile_width",0)) != 96 or int(adbg.get("tile_height",0)) != 96:
		_fail(15,"atlas vetorial dos animais não está em alta definição")
		return
	if not bool(dbg.get("decision_engine_0540",false)):
		_fail(16,"Atlas Decision Engine 0.5.40 regrediu")
		return
	scene.call("save_game")
	var f := FileAccess.open(SAVE_PATH,FileAccess.READ)
	if f == null:
		_fail(17,"save não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary) or str((parsed as Dictionary).get("version","")) != "0.5.40.1-alpha":
		_fail(18,"versão 0.5.40.1 não persistiu")
		return
	print("SMOKE 0.5.40.1 OK | vehicles=40x8@96x72 animals=4x8@96x96 vector=true decision_engine=true")
	quit(0)
