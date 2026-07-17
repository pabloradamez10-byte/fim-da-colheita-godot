class_name AWEDataLoader
extends RefCounted

const DATA_FILES := {
	"terrain": "res://AWE/terrain_types.json",
	"biomes": "res://AWE/biomes.json",
	"objects": "res://AWE/objects.json",
	"rules": "res://AWE/Rules/world_rules.json"
}

static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("AWE: arquivo não encontrado: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("AWE: não foi possível abrir: %s" % path)
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("AWE: JSON inválido ou raiz não é objeto: %s" % path)
		return {}

	return parsed as Dictionary

static func load_core_data() -> Dictionary:
	var result := {}
	for key in DATA_FILES:
		result[key] = load_json(DATA_FILES[key])
	return result
