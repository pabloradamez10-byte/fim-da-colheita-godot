extends "res://scripts/entities/zombie_3d_v066.gd"

const PERFORMANCE_VERSION_067 := "0.6.7-alpha"
const FULL_AI_DISTANCE_067 := 18.0
const REDUCED_AI_DISTANCE_067 := 32.0
const SLEEP_DISTANCE_067 := 46.0
const VISUAL_CULL_DISTANCE_067 := 62.0
const REDUCED_INTERVAL_067 := 0.085
const ALERT_FAR_INTERVAL_067 := 0.18
const SLEEP_CHECK_INTERVAL_067 := 0.55

var performance_player_067: Node3D = null
var performance_accumulator_067 := 0.0
var performance_tier_067 := "full"
var performance_full_ticks_067 := 0
var performance_reduced_ticks_067 := 0
var performance_sleep_ticks_067 := 0
var performance_skipped_ticks_067 := 0

func _ready() -> void:
	super._ready()
	add_to_group("zombie_performance_067")
	set_meta("performance_version", PERFORMANCE_VERSION_067)

func _physics_process(delta: float) -> void:
	if performance_player_067 == null or not is_instance_valid(performance_player_067):
		performance_player_067 = get_tree().get_first_node_in_group("player") as Node3D
	if performance_player_067 == null:
		super._physics_process(delta)
		return

	var planar_delta := performance_player_067.global_position - global_position
	planar_delta.y = 0.0
	var distance := planar_delta.length()
	_update_visual_cull_067(distance)
	performance_accumulator_067 += delta

	if distance <= FULL_AI_DISTANCE_067:
		performance_tier_067 = "full"
		var elapsed := performance_accumulator_067
		performance_accumulator_067 = 0.0
		performance_full_ticks_067 += 1
		super._physics_process(maxf(delta, elapsed))
		return

	if distance <= REDUCED_AI_DISTANCE_067:
		performance_tier_067 = "reduced"
		if performance_accumulator_067 >= REDUCED_INTERVAL_067:
			var elapsed := performance_accumulator_067
			performance_accumulator_067 = 0.0
			performance_reduced_ticks_067 += 1
			super._physics_process(elapsed)
		else:
			performance_skipped_ticks_067 += 1
			_cheap_motion_067(delta)
		return

	var alert_active := alert_state_0519 in ["chase", "investigate"]
	if distance <= SLEEP_DISTANCE_067 and alert_active:
		performance_tier_067 = "far_alert"
		if performance_accumulator_067 >= ALERT_FAR_INTERVAL_067:
			var elapsed := performance_accumulator_067
			performance_accumulator_067 = 0.0
			performance_reduced_ticks_067 += 1
			super._physics_process(elapsed)
		else:
			performance_skipped_ticks_067 += 1
			_cheap_motion_067(delta)
		return

	performance_tier_067 = "sleep"
	velocity = Vector3.ZERO
	if performance_accumulator_067 >= SLEEP_CHECK_INTERVAL_067:
		var elapsed := performance_accumulator_067
		performance_accumulator_067 = 0.0
		performance_sleep_ticks_067 += 1
		# Mantém timers/memória avançando sem rodar física, raycasts ou colisões.
		attack_cooldown = maxf(0.0, attack_cooldown - elapsed)
		memory_timer_0519 = maxf(0.0, memory_timer_0519 - elapsed)
		sense_timer_0519 = maxf(0.0, sense_timer_0519 - elapsed)
		wander_timer_0519 = maxf(0.0, wander_timer_0519 - elapsed)
		hinge_attack_timer_0537 = maxf(0.0, hinge_attack_timer_0537 - elapsed)
	else:
		performance_skipped_ticks_067 += 1

func _cheap_motion_067(delta: float) -> void:
	# Fora da zona de combate imediato evitamos move_and_slide/raycasts em todo frame.
	var planar := Vector3(velocity.x, 0.0, velocity.z)
	if planar.length_squared() > 0.0001:
		global_position += planar * delta
	global_position.y = GROUND_Y_0519

func _update_visual_cull_067(distance: float) -> void:
	if sprite_0537 != null and is_instance_valid(sprite_0537):
		sprite_0537.visible = distance <= VISUAL_CULL_DISTANCE_067

func get_performance_tier_067() -> String:
	return performance_tier_067

func get_performance_debug_067() -> Dictionary:
	return {
		"version": PERFORMANCE_VERSION_067,
		"tier": performance_tier_067,
		"full_distance": FULL_AI_DISTANCE_067,
		"reduced_distance": REDUCED_AI_DISTANCE_067,
		"sleep_distance": SLEEP_DISTANCE_067,
		"visual_cull_distance": VISUAL_CULL_DISTANCE_067,
		"full_ticks": performance_full_ticks_067,
		"reduced_ticks": performance_reduced_ticks_067,
		"sleep_ticks": performance_sleep_ticks_067,
		"skipped_ticks": performance_skipped_ticks_067,
		"sprite_visible": sprite_0537 == null or sprite_0537.visible
	}
