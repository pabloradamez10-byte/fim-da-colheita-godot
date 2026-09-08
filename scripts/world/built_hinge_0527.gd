class_name BuiltHinge0527
extends Node3D

@export var interaction_kind := "door"
@export var open_angle_degrees := 92.0
var is_open := false
var _busy := false

func _ready() -> void:
	add_to_group("built_hinge_0527")
	add_to_group("built_%s_0527" % interaction_kind)
	_apply_state_0527(false)

func toggle_interaction() -> void:
	if _busy:
		return
	_busy = true
	is_open = not is_open
	var collision := _find_collision_0527()
	if collision != null:
		collision.set_deferred("disabled", true)
	var target := deg_to_rad(open_angle_degrees) if is_open else 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation:y", target, 0.16)
	await tween.finished
	if not is_open and collision != null:
		collision.set_deferred("disabled", false)
	_busy = false

func set_open_state_0527(value: bool, animate: bool = false) -> void:
	is_open = value
	_apply_state_0527(animate)

func _apply_state_0527(animate: bool) -> void:
	var target := deg_to_rad(open_angle_degrees) if is_open else 0.0
	if animate:
		var tween := create_tween()
		tween.tween_property(self, "rotation:y", target, 0.12)
	else:
		rotation.y = target
	var collision := _find_collision_0527()
	if collision != null:
		collision.set_deferred("disabled", is_open)

func _find_collision_0527() -> CollisionShape3D:
	for child: Node in get_children():
		if child is StaticBody3D:
			for sub: Node in child.get_children():
				if sub is CollisionShape3D:
					return sub as CollisionShape3D
	return null

func get_open_state_0527() -> bool:
	return is_open
