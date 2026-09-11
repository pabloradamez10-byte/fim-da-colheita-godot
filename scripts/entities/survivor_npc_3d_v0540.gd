extends "res://scripts/entities/survivor_npc_3d_v0539.gd"

var decision_action_0540 := "role_patrol"
var decision_score_0540 := 0.0
var decision_reason_0540 := ""
var decision_target_0540 := Vector3.ZERO
var decision_count_0540 := 0
var decision_changed_0540 := 0
var decision_last_cycle_0540 := 0

func configure_survivor_0539(id: String, survivor_name: String, role_id: String, state: Dictionary, world_node: Node) -> void:
	super.configure_survivor_0539(id, survivor_name, role_id, state, world_node)
	decision_action_0540 = str(state.get("decision_action_0540", "role_patrol"))
	decision_score_0540 = float(state.get("decision_score_0540", 0.0))
	decision_reason_0540 = str(state.get("decision_reason_0540", ""))
	decision_target_0540 = _dict_to_vec_0540(state.get("decision_target_0540", {}) as Dictionary)
	decision_count_0540 = int(state.get("decision_count_0540", 0))
	decision_changed_0540 = int(state.get("decision_changed_0540", 0))
	decision_last_cycle_0540 = int(state.get("decision_last_cycle_0540", 0))

func _ready() -> void:
	super._ready()
	add_to_group("decision_actor_0540")

func apply_decision_0540(decision: Dictionary, target: Vector3, cycle_id: int) -> void:
	if dead_0539:
		decision_action_0540 = "dead"
		decision_score_0540 = 1000.0
		decision_reason_0540 = "survivor_dead"
		decision_target_0540 = global_position
		decision_last_cycle_0540 = cycle_id
		return

	var next_action := str(decision.get("action", "role_patrol"))
	if next_action != decision_action_0540:
		decision_changed_0540 += 1
	decision_action_0540 = next_action
	decision_score_0540 = float(decision.get("score", 0.0))
	decision_reason_0540 = str(decision.get("reason", ""))
	decision_target_0540 = target
	decision_count_0540 += 1
	decision_last_cycle_0540 = cycle_id

	if decision_action_0540 == "flee_threat":
		_start_flee_0539(target, "decision:zombie", 4200)
		return

	# Reuse the proven 0.5.39 locomotion. The decision engine owns the destination,
	# while the base character controller still owns collision and actual movement.
	wander_target_0539 = target
	wander_timer_0539 = 5.5
	state_0539 = decision_action_0540

func get_decision_state_0540() -> Dictionary:
	return {
		"action": decision_action_0540,
		"score": decision_score_0540,
		"reason": decision_reason_0540,
		"target": _vec_to_dict_0540(decision_target_0540),
		"count": decision_count_0540,
		"changed": decision_changed_0540,
		"cycle": decision_last_cycle_0540
	}

func export_state_0539() -> Dictionary:
	var result := super.export_state_0539()
	result["decision_action_0540"] = decision_action_0540
	result["decision_score_0540"] = decision_score_0540
	result["decision_reason_0540"] = decision_reason_0540
	result["decision_target_0540"] = _vec_to_dict_0540(decision_target_0540)
	result["decision_count_0540"] = decision_count_0540
	result["decision_changed_0540"] = decision_changed_0540
	result["decision_last_cycle_0540"] = decision_last_cycle_0540
	return result

func get_survivor_debug_0539() -> Dictionary:
	var result := super.get_survivor_debug_0539()
	result["decision_0540"] = get_decision_state_0540()
	return result

func _vec_to_dict_0540(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}

func _dict_to_vec_0540(value: Dictionary) -> Vector3:
	return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.20)), float(value.get("z", 0.0)))
