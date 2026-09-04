class_name MobileControls
extends Control

@export var joystick_radius: float = 92.0
@export var joystick_deadzone: float = 0.12

var joystick_center := Vector2.ZERO
var joystick_knob := Vector2.ZERO
var joystick_touch_id: int = -1
var move_vector := Vector2.ZERO
var attack_requested := false
var interact_requested := false

@onready var attack_button: Button = $AttackButton
@onready var interact_button: Button = $InteractButton
@onready var sprint_button: Button = $SprintButton

func _ready() -> void:
	add_to_group("mobile_controls")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	attack_button.pressed.connect(_on_attack_pressed)
	interact_button.pressed.connect(_on_interact_pressed)
	get_viewport().size_changed.connect(_refresh_layout)
	_refresh_layout()
	queue_redraw()

func _refresh_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	joystick_center = Vector2(150.0, viewport_size.y - 150.0)
	if joystick_touch_id == -1:
		joystick_knob = joystick_center
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if joystick_touch_id == -1 and touch.position.distance_to(joystick_center) <= joystick_radius * 1.7:
				joystick_touch_id = touch.index
				_update_joystick(touch.position)
		else:
			if touch.index == joystick_touch_id:
				joystick_touch_id = -1
				move_vector = Vector2.ZERO
				joystick_knob = joystick_center
				queue_redraw()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == joystick_touch_id:
			_update_joystick(drag.position)

func _update_joystick(touch_position: Vector2) -> void:
	var offset := touch_position - joystick_center
	var normalized_distance := minf(offset.length() / joystick_radius, 1.0)
	var direction := offset.normalized() if offset.length() > 0.001 else Vector2.ZERO
	joystick_knob = joystick_center + direction * joystick_radius * normalized_distance
	move_vector = direction * normalized_distance
	if move_vector.length() < joystick_deadzone:
		move_vector = Vector2.ZERO
	queue_redraw()

func get_move_vector() -> Vector2:
	return move_vector

func is_sprinting() -> bool:
	return sprint_button.button_pressed

func consume_attack() -> bool:
	if not attack_requested:
		return false
	attack_requested = false
	return true

func consume_interact() -> bool:
	if not interact_requested:
		return false
	interact_requested = false
	return true

func _on_attack_pressed() -> void:
	attack_requested = true

func _on_interact_pressed() -> void:
	interact_requested = true

func _draw() -> void:
	draw_circle(joystick_center, joystick_radius, Color(0.04, 0.05, 0.04, 0.36))
	draw_arc(joystick_center, joystick_radius, 0.0, TAU, 48, Color(0.88, 0.91, 0.86, 0.30), 3.0)
	draw_circle(joystick_knob, 36.0, Color(0.91, 0.78, 0.55, 0.52))
