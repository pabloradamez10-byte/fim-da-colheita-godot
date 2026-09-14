extends "res://scripts/world/world_runtime_3d_v05405.gd"

const PlayerV0600Script = preload("res://scripts/player/player_3d_v0600.gd")
const SAVE_VERSION_0600 := "0.6.0-alpha"
const SAVE_SCHEMA_0600 := 600
const SAVE_TEMP_PATH_0600 := "user://fim_da_colheita_save.tmp"
const SAVE_BACKUP_PATH_0600 := "user://fim_da_colheita_save.backup.json"

var save_in_progress_0600 := false
var last_save_valid_0600 := false
var save_failures_0600 := 0

func _spawn_player() -> void:
	actors_root = Node3D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	player = PlayerV0600Script.new()
	player.name = "Player"
	player.set("world", self)
	actors_root.add_child(player)
	var state: Dictionary = save_cache.get("player", {}) as Dictionary
	if not state.is_empty() and player.has_method("import_save_state"):
		player.call("import_save_state", state)
	else:
		player.global_position = _farm_to_world(Vector3(0, 0.20, 3.5))
	call_deferred("_recover_player_from_water_0513")

func save_game() -> void:
	if save_in_progress_0600:
		return
	save_in_progress_0600 = true
	super.save_game()
	last_save_valid_0600 = _finalize_save_0600()
	if not last_save_valid_0600:
		save_failures_0600 += 1
		printerr("SAVE 0.6.0: não foi possível finalizar o arquivo com segurança")
	save_in_progress_0600 = false

func _finalize_save_0600() -> bool:
	var source := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if source == null:
		return false
	var parsed: Variant = JSON.parse_string(source.get_as_text())
	if not (parsed is Dictionary):
		return false
	var payload := parsed as Dictionary
	if not payload.has("world") or not payload.has("player"):
		return false
	payload["version"] = SAVE_VERSION_0600
	payload["save_schema"] = SAVE_SCHEMA_0600
	var world_state := payload.get("world", {}) as Dictionary
	world_state["stabilization_0600"] = true
	world_state["save_schema_0600"] = SAVE_SCHEMA_0600
	world_state["protected_save_0600"] = true
	payload["world"] = world_state

	var serialized := JSON.stringify(payload)
	var temp := FileAccess.open(SAVE_TEMP_PATH_0600, FileAccess.WRITE)
	if temp == null:
		return false
	temp.store_string(serialized)
	temp.flush()
	temp.close()

	var verify := FileAccess.open(SAVE_TEMP_PATH_0600, FileAccess.READ)
	if verify == null:
		return false
	var verified: Variant = JSON.parse_string(verify.get_as_text())
	if not (verified is Dictionary):
		return false
	if str((verified as Dictionary).get("version", "")) != SAVE_VERSION_0600:
		return false

	var save_abs := ProjectSettings.globalize_path(SAVE_PATH)
	var temp_abs := ProjectSettings.globalize_path(SAVE_TEMP_PATH_0600)
	var backup_abs := ProjectSettings.globalize_path(SAVE_BACKUP_PATH_0600)
	if FileAccess.file_exists(SAVE_BACKUP_PATH_0600):
		DirAccess.remove_absolute(backup_abs)
	if DirAccess.rename_absolute(save_abs, backup_abs) != OK:
		return false
	if DirAccess.rename_absolute(temp_abs, save_abs) != OK:
		DirAccess.rename_absolute(backup_abs, save_abs)
		return false
	return true

func get_save_stabilization_debug_0600() -> Dictionary:
	var saved_version := ""
	var saved_schema := 0
	var valid_payload := false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file != null:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			var payload := parsed as Dictionary
			saved_version = str(payload.get("version", ""))
			saved_schema = int(payload.get("save_schema", 0))
			valid_payload = payload.has("world") and payload.has("player")
	return {
		"version": SAVE_VERSION_0600,
		"schema": SAVE_SCHEMA_0600,
		"last_save_valid": last_save_valid_0600,
		"save_failures": save_failures_0600,
		"file_exists": FileAccess.file_exists(SAVE_PATH),
		"backup_exists": FileAccess.file_exists(SAVE_BACKUP_PATH_0600),
		"saved_version": saved_version,
		"saved_schema": saved_schema,
		"valid_payload": valid_payload
	}

func get_world_summary() -> Dictionary:
	var result := super.get_world_summary()
	result["stabilization_0600"] = get_save_stabilization_debug_0600()
	return result
