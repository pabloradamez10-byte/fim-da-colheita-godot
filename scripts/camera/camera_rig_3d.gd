class_name CameraRig3D
extends Camera3D

@export var follow_offset := Vector3(17.0, 21.0, 17.0)
@export var look_height := 1.05
@export var orthographic_size := 22.2
@export var follow_smoothing := 10.5
@export var look_ahead := 1.25

var target: Node3D = null
var smoothed_target := Vector3.ZERO
var initialized := false

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = orthographic_size
	near = 0.1
	far = 500.0
	make_current()

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node3D
	if target == null:
		return
	var lead := Vector3.ZERO
	if target is CharacterBody3D:
		var body := target as CharacterBody3D
		var horizontal := Vector3(body.velocity.x, 0.0, body.velocity.z)
		if horizontal.length() > 0.2:
			lead = horizontal.normalized() * look_ahead
	var desired_target := target.global_position + lead
	if not initialized:
		smoothed_target = desired_target
		initialized = true
	else:
		var weight := 1.0 - exp(-follow_smoothing * delta)
		smoothed_target = smoothed_target.lerp(desired_target, weight)
	global_position = smoothed_target + follow_offset
	look_at(smoothed_target + Vector3(0.0, look_height, 0.0), Vector3.UP)
	if not is_current():
		make_current()
