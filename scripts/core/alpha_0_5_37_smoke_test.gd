extends SceneTree

const SAVE_PATH_0537 := "user://fim_da_colheita_alpha_0_5_2.save.json"
const HingeScript = preload("res://scripts/world/interactive_hinge_0512.gd")

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.37 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0537):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0537))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(110):
		await process_frame

	if not scene.has_method("get_zombie_ecology_debug_0537"):
		_fail(2, "runtime Zumbis 2.0 ausente")
		return
	var ecology := scene.call("get_zombie_ecology_debug_0537") as Dictionary
	if int(ecology.get("zombies", 0)) < 10:
		_fail(3, "população de zumbis 0.5.37 não foi criada")
		return
	if int(ecology.get("hordes", 0)) != 4:
		_fail(4, "quatro hordas não foram registradas")
		return
	if int(ecology.get("visual_profiles", 0)) != 5 or int(ecology.get("animation_frames", 0)) != 8:
		_fail(5, "atlas de 5 perfis x 8 frames não está ativo")
		return
	if int(ecology.get("sprites", 0)) != int(ecology.get("zombies", 0)):
		_fail(6, "nem todos os infectados receberam o novo sprite")
		return
	var horde_counts := ecology.get("horde_counts", {}) as Dictionary
	if horde_counts.size() != 4:
		_fail(7, "zumbis não foram distribuídos pelas quatro hordas")
		return
	var profiles := ecology.get("profiles", {}) as Dictionary
	if profiles.size() < 5:
		_fail(8, "os cinco perfis de infectados não apareceram")
		return

	for raw: Node in get_nodes_in_group("zombie_0537"):
		if not raw.has_method("get_ai_debug_0537"):
			_fail(9, "zumbi sem IA 0.5.37")
			return
		var debug := raw.call("get_ai_debug_0537") as Dictionary
		if not bool(debug.get("sprite_0537", false)):
			_fail(10, "sprite 0.5.37 ausente em um zumbi")
			return

	var target_before := scene.call("get_horde_target_0537", 0) as Vector3
	var migrations_before := int(ecology.get("migrations", 0))
	if not bool(scene.call("force_horde_migration_0537", 0)):
		_fail(11, "não foi possível forçar migração de horda")
		return
	var target_after := scene.call("get_horde_target_0537", 0) as Vector3
	if Vector2(target_after.x - target_before.x, target_after.z - target_before.z).length() < 1.0:
		_fail(12, "migração não trocou o destino da horda")
		return
	var ecology_after_migration := scene.call("get_zombie_ecology_debug_0537") as Dictionary
	if int(ecology_after_migration.get("migrations", 0)) <= migrations_before:
		_fail(13, "contador de migração não avançou")
		return

	var zombies := get_nodes_in_group("zombie_0537")
	if zombies.is_empty() or not (zombies[0] is Node3D):
		_fail(14, "nenhum zumbi disponível para teste de ruído")
		return
	var noise_pos := (zombies[0] as Node3D).global_position
	var noise_before := scene.call("get_zombie_ecology_debug_0537") as Dictionary
	scene.call("emit_noise_0519", noise_pos, 46.0, "shotgun", null)
	for _i in range(8):
		await process_frame
	var noise_after := scene.call("get_zombie_ecology_debug_0537") as Dictionary
	if int(noise_after.get("loud_noise_events", 0)) <= int(noise_before.get("loud_noise_events", 0)):
		_fail(15, "tiro não foi classificado como evento de alto ruído")
		return
	if int(noise_after.get("noise_alerts", 0)) <= int(noise_before.get("noise_alerts", 0)):
		_fail(16, "barulho não atualizou o destino de nenhuma horda")
		return

	var hinge: Node3D = HingeScript.new()
	hinge.name = "SmokeDoor0537"
	hinge.set("interaction_kind", "door")
	hinge.position = Vector3(390.0, 0.0, 390.0)
	scene.add_child(hinge)
	for _i in range(2):
		await process_frame
	scene.call("register_streamed_interaction", hinge.global_position, "door", "smoke0537:door", hinge, true)
	if not bool(scene.call("damage_world_hinge_0537", hinge, 100.0, "smoke_test")):
		_fail(17, "zumbi não conseguiu danificar porta")
		return
	for _i in range(20):
		await process_frame
	if not bool(hinge.get_meta("breached_0537", false)):
		_fail(18, "porta não entrou no estado arrombado")
		return
	if not bool(hinge.get("is_open")):
		_fail(19, "porta arrombada não abriu passagem")
		return
	var breach_after := scene.call("get_zombie_ecology_debug_0537") as Dictionary
	if int(breach_after.get("breaches", 0)) < 1:
		_fail(20, "arrombamento não foi contabilizado")
		return
	var breached_keys := breach_after.get("breached_keys", []) as Array
	if "smoke0537:door" not in breached_keys:
		_fail(21, "chave persistente da porta arrombada ausente")
		return

	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("get_vehicle_catalog_05362"):
		_fail(22, "frota 0.5.36.2 foi perdida")
		return
	var vehicle_catalog := streamer.call("get_vehicle_catalog_05362") as Dictionary
	if int(vehicle_catalog.get("variant_count", 0)) != 40 or int(vehicle_catalog.get("directions", 0)) != 8:
		_fail(23, "frota 40 x 8 não foi preservada")
		return
	if not scene.has_method("get_mission_debug_0536"):
		_fail(24, "missões 0.5.36 foram perdidas")
		return

	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0537, FileAccess.READ)
	if file == null:
		_fail(25, "save da linha 0.5.37+ não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(26, "save 0.5.37+ inválido")
		return
	var payload := parsed as Dictionary
	var saved_version := str(payload.get("version", ""))
	if saved_version not in ["0.5.37-alpha", "0.5.38-alpha"]:
		_fail(27, "versão do save não é compatível com 0.5.37+")
		return
	var world_state := payload.get("world", {}) as Dictionary
	var saved_hordes := world_state.get("horde_records_0537", {}) as Dictionary
	if saved_hordes.size() != 4:
		_fail(28, "hordas não foram serializadas")
		return
	var saved_breaches := world_state.get("breached_interactions_0537", []) as Array
	if "smoke0537:door" not in saved_breaches:
		_fail(29, "porta arrombada não persistiu no save")
		return

	print("SMOKE 0.5.37 OK | zombies=%d hordes=4 profiles=5 frames=8 migrations=%d noise=%d breaches=%d vehicles=40x8" % [
		int(breach_after.get("zombies", 0)),
		int(breach_after.get("migrations", 0)),
		int(breach_after.get("noise_alerts", 0)),
		int(breach_after.get("breaches", 0))
	])
	quit(0)
