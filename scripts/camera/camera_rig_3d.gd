class_name CameraRig3D
extends Camera3D

@export var follow_offset := Vector3(18.0, 22.0, 18.0)
@export var look_height := 1.0
@export var orthographic_size := 24.0

var target: Node3D = null

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = orthographic_size
	near = 0.1
	far = 500.0
	make_current()

func _process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node3D
	if target == null:
		return
	global_position = target.global_position + follow_offset
	look_at(target.global_position + Vector3(0.0, look_height, 0.0), Vector3.UP)
	if not is_current():
		make_current()
