class_name SaveSystem
extends RefCounted

const SAVE_PATH := "user://fim_da_colheita_alpha_0_3.save.json"
const SAVE_VERSION := "0.3.0"

static func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SAVE: não foi possível abrir o save.")
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SAVE: conteúdo inválido; iniciando um mundo novo.")
		return {}

	return parsed as Dictionary

static func save_game(world: Node, player: Node) -> bool:
	var payload := {
		"version": SAVE_VERSION,
		"saved_at_unix": Time.get_unix_time_from_system(),
		"world": {},
		"player": {}
	}

	if world != null and world.has_method("export_save_state"):
		payload["world"] = world.call("export_save_state")
	if player != null and player.has_method("export_save_state"):
		payload["player"] = player.call("export_save_state")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SAVE: não foi possível gravar o save.")
		return false

	file.store_string(JSON.stringify(payload))
	return true
