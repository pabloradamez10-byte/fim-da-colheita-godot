extends "res://scripts/player/player_3d_v0521.gd"

const WETNESS_RAIN_RATE_0522 := 2.15
const WETNESS_FOG_RATE_0522 := 0.06
const WETNESS_SHELTER_DRY_RATE_0522 := 1.65
const WETNESS_CLEAR_DRY_RATE_0522 := 0.42

var wetness_0522 := 0.0
var weather_name_0522 := "ABERTO"
var precipitation_0522 := 0.0
var weather_exposure_timer_0522 := 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_weather_exposure_0522(delta)

func _update_weather_exposure_0522(delta: float) -> void:
	weather_exposure_timer_0522 = maxf(0.0, weather_exposure_timer_0522 - delta)
	var raining := false
	var foggy := false
	if weather_exposure_timer_0522 <= 0.0 and world != null and world.has_method("get_weather_state_0522"):
		var raw: Variant = world.call("get_weather_state_0522")
		if raw is Dictionary:
			var state := raw as Dictionary
			weather_name_0522 = str(state.get("name", "ABERTO"))
			precipitation_0522 = float(state.get("precipitation", 0.0))
		weather_exposure_timer_0522 = 0.25

	raining = precipitation_0522 > 0.10
	foggy = weather_name_0522 == "NEBLINA"
	if sheltered_0521:
		wetness_0522 = maxf(0.0, wetness_0522 - WETNESS_SHELTER_DRY_RATE_0522 * delta)
	elif raining:
		wetness_0522 = minf(100.0, wetness_0522 + WETNESS_RAIN_RATE_0522 * precipitation_0522 * delta)
	elif foggy:
		wetness_0522 = minf(100.0, wetness_0522 + WETNESS_FOG_RATE_0522 * delta)
	else:
		wetness_0522 = maxf(0.0, wetness_0522 - WETNESS_CLEAR_DRY_RATE_0522 * delta)

	# Estar molhado torna o frio relevante e cobra mais do corpo mesmo antes da hipotermia.
	if wetness_0522 >= 40.0:
		fatigue_0521 = minf(100.0, fatigue_0521 + 0.012 * delta * (wetness_0522 / 40.0))
	if wetness_0522 >= 62.0:
		stamina = maxf(0.0, stamina - 0.18 * delta)
	if wetness_0522 >= 78.0 and effective_ambient_temperature_0521 < 18.0:
		body_temperature_0521 = maxf(33.0, body_temperature_0521 - 0.0065 * delta * (wetness_0522 / 78.0))

func sleep_0521(minutes_to_sleep: int, shelter_quality: float = 1.0) -> bool:
	var slept := super.sleep_0521(minutes_to_sleep, shelter_quality)
	if slept and shelter_quality >= 0.75:
		var recovery := clampf(float(minutes_to_sleep) / 240.0, 0.25, 2.5)
		wetness_0522 = maxf(0.0, wetness_0522 - 42.0 * recovery)
	return slept

func get_vitals() -> Dictionary:
	var result := super.get_vitals()
	result["wetness"] = wetness_0522
	result["weather"] = weather_name_0522
	return result

func export_save_state() -> Dictionary:
	var state := super.export_save_state()
	state["wetness_0522"] = wetness_0522
	return state

func import_save_state(state: Dictionary) -> void:
	super.import_save_state(state)
	wetness_0522 = float(state.get("wetness_0522", 0.0))
	weather_exposure_timer_0522 = 0.0

func reset_for_new_world() -> void:
	super.reset_for_new_world()
	wetness_0522 = 0.0
	weather_name_0522 = "ABERTO"
	precipitation_0522 = 0.0
	weather_exposure_timer_0522 = 0.0

func _respawn() -> void:
	super._respawn()
	wetness_0522 = minf(wetness_0522, 35.0)
	weather_exposure_timer_0522 = 0.0

func get_survival_debug_0522() -> Dictionary:
	return {
		"wetness": wetness_0522,
		"weather": weather_name_0522,
		"precipitation": precipitation_0522,
		"sheltered": sheltered_0521,
		"body_temperature": body_temperature_0521,
		"fatigue": fatigue_0521
	}
