extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.3 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.3-alpha":
		_fail(1, "versão do projeto incorreta")
		return
	if int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 0)) != 60:
		_fail(2, "regressão no tick de física")
		return
	if not bool(ProjectSettings.get_setting("physics/common/physics_interpolation", false)):
		_fail(3, "regressão na interpolação de física")
		return

	for path in [
		"res://assets/nature/fdc_tree_pinus_adult_062.png",
		"res://assets/nature/fdc_bush_dense_062.png",
		"res://assets/nature/fdc_rock_mossy_062.png"
	]:
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != Vector2(512, 512):
			_fail(4, "asset inválido: %s" % path)
			return
	for path in [
		"res://assets/buildings/full/fdc_building_house_urban_two_story_063.png",
		"res://assets/buildings/full/fdc_building_house_rural_two_story_063.png",
		"res://assets/buildings/full/fdc_building_house_fortified_two_story_063.png",
		"res://assets/buildings/full/fdc_building_hospital_063.png",
		"res://assets/buildings/full/fdc_building_market_063.png",
		"res://assets/buildings/full/fdc_building_bar_063.png",
		"res://assets/buildings/full/fdc_building_dairy_063.png",
		"res://assets/buildings/full/fdc_building_pharmacy_063.png",
		"res://assets/buildings/full/fdc_building_workshop_063.png",
		"res://assets/buildings/full/fdc_building_gas_station_063.png"
	]:
		var building_texture := load(path) as Texture2D
		if building_texture == null or building_texture.get_size() != Vector2(1024, 1024):
			_fail(20, "construção completa inválida: %s" % path)
			return

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(5, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(40):
		await process_frame

	if not scene.has_method("get_nature_asset_debug_062"):
		_fail(6, "runtime de natureza 0.6.2 não está ativo")
		return
	if not scene.has_method("get_fluidity_debug_0601"):
		_fail(7, "regressão no runtime fluido 0.6.1")
		return
	var fluidity := scene.call("get_fluidity_debug_0601") as Dictionary
	if str(fluidity.get("version", "")) != "0.6.1-alpha":
		_fail(8, "runtime fluido reportou versão incorreta")
		return

	var tree_root := scene.call("_create_tree", Vector3(1000, 0, 1000), 1.0, true) as Node3D
	var bush_root := scene.call("_create_bush", Vector3(1004, 0, 1000), 1.0) as Node3D
	var rock_root := scene.call("_create_rock", Vector3(1008, 0, 1000), 1.0) as Node3D
	for nature_root in [tree_root, bush_root, rock_root]:
		if nature_root == null or not nature_root.has_meta("nature_visual_version"):
			_fail(9, "raiz natural não recebeu o asset 0.6.2")
			return
		if _find_sprite(nature_root) == null:
			_fail(10, "sprite natural ausente")
			return
		if _has_visible_mesh(nature_root):
			_fail(11, "mesh provisório ainda está visível")
			return

	var nature_debug := scene.call("get_nature_asset_debug_062") as Dictionary
	if str(nature_debug.get("version", "")) != "0.6.2-alpha":
		_fail(12, "runtime de natureza reportou versão incorreta")
		return
	if int(nature_debug.get("tree_sprites", 0)) < 1 or int(nature_debug.get("bush_sprites", 0)) < 1 or int(nature_debug.get("rock_sprites", 0)) < 1:
		_fail(13, "nem todas as categorias naturais foram instanciadas")
		return

	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("get_nature_streaming_debug_062"):
		_fail(14, "streamer de natureza 0.6.2 não está ativo")
		return
	var chunk_test_root := Node3D.new()
	scene.add_child(chunk_test_root)
	streamer.call("_create_tree", chunk_test_root, Vector3.ZERO, 1.0, true)
	streamer.call("_create_rock", chunk_test_root, Vector3(4, 0, 0), 1.0)
	if chunk_test_root.get_child_count() != 2:
		_fail(15, "streamer não criou as raízes naturais")
		return
	for chunk_nature_root in chunk_test_root.get_children():
		if _find_sprite(chunk_nature_root) == null or not _has_collision(chunk_nature_root):
			_fail(16, "asset ou colisão do chunk não foi preservado")
			return

	if not streamer.has_method("get_building_asset_debug_063") or not streamer.has_method("_apply_two_story_house_063"):
		_fail(21, "streamer de construções 0.6.3 não está ativo")
		return
	var house_variants_seen := {}
	var first_house_root: Node3D = null
	for variant in range(3):
		var house_test_parent := Node3D.new()
		scene.add_child(house_test_parent)
		var coord := Vector2i(900 + variant, 900)
		streamer.call("_build_large_house_0511", house_test_parent, Vector3(1000 + variant * 40, 0, 1000), coord, variant, 7 + variant, 0.0)
		if house_test_parent.get_child_count() != 1:
			_fail(22, "casa de teste %d não foi criada" % variant)
			return
		var house_root := house_test_parent.get_child(0) as Node3D
		streamer.call("_apply_two_story_house_063", house_root, coord, variant, 7 + variant, variant)
		var house_asset := _find_building_asset(house_root)
		if house_root == null or house_asset == null or not _has_collision(house_root):
			_fail(23, "construção completa ou colisão da casa %d não foi preservada" % variant)
			return
		if house_root.get_node_or_null("InteractiveFrontDoor0512") == null:
			_fail(24, "porta funcional da casa %d foi removida" % variant)
			return
		if int(house_root.get_meta("storeys_063", 0)) != 2 or house_root.get_node_or_null("UpperFloor063") == null:
			_fail(29, "segundo piso funcional ausente na casa %d" % variant)
			return
		if house_root.get_node_or_null("Staircase063") == null or house_root.get_node_or_null("StairsUp063") == null:
			_fail(30, "escada funcional ausente na casa %d" % variant)
			return
		if _count_group_below(house_root, "upper_loot_furniture_063") != 5:
			_fail(32, "casa %d não possui cinco recipientes de loot no segundo piso" % variant)
			return
		if str(house_root.get_meta("building_asset_kind", "")) != "full_exterior":
			_fail(33, "casa %d não foi identificada como construção completa" % variant)
			return
		if not _verify_roof_cutaway(house_root, house_asset):
			_fail(34, "exterior completo da casa %d não acompanha o recorte do telhado" % variant)
			return
		var variant_name := str(house_root.get_meta("building_asset_variant", ""))
		house_variants_seen[variant_name] = true
		if first_house_root == null:
			first_house_root = house_root
	if house_variants_seen.size() != 3:
		_fail(35, "as três variações de sobrado não foram instanciadas")
		return

	var establishment_roles := ["hospital", "market", "bar", "dairy", "pharmacy", "workshop", "gas_station"]
	var expected_footprints := {
		"hospital": Vector2(18.0, 16.0),
		"market": Vector2(18.0, 14.0),
		"bar": Vector2(13.0, 11.0),
		"dairy": Vector2(20.0, 16.0),
		"pharmacy": Vector2(12.0, 10.0),
		"workshop": Vector2(18.0, 14.0),
		"gas_station": Vector2(11.0, 9.0)
	}
	var expected_loot := {"hospital": 8, "market": 5, "bar": 4, "dairy": 5, "pharmacy": 5, "workshop": 4, "gas_station": 5}
	for role_index in range(establishment_roles.size()):
		var role := str(establishment_roles[role_index])
		var role_root := Node3D.new()
		role_root.name = "SmokeBuilding_%s" % role
		role_root.position = Vector3(1200.0 + float(role_index) * 32.0, 0.0, 1200.0)
		role_root.add_to_group("city_building")
		scene.add_child(role_root)
		streamer.call("_apply_building_role_063", role_root, role, Vector2i(950 + role_index, 950), 30 + role_index)
		var role_asset := _find_building_asset(role_root)
		if role_asset == null or str(role_root.get_meta("building_asset_role", "")) != role:
			_fail(25, "construção completa não aplicada para %s" % role)
			return
		if str(role_root.get_meta("building_asset_kind", "")) != "full_exterior":
			_fail(26, "asset parcial detectado para %s" % role)
			return
		if not bool(role_root.get_meta("dedicated_establishment_063", false)):
			_fail(44, "planta dedicada ausente para %s" % role)
			return
		if role_root.get_meta("footprint_063", Vector2.ZERO) != expected_footprints[role]:
			_fail(45, "dimensão incorreta para %s" % role)
			return
		if role_root.get_node_or_null("EstablishmentFrontDoor063") == null or role_root.get_node_or_null("Roof") == null:
			_fail(46, "porta ou telhado funcional ausente para %s" % role)
			return
		if _count_group_below(role_root, "establishment_loot_%s_063" % role) != int(expected_loot[role]):
			_fail(47, "quantidade de loot interno incorreta para %s" % role)
			return
		if role == "hospital" and (int(role_root.get_meta("storeys_063", 0)) != 2 or role_root.get_node_or_null("UpperFloor063") == null or role_root.get_node_or_null("Staircase063") == null):
			_fail(48, "hospital não possui dois pisos")
			return
		if role != "hospital" and int(role_root.get_meta("storeys_063", 0)) != 1:
			_fail(49, "número de pisos incorreto para %s" % role)
			return
		if not _verify_roof_cutaway(role_root, role_asset):
			_fail(31, "recorte do exterior não funciona para %s" % role)
			return

	var building_debug := streamer.call("get_building_asset_debug_063") as Dictionary
	if str(building_debug.get("version", "")) != "0.6.3-alpha":
		_fail(27, "runtime de construções reportou versão incorreta")
		return
	var role_counts := building_debug.get("roles", {}) as Dictionary
	for role in ["house", "hospital", "market", "bar", "dairy", "pharmacy", "workshop", "gas_station"]:
		if int(role_counts.get(role, 0)) < 1:
			_fail(28, "categoria visual não instanciada: %s" % role)
			return
	if int(building_debug.get("two_story_houses", 0)) < 3 or int(building_debug.get("staircases", 0)) < 3 or int(building_debug.get("upper_loot", 0)) < 15:
		_fail(36, "sobrados, escadas ou loot superior incompletos")
		return
	var dedicated_debug := building_debug.get("dedicated_establishments", {}) as Dictionary
	for role in establishment_roles:
		if int(dedicated_debug.get(role, 0)) < 1:
			_fail(50, "estabelecimento dedicado não contabilizado: %s" % role)
			return
	if int(building_debug.get("establishment_loot", 0)) < 36:
		_fail(51, "loot dos estabelecimentos incompleto")
		return

	var player := scene.get_node_or_null("Actors/Player") as Node3D
	if player == null or not player.has_method("get_player_stabilization_debug_0600"):
		_fail(17, "regressão no player estabilizado")
		return
	if first_house_root == null:
		_fail(37, "casa de navegação vertical ausente")
		return
	var stairs_up := first_house_root.get_node_or_null("StairsUp063") as Node3D
	var stairs_down := first_house_root.get_node_or_null("UpperFloor063/StairsDown063") as Node3D
	if stairs_up == null or stairs_down == null:
		_fail(38, "marcadores da escada ausentes")
		return
	player.global_position = stairs_up.global_position
	if not bool(scene.call("try_interact_near", player.global_position, player)) or player.global_position.y < 3.0:
		_fail(39, "subida para o segundo piso falhou")
		return
	await physics_frame
	var tested_roof := first_house_root.get_node_or_null("Roof") as Node3D
	var tested_upper := first_house_root.get_node_or_null("UpperFloor063") as Node3D
	if tested_roof == null or tested_upper == null or tested_roof.visible or not tested_upper.visible:
		_fail(40, "recorte visual do segundo piso falhou")
		return
	player.global_position = stairs_down.global_position
	if not bool(scene.call("try_interact_near", player.global_position, player)) or player.global_position.y > 1.0:
		_fail(41, "descida para o térreo falhou")
		return
	await physics_frame
	if tested_roof.visible or tested_upper.visible:
		_fail(42, "recorte visual do térreo falhou")
		return
	player.global_position = first_house_root.to_global(Vector3(20.0, 0.25, 0.0))
	await physics_frame
	if not tested_roof.visible or not tested_upper.visible:
		_fail(43, "exterior completo não reapareceu ao sair da casa")
		return
	var loot_probe := {
		"bar": "food",
		"dairy": "food",
		"pharmacy": "antiseptic",
		"gas_station": "gasoline"
	}
	for role in loot_probe:
		var item_id := str(loot_probe[role])
		var before_inventory := player.call("get_inventory_snapshot") as Dictionary
		scene.call("_grant_contextual_loot_0514", "loot_poi_%s" % role, "smoke063:%s" % role, first_house_root, player)
		var after_inventory := player.call("get_inventory_snapshot") as Dictionary
		if int(after_inventory.get(item_id, 0)) <= int(before_inventory.get(item_id, 0)):
			_fail(52, "loot especializado não concedido para %s" % role)
			return
	var location_summary := scene.call("get_world_summary") as Dictionary
	var specialized_counts := location_summary.get("specialized_loot_found_063", {}) as Dictionary
	for role in loot_probe:
		if int(specialized_counts.get(role, 0)) < 1:
			_fail(53, "loot especializado não contabilizado para %s" % role)
			return
	player.call("unlock_weapon", "pistol")
	player.call("_damage_nearest", 0.0, 0.0)
	var combat := player.call("get_player_stabilization_debug_0600") as Dictionary
	if str(combat.get("last_combat_animation", "")) != "firearm_1h":
		_fail(18, "regressão na animação da pistola")
		return

	scene.call("save_game")
	var save_debug := scene.call("get_save_stabilization_debug_0600") as Dictionary
	if not bool(save_debug.get("last_save_valid", false)) or int(save_debug.get("saved_schema", 0)) != 600:
		_fail(19, "regressão no save compatível")
		return

	print("SMOKE 0.6.3 OK | assets=10 houses=3 establishments=7 establishment_loot=36 hospital_floors=2 stairs=working save=600")
	quit(0)

func _find_sprite(node: Node) -> Sprite3D:
	for child in node.get_children():
		if child is Sprite3D and child.is_in_group("nature_visual_062"):
			return child as Sprite3D
		var nested := _find_sprite(child)
		if nested != null:
			return nested
	return null

func _find_building_asset(node: Node) -> Sprite3D:
	for child in node.get_children():
		if child is Sprite3D and child.is_in_group("building_asset_063") and (child as Sprite3D).visible:
			return child as Sprite3D
		var nested := _find_building_asset(child)
		if nested != null:
			return nested
	return null

func _verify_roof_cutaway(building_root: Node3D, asset: Sprite3D) -> bool:
	var roof := building_root.get_node_or_null("Roof") as Node3D
	if roof == null or asset.get_parent() != roof:
		return false
	roof.visible = false
	var hidden_with_roof := not asset.is_visible_in_tree()
	roof.visible = true
	return hidden_with_roof and asset.is_visible_in_tree()

func _count_group_below(node: Node, group_name: String) -> int:
	var count := 1 if node.is_in_group(group_name) else 0
	for child in node.get_children():
		count += _count_group_below(child, group_name)
	return count

func _has_visible_mesh(node: Node) -> bool:
	for child in node.get_children():
		if child is MeshInstance3D and (child as MeshInstance3D).visible:
			return true
		if _has_visible_mesh(child):
			return true
	return false

func _has_collision(node: Node) -> bool:
	for child in node.get_children():
		if child is CollisionShape3D and (child as CollisionShape3D).shape != null:
			return true
		if _has_collision(child):
			return true
	return false
