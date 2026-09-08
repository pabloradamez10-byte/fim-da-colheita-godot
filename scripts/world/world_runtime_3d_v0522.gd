extends "res://scripts/world/world_runtime_3d_v0521.gd"

const PlayerV0522Script = preload("res://scripts/player/player_3d_v0522.gd")
const ZombieV0522Script = preload("res://scripts/entities/zombie_3d_v0522.gd")
const SAVE_VERSION_0522 := "0.5.22-alpha"
const WEATHER_CLEAR_0522 := 0
const WEATHER_OVERCAST_0522 := 1
const WEATHER_RAIN_0522 := 2
const WEATHER_FOG_0522 := 3
const WEATHER_SLOT_MINUTES_0522 := 180.0

var current_weather_0522 := WEATHER_CLEAR_0522
var current_weather_slot_0522 := -999999
var weather_override_0522 := -1
var rain_particles_0522: GPUParticles3D = null

func _ready() -> void:
	super._ready()
	_build_weather_visuals_0522()
	_update_weather_state_0522(true)
	_apply_time_visuals_0521()

func _process(delta: float) -> void:
	super._process(delta)
	_update_weather_state_0522(false)
	_update_rain_follow_0522()

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0522Script.new()
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
		var zombie: CharacterBody3D = ZombieV0522Script.new()
		zombie.name = zombie_name
		zombie.position = spawn_pos
		actors_root.add_child(zombie)

