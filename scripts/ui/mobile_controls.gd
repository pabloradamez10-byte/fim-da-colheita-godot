class_name MobileControls
extends Control

@export var joystick_radius: float = 92.0
@export var joystick_deadzone: float = 0.12

var joystick_center := Vector2.ZERO
var joystick_knob := Vector2.ZERO
var joystick_touch_id: int = -1
var move_vector := Vector2.ZERO
var attack_requested := false
var attack_held := false
var interact_requested := false
var cycle_weapon_requested := false
var new_seed_requested := false

@onready var attack_button: Button = $AttackButton
@onready var interact_button: Button = $InteractButton
@onready var sprint_button: Button = $SprintButton
@onready var weapon_button: Button = $WeaponButton
@onready var new_seed_button: Button = $NewSeedButton

func _ready() -> void:
	add_to_group("mobile_controls")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	attack_button.pressed.connect(func(): attack_requested = true)
	attack_button.button_down.connect(func(): attack_held = true)
	attack_button.button_up.connect(func(): attack_held = false)
	interact_button.pressed.connect(func(): interact_requested = true)
	weapon_button.pressed.connect(func(): cycle_weapon_requested = true)
	new_seed_button.pressed.connect(func(): new_seed_requested = true)
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
			if joystick_touch_id == -1 and touch.position.distance_to(joystick_center) <= joystick_radius * 1.75:
				joystick_touch_id = touch.index
				_update_joystick(touch.position)
		elif touch.index == joystick_touch_id:
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
	var raw_distance := minf(offset.length() / joystick_radius, 1.0)
	var direction := offset.normalized() if offset.length() > 0.001 else Vector2.ZERO
	joystick_knob = joystick_center + direction * joystick_radius * raw_distance
	if raw_distance <= joystick_deadzone:
		move_vector = Vector2.ZERO
	else:
		# Remove o salto da deadzone e devolve uma curva analógica 0..1 contínua.
		var remapped := (raw_distance - joystick_deadzone) / maxf(0.001, 1.0 - joystick_deadzone)
		var eased := pow(clampf(remapped, 0.0, 1.0), 0.82)
		move_vector = direction * eased
	queue_redraw()

func get_move_vector() -> Vector2:
	return move_vector

func is_sprinting() -> bool:
	return sprint_button.button_pressed

func is_attack_held() -> bool:
	return attack_held

func consume_attack() -> bool:
	if not attack_requested: return false
	attack_requested = false
	return true

func consume_interact() -> bool:
	if not interact_requested: return false
	interact_requested = false
	return true

func consume_cycle_weapon() -> bool:
	if not cycle_weapon_requested: return false
	cycle_weapon_requested = false
	return true

func consume_new_seed() -> bool:
	if not new_seed_requested: return false
	new_seed_requested = false
	return true

func _draw() -> void:
	draw_circle(joystick_center, joystick_radius, Color(0.035, 0.045, 0.035, 0.46))
	draw_arc(joystick_center, joystick_radius, 0.0, TAU, 48, Color(0.90, 0.90, 0.84, 0.34), 3.0)
	draw_circle(joystick_knob, 36.0, Color(0.70, 0.57, 0.31, 0.72))
