extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.6.2 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if str(ProjectSettings.get_setting("application/config/version", "")) != "0.6.2-alpha":
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

	var player := scene.get_node_or_null("Actors/Player")
	if player == null or not player.has_method("get_player_stabilization_debug_0600"):
		_fail(17, "regressão no player estabilizado")
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

	print("SMOKE 0.6.2 OK | nature=3 sprites collisions=preserved fluidity=compatible save=600")
	quit(0)

func _find_sprite(node: Node) -> Sprite3D:
	for child in node.get_children():
		if child is Sprite3D and child.is_in_group("nature_visual_062"):
			return child as Sprite3D
		var nested := _find_sprite(child)
		if nested != null:
			return nested
	return null

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
