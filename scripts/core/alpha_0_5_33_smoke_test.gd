extends SceneTree

const SAVE_PATH_0533 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.33 FAIL: %s" % message)
	quit(code)

func _clothing_count(player: Node) -> int:
	var total := 0
	var snapshot := player.call("get_inventory_snapshot") as Dictionary
	var defs := player.call("get_clothing_defs_0533") as Dictionary
	for raw_id: Variant in defs.keys():
		total += int(snapshot.get(str(raw_id), 0))
	return total

func _reset_injury_state(player: Node) -> void:
	player.set("health", 100.0)
	player.set("stamina", 100.0)
	player.set("pain_0519", 0.0)
	player.set("bleeding_0519", 0.0)
	player.set("infection_0520", 0.0)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0533):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0533))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(96):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_equipment_debug_0533"):
		_fail(2, "Player 0.5.33 não foi instanciado")
		return
	if not scene.has_method("get_body_equipment_world_debug_0533"):
		_fail(3, "World 0.5.33 ausente")
		return
	var world_debug := scene.call("get_body_equipment_world_debug_0533") as Dictionary
	if not bool(world_debug.get("player_0533", false)):
		_fail(4, "runtime não está usando PlayerV0533")
		return

	var inventory_uis := get_nodes_in_group("inventory_ui_0533")
	if inventory_uis.is_empty():
		_fail(5, "painel de vestuário 0.5.33 ausente")
		return
	var ui_debug := inventory_uis[0].call("get_inventory_ui_debug_0533") as Dictionary
	if not bool(ui_debug.get("equipment_scroll", false)) or not bool(ui_debug.get("equipment_box", false)):
		_fail(6, "coluna corporal não foi construída")
		return
	if float((ui_debug.get("panel_size", Vector2.ZERO) as Vector2).x) < 1100.0:
		_fail(7, "painel 0.5.33 não abriu espaço para vestuário")
		return

	# Migração/new game começa com roupa civil básica já no corpo.
	var equipment := player.call("get_equipment_snapshot_0533") as Dictionary
	if str(equipment.get("torso", "")) != "tshirt" or str(equipment.get("legs", "")) != "jeans" or str(equipment.get("feet", "")) != "sneakers":
		_fail(8, "equipamento inicial básico incorreto")
		return
	var base_stats := player.call("get_equipment_stats_0533") as Dictionary
	if float(base_stats.get("cut", 0.0)) <= 0.0 or float(base_stats.get("weight", 0.0)) <= 0.0:
		_fail(9, "roupas iniciais não geram proteção/peso")
		return

	# Troca real de slot: jaqueta entra no corpo e a camiseta volta à mochila.
	if not bool(player.call("receive_clothing_0533", "rain_jacket", 1)):
		_fail(10, "não foi possível receber jaqueta")
		return
	if not bool(player.call("equip_clothing_0533", "rain_jacket")):
		_fail(11, "não foi possível equipar jaqueta")
		return
	equipment = player.call("get_equipment_snapshot_0533") as Dictionary
	var snapshot := player.call("get_inventory_snapshot") as Dictionary
	if str(equipment.get("torso", "")) != "rain_jacket" or int(snapshot.get("tshirt", 0)) < 1:
		_fail(12, "troca de torso não devolveu a roupa anterior à mochila")
		return
	var rain_stats := player.call("get_equipment_stats_0533") as Dictionary
	if float(rain_stats.get("rain", 0.0)) <= float(base_stats.get("rain", 0.0)):
		_fail(13, "jaqueta impermeável não aumentou proteção de chuva")
		return

	# Baseline sem roupa para medir dano de zumbi.
	for slot in ["head", "torso", "hands", "legs", "feet", "back"]:
		player.call("unequip_slot_0533", slot)
	_reset_injury_state(player)
	player.call("take_zombie_damage_0520", 10.0, 3)
	var unprotected_damage := 100.0 - float(player.get("health"))
	if unprotected_damage < 9.5:
		_fail(14, "baseline sem roupa não recebeu dano esperado")
		return

	# Monta conjunto pesado/protetor e repete exatamente o mesmo ataque.
	for item_id in ["motorcycle_helmet", "rain_jacket", "work_gloves", "cargo_pants", "work_boots", "hiking_backpack"]:
		var inv_now := player.call("get_inventory_snapshot") as Dictionary
		if int(inv_now.get(item_id, 0)) <= 0:
			player.call("receive_clothing_0533", item_id, 1)
		if not bool(player.call("equip_clothing_0533", item_id)):
			_fail(15, "falha ao equipar conjunto protetor: %s" % item_id)
			return
	var protective_stats := player.call("get_equipment_stats_0533") as Dictionary
	if float(protective_stats.get("bite", 0.0)) < 50.0 or float(protective_stats.get("rain", 0.0)) < 70.0:
		_fail(16, "conjunto completo não acumulou proteção suficiente")
		return
	_reset_injury_state(player)
	player.call("take_zombie_damage_0520", 10.0, 3)
	var protected_damage := 100.0 - float(player.get("health"))
	if protected_damage >= unprotected_damage - 2.0:
		_fail(17, "proteção corporal não reduziu dano de zumbi")
		return
	var equip_debug := player.call("get_equipment_debug_0533") as Dictionary
	if float(equip_debug.get("blocked_damage", 0.0)) <= 0.0:
		_fail(18, "dano bloqueado não foi contabilizado")
		return

	# Proteção climática e peso precisam afetar o corpo, não apenas aparecer na UI.
	if float(player.call("get_rain_exposure_multiplier_0533")) >= 0.55:
		_fail(19, "roupa impermeável não reduz exposição à chuva")
		return
	if float(player.call("get_cold_insulation_0533")) <= 0.30:
		_fail(20, "conjunto não oferece isolamento térmico")
		return
	player.set("velocity", Vector3(6.0, 0.0, 0.0))
	player.set("stamina", 100.0)
	player.set("fatigue_0521", 10.0)
	player.call("_apply_equipment_encumbrance_0533", 1.0)
	if float(player.get("stamina")) >= 100.0 or float(player.get("fatigue_0521")) <= 10.0:
		_fail(21, "peso elevado não cobrou fôlego/cansaço")
		return

	# Guarda-roupas do mundo precisam alimentar o novo sistema.
	var clothing_before := _clothing_count(player)
	for i in range(20):
		scene.call("_grant_contextual_loot_0514", "loot_wardrobe", "smoke_wardrobe_%02d" % i, null, player)
	var clothing_after := _clothing_count(player)
	if clothing_after <= clothing_before:
		_fail(22, "loot de guarda-roupa não entregou nenhuma peça")
		return

	# Persistência de slots + versão do save.
	var saved_equipment := player.call("get_equipment_snapshot_0533") as Dictionary
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0533, FileAccess.READ)
	if file == null:
		_fail(23, "save 0.5.33 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(24, "save 0.5.33 inválido")
		return
	if str((parsed as Dictionary).get("version", "")) != "0.5.33-alpha":
		_fail(25, "save não foi marcado como 0.5.33")
		return
	var player_state := (parsed as Dictionary).get("player", {}) as Dictionary
	if not (player_state.get("equipment_0533", {}) is Dictionary):
		_fail(26, "slots corporais não foram serializados")
		return

	scene.queue_free()
	for _i in range(12):
		await process_frame
	var restored := packed.instantiate()
	root.add_child(restored)
	for _i in range(96):
		await process_frame
	var restored_player := get_first_node_in_group("player")
	if restored_player == null or not restored_player.has_method("get_equipment_snapshot_0533"):
		_fail(27, "player restaurado perdeu sistema corporal")
		return
	var restored_equipment := restored_player.call("get_equipment_snapshot_0533") as Dictionary
	for slot in ["head", "torso", "hands", "legs", "feet", "back"]:
		if str(restored_equipment.get(slot, "")) != str(saved_equipment.get(slot, "")):
			_fail(28, "slot %s não persistiu" % slot)
			return

	print("SMOKE 0.5.33 OK: slots=6 bite=%.0f cut=%.0f rain=%.0f weight=%.1f blocked=%.1f loot=%d persistent=true" % [float(protective_stats.get("bite", 0.0)), float(protective_stats.get("cut", 0.0)), float(protective_stats.get("rain", 0.0)), float(protective_stats.get("weight", 0.0)), float(equip_debug.get("blocked_damage", 0.0)), clothing_after - clothing_before])
	if FileAccess.file_exists(SAVE_PATH_0533):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0533))
	quit(0)
