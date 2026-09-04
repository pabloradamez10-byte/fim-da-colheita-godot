extends "res://scripts/player/player_3d_v054.gd"

const WALK_SPEED_058 := 5.15
const RUN_SPEED_058 := 7.85
const ACCEL_058 := 30.0
const DECEL_058 := 38.0
const ROTATE_SPEED_058 := 15.0

var torso_pivot: Node3D
var head_pivot: Node3D
var left_arm_pivot: Node3D
var right_arm_pivot: Node3D
var left_leg_pivot: Node3D
var right_leg_pivot: Node3D
var backpack_pivot: Node3D
var gait_phase: float = 0.0
var movement_amount: float = 0.0
var last_move_dir := Vector3(0, 0, -1)
var attack_pose: float = 0.0

func _build_visual() -> void:
	visual_root = Node3D.new()
	visual_root.name = "CharacterVisual"
	add_child(visual_root)

	torso_pivot = Node3D.new()
	torso_pivot.name = "TorsoPivot"
	torso_pivot.position = Vector3(0, 1.42, 0)
	visual_root.add_child(torso_pivot)
	_box_to(torso_pivot, Vector3(0.72, 0.88, 0.38), Vector3.ZERO, _material("33463b"))
	_box_to(torso_pivot, Vector3(0.76, 0.12, 0.40), Vector3(0, 0.40, -0.01), _material("43594a"))

	head_pivot = Node3D.new()
	head_pivot.name = "HeadPivot"
	head_pivot.position = Vector3(0, 2.08, -0.02)
	visual_root.add_child(head_pivot)
	_sphere_to(head_pivot, 0.34, Vector3.ZERO, _material("b88b67"), Vector3(0.90, 1.0, 0.88))
	_box_to(head_pivot, Vector3(0.62, 0.12, 0.62), Vector3(0, 0.30, 0.02), _material("28231f"))

	left_leg_pivot = _limb_pivot("LeftLegPivot", Vector3(-0.22, 0.96, 0), visual_root)
	right_leg_pivot = _limb_pivot("RightLegPivot", Vector3(0.22, 0.96, 0), visual_root)
	_box_to(left_leg_pivot, Vector3(0.28, 0.86, 0.30), Vector3(0, -0.42, 0), _material("252d29"))
	_box_to(right_leg_pivot, Vector3(0.28, 0.86, 0.30), Vector3(0, -0.42, 0), _material("252d29"))
	_box_to(left_leg_pivot, Vector3(0.30, 0.18, 0.48), Vector3(0, -0.82, -0.08), _material("322a24"))
	_box_to(right_leg_pivot, Vector3(0.30, 0.18, 0.48), Vector3(0, -0.82, -0.08), _material("322a24"))

	left_arm_pivot = _limb_pivot("LeftArmPivot", Vector3(-0.49, 1.73, -0.02), visual_root)
	right_arm_pivot = _limb_pivot("RightArmPivot", Vector3(0.49, 1.73, -0.02), visual_root)
	_box_to(left_arm_pivot, Vector3(0.23, 0.80, 0.23), Vector3(0, -0.38, 0), _material("33463b"))
	_box_to(right_arm_pivot, Vector3(0.23, 0.80, 0.23), Vector3(0, -0.38, 0), _material("33463b"))
	_sphere_to(left_arm_pivot, 0.14, Vector3(0, -0.80, 0), _material("b88b67"), Vector3.ONE)
	_sphere_to(right_arm_pivot, 0.14, Vector3(0, -0.80, 0), _material("b88b67"), Vector3.ONE)

	backpack_pivot = Node3D.new()
	backpack_pivot.name = "BackpackPivot"
	backpack_pivot.position = Vector3(0, 1.44, 0.33)
	visual_root.add_child(backpack_pivot)
	_box_to(backpack_pivot, Vector3(0.66, 0.82, 0.28), Vector3.ZERO, _material("554735"))
	_box_to(backpack_pivot, Vector3(0.54, 0.10, 0.32), Vector3(0, 0.34, 0.17), _material("6b5a42"))

	weapon_anchor = Node3D.new()
	weapon_anchor.name = "RightHandWeaponAnchor"
	weapon_anchor.position = Vector3(0.02, -0.77, -0.10)
	right_arm_pivot.add_child(weapon_anchor)
	_refresh_weapon_visual()

func _limb_pivot(node_name: String, pos: Vector3, parent: Node3D) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = pos
	parent.add_child(pivot)
	return pivot

