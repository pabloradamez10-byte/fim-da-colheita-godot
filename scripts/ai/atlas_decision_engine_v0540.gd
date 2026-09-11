extends RefCounted

const ENGINE_VERSION_0540 := "0.5.40-alpha"
const ACTION_ORDER_0540 := [
	"flee_threat",
	"seek_water",
	"seek_medical",
	"seek_food",
	"return_home",
	"regroup_player",
	"role_patrol"
]

func evaluate_0540(context: Dictionary) -> Dictionary:
	if bool(context.get("dead", false)):
		return _result_0540("dead", 1000.0, "survivor_dead", {}, context)

	var scores: Dictionary = {}
	var reasons: Dictionary = {}
	var health := clampf(float(context.get("health", 100.0)), 0.0, 100.0)
	var hunger := clampf(float(context.get("hunger", 100.0)), 0.0, 100.0)
	var thirst := clampf(float(context.get("thirst", 100.0)), 0.0, 100.0)
	var trust := clampi(int(context.get("trust", 0)), 0, 100)
	var zombie_distance := float(context.get("zombie_distance", 9999.0))
	var player_distance := float(context.get("player_distance", 9999.0))
	var met_player := bool(context.get("met_player", false))
	var night := bool(context.get("night", false))
	var role := str(context.get("role", "scavenger"))

	# Threat always has first right of refusal. The score rises sharply inside 10 m.
	var flee_score := 0.0
	if zombie_distance < 14.0:
		flee_score = 76.0 + maxf(0.0, 14.0 - zombie_distance) * 3.8
	if zombie_distance < 4.0:
		flee_score += 30.0
	scores["flee_threat"] = flee_score
	reasons["flee_threat"] = "zombie_%.1fm" % zombie_distance

	# Physiological needs create goals instead of directly granting resources.
	var water_score := maxf(0.0, 68.0 - thirst) * 1.75
	if thirst < 32.0:
		water_score += 32.0
	if met_player and player_distance < 34.0:
		water_score += 8.0
	scores["seek_water"] = water_score
	reasons["seek_water"] = "thirst_%.0f" % thirst

	var medical_score := maxf(0.0, 72.0 - health) * 1.45
	if health < 38.0:
		medical_score += 28.0
	if role == "medic":
		medical_score *= 0.88
	scores["seek_medical"] = medical_score
	reasons["seek_medical"] = "health_%.0f" % health

	var food_score := maxf(0.0, 66.0 - hunger) * 1.55
	if hunger < 30.0:
		food_score += 28.0
	if met_player and player_distance < 34.0:
		food_score += 6.0
	scores["seek_food"] = food_score
	reasons["seek_food"] = "hunger_%.0f" % hunger

	var home_score := 8.0
	if night:
		home_score = 56.0
		if health < 75.0:
			home_score += 10.0
	scores["return_home"] = home_score
	reasons["return_home"] = "night" if night else "day"

	var regroup_score := 0.0
	if met_player and trust >= 35 and player_distance < 26.0:
		regroup_score = 32.0 + minf(18.0, float(trust - 35) * 0.35)
	scores["regroup_player"] = regroup_score
	reasons["regroup_player"] = "trust_%d_player_%.1fm" % [trust, player_distance]

	var patrol_score := 26.0
	match role:
		"medic": patrol_score += 3.0
		"mechanic": patrol_score += 4.0
		"scavenger": patrol_score += 6.0
	scores["role_patrol"] = patrol_score
	reasons["role_patrol"] = "role_%s" % role

	var best_action := "role_patrol"
	var best_score := -INF
	for action in ACTION_ORDER_0540:
		var score := float(scores.get(action, 0.0))
		if score > best_score:
			best_score = score
			best_action = action

	return _result_0540(best_action, best_score, str(reasons.get(best_action, "")), scores, context)

func _result_0540(action: String, score: float, reason: String, scores: Dictionary, context: Dictionary) -> Dictionary:
	return {
		"engine_version": ENGINE_VERSION_0540,
		"action": action,
		"score": score,
		"reason": reason,
		"scores": scores.duplicate(true),
		"role": str(context.get("role", "scavenger")),
		"survivor_id": str(context.get("survivor_id", ""))
	}

func get_engine_debug_0540() -> Dictionary:
	return {
		"version": ENGINE_VERSION_0540,
		"actions": ACTION_ORDER_0540.duplicate(),
		"action_count": ACTION_ORDER_0540.size(),
		"offline": true,
		"deterministic_scores": true
	}
