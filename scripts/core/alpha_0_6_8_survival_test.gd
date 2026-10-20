extends SceneTree

const Player068 = preload("res://scripts/player/player_3d_v068.gd")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		printerr("FAIL 0.6.8: " + message)

func _floor_at(parent: Node3D, position_value: Vector3, size_value: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size_value
	shape.shape = box
	body.add_child(shape)
	body.position = position_value
	parent.add_child(body)
	return body

func _run() -> void:
	var arena := Node3D.new()
	root.add_child(arena)
	_floor_at(arena, Vector3(0, -0.5, 0), Vector3(80, 1, 80))
	var camera := Camera3D.new()
	arena.add_child(camera)
	camera.position = Vector3(17, 21, 17)
	camera.look_at(Vector3.ZERO)
	camera.make_current()
	var player := Player068.new()
	player.position = Vector3(0, 2, 0)
	arena.add_child(player)
	# Exercise production physics manually, without a second automatic controller tick.
	player.set_physics_process(false)
	for _i in range(90):
		await physics_frame
		player._apply_motion_058(Vector3.ZERO, 1.0 / 60.0)
	_check(player.is_on_floor(), "player did not settle onto the floor")
	_check(absf(player.position.y - 0.2) > 0.10, "legacy fixed-Y policy still active")
	var ground_y: float = player.position.y
	var right: Vector3 = player._motion_direction_058(Vector2.RIGHT).normalized()
	_check(right.dot(camera.global_basis.x.normalized()) > 0.99, "right input does not follow the camera")
	var saved_ticks := Engine.physics_ticks_per_second
	var distances: Array[float] = []
	for hz in [30, 60]:
		Engine.physics_ticks_per_second = hz
		player.position = Vector3(0, ground_y, 0)
		player.velocity = Vector3.ZERO
		for _i in range(hz):
			await physics_frame
			player._apply_motion_058(right * 5.15, 1.0 / float(hz))
		distances.append(Vector2(player.position.x, player.position.z).length())
	_check(absf(distances[0] - distances[1]) < 0.12, "distance differs at 30/60 physics ticks")
	_check(absf(distances[1] - 5.15) < 0.15, "unexpected full-stick distance")
	Engine.physics_ticks_per_second = 60
	var before := player.position
	await physics_frame
	player._apply_motion_058(Vector3.ZERO, 1.0 / 60.0)
	_check(Vector2(player.position.x - before.x, player.position.z - before.z).length() < 0.001, "released stick kept drifting")
	player.position = Vector3(0, ground_y, 0)
	for _i in range(60):
		await physics_frame
		player._apply_motion_058(right * 2.575, 1.0 / 60.0)
	_check(absf(Vector2(player.position.x, player.position.z).length() - 2.575) < 0.15, "half-strength input is not proportional")
	_floor_at(arena, Vector3(4, 1, 0), Vector3(1, 3, 25))
	player.position = Vector3(0, ground_y, 0)
	for _i in range(90):
		await physics_frame
		player._apply_motion_058(Vector3(5.15, 0, 0), 1.0 / 60.0)
	_check(player.position.x < 3.2, "player passed through the wall")
	_check(player.actual_speed_068 < 0.1, "wall collision did not stop actual travel")
	player._refresh_character_art_05402(1.0 / 60.0)
	_check(player.movement_state_064 == "idle", "walk animation continues while blocked by wall")
	_floor_at(arena, Vector3(-10, 0.5, 0), Vector3(6, 1, 6))
	player.position = Vector3(-10, 3, 0)
	player.velocity = Vector3.ZERO
	for _i in range(90):
		await physics_frame
		player._apply_motion_058(Vector3.ZERO, 1.0 / 60.0)
	_check(player.is_on_floor() and player.position.y > 0.9, "raised floor is overridden by fixed-Y/adhesion")
	for _i in range(120):
		await physics_frame
		player._apply_motion_058(Vector3(0, 0, 5.15), 1.0 / 60.0)
	_check(player.position.y < 0.15 and player.is_on_floor(), "player does not fall and settle after leaving raised platform")
	Engine.physics_ticks_per_second = saved_ticks
	arena.queue_free()
	await process_frame
	await _integration()
	if failures.is_empty():
		print("PASS 0.6.8: ground, camera, 30/60 ticks, proportional input, stop, wall, animation, production scene, icons, infected, save")
	quit(0 if failures.is_empty() else 1)

func _integration() -> void:
	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	_check(packed != null, "production scene cannot load")
	if packed == null:
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(80):
		await process_frame
	var player := get_first_node_in_group("player")
	_check(player != null and player.has_method("get_survival_motion_debug_068"), "new player not wired into world")
	_check(scene.has_method("get_performance_debug_067"), "performance runtime missing")
	if player != null:
		var snapshot: Dictionary = player.call("export_save_state") as Dictionary
		player.call("import_save_state", snapshot)
		var restored: Dictionary = player.call("export_save_state") as Dictionary
		_check(snapshot == restored, "save roundtrip changed player state")
		_check(player.has_method("_select_firearm_target_066"), "combat targeting missing")
	var controls := get_first_node_in_group("mobile_controls")
	_check(controls != null and controls.has_method("reset_motion_068"), "new controls not wired")
	if controls != null:
		var center: Vector2 = controls.get("joystick_center")
		var radius: float = controls.get("joystick_radius")
		controls.call("_update_joystick", center + Vector2.RIGHT * radius)
		var full: Vector2 = controls.call("get_move_vector")
		_check(full.is_equal_approx(Vector2.RIGHT), "full-stick sample has latency or wrong magnitude")
		controls.call("reset_motion_068")
		var released: Vector2 = controls.call("get_move_vector")
		_check(released == Vector2.ZERO, "focus/reset leaves stuck motion")
		controls.call("_update_joystick", center + Vector2.ONE.normalized() * radius)
		var diagonal: Vector2 = controls.call("get_move_vector")
		_check(absf(diagonal.length() - 1.0) < 0.001, "diagonal exceeds unit magnitude")
		controls.call("reset_motion_068")
	var ui := scene.get_node_or_null("InventoryUI")
	if ui == null:
		for node in scene.get_children():
			if node.has_method("_prepend_icon_068"):
				ui = node
	_check(ui != null and ui.has_method("_prepend_icon_068"), "new item icons not wired")
	if ui != null and player != null:
		ui.set("player", player)
		ui.call("_refresh_contents")
		var box := ui.get("items_box") as VBoxContainer
		_check(box.find_children("ItemIcon068", "TextureRect", true, false).size() > 0, "inventory produced no icons")
	var zombies := get_nodes_in_group("infected_visual_068")
	_check(zombies.size() >= 5, "new infected not wired")
	for zombie in zombies:
		var sprite := zombie.get("sprite_0537") as Sprite3D
		_check(sprite != null and sprite.texture.resource_path.ends_with("fdc_infected_atlas_068.png"), "infected uses wrong texture")
	scene.queue_free()
	await process_frame
