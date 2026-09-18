extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.5 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.5-alpha":
		_fail(1, "versão do projeto incorreta")
		return

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(2, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(45):
		await process_frame

	if not scene.has_method("get_spatial_combat_debug_065"):
		_fail(3, "runtime 0.6.5 não está ativo")
		return
	var debug := scene.call("get_spatial_combat_debug_065") as Dictionary
	if str(debug.get("version", "")) != "0.6.5-alpha":
		_fail(4, "versão do combate incorreta")
		return
	for flag in ["spatial_targeting", "line_of_sight", "melee_arc", "firearm_raycast", "bow_projectile"]:
		if not bool(debug.get(flag, false)):
			_fail(5, "recurso ausente: %s" % flag)
			return
	if int(debug.get("weapon_profiles", 0)) < 6:
		_fail(6, "perfis de armas incompletos")
		return

	var player := get_first_node_in_group("player") as CharacterBody3D
	if player == null:
		_fail(7, "player não foi criado")
		return
	player.set_physics_process(false)
	for weapon_id in ["machete", "axe", "pistol", "shotgun", "bow"]:
		if not player.get_owned_weapons().has(weapon_id):
			_fail(8, "kit de teste não contém %s" % weapon_id)
			return
	if int(player.get_inventory_snapshot().get("arrows", 0)) <= 0:
		_fail(9, "flechas não foram adicionadas")
		return

	var zombies: Array = scene.call("get_zombies") as Array
	if zombies.is_empty():
		_fail(10, "nenhum zumbi disponível para teste espacial")
		return
	for i in range(zombies.size()):
		if zombies[i] is Node3D:
			var zombie_far := zombies[i] as Node3D
			zombie_far.set_physics_process(false)
			zombie_far.global_position = Vector3(1100.0 + float(i) * 3.0, 5.0, 1100.0)

	var target := zombies[0] as Node3D
	player.global_position = Vector3(900.0, 5.0, 900.0)
	player.rotation.y = 0.0
	target.global_position = Vector3(900.0, 5.0, 897.9)
	await process_frame

	var selected: Node3D = player.call("_select_target_065", 3.0, 80.0, true) as Node3D
	if selected != target:
		_fail(11, "auto-alvo não selecionou inimigo à frente")
		return
	target.global_position = Vector3(900.0, 5.0, 902.1)
	await process_frame
	selected = player.call("_select_target_065", 3.0, 60.0, false) as Node3D
	if selected != null:
		_fail(12, "auto-alvo selecionou inimigo atrás do jogador")
		return

	target.global_position = Vector3(900.0, 5.0, 897.9)
	player.rotation.y = 0.0
	player.attack_cooldown = 0.0
	player.equip_weapon("machete")
	var melee_before := int(player.call("get_spatial_combat_debug_065").get("melee_hits", 0))
	player.call("_attack")
	var melee_after := int(player.call("get_spatial_combat_debug_065").get("melee_hits", 0))
	if melee_after <= melee_before:
		_fail(13, "ataque corpo a corpo espacial não acertou")
		return

	target.global_position = Vector3(900.0, 5.0, 892.0)
	player.rotation.y = 0.0
	player.attack_cooldown = 0.0
	player.equip_weapon("pistol")
	var pistol_before := int(player.get_inventory_snapshot().get("ammo_9mm", 0))
	player.call("_attack")
	var pistol_after := int(player.get_inventory_snapshot().get("ammo_9mm", 0))
	if pistol_after != pistol_before - 1:
		_fail(14, "pistola não consumiu munição")
		return

	player.attack_cooldown = 0.0
	player.equip_weapon("shotgun")
	var shells_before := int(player.get_inventory_snapshot().get("shells", 0))
	player.call("_attack")
	if int(player.get_inventory_snapshot().get("shells", 0)) != shells_before - 1:
		_fail(15, "espingarda não consumiu cartucho")
		return

	player.attack_cooldown = 0.0
	player.equip_weapon("bow")
	var arrows_before := int(player.get_inventory_snapshot().get("arrows", 0))
	player.call("_attack")
	if int(player.get_inventory_snapshot().get("arrows", 0)) != arrows_before - 1:
		_fail(16, "arco não consumiu flecha")
		return
	if int(player.call("get_spatial_combat_debug_065").get("arrows_fired", 0)) <= 0:
		_fail(17, "projétil do arco não foi disparado")
		return

	print("SMOKE 0.6.5 OK | spatial_targeting melee_arc pistol_raycast shotgun_pellets bow_projectile test_loadout")
	quit(0)
