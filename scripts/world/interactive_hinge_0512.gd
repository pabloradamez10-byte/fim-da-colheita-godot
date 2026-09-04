extends Node3D

@export var interaction_kind: String = "door"
@export var open_angle_degrees: float = 92.0
@export var transition_seconds: float = 0.16
var is_open: bool = false
var _busy: bool = false

func _ready() -> void:
	add_to_group("interactive_hinge_0512")
	add_to_group("interactive_door_0512" if interaction_kind == "door" else "interactive_window_0512")

func toggle_interaction() -> void:
	if _busy:
		return
	_busy = true
	is_open = not is_open
	var panel := get_node_or_null("Panel") as StaticBody3D
	if panel != null:
		var collision := panel.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision != null:
			collision.set_deferred("disabled", is_open)
	var target := deg_to_rad(open_angle_degrees) if is_open else 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation:y", target, transition_seconds)
	await tween.finished
	_busy = false

func get_interaction_state() -> Dictionary:
	return {"kind": interaction_kind, "open": is_open, "angle": rotation.y}
