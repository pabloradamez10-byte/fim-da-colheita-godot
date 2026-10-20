extends "res://scripts/ui/mobile_controls_v0601.gd"

func _ready() -> void:
	super._ready()
	joystick_deadzone = 0.08
	add_to_group("survival_controls_068")

func get_move_vector() -> Vector2:
	return move_vector.limit_length(1.0)

func _process(_delta: float) -> void:
	# The parent visual/debug contract stays current without filtering input twice.
	smoothed_move_vector_0601 = move_vector

func _update_joystick(touch_position: Vector2) -> void:
	var offset := touch_position - joystick_center
	var distance := minf(offset.length() / maxf(joystick_radius, 1.0), 1.0)
	var direction := offset.normalized() if offset.length_squared() > 0.000001 else Vector2.ZERO
	joystick_knob = joystick_center + direction * joystick_radius * distance
	var strength := clampf((distance - joystick_deadzone) / (1.0 - joystick_deadzone), 0.0, 1.0)
	move_vector = direction * strength
	queue_redraw()

func reset_motion_068() -> void:
	joystick_touch_id = -1
	move_vector = Vector2.ZERO
	smoothed_move_vector_0601 = Vector2.ZERO
	joystick_knob = joystick_center
	attack_held = false
	attack_requested = false
	interact_requested = false
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		reset_motion_068()
