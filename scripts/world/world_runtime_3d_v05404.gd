extends "res://scripts/world/world_runtime_3d_v05403.gd"

const SAVE_VERSION_05404 := "0.5.40.4-alpha"

var feedback_events_05404 := 0
var last_feedback_05404 := ""

func emit_feedback_05404(kind: String, text: String = "", strength: float = 1.0) -> void:
	feedback_events_05404 += 1
	last_feedback_05404 = kind
	var audio_nodes := get_tree().get_nodes_in_group("audio_feedback_05404")
	if not audio_nodes.is_empty() and audio_nodes[0].has_method("play_cue_05404"):
		audio_nodes[0].call("play_cue_05404", kind, strength)
	var ui_nodes := get_tree().get_nodes_in_group("feedback_ui_05404")
	if not ui_nodes.is_empty() and ui_nodes[0].has_method("pulse_05404"):
		ui_nodes[0].call("pulse_05404", kind, text, strength)

func try_interact_near(pos: Vector3, target_player: Node) -> bool:
	var success := super.try_interact_near(pos, target_player)
	if success:
		emit_feedback_05404("action", "AÇÃO CONCLUÍDA", 0.92)
	else:
		emit_feedback_05404("denied", "NADA PARA INTERAGIR", 0.65)
	return success

func butcher_animal_0538(animal_id: String, target_player: Node = null) -> bool:
	var success := super.butcher_animal_0538(animal_id, target_player)
	if success:
		emit_feedback_05404("pickup", "RECURSOS DE CAÇA", 1.0)
	return success

func emit_noise_0519(pos: Vector3, radius: float, kind: String, source: Node = null) -> void:
	super.emit_noise_0519(pos, radius, kind, source)
	if source == player:
		var normalized := kind.to_lower()
		if "shot" in normalized or "gun" in normalized or "pistol" in normalized or "rifle" in normalized or "shotgun" in normalized:
			emit_feedback_05404("attack", "", 1.18)

func emit_alert_feedback_05404(text: String = "PERIGO") -> void:
	emit_feedback_05404("alert", text, 1.15)

func save_game() -> void:
	super.save_game()
	var read_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	if not (parsed is Dictionary):
		return
	var payload := parsed as Dictionary
	payload["version"] = SAVE_VERSION_05404
	var world_state := payload.get("world", {}) as Dictionary
	world_state["feedback_audio_05404"] = true
	world_state["feedback_events_05404"] = feedback_events_05404
	world_state["last_feedback_05404"] = last_feedback_05404
	world_state["audio_mode_05404"] = "procedural-local-offline"
	payload["world"] = world_state
	var write_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if write_file != null:
		write_file.store_string(JSON.stringify(payload))

func get_feedback_audio_debug_05404() -> Dictionary:
	var audio_debug: Dictionary = {}
	var ui_debug: Dictionary = {}
	var mobile_debug: Dictionary = {}
	var audio_nodes := get_tree().get_nodes_in_group("audio_feedback_05404")
	if not audio_nodes.is_empty() and audio_nodes[0].has_method("get_audio_feedback_debug_05404"):
		audio_debug = audio_nodes[0].call("get_audio_feedback_debug_05404") as Dictionary
	var ui_nodes := get_tree().get_nodes_in_group("feedback_ui_05404")
	if not ui_nodes.is_empty() and ui_nodes[0].has_method("get_feedback_ui_debug_05404"):
		ui_debug = ui_nodes[0].call("get_feedback_ui_debug_05404") as Dictionary
	var mobile_nodes := get_tree().get_nodes_in_group("mobile_feedback_05404")
	if not mobile_nodes.is_empty() and mobile_nodes[0].has_method("get_mobile_feedback_debug_05404"):
		mobile_debug = mobile_nodes[0].call("get_mobile_feedback_debug_05404") as Dictionary
	var previous := get_world_rework_debug_05403()
	return {
		"version": SAVE_VERSION_05404,
		"events": feedback_events_05404,
		"last_feedback": last_feedback_05404,
		"audio": audio_debug,
		"ui": ui_debug,
		"mobile": mobile_debug,
		"world_rework_05403": str(previous.get("version", "")) == "0.5.40.3-alpha",
		"player_high_detail": bool(previous.get("player_high_detail", false)),
		"zombie_profiles": int(previous.get("zombie_profiles", 0)),
		"zombie_frames": int(previous.get("zombie_frames", 0)),
		"items": int(previous.get("items", 0)),
		"vehicle_variants": int(previous.get("vehicle_variants", 0)),
		"vehicle_directions": int(previous.get("vehicle_directions", 0)),
		"animal_species": int(previous.get("animal_species", 0)),
		"animal_directions": int(previous.get("animal_directions", 0)),
		"decision_engine_0540": bool(previous.get("decision_engine_0540", false))
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["feedback_audio_05404"] = get_feedback_audio_debug_05404()
	return result