func _sphere_to(parent: Node3D, radius: float, pos: Vector3, mat: Material, scale_value: Vector3) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 5
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.scale = scale_value
	parent.add_child(node)
	return node

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	attack_pose = maxf(0.0, attack_pose - delta)
	_update_needs(delta)
	if mobile_controls == null or not is_instance_valid(mobile_controls):
		mobile_controls = get_tree().get_first_node_in_group("mobile_controls")

	var input_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): input_vec.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): input_vec.y += 1.0
	if mobile_controls != null and mobile_controls.has_method("get_move_vector"):
		var mv: Variant = mobile_controls.call("get_move_vector")
		if mv is Vector2 and (mv as Vector2).length() > 0.01:
			input_vec = mv as Vector2

	var input_strength: float = clampf(input_vec.length(), 0.0, 1.0)
	var sprint: bool = Input.is_key_pressed(KEY_SHIFT)
	if mobile_controls != null and mobile_controls.has_method("is_sprinting"):
		sprint = sprint or bool(mobile_controls.call("is_sprinting"))
	var running: bool = sprint and input_strength > 0.15 and stamina > 2.0
	if running:
		stamina = maxf(0.0, stamina - 17.0 * delta)
	else:
		stamina = minf(100.0, stamina + 12.5 * delta)

	var dir := Vector3(input_vec.x + input_vec.y, 0.0, -input_vec.x + input_vec.y)
	if dir.length() > 0.01:
		dir = dir.normalized()
		last_move_dir = dir
		var target_yaw: float = atan2(dir.x, dir.z) + PI
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(delta * ROTATE_SPEED_058, 0.0, 1.0))

	var base_speed: float = RUN_SPEED_058 if running else WALK_SPEED_058
	var analog_speed: float = base_speed * input_strength
	var desired: Vector3 = dir * analog_speed
	var accel: float = ACCEL_058 if input_strength > 0.02 else DECEL_058
	velocity.x = move_toward(velocity.x, desired.x, accel * delta)
	velocity.z = move_toward(velocity.z, desired.z, accel * delta)
	velocity.y = 0.0
	move_and_slide()

	movement_amount = Vector2(velocity.x, velocity.z).length() / RUN_SPEED_058
	_update_character_animation(delta, running)

	var attack: bool = Input.is_key_pressed(KEY_SPACE)
	if mobile_controls != null and mobile_controls.has_method("consume_attack"):
		attack = attack or bool(mobile_controls.call("consume_attack"))
	if mobile_controls != null and mobile_controls.has_method("is_attack_held"):
		attack = attack or bool(mobile_controls.call("is_attack_held"))
	if attack:
		_attack()

	var interact: bool = Input.is_key_pressed(KEY_E)
	if mobile_controls != null and mobile_controls.has_method("consume_interact"):
		interact = interact or bool(mobile_controls.call("consume_interact"))
	if interact and world != null and world.has_method("try_interact_near"):
		world.call("try_interact_near", global_position, self)

	var cycle: bool = Input.is_key_pressed(KEY_Q)
	if mobile_controls != null and mobile_controls.has_method("consume_cycle_weapon"):
		cycle = cycle or bool(mobile_controls.call("consume_cycle_weapon"))
	if cycle:
		cycle_weapon()