func save_game() -> void:
	if player == null:
		return
	var payload := {
		"version": SAVE_VERSION_0522,
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

func _weather_slot_key_0522() -> int:
	return world_day_0521 * 8 + int(floor(world_minutes_0521 / WEATHER_SLOT_MINUTES_0522))

func _resolved_weather_type_0522() -> int:
	if weather_override_0522 >= 0:
		return clampi(weather_override_0522, WEATHER_CLEAR_0522, WEATHER_FOG_0522)
	var slot := int(floor(world_minutes_0521 / WEATHER_SLOT_MINUTES_0522))
	var marker := int(abs(hash("weather0522:%d:%d:%d" % [world_seed, world_day_0521, slot])))
	var roll := marker % 100
	var hour := world_minutes_0521 / 60.0
	# Neblina é mais provável na madrugada/manhã; chuva é deliberadamente comum para
	# que o sistema de abrigo e umidade apareça durante sessões curtas no celular.
	if hour >= 4.5 and hour < 9.0 and roll < 24:
		return WEATHER_FOG_0522
	if roll < 29:
		return WEATHER_RAIN_0522
	if roll < 54:
		return WEATHER_OVERCAST_0522
	if roll < 64:
		return WEATHER_FOG_0522
	return WEATHER_CLEAR_0522

func _update_weather_state_0522(force: bool) -> void:
	var slot_key := _weather_slot_key_0522()
	var resolved := _resolved_weather_type_0522()
	if not force and slot_key == current_weather_slot_0522 and resolved == current_weather_0522:
		return
	current_weather_slot_0522 = slot_key
	current_weather_0522 = resolved
	_apply_weather_visuals_0522()

func set_weather_override_0522(weather_type: int) -> void:
	weather_override_0522 = clampi(weather_type, WEATHER_CLEAR_0522, WEATHER_FOG_0522)
	_update_weather_state_0522(true)
	_apply_time_visuals_0521()

func clear_weather_override_0522() -> void:
	weather_override_0522 = -1
	current_weather_slot_0522 = -999999
	_update_weather_state_0522(true)
	_apply_time_visuals_0521()

func get_weather_state_0522() -> Dictionary:
	var weather := _resolved_weather_type_0522()
	return {
		"type": weather,
		"name": _weather_name_0522(weather),
		"precipitation": 1.0 if weather == WEATHER_RAIN_0522 else 0.0,
		"fog": weather == WEATHER_FOG_0522,
		"overcast": weather == WEATHER_OVERCAST_0522,
		"slot": _weather_slot_key_0522()
	}

func _weather_name_0522(weather: int) -> String:
	match weather:
		WEATHER_OVERCAST_0522:
			return "NUBLADO"
		WEATHER_RAIN_0522:
			return "CHUVA"
		WEATHER_FOG_0522:
			return "NEBLINA"
		_:
			return "ABERTO"

func _ambient_temperature_0521() -> float:
	var base_temp := super._ambient_temperature_0521()
	match _resolved_weather_type_0522():
		WEATHER_RAIN_0522:
			return base_temp - 3.2
		WEATHER_OVERCAST_0522:
			return base_temp - 1.5
		WEATHER_FOG_0522:
			return base_temp - 2.1
		_:
			return base_temp

func get_environment_state_0521(pos: Vector3) -> Dictionary:
	var sheltered := _is_position_sheltered_0521(pos)
	var ambient := _ambient_temperature_0521()
	var effective := lerpf(ambient, 19.0, 0.72) if sheltered else ambient
	return {
		"sheltered": sheltered,
		"ambient_temperature": ambient,
		"effective_temperature": effective,
		"night": is_night_0521(),
		"day": world_day_0521,
		"minutes": world_minutes_0521,
		"weather": _weather_name_0522(_resolved_weather_type_0522()),
		"precipitation": 1.0 if _resolved_weather_type_0522() == WEATHER_RAIN_0522 else 0.0
	}

func get_zombie_weather_modifiers_0522() -> Dictionary:
	match _resolved_weather_type_0522():
		WEATHER_RAIN_0522:
			# Chuva prejudica visão e mascara passos/disparos à distância.
			return {"vision": 0.78, "hearing": 0.68}
		WEATHER_FOG_0522:
			return {"vision": 0.52, "hearing": 0.90}
		WEATHER_OVERCAST_0522:
			return {"vision": 0.92, "hearing": 1.0}
		_:
			return {"vision": 1.0, "hearing": 1.0}

func _apply_time_visuals_0521() -> void:
	_update_weather_state_0522(false)
	super._apply_time_visuals_0521()
	_apply_weather_visuals_0522()

func _apply_weather_visuals_0522() -> void:
	if environment_0521 != null:
		environment_0521.fog_enabled = current_weather_0522 == WEATHER_FOG_0522 or current_weather_0522 == WEATHER_RAIN_0522
		environment_0521.fog_density = 0.038 if current_weather_0522 == WEATHER_FOG_0522 else (0.010 if current_weather_0522 == WEATHER_RAIN_0522 else 0.0)
		environment_0521.fog_light_color = Color("a9b2b3") if current_weather_0522 == WEATHER_FOG_0522 else Color("8998a4")
		if current_weather_0522 == WEATHER_OVERCAST_0522:
			environment_0521.ambient_light_energy *= 0.78
			environment_0521.background_color = environment_0521.background_color.darkened(0.18)
		elif current_weather_0522 == WEATHER_RAIN_0522:
			environment_0521.ambient_light_energy *= 0.66
			environment_0521.background_color = environment_0521.background_color.darkened(0.28)
		elif current_weather_0522 == WEATHER_FOG_0522:
			environment_0521.ambient_light_energy *= 0.82
			environment_0521.background_color = environment_0521.background_color.lerp(Color("727b79"), 0.34)
	if sun_0521 != null:
		if current_weather_0522 == WEATHER_OVERCAST_0522:
			sun_0521.light_energy *= 0.58
		elif current_weather_0522 == WEATHER_RAIN_0522:
			sun_0521.light_energy *= 0.38
		elif current_weather_0522 == WEATHER_FOG_0522:
			sun_0521.light_energy *= 0.48
	_update_rain_follow_0522()

func _build_weather_visuals_0522() -> void:
	if rain_particles_0522 != null:
		return
	rain_particles_0522 = GPUParticles3D.new()
	rain_particles_0522.name = "RainParticles0522"
	rain_particles_0522.amount = 520
	rain_particles_0522.lifetime = 1.25
	rain_particles_0522.randomness = 0.32
	rain_particles_0522.visibility_aabb = AABB(Vector3(-18.0, -13.0, -18.0), Vector3(36.0, 28.0, 36.0))
	rain_particles_0522.add_to_group("weather_rain_0522")
	add_child(rain_particles_0522)

	var process_mat := ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = Vector3(13.5, 0.6, 13.5)
	process_mat.direction = Vector3(0.08, -1.0, 0.03)
	process_mat.spread = 4.0
	process_mat.gravity = Vector3(0.0, -28.0, 0.0)
	process_mat.initial_velocity_min = 17.0
	process_mat.initial_velocity_max = 24.0
	rain_particles_0522.process_material = process_mat

	var quad := QuadMesh.new()
	quad.size = Vector2(0.035, 0.86)
	var rain_mat := StandardMaterial3D.new()
	rain_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rain_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_mat.albedo_color = Color(0.64, 0.76, 0.88, 0.62)
	rain_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = rain_mat
	rain_particles_0522.draw_pass_1 = quad
	_update_rain_follow_0522()

func _update_rain_follow_0522() -> void:
	if rain_particles_0522 == null:
		return
	var sheltered := player != null and _is_position_sheltered_0521(player.global_position)
	var should_emit := current_weather_0522 == WEATHER_RAIN_0522 and not sheltered
	rain_particles_0522.emitting = should_emit
	rain_particles_0522.visible = should_emit
	if player != null and is_instance_valid(player):
		rain_particles_0522.global_position = player.global_position + Vector3(0.0, 10.5, 0.0)

func new_seed() -> void:
	weather_override_0522 = -1
	current_weather_slot_0522 = -999999
	super.new_seed()
	_update_weather_state_0522(true)

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	var weather := get_weather_state_0522()
	result["weather_0522"] = str(weather.get("name", "ABERTO"))
	result["precipitation_0522"] = float(weather.get("precipitation", 0.0))
	if player != null and player.has_method("get_vitals"):
		var vitals := player.call("get_vitals") as Dictionary
		result["wetness_0522"] = float(vitals.get("wetness", 0.0))
	return result

func get_weather_debug_0522() -> Dictionary:
	return {
		"weather": _weather_name_0522(current_weather_0522),
		"type": current_weather_0522,
		"slot": current_weather_slot_0522,
		"rain_particles": rain_particles_0522 != null,
		"rain_emitting": rain_particles_0522 != null and rain_particles_0522.emitting,
		"modifiers": get_zombie_weather_modifiers_0522(),
		"player_0522": player != null and player.get_script() == PlayerV0522Script
	}
