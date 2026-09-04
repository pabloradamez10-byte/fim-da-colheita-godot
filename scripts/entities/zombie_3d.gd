class_name Zombie3D
extends CharacterBody3D

var health := 70.0
var player: Node3D = null
var attack_cooldown := 0.0
var visual_root: Node3D
var gait_time := 0.0
var variant := 0

const SPEED := 2.25
const DETECTION := 18.0
const ATTACK_RANGE := 1.55

func _ready() -> void:
	add_to_group("zombies")
	variant = int(abs(hash(name))) % 4
	_build_collision()
	_build_visual()

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var distance := global_position.distance_to(player.global_position)
	if distance > DETECTION:
		velocity = Vector3.ZERO
		return
	var dir := global_position.direction_to(player.global_position)
	dir.y = 0.0
	if distance > ATTACK_RANGE:
		velocity = dir.normalized() * SPEED
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), minf(1.0, delta * 7.0))
		move_and_slide()
		gait_time += delta * 7.0
		if visual_root != null:
			visual_root.position.y = abs(sin(gait_time)) * 0.05
	else:
		velocity = Vector3.ZERO
		if attack_cooldown <= 0.0 and player.has_method("take_damage"):
			player.call("take_damage", 8.0 + float(variant))
			attack_cooldown = 1.15

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		queue_free()
	else:
		var tween := create_tween()
		tween.tween_property(visual_root, "scale", Vector3(1.08,0.92,1.08), 0.06)
		tween.tween_property(visual_root, "scale", Vector3.ONE, 0.1)

func _build_collision() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.7
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.82
	add_child(collision)

func _build_visual() -> void:
	visual_root = Node3D.new()
	add_child(visual_root)
	var shirt_colors := ["58654d","4b5547","665b4e","3e4d48"]
	var pants_colors := ["3d403c","2f3532","4a443d","34393a"]
	var skin_colors := ["79836a","68745f","858873","6e765f"]
	_box(Vector3(0.72,0.88,0.40), Vector3(0,1.3,0), _mat(shirt_colors[variant]))
	_box(Vector3(0.28,0.82,0.28), Vector3(-0.20,0.52,0.03), _mat(pants_colors[variant]))
	_box(Vector3(0.28,0.82,0.28), Vector3(0.20,0.52,-0.04), _mat(pants_colors[variant]))
	var left_arm := _box(Vector3(0.22,0.85,0.22), Vector3(-0.48,1.3,-0.18), _mat(skin_colors[variant]))
	left_arm.rotation_degrees.x = -18.0
	var right_arm := _box(Vector3(0.22,0.85,0.22), Vector3(0.48,1.3,-0.12), _mat(skin_colors[variant]))
	right_arm.rotation_degrees.x = -26.0
	_sphere(0.34, Vector3(0,2.0,0), _mat(skin_colors[variant]), Vector3(0.92,1.0,0.9))
	# Feridas/roupa rasgada visualmente simples, mas tridimensionais.
	_box(Vector3(0.30,0.06,0.05), Vector3(0.12,1.5,0.23), _mat("641919"))
	if variant % 2 == 0:
		_box(Vector3(0.72,0.08,0.72), Vector3(0,2.28,0), _mat("2d2c27"))

func _mat(hex: String) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(hex)
	mat.roughness = 1.0
	return mat

func _box(size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	visual_root.add_child(node)
	return node

func _sphere(radius: float, pos: Vector3, mat: Material, scale_value: Vector3) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.scale = scale_value
	visual_root.add_child(node)
	return node