func _update_character_animation(delta: float, running: bool) -> void:
	if visual_root == null or left_leg_pivot == null:
		return
	var moving: bool = movement_amount > 0.035
	if moving:
		gait_phase += delta * lerpf(7.5, 12.5, clampf(movement_amount, 0.0, 1.0))
	var blend: float = clampf(movement_amount * 1.35, 0.0, 1.0)
	var leg_amp: float = 42.0 if running else 30.0
	var arm_amp: float = 25.0 if running else 18.0
	var wave: float = sin(gait_phase)
	var opposite: float = sin(gait_phase + PI)
	var target_left_leg: float = wave * leg_amp * blend
	var target_right_leg: float = opposite * leg_amp * blend
	var firearm: bool = get_equipped_weapon() in ["pistol", "shotgun"]
	var target_left_arm: float = opposite * arm_amp * blend
	var target_right_arm: float = wave * arm_amp * blend
	if firearm:
		target_left_arm = -32.0 + wave * 4.0 * blend
		target_right_arm = -34.0 + opposite * 3.0 * blend
	elif attack_pose > 0.0:
		target_right_arm = -65.0
		target_left_arm *= 0.35

	left_leg_pivot.rotation_degrees.x = lerpf(left_leg_pivot.rotation_degrees.x, target_left_leg, clampf(delta * 16.0, 0.0, 1.0))
	right_leg_pivot.rotation_degrees.x = lerpf(right_leg_pivot.rotation_degrees.x, target_right_leg, clampf(delta * 16.0, 0.0, 1.0))
	left_arm_pivot.rotation_degrees.x = lerpf(left_arm_pivot.rotation_degrees.x, target_left_arm, clampf(delta * 14.0, 0.0, 1.0))
	right_arm_pivot.rotation_degrees.x = lerpf(right_arm_pivot.rotation_degrees.x, target_right_arm, clampf(delta * 14.0, 0.0, 1.0))

	var bob: float = absf(sin(gait_phase * 2.0)) * (0.055 if running else 0.038) * blend
	visual_root.position.y = lerpf(visual_root.position.y, bob, clampf(delta * 18.0, 0.0, 1.0))
	var torso_roll: float = sin(gait_phase) * (2.8 if running else 1.6) * blend
	torso_pivot.rotation_degrees.z = lerpf(torso_pivot.rotation_degrees.z, torso_roll, clampf(delta * 12.0, 0.0, 1.0))
	head_pivot.rotation_degrees.z = lerpf(head_pivot.rotation_degrees.z, -torso_roll * 0.45, clampf(delta * 10.0, 0.0, 1.0))
	backpack_pivot.rotation_degrees.x = lerpf(backpack_pivot.rotation_degrees.x, sin(gait_phase * 2.0) * 2.0 * blend, clampf(delta * 8.0, 0.0, 1.0))

	if not moving:
		visual_root.position.y = lerpf(visual_root.position.y, 0.0, clampf(delta * 10.0, 0.0, 1.0))
		left_leg_pivot.rotation_degrees.x = lerpf(left_leg_pivot.rotation_degrees.x, 0.0, clampf(delta * 9.0, 0.0, 1.0))
		right_leg_pivot.rotation_degrees.x = lerpf(right_leg_pivot.rotation_degrees.x, 0.0, clampf(delta * 9.0, 0.0, 1.0))

func _attack() -> void:
	if attack_cooldown > 0.0:
		return
	_face_soft_target()
	super._attack()

func _face_soft_target() -> void:
	if world == null or not world.has_method("get_zombies"):
		return
	var weapon: String = get_equipped_weapon()
	var max_range: float = 4.2
	if weapon == "pistol": max_range = 20.0
	elif weapon == "shotgun": max_range = 13.0
	var nearest: Node3D = null
	var best: float = max_range
	for raw in world.call("get_zombies"):
		if raw is Node3D:
			var zombie := raw as Node3D
			var d: float = global_position.distance_to(zombie.global_position)
			if d < best:
				best = d
				nearest = zombie
	if nearest != null:
		var delta_pos: Vector3 = nearest.global_position - global_position
		delta_pos.y = 0.0
		if delta_pos.length() > 0.01:
			var target_yaw: float = atan2(delta_pos.x, delta_pos.z) + PI
			rotation.y = lerp_angle(rotation.y, target_yaw, 0.82)

func _animate_weapon_swing() -> void:
	attack_pose = 0.30
	if right_arm_pivot == null or torso_pivot == null:
		super._animate_weapon_swing()
		return
	var arm_start: Vector3 = right_arm_pivot.rotation_degrees
	var torso_start: Vector3 = torso_pivot.rotation_degrees
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(right_arm_pivot, "rotation_degrees:x", -88.0, 0.08)
	tween.tween_property(right_arm_pivot, "rotation_degrees:z", -24.0, 0.08)
	tween.tween_property(torso_pivot, "rotation_degrees:y", -18.0, 0.08)
	await tween.finished
	var recover := create_tween()
	recover.set_parallel(true)
	recover.tween_property(right_arm_pivot, "rotation_degrees", arm_start, 0.18)
	recover.tween_property(torso_pivot, "rotation_degrees", torso_start, 0.18)

func get_motion_debug() -> Dictionary:
	return {
		"speed": Vector2(velocity.x, velocity.z).length(),
		"movement_amount": movement_amount,
		"articulated": left_leg_pivot != null and right_arm_pivot != null,
		"weapon_anchor_parent": weapon_anchor.get_parent().name if weapon_anchor != null else ""
	}
