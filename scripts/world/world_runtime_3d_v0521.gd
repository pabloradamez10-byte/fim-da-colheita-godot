extends "res://scripts/world/world_runtime_3d_v0520.gd"

const PlayerV0521Script = preload("res://scripts/player/player_3d_v0521.gd")
const ZombieV0521Script = preload("res://scripts/entities/zombie_3d_v0521.gd")
const SAVE_VERSION_0521 := "0.5.21-alpha"
const GAME_MINUTES_PER_REAL_SECOND_0521 := 1.0
const DAY_MINUTES_0521 := 1440.0
const BED_INTERACT_RANGE_0521 := 1.45

var world_day_0521 := 1
var world_minutes_0521 := 8.0 * 60.0
var visual_clock_accumulator_0521 := 0.0
var sun_0521: DirectionalLight3D = null
var fill_light_0521: DirectionalLight3D = null
var environment_0521: Environment = null

func _load_save() -> void:
	super._load_save()
	var world_state := save_cache.get("world", {}) as Dictionary
	world_day_0521 = maxi(1, int(world_state.get("world_day_0521", 1)))
	world_minutes_0521 = clampf(float(world_state.get("world_minutes_0521", 8.0 * 60.0)), 0.0, DAY_MINUTES_0521 - 0.01)

func _build_environment() -> void:
	super._build_environment()
	var directional_index := 0
	for child in get_children():
		if child is WorldEnvironment:
			var world_env := child as WorldEnvironment
			environment_0521 = world_env.environment
		elif child is DirectionalLight3D:
			if directional_index == 0:
				sun_0521 = child as DirectionalLight3D
			else:
				fill_light_0521 = child as DirectionalLight3D
			directional_index += 1
	_apply_time_visuals_0521()

func _process(delta: float) -> void:
	advance_time_0521(delta * GAME_MINUTES_PER_REAL_SECOND_0521, false)
	visual_clock_accumulator_0521 += delta
	if visual_clock_accumulator_0521 >= 0.20:
		visual_clock_accumulator_0521 = 0.0
		_apply_time_visuals_0521()

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0521Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func _spawn_zombies(count: int) -> void:
	for i in range(count):
		var zombie_name := "Zombie_%02d" % i
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(18.0, 52.0)
		var spawn_pos := Vector3(cos(angle) * radius, 0.20, sin(angle) * radius)
		if dead_zombies_0520.has(zombie_name):
			continue
		var zombie: CharacterBody3D = ZombieV0521Script.new()
		zombie.name = zombie_name
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0521,
		"world": {
			"seed": world_seed,
			"farm_layout": farm_layout,
			"harvested": harvested_keys.duplicate(),
			"dead_zombies_0520": dead_zombies_0520.duplicate(),
			"corpse_records_0520": corpse_records_0520.duplicate(true),
			"death_bags_0520": death_bags_0520.duplicate(true),
			"kills_0520": kills_0520,
			"deaths_0520": deaths_0520,
			"world_day_0521": world_day_0521,
			"world_minutes_0521": world_minutes_0521
		},
		"player": player.call("export_save_state")
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))

func advance_time_0521(minutes: float, refresh_visuals: bool = true) -> void:
	if minutes == 0.0:
		return
	world_minutes_0521 += minutes
	while world_minutes_0521 >= DAY_MINUTES_0521:
		world_minutes_0521 -= DAY_MINUTES_0521
		world_day_0521 += 1
	while world_minutes_0521 < 0.0:
		world_minutes_0521 += DAY_MINUTES_0521
		world_day_0521 = maxi(1, world_day_0521 - 1)
	if refresh_visuals:
		_apply_time_visuals_0521()

func set_time_0521(day: int, minute_of_day: float) -> void:
	world_day_0521 = maxi(1, day)
	world_minutes_0521 = clampf(minute_of_day, 0.0, DAY_MINUTES_0521 - 0.01)
	_apply_time_visuals_0521()

func is_night_0521() -> bool:
	var hour := world_minutes_0521 / 60.0
	return hour >= 19.5 or hour < 6.0

func get_time_state_0521() -> Dictionary:
	var total_minutes := int(floor(world_minutes_0521))
	var hour := int(total_minutes / 60)
	var minute := total_minutes % 60
	return {
		"day": world_day_0521,
		"minutes": world_minutes_0521,
		"hour": hour,
		"minute": minute,
		"formatted": "%02d:%02d" % [hour, minute],
		"night": is_night_0521(),
		"ambient_temperature": _ambient_temperature_0521()
	}

func _ambient_temperature_0521() -> float:
	var hour := world_minutes_0521 / 60.0
	return 16.0 + 8.0 * sin((hour - 8.0) / 24.0 * TAU)

func get_environment_state_0521(pos: Vector3) -> Dictionary:
	var sheltered := _is_position_sheltered_0521(pos)
	var ambient := _ambient_temperature_0521()
	var effective := lerpf(ambient, 19.0, 0.68) if sheltered else ambient
	return {
		"sheltered": sheltered,
		"ambient_temperature": ambient,
		"effective_temperature": effective,
		"night": is_night_0521(),
		"day": world_day_0521,
		"minutes": world_minutes_0521
	}

