extends "res://scripts/camera/camera_rig_3d.gd"

const FLUIDITY_VERSION_0601 := "0.6.1-alpha"
const MAX_PLAYER_SPEED_0601 := 7.85

@export var lead_smoothing_0601 := 7.5

var smoothed_lead_0601 := Vector3.ZERO

func _ready() -> void:
	super._ready()
	add_to_group("camera_fluidity_0601")

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node3D
	if target == null:
		return

	var desired_lead := Vector3.ZERO
	if target is CharacterBody3D:
		var body := target as CharacterBody3D
		var horizontal := Vector3(body.velocity.x, 0.0, body.velocity.z)
		desired_lead = horizontal.limit_length(MAX_PLAYER_SPEED_0601) * (look_ahead / MAX_PLAYER_SPEED_0601)

	var lead_weight := 1.0 - exp(-lead_smoothing_0601 * maxf(delta, 0.0))
	smoothed_lead_0601 = smoothed_lead_0601.lerp(desired_lead, lead_weight)
	var desired_target := target.global_position + smoothed_lead_0601
	if not initialized:
		smoothed_target = desired_target
		initialized = true
	else:
		var follow_weight := 1.0 - exp(-follow_smoothing * maxf(delta, 0.0))
		smoothed_target = smoothed_target.lerp(desired_target, follow_weight)

	global_position = smoothed_target + follow_offset
	look_at(smoothed_target + Vector3(0.0, look_height, 0.0), Vector3.UP)
	if not is_current():
		make_current()

func get_camera_fluidity_debug_0601() -> Dictionary:
	return {
		"version": FLUIDITY_VERSION_0601,
		"lead_smoothing": lead_smoothing_0601,
		"smoothed_lead": smoothed_lead_0601,
		"initialized": initialized
	}
