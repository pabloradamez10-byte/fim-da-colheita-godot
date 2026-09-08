extends "res://scripts/entities/zombie_3d_v0527.gd"

const BARRICADE_RETALIATION_0528 := 4.0

func _physics_process(delta: float) -> void:
	var was_ready: bool = structure_attack_timer_0527 <= 0.0
	super._physics_process(delta)
	if not was_ready or structure_attack_timer_0527 <= 0.0:
		return
	# Se o ataque estrutural acabou de entrar em cooldown e a colisão era uma barricada,
	# o zumbi sofre dano dos espigões. Isso cria defesa passiva sem tornar a peça invencível.
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		if collision == null:
			continue
		var collider: Object = collision.get_collider()
		if not (collider is Node):
			continue
		var structure: Node3D = _find_structure_root_0527(collider as Node)
		if structure == null:
			continue
		if str(structure.get_meta("build_type_0526", "")) != "barricade":
			continue
		take_damage(BARRICADE_RETALIATION_0528 + float(variant) * 0.45)
		return

func get_ai_debug_0528() -> Dictionary:
	var result: Dictionary = get_ai_debug_0527()
	result["barricade_retaliation_0528"] = BARRICADE_RETALIATION_0528 + float(variant) * 0.45
	return result
