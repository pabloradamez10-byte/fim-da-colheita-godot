extends "res://scripts/world/world_runtime_3d_v0537.gd"

# Correção final da 0.5.37: o runtime pai cria os registros de horda antes de a
# cadeia legada trocar a seed em new_seed(). Ao retornar, reconstruímos os pontos
# com a seed nova e reposicionamos os membros sem perder nenhum sistema anterior.
func new_seed() -> void:
	var previous_seed := world_seed
	super.new_seed()
	if world_seed == previous_seed:
		return

	horde_records_0537.clear()
	horde_migration_timer_0537 = 0.0
	_ensure_horde_records_0537()

	for raw: Node in get_tree().get_nodes_in_group("zombie_0537"):
		if not (raw is Node3D):
			continue
		var zombie := raw as Node3D
		var horde_id := int(zombie.get("horde_id_0537"))
		var member_index := int(zombie.get("horde_member_index_0537"))
		if horde_id < 0 or horde_id >= HORDE_COUNT_0537:
			continue
		var record: Dictionary = horde_records_0537.get(str(horde_id), {}) as Dictionary
		var center := _dict_to_vec_0537(record.get("spawn", {}) as Dictionary)
		var member_angle := float(member_index * 2 + horde_id) * 1.31
		var member_radius := 1.8 + float(member_index % 3) * 1.25
		zombie.global_position = center + Vector3(cos(member_angle) * member_radius, 0.20, sin(member_angle) * member_radius)
		zombie.global_position.y = 0.20

	save_game()

func get_zombie_ecology_debug_0537() -> Dictionary:
	var result: Dictionary = super.get_zombie_ecology_debug_0537()
	result["seed_finalized_0537"] = true
	result["seed_0537"] = world_seed
	return result
