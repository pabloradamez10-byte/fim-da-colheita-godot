extends CharacterBody3D

const ARROW_SPEED_065 := 19.5
const ARROW_LIFETIME_065 := 1.35

var source_player_065: Node = null
var travel_direction_065 := Vector3.FORWARD
var base_damage_065 := 58.0
var lifetime_065 := ARROW_LIFETIME_065

func setup_065(source_player: Node, direction: Vector3, damage: float, max_range: float) -> void:
	source_player_065 = source_player
	travel_direction_065 = direction.normalized()
	base_damage_065 = maxf(1.0, damage)
	lifetime_065 = maxf(0.25, max_range / ARROW_SPEED_065 + 0.15)
	if source_player is PhysicsBody3D:
		add_collision_exception_with(source_player as PhysicsBody3D)

func _ready() -> void:
	name = "ArrowProjectile065"
	add_to_group("arrow_projectile_065")
	collision_layer = 0
	collision_mask = 1
	_build_visual_065()
	_build_collision_065()
	if travel_direction_065.length() > 0.01:
		look_at(global_position + travel_direction_065, Vector3.UP)

func _physics_process(delta: float) -> void:
	lifetime_065 -= delta
	if lifetime_065 <= 0.0:
		queue_free()
		return
	var collision := move_and_collide(travel_direction_065 * ARROW_SPEED_065 * delta)
	if collision == null:
		return
	var collider: Object = collision.get_collider()
	if source_player_065 != null and is_instance_valid(source_player_065) and source_player_065.has_method("register_arrow_hit_065"):
		source_player_065.call("register_arrow_hit_065", collider, base_damage_065)
	queue_free()

func _build_collision_065() -> void:
	var shape := SphereShape3D.new()
	shape.radius = 0.075
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)

func _build_visual_065() -> void:
	var shaft_mesh := BoxMesh.new()
	shaft_mesh.size = Vector3(0.035, 0.035, 0.82)
	var shaft_mat := StandardMaterial3D.new()
	shaft_mat.albedo_color = Color("765338")
	shaft_mat.roughness = 0.9
	shaft_mesh.material = shaft_mat
	var shaft := MeshInstance3D.new()
	shaft.mesh = shaft_mesh
	add_child(shaft)

	var tip_mesh := BoxMesh.new()
	tip_mesh.size = Vector3(0.075, 0.055, 0.13)
	var tip_mat := StandardMaterial3D.new()
	tip_mat.albedo_color = Color("b9b9b2")
	tip_mat.roughness = 0.72
	tip_mesh.material = tip_mat
	var tip := MeshInstance3D.new()
	tip.mesh = tip_mesh
	tip.position = Vector3(0.0, 0.0, -0.46)
	add_child(tip)
