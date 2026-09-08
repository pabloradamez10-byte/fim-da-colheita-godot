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
var vehicle_mode_0530 := false

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
	joystick_radius = clampf(viewport_size.y * 0.125, 72.0, 92.0)
	var joystick_margin := clampf(viewport_size.y * 0.075, 42.0, 56.0)
	joystick_center = Vector2(joystick_radius + joystick_margin, viewport_size.y - joystick_radius - joystick_margin)
	if joystick_touch_id == -1:
		joystick_knob = joystick_center

	var edge := 18.0
	var attack_size := Vector2(116.0, 112.0)
	var small_size := Vector2(116.0, 64.0)
	var action_size := Vector2(136.0, 64.0)
	attack_button.size = attack_size
	weapon_button.size = small_size
	interact_button.size = action_size
	sprint_button.size = Vector2(122.0, 64.0)
	new_seed_button.size = Vector2(126.0, 46.0)

	var attack_pos := Vector2(viewport_size.x - edge - attack_size.x, viewport_size.y - edge - attack_size.y)
	attack_button.position = attack_pos
	weapon_button.position = Vector2(attack_pos.x, attack_pos.y - 12.0 - small_size.y)
	var middle_x := attack_pos.x - 14.0 - action_size.x
	interact_button.position = Vector2(middle_x, viewport_size.y - edge - action_size.y)
	sprint_button.position = Vector2(middle_x + 7.0, interact_button.position.y - 12.0 - 64.0)
	new_seed_button.position = Vector2(viewport_size.x - edge - 126.0, 14.0)
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
		var remapped := (raw_distance - joystick_deadzone) / maxf(0.001, 1.0 - joystick_deadzone)
		var eased := pow(clampf(remapped, 0.0, 1.0), 0.82)
		move_vector = direction * eased
	queue_redraw()

func get_move_vector() -> Vector2:
	return move_vector

func is_sprinting() -> bool:
	return false if vehicle_mode_0530 else sprint_button.button_pressed

func is_attack_held() -> bool:
	return false if vehicle_mode_0530 else attack_held

func consume_attack() -> bool:
	if vehicle_mode_0530:
		attack_requested = false
		attack_held = false
		return false
	if not attack_requested:
		return false
	attack_requested = false
	return true

func consume_interact() -> bool:
	if not interact_requested:
		return false
	interact_requested = false
	return true

func consume_cycle_weapon() -> bool:
	if vehicle_mode_0530:
		cycle_weapon_requested = false
		return false
	if not cycle_weapon_requested:
		return false
	cycle_weapon_requested = false
	return true

func consume_new_seed() -> bool:
	if not new_seed_requested:
		return false
	new_seed_requested = false
	return true

func set_vehicle_mode_0530(enabled: bool) -> void:
	vehicle_mode_0530 = enabled
	attack_requested = false
	attack_held = false
	cycle_weapon_requested = false
	attack_button.visible = not enabled
	weapon_button.visible = not enabled
	sprint_button.visible = not enabled
	sprint_button.button_pressed = false
	interact_button.text = "SAIR" if enabled else "INTERAGIR"

func is_vehicle_mode_0530() -> bool:
	return vehicle_mode_0530

func _draw() -> void:
	draw_circle(joystick_center, joystick_radius, Color(0.035, 0.045, 0.035, 0.46))
	draw_arc(joystick_center, joystick_radius, 0.0, TAU, 48, Color(0.90, 0.90, 0.84, 0.34), 3.0)
	draw_circle(joystick_knob, minf(36.0, joystick_radius * 0.42), Color(0.70, 0.57, 0.31, 0.72))

func get_layout_debug_05321() -> Dictionary:
	return {
		"viewport": get_viewport().get_visible_rect().size,
		"joystick_center": joystick_center,
		"joystick_radius": joystick_radius,
		"attack_rect": Rect2(attack_button.position, attack_button.size),
		"interact_rect": Rect2(interact_button.position, interact_button.size),
		"sprint_rect": Rect2(sprint_button.position, sprint_button.size),
		"weapon_rect": Rect2(weapon_button.position, weapon_button.size),
		"seed_rect": Rect2(new_seed_button.position, new_seed_button.size)
	}
