extends SceneTree

const SAVE_PATH_05321 := "user://fim_da_colheita_alpha_0_5_2.save.json"
const VEHICLE_KEY_05321 := "smoke05321:hatch"

class DummyDoor:
	extends Node3D
	var toggled := false
	func toggle_interaction() -> void:
		toggled = true

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.32.1 FAIL: %s" % message)
	quit(code)

func _find_vehicle(uid: String) -> Node3D:
	for raw: Node in get_nodes_in_group("vehicle_0530"):
		if raw is Node3D and str((raw as Node3D).get_meta("vehicle_key_0530", "")) == uid:
			return raw as Node3D
	return null

func _rect_inside(rect: Rect2, viewport_size: Vector2) -> bool:
	return rect.position.x >= -0.1 and rect.position.y >= -0.1 and rect.position.x + rect.size.x <= viewport_size.x + 0.1 and rect.position.y + rect.size.y <= viewport_size.y + 0.1

func _find_trunk_withdraw_button(rows: VBoxContainer, item_name: String) -> Button:
	if rows == null:
		return null
	for raw_row: Node in rows.get_children():
		if not (raw_row is HBoxContainer):
			continue
		var row := raw_row as HBoxContainer
		var matches := false
		for child: Node in row.get_children():
			if child is Label and (child as Label).text == item_name:
				matches = true
		if not matches:
			continue
		for child: Node in row.get_children():
			if child is Button and (child as Button).text == "< 1":
				var button := child as Button
				if not button.disabled:
					return button
	return null

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_05321):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_05321))

	if str(ProjectSettings.get_setting("display/window/stretch/aspect", "")) != "expand":
		_fail(1, "viewport não está configurado para expand em telas largas")
		return

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(2, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(90):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null:
		_fail(3, "jogador ausente")
		return

	# HUD superior deve ficar compacto e controles precisam respeitar os limites reais do viewport.
	var hud := scene.get_node_or_null("HUD")
	if hud == null or not hud.has_method("get_hud_layout_debug_05321"):
		_fail(4, "HUD responsivo 0.5.32.1 ausente")
		return
	var hud_debug := hud.call("get_hud_layout_debug_05321") as Dictionary
	var panel_size := hud_debug.get("panel_size", Vector2.ZERO) as Vector2
	if panel_size.y > 110.0 or panel_size.y < 90.0:
		_fail(5, "painel superior não ficou compacto")
		return

	var controls := get_first_node_in_group("mobile_controls")
	if controls == null or not controls.has_method("get_layout_debug_05321"):
		_fail(6, "controles responsivos 0.5.32.1 ausentes")
		return
	var controls_debug := controls.call("get_layout_debug_05321") as Dictionary
	var viewport_size := controls_debug.get("viewport", Vector2.ZERO) as Vector2
	for key in ["attack_rect", "interact_rect", "sprint_rect", "weapon_rect", "seed_rect"]:
		var rect := controls_debug.get(key, Rect2()) as Rect2
		if not _rect_inside(rect, viewport_size):
			_fail(7, "controle %s ficou fora da tela" % key)
			return

	# Porta-malas: simula o início do toque mobile no botão CARRO -> MOCHILA.
	var streamer := scene.get_node_or_null("ChunkStreamer")
	if streamer == null or not streamer.has_method("_build_vehicle_sprite_0517"):
		_fail(8, "streamer de veículos ausente")
		return
	var probe_parent := Node3D.new()
	scene.add_child(probe_parent)
	streamer.call("_build_vehicle_sprite_0517", probe_parent, Vector3(420.0, 0.28, 420.0), 0.0, 0, VEHICLE_KEY_05321)
	for _i in range(4):
		await process_frame
	var vehicle := _find_vehicle(VEHICLE_KEY_05321)
	if vehicle == null:
		_fail(9, "veículo de teste não foi criado")
		return
	player.call("add_item", "fiber", 2)
	player.global_position = vehicle.global_position + Vector3(0.8, -0.08, 0.0)
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(10, "painel do veículo não abriu")
		return
	for _i in range(3):
		await process_frame
	if not bool(scene.call("vehicle_trunk_deposit_0530", VEHICLE_KEY_05321, "fiber", 1, player)):
		_fail(11, "não foi possível preparar item dentro do porta-malas")
		return
	var vehicle_uis := get_nodes_in_group("vehicle_ui_0530")
	if vehicle_uis.is_empty():
		_fail(12, "UI de veículo ausente")
		return
	var vehicle_ui := vehicle_uis[0]
	# Força o refresh e deixa o queue_free dos rows antigos terminar antes de buscar o botão tocável.
	vehicle_ui.set("trunk_signature_05321", "")
	vehicle_ui.call("_refresh_0530")
	await process_frame
	var ui_debug := vehicle_ui.call("get_vehicle_ui_debug_0530") as Dictionary
	if not bool(ui_debug.get("touch_transfer_05321", false)):
		_fail(13, "UI não está usando transferência touch segura")
		return
	var rows := vehicle_ui.get("rows_0530") as VBoxContainer
	var withdraw_button := _find_trunk_withdraw_button(rows, "Fibra")
	if withdraw_button == null:
		_fail(14, "botão tocável de retirar fibra do carro não ficou disponível")
		return
	var backpack_before := int((player.call("get_inventory_snapshot") as Dictionary).get("fiber", 0))
	withdraw_button.emit_signal("button_down")
	await process_frame
	var backpack_after := int((player.call("get_inventory_snapshot") as Dictionary).get("fiber", 0))
	var trunk_after := (scene.call("get_vehicle_status_0530", VEHICLE_KEY_05321) as Dictionary).get("trunk", {}) as Dictionary
	if backpack_after != backpack_before + 1 or int(trunk_after.get("fiber", 0)) != 0:
		_fail(15, "toque no botão CARRO -> MOCHILA não retirou o item")
		return
	vehicle_ui.call("close_vehicle_0530")

	# Porta deve vencer uma cama próxima: INTERAGIR não pode avançar horas ao tocar na porta.
	var test_pos := Vector3(760.0, 0.20, 760.0)
	var dummy_door := DummyDoor.new()
	dummy_door.name = "SmokeDoor05321"
	scene.add_child(dummy_door)
	dummy_door.global_position = test_pos
	var dummy_bed := Node3D.new()
	dummy_bed.name = "SmokeBed05321"
	scene.add_child(dummy_bed)
	dummy_bed.global_position = test_pos + Vector3(0.70, 0.0, 0.0)
	var interactables := scene.get("interactables") as Array
	interactables.append({"type":"door", "key":"smoke_door_05321", "position":test_pos, "node":dummy_door})
	interactables.append({"type":"sleep_bed_0521", "key":"smoke_bed_05321", "position":dummy_bed.global_position, "node":dummy_bed})
	player.global_position = test_pos
	player.set("last_move_dir", Vector3(1.0, 0.0, 0.0))
	var time_before := float((scene.call("get_time_state_0521") as Dictionary).get("minutes", 0.0))
	if not bool(scene.call("try_interact_near", player.global_position, player)):
		_fail(16, "interação sintética de porta não foi tratada")
		return
	var time_after := float((scene.call("get_time_state_0521") as Dictionary).get("minutes", 0.0))
	if not dummy_door.toggled:
		_fail(17, "cama próxima ainda roubou a interação da porta")
		return
	if absf(time_after - time_before) > 2.0:
		_fail(18, "interagir na porta ainda avançou o relógio")
		return

	print("SMOKE 0.5.32.1 OK: expand=true hud=%.0fpx trunk_touch=true door_priority=true" % panel_size.y)
	if FileAccess.file_exists(SAVE_PATH_05321):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_05321))
	quit(0)
