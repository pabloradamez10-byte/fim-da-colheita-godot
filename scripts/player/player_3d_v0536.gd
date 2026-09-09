extends "res://scripts/player/player_3d_v0535.gd"

func award_skill_xp_0535(skill_id: String, amount: int, reason: String = "") -> bool:
	var awarded := super.award_skill_xp_0535(skill_id, amount, reason)
	if not awarded or reason == "mission_reward":
		return awarded
	var event_id := _mission_event_from_progression_0536(skill_id, reason)
	if event_id != "" and world != null and world.has_method("report_mission_event_0536"):
		world.call("report_mission_event_0536", event_id, 1, reason, self)
	return awarded

func _mission_event_from_progression_0536(skill_id: String, reason: String) -> String:
	match skill_id:
		"combat":
			if reason == "hit":
				return "combat_hit"
		"farming":
			if reason == "harvest":
				return "harvest"
		"medicine":
			if reason in ["bandage", "antiseptic"]:
				return "medicine_use"
		"mechanics":
			if reason == "repair_vehicle":
				return "vehicle_repair"
		"scavenging":
			if reason.begins_with("loot_poi_"):
				return "poi_loot"
		_:
			pass
	return ""

func get_mission_bridge_debug_0536() -> Dictionary:
	return {
		"world_bridge": world != null and world.has_method("report_mission_event_0536"),
		"combat_event": _mission_event_from_progression_0536("combat", "hit"),
		"harvest_event": _mission_event_from_progression_0536("farming", "harvest"),
		"medicine_event": _mission_event_from_progression_0536("medicine", "bandage"),
		"repair_event": _mission_event_from_progression_0536("mechanics", "repair_vehicle"),
		"poi_event": _mission_event_from_progression_0536("scavenging", "loot_poi_market")
	}
