extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE FAIL: main_3d.tscn não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(8):
		await process_frame
	var camera := root.get_camera_3d()
	if camera == null or not camera.current:
		printerr("SMOKE FAIL: nenhuma Camera3D ativa")
		quit(2)
		return
	var mesh_count := _count_visuals(scene)
	if mesh_count < 25:
		printerr("SMOKE FAIL: poucos meshes gerados: %d" % mesh_count)
		quit(3)
		return
	var player := get_first_node_in_group("player")
	if player == null:
		printerr("SMOKE FAIL: player ausente")
		quit(4)
		return
	print("SMOKE OK: camera ativa, player presente, visuals=%d" % mesh_count)
	quit(0)

func _count_visuals(node: Node) -> int:
	var total := 1 if (node is MeshInstance3D or node is MultiMeshInstance3D) else 0
	for child in node.get_children():
		total += _count_visuals(child)
	return total
