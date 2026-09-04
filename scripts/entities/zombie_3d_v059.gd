extends "res://scripts/entities/zombie_3d.gd"

const GROUND_Y_059 := 0.20

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Os zumbis herdavam spawn em Y=0.75 sem gravidade e pareciam flutuar.
	global_position.y = GROUND_Y_059
	if visual_root != null:
		visual_root.position.y = 0.0

func get_ground_debug() -> Dictionary:
	return {"ground_y": global_position.y, "visual_y": visual_root.position.y if visual_root != null else 999.0}
