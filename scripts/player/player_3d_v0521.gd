extends "res://scripts/player/player_3d_v0520.gd"

const FATIGUE_BASE_RATE_0521 := 0.090
const FATIGUE_RUN_RATE_0521 := 0.045
const NORMAL_BODY_TEMP_0521 := 36.9
const ENVIRONMENT_POLL_SECONDS_0521 := 0.20

var fatigue_0521 := 8.0
var body_temperature_0521 := NORMAL_BODY_TEMP_0521
var sheltered_0521 := false
var effective_ambient_temperature_0521 := 18.0
var last_sleep_minutes_0521 := 0
var environment_poll_timer_0521 := 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_fatigue_0521(delta)
	_update_temperature_0521(delta)

func _update_fatigue_0521(delta: float) -> void:
	var gain := FATIGUE_BASE_RATE_0521
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if horizontal_speed > 6.15:
		gain += FATIGUE_RUN_RATE_0521
	if pain_0519 >= 45.0:
		gain += 0.020
	if infection_0520 >= 55.0:
		gain += 0.024
	fatigue_0521 = minf(100.0, fatigue_0521 + gain * delta)

	# O cansaço não substitui o fôlego: ele reduz o teto de recuperação disponível.
	if fatigue_0521 >= 70.0:
		var stamina_cap := maxf(52.0, 100.0 - (fatigue_0521 - 70.0) * 1.60)
		stamina = minf(stamina, stamina_cap)
	if fatigue_0521 >= 92.0:
		pain_0519 = minf(100.0, pain_0519 + 0.045 * delta)

func _update_temperature_0521(delta: float) -> void:
	environment_poll_timer_0521 = maxf(0.0, environment_poll_timer_0521 - delta)
	if environment_poll_timer_0521 <= 0.0 and world != null and world.has_method("get_environment_state_0521"):
		var raw: Variant = world.call("get_environment_state_0521", global_position)
		if raw is Dictionary:
			var env := raw as Dictionary
			sheltered_0521 = bool(env.get("sheltered", false))
			effective_ambient_temperature_0521 = float(env.get("effective_temperature", 18.0))
		environment_poll_timer_0521 = ENVIRONMENT_POLL_SECONDS_0521

	var target := NORMAL_BODY_TEMP_0521
	if effective_ambient_temperature_0521 < 10.0:
		target = 34.9 if not sheltered_0521 else 36.15
	elif effective_ambient_temperature_0521 < 15.0:
		target = 35.55 if not sheltered_0521 else 36.45
	elif effective_ambient_temperature_0521 < 18.0:
		target = 36.25 if not sheltered_0521 else 36.70
	elif effective_ambient_temperature_0521 > 30.0:
		target = 38.15 if not sheltered_0521 else 37.35
	elif effective_ambient_temperature_0521 > 26.0:
		target = 37.55 if not sheltered_0521 else 37.10

	# 0.5.33: roupa equipada pode puxar o alvo térmico de frio para perto do normal.
	# O hook é opcional para preservar todas as versões anteriores do Player.
	if effective_ambient_temperature_0521 < 18.0 and has_method("get_cold_insulation_0533"):
		var insulation := clampf(float(call("get_cold_insulation_0533")), 0.0, 0.78)
		target = lerpf(target, NORMAL_BODY_TEMP_0521, insulation)

	var response_rate := 0.010 if sheltered_0521 else 0.016
	body_temperature_0521 = move_toward(body_temperature_0521, target, response_rate * delta)

	if body_temperature_0521 < 35.4:
		stamina = maxf(0.0, stamina - 0.70 * delta)
	if body_temperature_0521 < 34.6:
		health = maxf(0.0, health - 0.40 * delta)
	if body_temperature_0521 > 38.3:
		thirst = maxf(0.0, thirst - 0.45 * delta)
	if body_temperature_0521 > 39.0:
		health = maxf(0.0, health - 0.34 * delta)
	if health <= 0.0:
		_respawn()

func sleep_0521(minutes_to_sleep: int, shelter_quality: float = 1.0) -> bool:
	if minutes_to_sleep <= 0:
		return false
	var minutes := clampi(minutes_to_sleep, 30, 720)
	last_sleep_minutes_0521 = minutes
	var recovery_factor := clampf(float(minutes) / 480.0, 0.05, 1.5)
	fatigue_0521 = maxf(0.0, fatigue_0521 - 92.0 * recovery_factor)
	stamina = minf(100.0, stamina + 74.0 * recovery_factor)
	pain_0519 = maxf(0.0, pain_0519 - 16.0 * recovery_factor)
	# Dormir faz o relógio andar; fome e sede também precisam sentir esse tempo pulado.
	hunger = maxf(0.0, hunger - float(minutes) * 0.018)
	thirst = maxf(0.0, thirst - float(minutes) * 0.026)
	if shelter_quality >= 0.75:
		body_temperature_0521 = move_toward(body_temperature_0521, NORMAL_BODY_TEMP_0521, 1.35 * recovery_factor)
	environment_poll_timer_0521 = 0.0
	return true

func get_vitals() -> Dictionary:
	var result := super.get_vitals()
	result["fatigue"] = fatigue_0521
	result["body_temperature"] = body_temperature_0521
	result["sheltered"] = sheltered_0521
	result["ambient_temperature"] = effective_ambient_temperature_0521
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["fatigue_0521"] = fatigue_0521
	state["body_temperature_0521"] = body_temperature_0521
	state["last_sleep_minutes_0521"] = last_sleep_minutes_0521
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	fatigue_0521 = float(state.get("fatigue_0521", 8.0))
	body_temperature_0521 = float(state.get("body_temperature_0521", NORMAL_BODY_TEMP_0521))
	last_sleep_minutes_0521 = int(state.get("last_sleep_minutes_0521", 0))
	environment_poll_timer_0521 = 0.0

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	fatigue_0521 = 8.0
	body_temperature_0521 = NORMAL_BODY_TEMP_0521
	sheltered_0521 = false
	effective_ambient_temperature_0521 = 18.0
	last_sleep_minutes_0521 = 0
	environment_poll_timer_0521 = 0.0

func _respawn() -> void:
	super._respawn()
	fatigue_0521 = 38.0
	body_temperature_0521 = 36.7
	sheltered_0521 = false
	environment_poll_timer_0521 = 0.0

func get_survival_debug_0521() -> Dictionary:
	return {
		"fatigue": fatigue_0521,
		"body_temperature": body_temperature_0521,
		"sheltered": sheltered_0521,
		"effective_ambient": effective_ambient_temperature_0521,
		"last_sleep_minutes": last_sleep_minutes_0521,
		"stamina": stamina
	}
