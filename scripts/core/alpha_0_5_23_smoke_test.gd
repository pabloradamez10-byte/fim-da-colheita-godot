extends SceneTree

const SAVE_PATH_0523 := "user://fim_da_colheita_alpha_0_5_2.save.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	printerr("SMOKE 0.5.23 FAIL: %s" % message)
	quit(code)

func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH_0523):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH_0523))

	var packed := load("res://scenes/main_3d.tscn") as PackedScene
	if packed == null:
		_fail(1, "cena principal não carregou")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	for _i in range(54):
		await process_frame

	var player := get_first_node_in_group("player")
	if player == null or not player.has_method("get_equipment_debug_0523"):
		_fail(2, "PlayerV0523 não foi instanciado")
		return
	if get_nodes_in_group("hotbar_slot_0523").size() != 6:
		_fail(3, "hotbar não criou seis slots")
		return

	var initial_dur := float(player.call("get_weapon_durability_0523", "machete"))
	if initial_dur < 99.0:
		_fail(4, "facão não iniciou com durabilidade cheia")
		return

	# Um golpe realmente executado precisa desgastar a arma.
	player.set("attack_cooldown", 0.0)
	player.set("stamina", 100.0)
	player.call("_attack")
	var worn_dur := float(player.call("get_weapon_durability_0523", "machete"))
	if worn_dur >= initial_dur:
		_fail(5, "ataque não consumiu durabilidade")
		return

	# Arma quebrada não deve iniciar novo ataque.
	var durability_map := player.get("weapon_durability_0523") as Dictionary
	durability_map["machete"] = 0.0
	player.set("weapon_durability_0523", durability_map)
	player.set("attack_cooldown", 0.0)
	player.call("_attack")
	if float(player.get("attack_cooldown")) > 0.001:
		_fail(6, "arma quebrada ainda conseguiu atacar")
		return
	if not bool(player.call("is_weapon_broken_0523", "machete")):
		_fail(7, "arma em zero não foi marcada como quebrada")
		return

	# Reparo deve cobrar recursos e devolver funcionalidade.
	player.call("add_item", "stone", 3)
	player.call("add_item", "fiber", 3)
	var before_repair_inv := player.call("get_inventory_snapshot") as Dictionary
	if not bool(player.call("repair_weapon_0523", "machete")):
		_fail(8, "facão quebrado não pôde ser reparado")
		return
	var repaired_dur := float(player.call("get_weapon_durability_0523", "machete"))
	if repaired_dur <= 0.0:
		_fail(9, "reparo não recuperou durabilidade")
		return
	var after_repair_inv := player.call("get_inventory_snapshot") as Dictionary
	if int(after_repair_inv.get("stone", 0)) >= int(before_repair_inv.get("stone", 0)):
		_fail(10, "reparo não consumiu pedra")
		return

	# Craft antigo precisa continuar funcionando e inicializar durabilidade da nova ferramenta.
	player.call("add_item", "wood", 8)
	player.call("add_item", "stone", 6)
	player.call("add_item", "fiber", 5)
	if not bool(player.call("craft_recipe", "axe")):
		_fail(11, "craft de machadinha regrediu")
		return
	if not (player.call("get_owned_weapons") as Array).has("axe"):
		_fail(12, "machadinha criada não entrou no equipamento")
		return
	if float(player.call("get_weapon_durability_0523", "axe")) < 84.0:
		_fail(13, "arma criada não recebeu durabilidade cheia")
		return

	# Hotbar deve equipar armas e consumir itens sem abrir inventário.
	if not bool(player.call("hotbar_activate_0523", "axe")):
		_fail(14, "hotbar não equipou machadinha")
		return
	if str(player.call("get_equipped_weapon")) != "axe":
		_fail(15, "arma selecionada na hotbar não ficou ativa")
		return
	player.call("add_item", "water", 2)
	player.set("thirst", 40.0)
	var water_before := int((player.call("get_inventory_snapshot") as Dictionary).get("water", 0))
	if not bool(player.call("hotbar_activate_0523", "water")):
		_fail(16, "hotbar não usou água")
		return
	var water_after := int((player.call("get_inventory_snapshot") as Dictionary).get("water", 0))
	if water_after != water_before - 1 or float(player.get("thirst")) <= 40.0:
		_fail(17, "uso rápido de água não aplicou consumo/efeito")
		return

	var slots := player.call("get_hotbar_slots_0523") as Array
	if slots.is_empty() or slots.size() > 6:
		_fail(18, "conteúdo da hotbar inválido")
		return

	# Persistência da durabilidade deve entrar no save junto aos sistemas 0.5.20–0.5.22.
	scene.call("save_game")
	var file := FileAccess.open(SAVE_PATH_0523, FileAccess.READ)
	if file == null:
		_fail(19, "save 0.5.23 não foi gravado")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_fail(20, "save 0.5.23 inválido")
		return
	var payload := parsed as Dictionary
	if str(payload.get("version", "")) != "0.5.23-alpha":
		_fail(21, "versão do save não foi atualizada")
		return
	var player_state := payload.get("player", {}) as Dictionary
	var saved_dur := player_state.get("weapon_durability_0523", {}) as Dictionary
	if not saved_dur.has("machete") or not saved_dur.has("axe"):
		_fail(22, "durabilidade não foi persistida")
		return
	if not player_state.has("wetness_0522") or not player_state.has("fatigue_0521") or not player_state.has("infection_0520"):
		_fail(23, "sobrevivência anterior não foi preservada no save")
		return

	# Regressões sistêmicas: clima, casas, água, veículos e sono continuam presentes.
	if not scene.has_method("get_weather_state_0522"):
		_fail(24, "clima 0.5.22 regrediu")
		return
	scene.call("set_weather_override_0522", 2)
	var weather := scene.call("get_weather_state_0522") as Dictionary
	if str(weather.get("name", "")) != "CHUVA" or get_nodes_in_group("weather_rain_0522").is_empty():
		_fail(25, "chuva 0.5.22 não sobreviveu à 0.5.23")
		return
	if get_nodes_in_group("sleep_surface_0521").is_empty():
		_fail(26, "sono/camas 0.5.21 regrediram")
		return
	if get_nodes_in_group("water_blocker_0513").is_empty():
		_fail(27, "água bloqueada regrediu")
		return
	if get_nodes_in_group("internal_door_0514").is_empty():
		_fail(28, "portas internas regrediram")
		return
	if get_nodes_in_group("vehicle_sprite_0517").is_empty():
		_fail(29, "veículos regrediram")
		return

	print("SMOKE 0.5.23 OK: hotbar=%d machete=%.1f repaired=%.1f axe=%.1f slots=%d" % [get_nodes_in_group("hotbar_slot_0523").size(), worn_dur, repaired_dur, float(player.call("get_weapon_durability_0523", "axe")), slots.size()])
	quit(0)
