extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.0 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.0-alpha":
		_fail(1, "versão do projeto incorreta")
		return
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(2, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(30):
		await process_frame

	var player := scene.get_node_or_null("Actors/Player")
	if player == null or not player.has_method("get_player_stabilization_debug_0600"):
		_fail(3, "player estabilizado não foi criado")
		return

	player.call("equip_weapon", "machete")
	player.call("_damage_nearest", 0.0, 0.0)
	var melee := player.call("get_player_stabilization_debug_0600") as Dictionary
	if str(melee.get("last_combat_animation", "")) != "melee_1h":
		_fail(4, "animação do facão incorreta")
		return

	player.call("unlock_weapon", "pistol")
	player.call("_damage_nearest", 0.0, 0.0)
	var pistol := player.call("get_player_stabilization_debug_0600") as Dictionary
	if str(pistol.get("last_combat_animation", "")) != "firearm_1h":
		_fail(5, "pistola ainda usa animação corpo a corpo")
		return

	player.call("unlock_weapon", "shotgun")
	player.call("_damage_nearest", 0.0, 0.0)
	var shotgun := player.call("get_player_stabilization_debug_0600") as Dictionary
	if str(shotgun.get("last_combat_animation", "")) != "firearm_2h":
		_fail(6, "espingarda ainda usa animação corpo a corpo")
		return

	if not scene.has_method("get_debug_0516"):
		_fail(7, "diagnóstico de portas ausente")
		return
	var doors := scene.call("get_debug_0516") as Dictionary
	if int(doors.get("registered_doors", 0)) <= 0:
		_fail(8, "nenhuma porta foi registrada")
		return
	if int(doors.get("walkable_thresholds", 0)) <= 0:
		_fail(9, "nenhuma passagem de porta foi marcada como caminhável")
		return

	scene.call("save_game")
	var save_debug := scene.call("get_save_stabilization_debug_0600") as Dictionary
	if not bool(save_debug.get("last_save_valid", false)):
		_fail(10, "save protegido não foi finalizado")
		return
	if str(save_debug.get("saved_version", "")) != "0.6.0-alpha":
		_fail(11, "save gravado com versão incorreta")
		return
	if int(save_debug.get("saved_schema", 0)) != 600 or not bool(save_debug.get("valid_payload", false)):
		_fail(12, "schema ou conteúdo do save inválido")
		return
	if not bool(save_debug.get("backup_exists", false)):
		_fail(13, "backup recuperável não foi criado")
		return

	print("SMOKE 0.6.0 OK | version=600 combat=melee+pistol+shotgun doors=registered save=protected")
	quit(0)
