extends Node3D

@export var interaction_kind: String = "door"
@export var open_angle_degrees: float = 92.0
@export var transition_seconds: float = 0.16
var is_open: bool = false
var _busy: bool = false
var _transition_serial: int = 0

func _ready() -> void:
	add_to_group("interactive_hinge_0512")
	add_to_group("interactive_door_0512" if interaction_kind == "door" else "interactive_window_0512")
	_tune_collision_0513()

func _find_panel() -> StaticBody3D:
	for child in get_children():
		if child is StaticBody3D:
			return child as StaticBody3D
	return null

func _find_collision(panel: StaticBody3D) -> CollisionShape3D:
	if panel == null:
		return null
	for child in panel.get_children():
		if child is CollisionShape3D:
			return child as CollisionShape3D
	return null

func _tune_collision_0513() -> void:
	var panel := _find_panel()
	var collision := _find_collision(panel)
	if collision == null or not (collision.shape is BoxShape3D):
		return
	var box := collision.shape as BoxShape3D
	if interaction_kind == "door":
		# Visual continua largo, mas o collider é menor para não agarrar o player no batente.
		box.size = Vector3(minf(box.size.x, 0.84), box.size.y, minf(box.size.z, 0.09))
		panel.add_to_group("door_clearance_0513")
	else:
		box.size.z = minf(box.size.z, 0.055)

func toggle_interaction() -> void:
	if _busy:
		return
	_busy = true
	_transition_serial += 1
	var serial := _transition_serial
	is_open = not is_open
	var collision := _panel_collision()
	# Ao abrir, libera a passagem antes da animação. Ao fechar, só rearma depois.
	if collision != null:
		collision.set_deferred("disabled", true)
	var target := deg_to_rad(open_angle_degrees) if is_open else 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation:y", target, transition_seconds)
	await tween.finished
	_busy = false
	if not is_open:
		_restore_collision_when_clear_0513(serial)

func _panel_collision() -> CollisionShape3D:
	return _find_collision(_find_panel())

func _restore_collision_when_clear_0513(serial: int) -> void:
	var collision := _panel_collision()
	if collision == null:
		return
	# Nunca ligamos o collider em cima do jogador. A porta pode fechar visualmente e
	# rearma a física assim que o vão estiver livre, eliminando o efeito de prender.
	while serial == _transition_serial and not is_open:
		var player := get_tree().get_first_node_in_group("player") as Node3D
		if player == null or not is_instance_valid(player) or player.global_position.distance_to(global_position) > 1.05:
			collision.set_deferred("disabled", false)
			return
		await get_tree().process_frame

func get_interaction_state() -> Dictionary:
	var collision := _panel_collision()
	return {
		"kind": interaction_kind,
		"open": is_open,
		"angle": rotation.y,
		"collision_disabled": collision.disabled if collision != null else true,
		"has_collision": collision != null
	}
