extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		printerr("SMOKE 0.5.2 FAIL: main_3d.tscn não carregou")
		quit(1)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(12):
		await process_frame

	var camera := root.get_camera_3d()
	if camera == null or not camera.current:
		printerr("SMOKE 0.5.2 FAIL: câmera 3D não está ativa")
		quit(2)
		return

	var player := get_first_node_in_group("player")
	if player == null:
		printerr("SMOKE 0.5.2 FAIL: player ausente")
		quit(3)
		return

	if not scene.has_method("get_debug_metrics"):
		printerr("SMOKE 0.5.2 FAIL: runtime sem métricas de validação")
		quit(4)
		return
	var metrics: Dictionary = scene.call("get_debug_metrics")
	if int(metrics.get("colliders", 0)) < 80:
		printerr("SMOKE 0.5.2 FAIL: poucos colliders: %s" % str(metrics.get("colliders", 0)))
		quit(5)
		return
	if int(metrics.get("materials", 0)) < 20:
		printerr("SMOKE 0.5.2 FAIL: materiais texturizados insuficientes: %s" % str(metrics.get("materials", 0)))
		quit(6)
		return
	if not bool(metrics.get("roof", false)) or not bool(metrics.get("interior", false)) or not bool(metrics.get("trigger", false)):
		printerr("SMOKE 0.5.2 FAIL: sistema de interior/telhado incompleto: %s" % str(metrics))
		quit(7)
		return

	var roof := scene.find_child("FarmhouseRoof", true, false) as Node3D
	var trigger := scene.find_child("FarmhouseInteriorTrigger", true, false) as Area3D
	if roof == null or trigger == null:
		printerr("SMOKE 0.5.2 FAIL: nós do interior não encontrados")
		quit(8)
		return
	scene.call("_on_house_body_entered", player, roof)
	if roof.visible:
		printerr("SMOKE 0.5.2 FAIL: telhado não ocultou ao entrar")
		quit(9)
		return
	scene.call("_on_house_body_exited", player, roof)
	if not roof.visible:
		printerr("SMOKE 0.5.2 FAIL: telhado não voltou ao sair")
		quit(10)
		return

	var mesh_count := _count_visuals(scene)
	var body_count := _count_static_bodies(scene)
	if mesh_count < 60:
		printerr("SMOKE 0.5.2 FAIL: poucos elementos visuais: %d" % mesh_count)
		quit(11)
		return
	if body_count < 80:
		printerr("SMOKE 0.5.2 FAIL: poucos StaticBody3D: %d" % body_count)
		quit(12)
		return

	print("SMOKE 0.5.2 OK: camera ativa, visuals=%d, colliders=%d, materiais=%d, interior+telhado OK" % [mesh_count, body_count, int(metrics.get("materials", 0))])
	quit(0)

func _count_visuals(node: Node) -> int:
	var total := 1 if (node is MeshInstance3D or node is MultiMeshInstance3D) else 0
	for child in node.get_children():
		total += _count_visuals(child)
	return total

func _count_static_bodies(node: Node) -> int:
	var total := 1 if node is StaticBody3D else 0
	for child in node.get_children():
		total += _count_static_bodies(child)
	return total
