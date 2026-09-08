extends "res://scripts/entities/zombie_3d_v0522.gd"

const STRUCTURE_DAMAGE_0527 := 8.0
const STRUCTURE_ATTACK_COOLDOWN_0527 := 1.25
var structure_attack_timer_0527 := 0.0

func _physics_process(delta: float) -> void:
	structure_attack_timer_0527 = maxf(0.0, structure_attack_timer_0527 - delta)
	super._physics_process(delta)
	if structure_attack_timer_0527 > 0.0:
		return
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		if collision == null:
			continue
		var collider: Object = collision.get_collider()
		if not (collider is Node):
			continue
		var structure := _find_structure_root_0527(collider as Node)
		if structure == null:
			continue
		var uid: String = str(structure.get_meta("build_uid_0526", ""))
		if uid == "":
			continue
		if world_0519 == null or not is_instance_valid(world_0519):
			world_0519 = _resolve_world_0519()
		if world_0519 != null and world_0519.has_method("damage_structure_0527"):
			world_0519.call("damage_structure_0527", uid, STRUCTURE_DAMAGE_0527 + float(variant) * 1.5, "zombie")
			structure_attack_timer_0527 = STRUCTURE_ATTACK_COOLDOWN_0527
			_emit_noise_0519(8.5, "zombie_structure")
			return

func _find_structure_root_0527(node: Node) -> Node3D:
	var current: Node = node
	while current != null:
		if current is Node3D and current.is_in_group("build_structure_0526"):
			return current as Node3D
		current = current.get_parent()
	return null

func get_ai_debug_0527() -> Dictionary:
	var result: Dictionary = get_ai_debug_0522()
	result["structure_attack_ready_0527"] = structure_attack_timer_0527 <= 0.0
	return result