func _is_position_sheltered_0521(pos: Vector3) -> bool:
	for raw in get_tree().get_nodes_in_group("shelter_structure_0521"):
		if not (raw is Node3D):
			continue
		var structure := raw as Node3D
		if not is_instance_valid(structure):
			continue
		var local := structure.to_local(pos)
		var half_x := 7.55 if structure.is_in_group("large_house_0511") else 5.6
		var half_z := 6.45 if structure.is_in_group("large_house_0511") else 4.6
		if absf(local.x) <= half_x and absf(local.z) <= half_z and local.y < 4.6:
			return true
	return false

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	# Interações físicas visíveis (principalmente portas) têm prioridade sobre sono.
	# Isso evita que uma cama próxima atrás da parede/porta avance várias horas ao tocar INTERAGIR.
	var direct_index := _pick_special_interactable_0513(pos, target_player)
	if direct_index >= 0:
		if super.try_interact_near(pos, target_player):
			return true

	var bed_index := _nearest_bed_interaction_0521(pos)
	if bed_index >= 0:
		var sleep_minutes := _sleep_duration_0521(target_player)
		if target_player != null and target_player.has_method("sleep_0521"):
			var rested := bool(target_player.call("sleep_0521", sleep_minutes, 1.0))
			if rested:
				advance_time_0521(float(sleep_minutes), true)
				save_game()
				return true
	return super.try_interact_near(pos, target_player)

func _nearest_bed_interaction_0521(pos: Vector3) -> int:
	var nearest := -1
	var best := BED_INTERACT_RANGE_0521
	for i in range(interactables.size()):
		var data := interactables[i] as Dictionary
		if str(data.get("type", "")) != "sleep_bed_0521":
			continue
		var node_value: Variant = data.get("node")
		# Pode existir referência antiga de uma cama que já foi removida do chunk.
		# Validar a instância antes do operador `is` evita interromper toda a prioridade de interação.
		if node_value != null and typeof(node_value) == TYPE_OBJECT and not is_instance_valid(node_value):
			continue
		var target_pos := data.get("position", Vector3.ZERO) as Vector3
		var distance := Vector2(pos.x - target_pos.x, pos.z - target_pos.z).length()
		if distance < best:
			best = distance
			nearest = i
	return nearest

func _sleep_duration_0521(target_player: Node) -> int:
	var hour := world_minutes_0521 / 60.0
	if hour >= 18.5:
		return int((DAY_MINUTES_0521 - world_minutes_0521) + 6.5 * 60.0)
	if hour < 6.5:
		return int(6.5 * 60.0 - world_minutes_0521)
	var fatigue := 50.0
	if target_player != null:
		var raw_fatigue: Variant = target_player.get("fatigue_0521")
		if raw_fatigue is float or raw_fatigue is int:
			fatigue = float(raw_fatigue)
	return 300 if fatigue >= 70.0 else 180

func _apply_time_visuals_0521() -> void:
	var hour := world_minutes_0521 / 60.0
	var daylight := 0.0
	if hour >= 5.5 and hour <= 20.5:
		daylight = clampf(sin((hour - 5.5) / 15.0 * PI), 0.0, 1.0)
	var night_color := Color("101722")
	var day_color := Color("7f8972")
	if environment_0521 != null:
		environment_0521.background_color = night_color.lerp(day_color, daylight)
		environment_0521.ambient_light_color = Color("8093b4").lerp(Color("d8d0b8"), daylight)
		environment_0521.ambient_light_energy = lerpf(0.18, 0.66, daylight)
	if sun_0521 != null:
		sun_0521.light_energy = lerpf(0.08, 1.18, daylight)
		sun_0521.light_color = Color("9bb4df").lerp(Color("ffe8bd"), daylight)
		sun_0521.rotation_degrees = Vector3(lerpf(-16.0, -58.0, daylight), -120.0 + hour * 8.0, 0.0)
	if fill_light_0521 != null:
		fill_light_0521.light_energy = lerpf(0.09, 0.22, daylight)
		fill_light_0521.light_color = Color("7f96bd").lerp(Color("9fb2c0"), daylight)

func new_seed() -> void:
	world_day_0521 = 1
	world_minutes_0521 = 8.0 * 60.0
	super.new_seed()
	_apply_time_visuals_0521()

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var time_state := get_time_state_0521()
	result["day_0521"] = world_day_0521
	result["time_0521"] = str(time_state.get("formatted", "--:--"))
	result["night_0521"] = bool(time_state.get("night", false))
	result["ambient_temperature_0521"] = float(time_state.get("ambient_temperature", 18.0))
	result["sheltered_0521"] = player != null and _is_position_sheltered_0521(player.global_position)
	return result

func get_survival_loop_debug_0521() -> Dictionary:
	return {
		"day": world_day_0521,
		"minutes": world_minutes_0521,
		"night": is_night_0521(),
		"ambient_temperature": _ambient_temperature_0521(),
		"beds": get_tree().get_nodes_in_group("sleep_surface_0521").size(),
		"shelters": get_tree().get_nodes_in_group("shelter_structure_0521").size(),
		"player_0521": player != null and player.get_script() == PlayerV0521Script,
		"zombies_0521": get_tree().get_nodes_in_group("zombies").size(),
		"bed_interact_range_05321": BED_INTERACT_RANGE_0521
	}
