extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.6 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.6-alpha":
		_fail(1, "versão do projeto incorreta")
		return

	for path in [
		"res://assets/vehicles/fdc_vehicle_atlas_066.png",
		"res://assets/zombies/fdc_zombie_atlas_066.png"
	]:
		var texture := load(path) as Texture2D
		if texture == null:
			_fail(2, "asset 0.6.6 não carregou: %s" % path)
			return

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(3, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(50):
		await process_frame

	if not scene.has_method("get_quality_debug_066"):
		_fail(4, "runtime 0.6.6 não está ativo")
		return

	var player := get_first_node_in_group("player") as CharacterBody3D
	if player == null:
		_fail(5, "player não foi criado")
		return
	if not bool(player.get_meta("grounding_066", false)):
		_fail(6, "grounding 0.6.6 não foi instalado")
		return
	if player.floor_snap_length < 0.5:
		_fail(7, "floor snap insuficiente")
		return
	if not player.has_method("_select_firearm_target_066"):
		_fail(8, "tiro 360 não está ativo")
		return

	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer != null:
		streamer.set_process(false)

	# Teste real de contato com chão em uma plataforma isolada.
	var floor_body := StaticBody3D.new()
	floor_body.name = "SmokeFloor066"
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(8.0, 0.20, 8.0)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	scene.add_child(floor_body)
	floor_body.global_position = Vector3(900.0, 0.0, 900.0)
	player.global_position = Vector3(900.0, 0.72, 900.0)
	player.velocity = Vector3.ZERO
	for _i in range(45):
		await physics_frame
	var qdebug := player.call("get_quality_debug_066") as Dictionary
	print("GROUND 0.6.6 y=", player.global_position.y, " floor=", player.is_on_floor(), " adhesion=", qdebug.get("ground_adhesion_hits", 0))
	if player.global_position.y > 0.24:
		_fail(9, "player permanece alto demais do piso")
		return
	if not player.is_on_floor() and int(qdebug.get("ground_adhesion_hits", 0)) <= 0:
		_fail(10, "player não assentou nem aderiu ao chão")
		return

	# Tiro 360: alvo atrás do personagem deve ser selecionado e causar giro.
	var zombies: Array = scene.call("get_zombies") as Array
	if zombies.is_empty():
		_fail(11, "nenhum zumbi para teste 360")
		return
	for i in range(zombies.size()):
		if zombies[i] is Node3D:
			var z := zombies[i] as Node3D
			z.set_physics_process(false)
			z.global_position = Vector3(1100.0 + float(i) * 4.0, player.global_position.y, 1100.0)
	var target := zombies[0] as Node3D
	player.rotation.y = 0.0
	target.global_position = player.global_position + Vector3(0.0, 0.0, 8.0)
	await physics_frame
	var selected := player.call("_select_firearm_target_066", 21.0) as Node3D
	if selected != target:
		_fail(12, "arma de fogo não seleciona alvo em 360 graus")
		return
	player.call("_face_target_065", target)
	var forward := -player.global_transform.basis.z
	forward.y = 0.0
	var to_target := target.global_position - player.global_position
	to_target.y = 0.0
	if forward.normalized().dot(to_target.normalized()) < 0.98:
		_fail(13, "personagem não gira para o alvo 360")
		return

	# Zumbi deve estar usando o atlas 0.6.6.
	if not target.has_method("get_zombie_visual_debug_066"):
		_fail(14, "zumbi visual 0.6.6 não está ativo")
		return
	var zdebug := target.call("get_zombie_visual_debug_066") as Dictionary
	if str(zdebug.get("version", "")) != "0.6.6" or not bool(zdebug.get("sprite", false)):
		_fail(15, "zumbi ainda usa visual antigo")
		return

	# Variante antiga de carcaça (8) precisa ser migrada e usar o atlas novo.
	var VehicleScript = load("res://scripts/entities/vehicle_3d_v066.gd")
	var vehicle := VehicleScript.new() as CharacterBody3D
	scene.add_child(vehicle)
	vehicle.call("configure_parked_0530", scene, "smoke:ruin:066", 8, 0.0, 6606)
	var vdebug := vehicle.call("get_vehicle_visual_debug_066") as Dictionary
	if int(vdebug.get("variant", 8)) == 8:
		_fail(16, "variante de ruína não foi removida")
		return
	if not bool(vdebug.get("ruin_removed", false)) or not bool(vdebug.get("sprite", false)):
		_fail(17, "veículo ainda usa asset antigo/ruína")
		return

	print("SMOKE 0.6.6 OK | grounded floor_snap firearm_360 vehicle_ruin_removed zombie_visual_replaced")
	quit(0)
