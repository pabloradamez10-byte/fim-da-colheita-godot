extends "res://scripts/ui/mobile_controls_v05404.gd"

const FLUIDITY_VERSION_0601 := "0.6.1-alpha"

@export var input_response_0601 := 18.0
@export var input_release_response_0601 := 24.0

var smoothed_move_vector_0601 := Vector2.ZERO

func _ready() -> void:
	super._ready()
	joystick_deadzone = 0.10
	add_to_group("mobile_fluidity_0601")
	smoothed_move_vector_0601 = move_vector
	set_process(true)

func _process(delta: float) -> void:
	var response := input_response_0601
	if move_vector.length_squared() < smoothed_move_vector_0601.length_squared():
		response = input_release_response_0601
	var weight := 1.0 - exp(-response * maxf(delta, 0.0))
	smoothed_move_vector_0601 = smoothed_move_vector_0601.lerp(move_vector, weight)
	if move_vector.is_zero_approx() and smoothed_move_vector_0601.length_squared() < 0.000064:
		smoothed_move_vector_0601 = Vector2.ZERO

func get_move_vector() -> Vector2:
	return smoothed_move_vector_0601

func get_mobile_fluidity_debug_0601() -> Dictionary:
	return {
		"version": FLUIDITY_VERSION_0601,
		"raw_vector": move_vector,
		"smoothed_vector": smoothed_move_vector_0601,
		"deadzone": joystick_deadzone,
		"input_response": input_response_0601,
		"release_response": input_release_response_0601
	}
