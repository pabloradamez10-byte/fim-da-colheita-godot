extends "res://scripts/world/city_chunk_streamer_3d_v0601.gd"

const NATURE_VERSION_062 := "0.6.2-alpha"
const NatureVisual := preload("res://scripts/visual/nature_visual_062.gd")

func _create_tree(parent: Node3D, pos: Vector3, scale_value: float, pinus: bool) -> void:
	var child_index := parent.get_child_count()
	super._create_tree(parent, pos, scale_value, pinus)
	_decorate_new_nature_root(parent, child_index, "tree")

func _create_bush(parent: Node3D, pos: Vector3, scale_value: float) -> void:
	var child_index := parent.get_child_count()
	super._create_bush(parent, pos, scale_value)
	_decorate_new_nature_root(parent, child_index, "bush")

func _create_rock(parent: Node3D, pos: Vector3, scale_value: float) -> void:
	var child_index := parent.get_child_count()
	super._create_rock(parent, pos, scale_value)
	_decorate_new_nature_root(parent, child_index, "rock")

func _decorate_new_nature_root(parent: Node3D, child_index: int, kind: String) -> void:
	if child_index >= parent.get_child_count():
		push_warning("Nature 0.6.2: raiz ausente para %s" % kind)
		return
	var root := parent.get_child(child_index) as Node3D
	NatureVisual.apply(root, kind)

func get_nature_streaming_debug_062() -> Dictionary:
	return {
		"version": NATURE_VERSION_062,
		"visuals": get_tree().get_nodes_in_group("nature_visual_062").size(),
		"collisions_preserved": true,
		"fluidity_version": FLUIDITY_VERSION_0601
	}
